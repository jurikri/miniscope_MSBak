m%% 20180318 SinalPositionMatrixGenerator by MSBak
% CNMF_E 이후, 필요한 data를 matrix 형태로 가공함

% msSignal : (neuron #, frame) = siganl raw value가 기록됨
% msSignal_cut : 낮은 df는 0으로 값을 바꿈 (계산용)
% 낮은 df의 기준 : 105% 이하
% msPeak_signal : 특정기준을 만족하면 signal peak에서 1로 표기함
% 특정기준 : 낮은 df 기준을 넘어서서 30frame 이상 지속되는 상태
% msPeak_num 은 detection된 neuron 별로 그 neuron이 '특정기준'을 몇 회 넘었는지, 즉 signal이 몇번 뛰었는지 기록함.

%% path 수동 입력
ForCheck = input('시작하려면 아무 숫자를 입력하세요 '); % 개발중에 실수로 시작하여 변수가 날아가는것을 방지하기 위한 체크 구문
clear; clc;

file_nm = []; dir_nm = [];
[file_nm, dir_nm] = uigetfile(fullfile(dir_nm, '*.tif;*.mat;*.h5;*.avi'));
filepath = [dir_nm, file_nm];

CNMF_List =  msCamVideoFileDetection(dir_nm  , '_excluded', '.mat'); % 20181126 수정

%% mat file load
% load([dir_nm '\exclude_info.mat']) % 20181126 수정
for CNMF_Num = 1:size(CNMF_List,2)
    clearvars -except dir_nm file_nm filepath CNMF_List CNMF_Num exclude_info
    load(cell2mat(CNMF_List(1,CNMF_Num)));
    
%% msSignal 변수에 signal을 저장함.
clear msSignal

A = full(neuron.A);
C = neuron.C_raw; % neuron.C에서 neuron.C_raw로 수정 20181025 by MSBak
cnt = 0;
for neuronNum = 1:size(C, 1)
%      try
%         if isempty(find(exclude_info(CNMF_Num,:)==neuronNum))
            cnt = cnt + 1;
            msSignal(cnt, :) = double(C(neuronNum,:) * max(A(:,neuronNum)));
%         end

%      catch; end
end

% exclution을 외부에서 실행하는 것으로 변경하면서 이 코드도 변경됨. 20181126 MSBak


%% 스무딩하여 변화율 계산, frame당 0.2이상 증가하면 spike로 간주

sigNum = 4;
smooth_paramether = 10;

for sigNum = 1:size(msSignal, 1)
    clear msSignal_smooth
    msSignal_smooth(sigNum,:) = reshape(smooth(msSignal(sigNum,:),smooth_paramether),1,size(msSignal, 2));

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

gap_time = 5;
thr = 5;

signal_matrix_save = zeros(size(msSignal, 1),size(msSignal, 2));

for sigNum = 1:size(msSignal, 1)
    for frame = 1:size(msSignal, 2)-1
        if skip_cnt > gap_time; skip_sw = 0; skip_cnt = 0; end % thr (5)를 넘은 시점으로 부터, gap_time frame이 지나면 skip_sw를 off

        if skip_sw; skip_cnt = skip_cnt + 1; continue; end % skip_sw가 on이면, continue로 아래 code를 skip함.
        
        if msSignal(sigNum, frame) < thr; start_sw = 1; end
        
        if msSignal_diff(sigNum,frame) > 0.2; accelerate_sw = 1; accelerate_cnt = 0; end
        if accelerate_sw; accelerate_cnt = accelerate_cnt + 1; end
        if accelerate_cnt > 30; accelerate_cnt = 0; accelerate_sw = 0; end
        
        
        if msSignal_diff(sigNum,frame) < 0.2 && accelerate_cnt == 0; accelerate_sw = 0; end
        
        if start_sw && msSignal(sigNum, frame) >= thr && accelerate_sw
            skip_sw = 1; start_sw = 0;
            [M, I] = max(msSignal(sigNum, frame:min(frame+10,size(msSignal, 2))));
            peak_idx = frame-1+I;
            if M < thr; disp("peak값이 5이하?"); end
            
            signal_matrix_save(sigNum,peak_idx) = 1;
            accelerate_sw = 0; accelerate_cnt = 0;
            
        end
    end
end
 %% visualization     
num = 147

figure(1)
subplot(3,1,1)
plot(msSignal(num,:))
subplot(3,1,2)
plot(msSignal_diff(num,:))
subplot(3,1,3)
plot(signal_matrix_save(num,:))

%% msPeak_num 은 detection된 neuron 별로 그 neuron이 '특정기준'을 몇 회 넘었는지, 즉 signal이 몇번 뛰었는지 기록함.
clear msPeak_signal
msPeak_signal = signal_matrix_save;
clear msPeak_num
for sigNum = 1:size(msPeak_signal, 1)
    msPeak_num(sigNum, :) = sum(msPeak_signal(sigNum,:) == 1);
end

%% Noise 검사
for ix = 1:size(msPeak_num,1)
    if msPeak_num(ix,1) > 15
        disp ([num2str(ix) ' neuron은 signal이 15개 이상입니다. noise로 의심됩니다.'])
    end
    
    if max(msSignal(ix,:),[],2) > 30
        disp ([num2str(ix) ' neuron은 df/f value가 30 이상입니다. noise로 의심됩니다.'])
    end
end


%%
[project, miceID, day, start_idx] = msbak_project_miceID_extract_from_filepath(cell2mat(CNMF_List(1,CNMF_Num)));

savename = [dir_nm project '_' day '_SignalMatrix.mat'];
save(savename, 'msPeak_signal', 'msPeak_num', 'Coor', 'sizefix_info', 'savename', '-v7.3');


end



























