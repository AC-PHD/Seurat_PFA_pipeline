#!/usr/bin/env python
# coding: utf-8

# In[ ]:


#pip install pandas


# In[ ]:


import pandas as pd


# In[ ]:


path="result_1.csv" #Please insert correct file input name

data=pd.read_csv(path, header=None)
gene_names=pd.DataFrame({'gene_names': list(data.iloc[:,0])})
expression_data=data.iloc[:,1:]

gene_names.to_csv('gene_names.csv',index=False)
expression_data.to_csv('PFA_analysis_data.csv',index=False, header=False)

