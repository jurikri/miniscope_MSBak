# -*- coding: utf-8 -*-
"""
Created on Fri Oct 26 17:26:39 2018

@author: msbak
"""

import pandas as pd
import matplotlib_venn as venn
import matplotlib.pyplot as plt
import numpy as np

#filename = '‪C:\\Python\\itgidx.xlsx'

filepath = 'GPF201808_#1.4_itgidx.xlsx'
itg_idx_start = pd.read_excel(filepath, header=None)

#import matplotlib.pyplot as plt

# In[]

def venn_diagram(itg_idx_3columns, set1_name, set2_name, set3_name):
    
#    print(itg_idx_3columns)
    itg_idx = itg_idx_3columns
    itg_idx.columns = range(itg_idx.shape[1])
    
#    print(itg_idx)
    
    #  1 set
    for day in itg_idx.columns:
        cnt = 0
        for neuronNum in itg_idx.index:
            temp = itg_idx.iloc[neuronNum, day]
            if not(0 == temp):
                cnt += 1
                
        if day == 0:
            set1_pure = cnt
        elif day == 1:
            set2_pure = cnt
        elif day == 2:
            set3_pure = cnt
    
    #  2 set merge
    
    two_set_merge_list = [[0,1],[0,2],[1,2]]
#    three_set_merge_list = [1,2,3]
    
    for two_set in two_set_merge_list:
        cnt = 0
    
        dayA = two_set[0]
        dayB = two_set[1]
        
        for neuronNum in itg_idx.index:
            temp = list([itg_idx.iloc[neuronNum,dayA],itg_idx.iloc[neuronNum,dayB]])
            if not(0 in temp):
                cnt += 1
                
        if two_set == [0,1]:
            set1_2_merge = cnt
        elif two_set == [0,2]:
            set1_3_merge = cnt
        elif two_set == [1,2]:
            set2_3_merge = cnt
            
            
    #  3 set merge
            
    cnt = 0
    for neuronNum in itg_idx.index:
        temp = list(itg_idx.iloc[neuronNum,:])
        if not(0 in temp):
            cnt += 1
        
        set1_2_3_merge = cnt
          
    #  calculation
        
    set1_pure = set1_pure - set1_2_merge - set1_3_merge + set1_2_3_merge
    set2_pure = set2_pure - set1_2_merge - set2_3_merge + set1_2_3_merge
    set3_pure = set3_pure - set1_3_merge - set2_3_merge + set1_2_3_merge
    
    set1_2_merge = set1_2_merge - set1_2_3_merge
    set2_3_merge = set2_3_merge - set1_2_3_merge
    set1_3_merge = set1_3_merge - set1_2_3_merge
    
    return venn.venn3(subsets = (set1_pure, set2_pure, set1_2_merge, set3_pure, set1_3_merge, set2_3_merge, set1_2_3_merge), \
                      set_labels = (set1_name, set2_name, set3_name))
    
# In[]

plt.figure(1)
venn_diagram(itg_idx_start.iloc[:,0:3], 'day1', 'day2', 'day3')

plt.figure(2) 
venn_diagram(itg_idx_start.iloc[:,1:4], 'day2', 'day3', 'day4')



# In[]

def overlapping_calc_var_day(itg_idx_3columns, calc_list):
    mslist = []
    sw = 1
    for gaplist in calc_list:
        cnt = 0
        if len(np.shape(calc_list)) != 1:
            dayA = gaplist[0]
            dayB = gaplist[1]
        elif len(np.shape(calc_list)) == 1:
            dayA = calc_list[0]
            dayB = calc_list[1]
            
        if sw:
            for neuronNum in itg_idx_3columns.index:
                temp = list([itg_idx_3columns.iloc[neuronNum,dayA],itg_idx_3columns.iloc[neuronNum,dayB]])
                if not(0 in temp):
                    cnt += 1
                    
            dayA_list = list(itg_idx_3columns.iloc[:,dayA])
            dayB_list = list(itg_idx_3columns.iloc[:,dayB])
                    
            total_neuron = (len(dayA_list) - dayA_list.count(0)) + (len(dayB_list) - dayB_list.count(0)) - cnt
            cnt = cnt/total_neuron
            
            print('day', str(dayA+1), 'and day', str(dayB+1), ' total_neuron ', str(total_neuron))
            
            mslist.append(cnt)
            
            if len(np.shape(calc_list)) == 1:
                sw = 0
                
    return mslist

