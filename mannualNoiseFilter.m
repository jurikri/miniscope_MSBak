a = input('input any number for start this code')
close all; clc; clear;

%%
disp('select a CNMF_E mat file')
file_nm = []; path = []; [file_nm, path] = uigetfile(fullfile(path, '*.mat')); filepath = [path, file_nm];

%%
disp('select a Excel file')
file_nm = []; path = []; [file_nm, path] = uigetfile(fullfile(path, '*.xlsx')); filepath2 = [path, file_nm];

%%
excel = xlsread(filepath2);
load(filepath);

Coor_tmp = Coor;
A = neuron.A;
C = neuron.C_raw;
Cn = neuron.Cn;
clearvars('neuron', 'Coor')

neuron.Cn = Cn
cnt = 0;
for ix = 1:size(excel,1)
    selection = excel(ix,1);
    if selection
        cnt = cnt + 1;
        neuron.A(:,cnt) = A(:,ix);
        neuron.C_raw(cnt, :) = C(ix, :);
        Coor(cnt, 1) = Coor_tmp(ix, 1);
    end
end



save([path file_nm '_excluded.mat'], 'neuron', 'Coor', 'sizefix_info', 'savename', '-v7.3');

disp('done')