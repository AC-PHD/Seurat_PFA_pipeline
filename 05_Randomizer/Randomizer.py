#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import csv
import random
import os
from IPython.display import clear_output


# In[ ]:


initial_path = 'Adipocytes_as_0_mesothelium_as_1.csv' #Insert File Name From Merged File Using The SeuratPipeline


# In[ ]:


# Prepare Step

def get_random_columns(path, count):
    with open(path, 'r') as file:
        reader = csv.reader(file, delimiter=',')
        rows = []
        cnt = 0
        for row in reader:
            cnt = cnt + 1
            rows.append(row)
            # ACTIVATE FOR TESTING PURPOSE ONLY - LIMITS THE AMOUNT OF GENES (NOT CELLS)
            # if cnt > 500:
            #     break
        if check_row_size(rows[0], count) == False:
            return {'success': False }
        
        selected_columns = []
        results_zeroes = []
        results_ones = []
        results_found = False
        while( results_found == False):
            column_found = False
            while column_found == False:
                random_num = get_random_column(len(rows[0]))
                if random_num not in selected_columns:
                    column_found = True
                    column = rows[0][random_num]
                    if column == '0' and len(results_zeroes) < count:
                        results_zeroes.append(random_num)
                        selected_columns.append(random_num)
                    elif column == '1' and len(results_ones) < count:
                        results_ones.append(random_num)
                        selected_columns.append(random_num)
                if len(results_zeroes) >= count and len(results_ones) >= count:
                    results_found = True
        result = []
        rest = []
        for row in rows:
            new_row = []
            rest_row = []
            new_row.append(row[0])
            for col in results_zeroes:
                new_row.append(row[col])
            for col in results_ones:
                new_row.append(row[col])
            result.append(new_row)
            total_cols = len(rows[0])
            for i in range(0, total_cols):
                if i not in selected_columns:
                    rest_row.append(row[i])
            rest.append(rest_row)
        return {"result" : result, "rest" : rest, 'success': True}
                    
                    
def check_row_size(row_zero, count):
    zeroes = 0
    ones = 0
    if len(row_zero) < 2 * count:
        return false
    for column in row_zero:
        if column == '0':
            zeroes = zeroes +1
        else :
            ones = ones +1
    if zeroes < count or ones < count:
        return False
    return True


def get_random_column(size):
    return random.randint(1,size-1)

def get_zeroes(row):
    zeroes = 0
    for col in row:
        if col == '1':
            zeroes = zeroes + 1
    return zeroes


# In[ ]:


# Randomizer Step

cell_count = 1000 # how many cells of each type shall be selected as input for PFA

if __name__ == '__main__':
    if not os.path.exists('randomizer_results'):
        os.makedirs('randomizer_results')
    result_cnt = 1
    results = get_random_columns(initial_path, cell_count)
    with open('randomizer_results/result_{}.csv'.format(result_cnt), 'w') as file:
        writer = csv.writer(file)
        for row in results['result']:
            writer.writerow(row)
    with open('randomizer_results/rest_{}.csv'.format(result_cnt), 'w') as file:
        writer = csv.writer(file)
        for row in results['rest']:
            writer.writerow(row)
    result_cnt = result_cnt + 1
    finished = False
    while finished == False:
        print("Result", result_cnt, "is starting to randomize")
        results = get_random_columns('randomizer_results/rest_{}.csv'.format(result_cnt-1), cell_count)
        if results['success'] == False:
            finished = True
            break
        with open('randomizer_results/result_{}.csv'.format(result_cnt), 'w') as file:
            writer = csv.writer(file)
            for row in results['result']:
                writer.writerow(row)
        with open('randomizer_results/rest_{}.csv'.format(result_cnt), 'w') as file:
            writer = csv.writer(file)
            for row in results['rest']:
                writer.writerow(row)
        result_cnt = result_cnt + 1

