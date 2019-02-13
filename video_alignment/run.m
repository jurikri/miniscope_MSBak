%% select a videofile (*.avi, *.tif, *.lsm)
a = input('input any number for start this code')
close all; clc; clear;

file_nm = []; path = []; [file_nm, path] = uigetfile(fullfile(path, '*.*')); fileName = [path, file_nm];

for i = size(file_nm,2):-1:1
    if file_nm(i) == '.'
        extenstion_nm = file_nm(1,i:size(file_nm,2));
        break
    end
end

if strcmp(extenstion_nm, '.lsm')
    [Data, varargout] = lsmread(fileName);
    height = size(Data,4);
    width = size(Data,5);
    for frame = 1:size(Data,1)
        msFrame(:,:,frame) = reshape(Data(frame,1,1,:,:),height,width);
    end

elseif strcmp(extenstion_nm, '.tif')
    tiff_info = imfinfo(fileName);
    for frame = 1:size(tiff_info,1)
        msFrame(:,:,frame) = imread(fileName,frame);
    end
       
elseif strcmp(extenstion_nm, '.avi')
    v = VideoReader(fileName);
    for frame = 1: v.NumberOfFrames
        tmpFrame = double(v.read(frame));
        msFrame(:,:,frame) = tmpFrame(:,:,1);
    end
else
    disp('This extenstion type is not supported')
end

%% 전역변수 설정

rs = size(msFrame,1); %% row, height size
cs = size(msFrame,2); %% col, width size
cm = pre_linear_model(rs, cs); %% frame shift 할 linear model을 사전에 만들어서 cm construct 변수에 저장함. 

%% 최적 보정 값 찾기
ref = mean(double(msFrame),3); % ref는 total mean을 설정하였음.
for frame = 1:size(msFrame,3)
    img = double(msFrame(:,:,frame));

    ms = msali16(img, ref, cm);

    fix_info_row(:,:,frame) = cm.cmrowa(:,:,ms.Aixo)+cm.cmrowb(:,:,ms.Bixo);
    fix_info_col(:,:,frame) = cm.cmcola(:,:,ms.Cixo)+cm.cmcolb(:,:,ms.Dixo);
end

%% 보정값을 이용하여 frame 보정하기
for frame = 1:size(msFrame,3)
    fix1 = correction_fill_secondstep(msFrame(:,:,frame), fix_info_row(:,:,frame), fix_info_col(:,:,frame));
    fixFrame(:,:,frame) = fix1;
end

implay(uint8(fixFrame)) % 보정된 frame을 matlab 내에서 재생

%% 기존 평면보정 code 추가 적용 
matrix1 = fixFrame;
rotate_index = rotate_index_Generator(20); 

meanframe = mean(double(matrix1),3);

figure(1)
imshow(uint8(meanframe))
roi = getrect(); roi = ceil(roi);
xmin = roi(1); ymin = roi(2); xmax = roi(3) + roi(1); ymax = roi(4) + roi(2);
%%
for frame = 1:size(matrix1,3)
    for rix = 1:size(rotate_index,1)
        drow = rotate_index(rix,1);
        dcol = rotate_index(rix,2);

        try
            C_match = abs(meanframe(ymin:ymax, xmin:xmax) - double(matrix1(ymin+drow:ymax+drow, xmin+dcol:xmax+dcol,frame)));
%             imshow(C_match,[])
            indicator(frame,rix) = sum(sum(C_match,1),2);

        catch
            indicator(frame,rix) = -inf;
            disp('out of boundary')
        end
    end
    [vx, ix] = min(indicator(frame,:));
    fix_info(frame, :) = rotate_index(ix, :);
    ali_frame(:,:,frame) = circshift(circshift(matrix1(:,:,frame),-fix_info(frame,1),1),-fix_info(frame,2),2);
end

implay(uint8(ali_frame))

%% 아래부터는 저장장치로 출력에 관한 code

timeName = datetimeGeneretor();

before_day_address = [pwd '\ouput'];
if (exist(before_day_address, 'dir') == 0)
    disp(['Made a result directory at :', newline, char(9), before_day_address]);
    mkdir(before_day_address);
end

data = uint16(ali_frame);
filepath = [before_day_address '\' file_nm '_' timeName '_fix.tif'];
for frame = 1:size(data ,3)
    imwrite(data(:,:,frame), filepath, 'WriteMode', 'append', 'Compression', 'none')
end
%%
msCam_savePath = [before_day_address '\' file_nm '_' timeName  '_fix.avi'];
msCam_save = VideoWriter(msCam_savePath);
open(msCam_save)
for frame = 1:size(msFrame,3)
    writeVideo(msCam_save, uint8(data(:,:,frame)));
end
close(msCam_save)

%%
savename = [before_day_address '\' file_nm  '_' timeName  '_fix.mat'];
save(savename,'-v7.3');






