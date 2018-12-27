%% 20180318 SinalPositionMatrixGenerator by MSBak
% CNMF_E ����, �ʿ��� data�� matrix ���·� ������

% msSignal : (neuron #, frame) = siganl raw value�� ��ϵ�
% msSignal_cut : ���� df�� 0���� ���� �ٲ� (����)
% ���� df�� ���� : 105% ����
% msPeak_signal : Ư�������� �����ϸ� signal peak���� 1�� ǥ����
% Ư������ : ���� df ������ �Ѿ�� 30frame �̻� ���ӵǴ� ����
% msPeak_num �� detection�� neuron ���� �� neuron�� 'Ư������'�� �� ȸ �Ѿ�����, �� signal�� ��� �پ����� �����.

%% path ���� �Է�
ForCheck = input('�����Ϸ��� �ƹ� ���ڸ� �Է��ϼ��� '); % �����߿� �Ǽ��� �����Ͽ� ������ ���ư��°��� �����ϱ� ���� üũ ����
clear; clc;

file_nm = []; dir_nm = [];
[file_nm, dir_nm] = uigetfile(fullfile(dir_nm, '*.tif;*.mat;*.h5;*.avi'));
filepath = [dir_nm, file_nm];

CNMF_List =  msCamVideoFileDetection(dir_nm  , '_excluded', '.mat'); % 20181126 ����

%% mat file load
% load([dir_nm '\exclude_info.mat']) % 20181126 ����
figure_cnt = 0;
for CNMF_Num = 1:size(CNMF_List,2)
    clearvars -except dir_nm file_nm filepath CNMF_List CNMF_Num exclude_info figure_cnt
    load(cell2mat(CNMF_List(1,CNMF_Num)));
    
%% msSignal ������ signal�� ������.
clear msSignal

A = full(neuron.A);
C = neuron.C_raw; % neuron.C���� neuron.C_raw�� ���� 20181025 by MSBak
cnt = 0;
for neuronNum = 1:size(C, 1)
%      try
%         if isempty(find(exclude_info(CNMF_Num,:)==neuronNum))
            cnt = cnt + 1;
            msSignal(cnt, :) = double(C(neuronNum,:) * max(A(:,neuronNum)));
%         end

%      catch; end
end

% exclution�� �ܺο��� �����ϴ� ������ �����ϸ鼭 �� �ڵ嵵 �����. 20181126 MSBak

%% df/f 105% and Z-score�� ��ȯ sd 1 �̻��̸� signal�� ���

for ix = 1:size(msSignal,1)
    std1 = std(msSignal(ix,:));
    msSignal_z(ix,:) = msSignal(ix,:)/std1;
end




%% �������Ͽ� ��ȭ�� ���, frame�� 0.2�̻� �����ϸ� spike�� ����

sigNum = 4;
smooth_paramether = 20;

for sigNum = 1:size(msSignal_z, 1)
    clear msSignal_smooth
    msSignal_smooth(sigNum,:) = reshape(smooth(msSignal_z(sigNum,:),smooth_paramether),1,size(msSignal_z, 2));

    for frame = 1:size(msSignal_smooth,2)-1
        msSignal_diff(sigNum,frame) = msSignal_smooth(sigNum, frame+1) - msSignal_smooth(sigNum, frame);
    end

%     plot(msSignal_diff)
end

%%

start_sw = 0;
skip_sw = 0;
skip_cnt = 0;
accelerate_sw = 0; accelerate_cnt = 0;

gap_time = 20;
thr = 1; % sd
accelerate_thr = 0.05;

signal_matrix_save = zeros(size(msSignal_z, 1),size(msSignal_z, 2));

for sigNum = 1:size(msSignal_z, 1)
    for frame = 1:size(msSignal_z, 2)-1
        if skip_cnt > gap_time; skip_sw = 0; skip_cnt = 0; end % thr (5)�� ���� �������� ����, gap_time frame�� ������ skip_sw�� off

        if skip_sw; skip_cnt = skip_cnt + 1; continue; end % skip_sw�� on�̸�, continue�� �Ʒ� code�� skip��.
        
        if msSignal_diff(sigNum,frame) < - 0.04 || msSignal_z(sigNum, frame) < 0.5; start_sw = 1; end % reset parameter��. ������ �����̸� reset 
        
        if msSignal_diff(sigNum,frame) > accelerate_thr; accelerate_sw = 1; accelerate_cnt = 0; end
        if accelerate_sw; accelerate_cnt = accelerate_cnt + 1; end
        if accelerate_cnt > 5; accelerate_cnt = 0; accelerate_sw = 0; end
        
        
        if msSignal_diff(sigNum,frame) < accelerate_thr && accelerate_cnt == 0; accelerate_sw = 0; end
        
        if start_sw && msSignal_z(sigNum, frame) >= thr && accelerate_sw && msSignal(sigNum, frame) >= 5 && msSignal_diff(sigNum,frame) > 0 % 5 for df/f
            skip_sw = 1; start_sw = 0;
            [M, I] = max(msSignal_z(sigNum, frame:min(frame+10,size(msSignal_z, 2))));
            peak_idx = frame-1+I;
            if M < thr; disp("peak���� 5����?"); end
            
            signal_matrix_save(sigNum,peak_idx) = 1;
            accelerate_sw = 0; accelerate_cnt = 0;
            
        end
    end
end

%% msPeak_num �� detection�� neuron ���� �� neuron�� 'Ư������'�� �� ȸ �Ѿ�����, �� signal�� ��� �پ����� �����.
clear msPeak_signal
msPeak_signal = signal_matrix_save;
clear msPeak_num
for sigNum = 1:size(msPeak_signal, 1)
    msPeak_num(sigNum, :) = sum(msPeak_signal(sigNum,:) == 1);
end

%% Noise �˻�
noise_sw = 0;
noise_sw2 = 0;

for ix = 1:size(msPeak_num,1)
    if msPeak_num(ix,1) > 15
        disp ([num2str(ix) ' neuron�� signal�� 15�� �̻��Դϴ�. noise�� �ǽɵ˴ϴ�.'])
        noise_sw = 1; noise_sw2 = 1;
    end
    
    if max(msSignal_z(ix,:),[],2) > 20
        disp ([num2str(ix) ' neuron�� z-score�� 20 �̻��Դϴ�. noise�� �ǽɵ˴ϴ�.'])
        noise_sw = 1; noise_sw2 = 1;
    end
    
    if max(msSignal(ix,:),[],2) > 30
        disp ([num2str(ix) ' neuron�� df/f value�� 30 �̻��Դϴ�. noise�� �ǽɵ˴ϴ�.'])
        noise_sw = 1; noise_sw2 = 1;
    end
    %%
    if noise_sw2 
        noise_sw2 = 0;
        figure_cnt = figure_cnt+1;
        figure(figure_cnt)
        suptitle([num2str(CNMF_Num) ' session #' num2str(ix) ' neuron' ' (' num2str(msPeak_num(ix,1)) ')'])
        
        num = ix;

        subplot(5,1,1)
        plot(msSignal(num,:))
        subplot(5,1,2)
        plot(msSignal_z(num,:))
        subplot(5,1,3)
        plot(msSignal_diff(num,:))
        subplot(5,1,4)
        plot(signal_matrix_save(num,:))
      %%
        rowsize = 200;
        colsize = 200;

        clear CenterPositionIndex
        CenterPositionIndex = cell2mat(Coor(ix,1)); % (1,) - col, (2,) - row
        CenterPosition = round(mean(CenterPositionIndex,2));


        signal = neuron.A(:,neuronNum);
        signal_full = full(signal);
        signal_reshape = reshape(signal_full, size(neuron.Cn,1), size(neuron.Cn,2));
        
        subplot(5,1,5)
        imagesc(signal_reshape)
    end
end
        
if ~noise_sw; disp('Noise�� �ǽɵǴ� signal�� �����ϴ�.'); end
%%
[project, miceID, day, start_idx] = msbak_project_miceID_extract_from_filepath(cell2mat(CNMF_List(1,CNMF_Num)));

savename = [dir_nm project '_' day '_SignalMatrix.mat'];
save(savename, 'msPeak_signal', 'msPeak_num', 'Coor', 'sizefix_info', 'savename', '-v7.3');


end



