overlap_in_1day_gap = [[0,1],[1,2],[2,3]]
overlap_in_2day_gap = [[0,2],[1,3]]
overlap_in_3day_gap = [0,3]

print(overlapping_calc(itg_idx_start, overlap_in_1day_gap))
print(overlapping_calc(itg_idx_start, overlap_in_2day_gap))
print(overlapping_calc(itg_idx_start, overlap_in_3day_gap))


dayA_list = list(itg_idx_start.iloc[:,0])

# In[]

def overlapping_calc(matrix1): # pandas dataframe
    days_num = matrix1.shape[1]
    itg_idx_len = matrix1.shape[0]
    
    save_neuron = np.zeros((days_num,days_num))
    save_signal = np.zeros((days_num,days_num))
    
    for dayA in np.arange(days_num):
        for dayB in np.arange(days_num):
            dayA_siganl = np.array(matrix1.iloc[:,dayA])
            dayB_siganl = np.array(matrix1.iloc[:,dayB])
            
            neuron_both_cnt = 0
            neuron_A_cnt = 0
            
            signal_both_cnt = 0
            signal_A_cnt = 0
            for ix in np.arange(itg_idx_len):              
                if (dayA_siganl[ix] > 0 and dayB_siganl[ix] > 0): # both signal A ∩ B 
                    neuron_both_cnt += 1
                    signal_both_cnt += np.abs(dayA_siganl[ix] - dayB_siganl[ix])
                
                if dayA_siganl[ix] > 0:
                    neuron_A_cnt += 1 # A signal
                    signal_A_cnt += dayA_siganl[ix]
       
            save_neuron[dayA,dayB] = neuron_both_cnt/neuron_A_cnt # A, B의 'neuron' overlap ratio = A neuron ∩ B neuron / A neuron
            save_signal[dayA,dayB] = 1 - signal_both_cnt/signal_A_cnt # A, B의 'signal' overlap ratio = 1 - (|(A signal - B signal)| / A signal)
            
    
    return save_neuron, save_signal 
                    

# In[]
    
save_neuron, save_signal = overlapping_calc(itg_idx_start)

# In[] up regulate neuron만 선별, dafaFrame indexing 방법은 계속 사용, code 자체는 쓸모없음 


day_name_idx = {0 : 'day 1 to 2', 1 : 'day 2 to 3', 2: 'day 3 to 4', 3: 'day4'}
matrix1 = itg_idx_start

row_idx = ['up_regulated_neuron', 'down_regulated_neuron', 'same_regulated_neuron', 'up_regulated_signal', 'down_regulated_signal']
col_idx = list()
for ix in np.arange(len(day_name_idx)):
    col_idx.append(day_name_idx[ix])

save_df = pd.DataFrame([], index = row_idx, columns = col_idx)

#
up_regulated_index = list()
#

for dayA in np.arange(matrix1.shape[1]-1):
    up_regulated_neuron = 0
    up_regulated_signal = 0
    down_regulated_neuron = 0
    down_regulated_signal = 0
    same_regulated_neuron = 0
    
    for nueronNum in np.arange(matrix1.shape[0]):
        signal_A = matrix1.iloc[nueronNum, dayA]
        signal_B = matrix1.iloc[nueronNum, dayA+1]
        if signal_A == 0 and signal_B == 0:
            pass
        elif signal_B > signal_A: # up
            up_regulated_neuron += 1
            up_regulated_signal += signal_B-signal_A
            if signal_B-signal_A < 1:
                print ('up condition has minus value, it should be checked')
                
                #
            if dayA == 1: # day 2 to 3에서 up_regulation된 neuron indexing
                up_regulated_index.append(nueronNum)
                #
        elif signal_A > signal_B: # down
            down_regulated_neuron += 1
            down_regulated_signal += signal_A-signal_B
            if signal_A-signal_B < 1:
                print ('down condition has minus value, it should be checked')
                
        elif signal_A  == signal_B: # same
            same_regulated_neuron += 1
            
        else:
            print ('unexpected codition')
            
        
        save_df.loc['up_regulated_neuron',day_name_idx[dayA]] = up_regulated_neuron
        save_df.loc['down_regulated_neuron',day_name_idx[dayA]] = down_regulated_neuron
        save_df.loc['same_regulated_neuron',day_name_idx[dayA]] = same_regulated_neuron
        save_df.loc['up_regulated_signal',day_name_idx[dayA]] = up_regulated_signal
        save_df.loc['down_regulated_signal',day_name_idx[dayA]] = down_regulated_signal
        
        
