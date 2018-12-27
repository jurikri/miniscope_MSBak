# -*- coding: utf-8 -*-
"""
Created on Sun Dec 23 12:37:45 2018

@author: msbak
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats.stats import pearsonr
import hdf5storage

def zeromean(array):
    sum1 = 0
    cnt = 0
    for value1 in array:
        if not (value1==0):
            sum1 += value1
            cnt += 1
            
    zeromean = sum1/cnt
    return zeromean

# In[] msPeak_signal load
    
# itgidx
filepath1 = 'itgidx.xlsx'
itgidx = np.array(pd.read_excel(filepath1, header=None))

# signal
loadlist = list(['F:\\Miniscope imaging data\\Analysis\\201808\\GPF201808_#1.4_CtxA\\GPF201808_#1.4_CtxA_day1_SignalMatrix.mat', \
                'F:\\Miniscope imaging data\\Analysis\\201808\\GPF201808_#1.4_CtxA\\GPF201808_#1.4_CtxA_day2_SignalMatrix.mat', \
                'F:\\Miniscope imaging data\\Analysis\\201808\\GPF201808_#1.4_CtxA\\GPF201808_#1.4_CtxA_day3_SignalMatrix.mat', \
                'F:\\Miniscope imaging data\\Analysis\\201808\\GPF201808_#1.4_CtxA\\GPF201808_#1.4_CtxA_day4_SignalMatrix.mat'])
                # 추후 수정요망 
                
msPeak_signal = np.zeros((len(loadlist),185,8330)) # 추후 수정요망 
signal_matrix = np.zeros((itgidx.shape[0],itgidx.shape[1],8330))

for filename in np.arange(len(loadlist)):
    mat_tmp = hdf5storage.loadmat(loadlist[filename])
    mat_signal_tmp = mat_tmp['msPeak_signal']

    for neuron in np.arange(mat_signal_tmp.shape[0]): 
        itg_index = list(itgidx[:,filename]).index(neuron+1) # matlab to python
        signal_matrix[itg_index,filename,0:mat_signal_tmp.shape[1]] = mat_signal_tmp[neuron,:]
        if not(filename==0) and itg_index == 0:
            print(filename, neuron, itg_index )
            

ans = np.sum(signal_matrix, axis = 2)


    
# In[] freezing index load for day3
syn = 14 # notebook 1 frame 때, miniscope frame
tr = 1.3 # time range
filepath = 'F:\\Miniscope imaging data\\Analysis\\201808\\GPF201808_#1.4_CtxA\\GPF201808_#1.4_CtxA_day3_freezing.xlsx'
df1 = pd.read_excel(filepath, header=None)

freeizng_index = np.array(df1.iloc[2:,0:2])
freezing_start = list(freeizng_index[:,0])

#    plot_ms = np.zeros(30*tr*2)
signal_sum = np.zeros(signal_matrix.shape[0])

signal_freezing_by = list()
signal_freezing_by_overlap_filter = list()
freeizng_freeizng_by = list()

training = np.sum(signal_matrix[:,1,600:7860],axis=1) # training sesion matrix
test1 = np.sum(signal_matrix[:,2,740:4752],axis=1) # training sesion matrix

overlap_mask = (test1 * training > 0)

for ix in np.arange(len(freezing_start)):
    msCamix = int(freezing_start[ix]/40*30 + syn) # miniscope, notebokk 간의 syn 조정
    tmp_matrix = np.sum(signal_matrix[:,2,int(msCamix-30*tr):int(msCamix+30*tr)], axis = 1)
    signal_sum += tmp_matrix # signal total matrix 생성
    
    signal_freezing_by.append(np.sum(tmp_matrix))
    
    tmp3 = np.sum(tmp_matrix * overlap_mask)
    signal_freezing_by_overlap_filter.append(tmp3)
    freeizng_freeizng_by.append((freeizng_index[ix,1]-freeizng_index[ix,0])/40)


# training session siganl을 training에 저장하고, signal_sum(freezing 시작 부위 signal)과 overlap
    

overlap = np.sum(signal_sum * training > 0)/np.sum(signal_sum > 0)
print(overlap)

# In[] freezing index load for day3
syn = 122 # notebook 1 frame 때, miniscope frame
#tr = 1 # time range
filepath = 'F:\\Miniscope imaging data\\Analysis\\201808\\GPF201808_#1.4_CtxA\\GPF201808_#1.4_CtxA_day4_freezing.xlsx'
df1 = pd.read_excel(filepath, header=None)

freeizng_index2 = np.array(df1.iloc[2:,0:2])
freezing_start2 = list(freeizng_index2[:,0])

#plot_ms = np.zeros(30*tr*2)
signal_sum2 = np.zeros(signal_matrix.shape[0])

signal_freezing_by2 = list()
signal_freezing_by_overlap_filter2 = list()
freeizng_freeizng_by2 = list()

training = np.sum(signal_matrix[:,1,600:7860],axis=1) # training sesion matrix 

for ix in np.arange(len(freezing_start2)):
    msCamix = int(freezing_start2[ix]/40*30 + syn) # miniscope, notebokk 간의 syn 조정
    tmp_matrix = np.sum(signal_matrix[:,3,int(msCamix-30*tr):int(msCamix+30*tr)], axis = 1)
    signal_sum2 += tmp_matrix # signal total matrix 생성
    
    signal_freezing_by2.append(np.sum(tmp_matrix))
    
    overlap_mask = (tmp_matrix * training > 0)
    tmp3 = np.sum(tmp_matrix * overlap_mask)
    signal_freezing_by_overlap_filter2.append(tmp3)
    freeizng_freeizng_by2.append((freeizng_index2[ix,1]-freeizng_index2[ix,0])/40)

# In[]
    
A = tuple(freeizng_freeizng_by + freeizng_freeizng_by2)
B1 = tuple(signal_freezing_by_overlap_filter + signal_freezing_by_overlap_filter2)
B2 = tuple(signal_freezing_by + signal_freezing_by2)
    
print(tr, pearsonr(A,B1), pearsonr(A,B2))



# In[]
    
zeromean(signal_sum2)
zeromean(signal_sum)

np.sum(np.sum(signal_matrix[:,3,1:4368], axis = 0))/((4368-1)/30)
np.sum(signal_sum2)/(len(freezing_start2)*2)

np.sum(np.sum(signal_matrix[:,2,740:4752], axis = 0))/((4752-740)/30)
np.sum(signal_sum)/(len(freezing_start)*2)

np.sum((signal_sum * (training >  0)) > 0)/np.sum(signal_sum > 0)
np.sum((signal_sum2 * (training >  0)) > 0)/np.sum(signal_sum2 > 0)

test1 = np.sum(signal_matrix[:,2,740:4752], axis = 1)
test2 = np.sum(signal_matrix[:,3,1:4368], axis = 1)

np.sum((training * test2) > 0)/np.sum(test2 > 0)
np.sum((training * test1) > 0)/np.sum(test1 > 0)

plt.hist(A, bins = 50)


#plt.eventplot(signal_matrix[:,2,740:4752])
# In[]

# signal matrix
test1_matrix = signal_matrix[:,2,:]

# freezing bar
syn = 14
mask_freezing = np.zeros((1, signal_matrix.shape[2]))
freezing_index = freeizng_index
#print(np.sum(mask_freeeizng))
for ix in np.arange(len(freezing_index)):
    msCamix = int(freezing_index[ix,0]/40*30 + syn) # miniscope, notebokk 간의 syn 조정
    msCamix_end = int(freezing_index[ix,1]/40*30 + syn)
    
    mask_freezing[0,msCamix:msCamix_end] = 1
    
  
# binning 
    
timebin = 10 # frames/bin
y_axis = int(test1_matrix.shape[1]/timebin)
im_matrix = np.zeros((test1_matrix.shape[0],y_axis))
im_freezing = np.zeros((1,y_axis))
for bin1 in np.arange(y_axis):
    if bin1 == y_axis-1:
        im_matrix[:,bin1] = np.sum(test1_matrix[:,timebin*bin1:], axis = 1)
        im_freezing[0,bin1] = np.sum(mask_freezing[:,timebin*bin1:], axis = 1) > 0
    else:
        im_matrix[:,bin1] = np.sum(test1_matrix[:,timebin*bin1:timebin*(bin1+1)], axis = 1)
        im_freezing[0,bin1] = np.sum(mask_freezing[:,timebin*bin1:timebin*(bin1+1)], axis = 1) > 0

limit_s = int(740/timebin)
limit_e = int(4752/timebin)

max_height = int(np.max(np.sum(im_matrix, axis = 0)))
frth = np.zeros((max_height,y_axis))
for ix in np.arange(im_matrix.shape[1]):
    frth[0:int(np.sum(im_matrix[:,ix])), ix] = 1
    
f, (ax1, ax2, ax3) = plt.subplots(3, 1)
ax1.imshow(im_matrix[:,limit_s:limit_e], aspect='auto', cmap='gray')
ax1.set_title('Raster plot')
ax1.set_ylabel('neuron ID')
ax2.imshow(frth[:,limit_s:limit_e], aspect='auto', origin='lower', cmap='gray')
ax2.set_title('Firing-rate-time-histogram (FRTH)')
ax2.yaxis.set_visible(False)

ax3.set_title('Freezing')
ax3.imshow(im_freezing[:,limit_s:limit_e], aspect='auto', cmap='gray')
ax3.yaxis.set_visible(False)

# x axis좀 맞춰봐... ㅠㅠ 

# In[] 시간대비 signal/neuron 비율 계산 
test1
test1_matrix = signal_matrix[:,2,740:4740]


# total
np.sum(test1)/np.sum(test1>0)


# 1/10
bins = 5.12
total_time = test1_matrix.shape[1]
framebins = int(total_time/bins)

signal_n = list()
neuron_n = list()
for ix in np.arange(bins):
    tmp3 = np.sum(test1_matrix[:,int(framebins*ix):int(framebins*(ix+1))], axis =1)
    signal_n.append(np.sum(tmp3))
    neuron_n.append(np.sum(tmp3>0))
#    print(int(framebins*ix),int(framebins*(ix+1)))

ratio = np.array(signal_n)/np.array(neuron_n)
print( bins, np.nanmean(ratio))



total_time/(len(freeizng_freeizng_by)*2*30)

# In[] freezing cells 들이 freezing(start), freezing이 아닌 non-freezing에서 나타나는 비율


freezing_cells_index = (signal_sum * training) > 0
freezing_index = freeizng_index # 오타 수정 
tr = 1.3 # time range
syn = 14

trainig_timelimit = tuple([640, 7860])
test1_timelimit = tuple([740, 4752])

signal_matrix

##


# freezing(start) session masking
mask_freeizng_start = np.zeros((1, signal_matrix.shape[2])) # miniscope
for ix in np.arange(len(freezing_index)): # notebook
    msCamix = int(freezing_index[ix,0]/40*30 + syn) # miniscope, notebokk 간의 syn 조정
    mask_freeizng_start[0,int(msCamix-30*tr):int(msCamix+30*tr)] = 1
    

# freezing session masking (without start point)
mask_freeizng = np.zeros((1, signal_matrix.shape[2]))
#print(np.sum(mask_freeeizng))
for ix in np.arange(len(freezing_index)):
    msCamix = int(freezing_index[ix,0]/40*30 + syn) # miniscope, notebokk 간의 syn 조정
    msCamix_end = int(freezing_index[ix,1]/40*30 + syn)
    
    mask_freeizng[0,msCamix:msCamix_end] = 1
    
#print(np.sum(mask_freeeizng))
mask_freeizng = mask_freeizng - (mask_freeizng * mask_freeizng_start > 0)
#print(np.sum(mask_freeeizng))

# non_freezing session masking

non_freeizng = np.ones((1, signal_matrix.shape[2]))
#print(np.sum(non_freeeizng))
non_freeizng = non_freeizng - mask_freeizng
#print(np.sum(non_freeeizng))
non_freeizng = non_freeizng - mask_freeizng_start
#print(np.sum(non_freeeizng))

# visualization
f, (ax1, ax2, ax3) = plt.subplots(3, 1)
ax1.imshow(mask_freeizng_start[:,740:4752], aspect='auto', cmap='gray')
ax2.imshow(mask_freeizng[:,740:4752], aspect='auto', cmap='gray')
ax3.imshow(non_freeizng[:,740:4752], aspect='auto', cmap='gray')

mask_freeizng_start, mask_freeizng, non_freeizng

# total 단위 : signal/s
np.sum(np.sum(signal_matrix[:,2,740:4752] * mask_freeizng_start[:,740:4752], axis=1))/(np.sum(mask_freeizng_start[:,740:4752])/30)
np.sum(np.sum(signal_matrix[:,2,740:4752] * mask_freeizng[:,740:4752], axis=1))/(np.sum(mask_freeizng[:,740:4752])/30)
np.sum(np.sum(signal_matrix[:,2,740:4752] * non_freeizng[:,740:4752], axis=1))/(np.sum(non_freeizng[:,740:4752])/30)
#f, (ax1, ax2, ax3) = plt.subplots(3, 1)
#ax1.imshow(signal_matrix[:,2,:], aspect='auto', cmap='gray')
#ax2.imshow((signal_matrix[:,2,:] * mask_freeeizng_start), aspect='auto', cmap='gray')
#ax3.imshow(mask_freeeizng_start, aspect='auto', cmap='gray')

# freezing cells only

np.sum(np.sum(signal_matrix[:,2,740:4752] * mask_freeizng_start[:,740:4752], axis=1)*freezing_cells_index)/(np.sum(mask_freeizng_start[:,740:4752])/30)
np.sum(np.sum(signal_matrix[:,2,740:4752] * mask_freeizng[:,740:4752], axis=1)*freezing_cells_index)/(np.sum(mask_freeizng[:,740:4752])/30)
np.sum(np.sum(signal_matrix[:,2,740:4752] * non_freeizng[:,740:4752], axis=1)*freezing_cells_index)/(np.sum(non_freeizng[:,740:4752])/30)



v1 = np.sum(np.transpose(np.transpose(signal_matrix[:,2,740:4752]) * freezing_cells_index), axis=0)
v2 = np.zeros((1,v1.shape[0]))
v2[0,:] = v1

for ix in np.arange(len(freezing_index)):
    msCamix = int(freezing_index[ix,0]/40*30 + syn) # miniscope, notebokk 간의 syn 조정
    msCamix_end = int(freezing_index[ix,1]/40*30 + syn)
    
    mask_freeizng[0,msCamix:msCamix_end] = 1

f, (ax1, ax2) = plt.subplots(2, 1)
ax1.imshow(mask_freeizng[:,740:4752], aspect='auto', cmap='gray')
ax1.yaxis.set_visible(False)
ax2.imshow(v2, aspect='auto', cmap='gray')
ax2.yaxis.set_visible(False)






















                           