# In[] 특정한 neuron list를 받아서, neuron , signal overlap meatrix 만듬 
            
def overlapping_calc_specific_neurons(matrix1, neurons_list): # pandas dataframe
    neurons_list = neurons_list
    days_num = matrix1.shape[1]
#    itg_idx_len = matrix1.shape[0]
    
    save_neuron = np.zeros((days_num,days_num))
    save_signal = np.zeros((days_num,days_num))
    
    for dayA in np.arange(days_num):
        for dayB in np.arange(days_num):
            dayA_siganl = np.array(matrix1.iloc[:,dayA])
            dayB_siganl = np.array(matrix1.iloc[:,dayB])
            
            neuron_both_cnt = 0
            neuron_A_cnt = 0
            neuron_total_cnt = 0
            
            signal_diff_cnt = 0
            signal_A_cnt = 0
            signal_total_cnt = 0
            for ix in neurons_list:              
                if (dayA_siganl[ix] > 0 and dayB_siganl[ix] > 0): # both signal A ∩ B 
                    neuron_both_cnt += 1
                
                if dayA_siganl[ix] > 0:
                    neuron_A_cnt += 1 # A signal
                
                if (dayA_siganl[ix] > 0 or dayB_siganl[ix] > 0):
                    neuron_total_cnt += 1
                    
                    
                    
                    signal_diff_cnt += abs(dayA_siganl[ix]-dayB_siganl[ix])
       
            save_neuron[dayA,dayB] = neuron_both_cnt/neuron_total_cnt # A, B의 'neuron' overlap ratio = A neuron ∩ B neuron / A neuron
            save_signal[dayA,dayB] = signal_diff_cnt/neuron_total_cnt # A, B의 'signal' overlap ratio = 1 - (|(A signal - B signal)| / A signal)
            
    
    return save_neuron, save_signal 
        
save_neuron2, save_signal2 = overlapping_calc_specific_neurons(itg_idx_start,up_regulated_index)
    
# In[] 2,3,4에 겹치는 neuron들이 1,2와 비교하여 3, 4에서 signal이 얼마나 많은지 

# 
neurons_list = list()
mxtrix1 = itg_idx_start
itg_idx_len = matrix1.shape[0]
days_num = matrix1.shape[1]


save_saignal_num = np.zeros([days_num])

#for ix in np.arange(itg_idx_len):        
#    if (mxtrix1.iloc[ix,1] > 0 and mxtrix1.iloc[ix,2] > 0, mxtrix1.iloc[ix,3] > 0): # both signal A ∩ B 
#        neurons_list.append(ix)

for dayA in np.arange(days_num):
    signal1 = 0
    signal_total = 0
    
    merge_cnt = 0
    total_cnt = 0
    
    for ix in np.arange(itg_idx_len):
        signal_total += mxtrix1.iloc[ix,dayA]
        
        if (mxtrix1.iloc[ix,1] > 0 and mxtrix1.iloc[ix,2] > 0 and mxtrix1.iloc[ix,3] > 0):
            merge_cnt += 1
            signal1 += mxtrix1.iloc[ix,dayA]
        
        total_cnt += 1
        
        
    save_saignal_num[dayA] = signal1/signal_total
    

save_total_neuronNum = np.zeros(days_num)

for dayA in np.arange(days_num):
    total_neuron_num = 0
    for ix in np.arange(itg_idx_len):
        if mxtrix1.iloc[ix,dayA] > 0:
            total_neuron_num += 1
        
    save_total_neuronNum[dayA] = total_neuron_num
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    # In[]
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


# In[]   




































