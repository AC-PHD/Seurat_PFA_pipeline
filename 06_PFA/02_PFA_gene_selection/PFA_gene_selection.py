#!/usr/bin/env python
# coding: utf-8

# In[ ]:


#pip install networkx
#pip install scipy
#pip install principal-feature-analysis
#pip install pandas


# In[ ]:


from principal_feature_analysis import pfa 
import pandas as pd


# In[ ]:


res,mutual_information=pfa(path="PFA_analysis_data.csv", calculate_mutual_information=True,
                           cluster_size=300, min_n_datapoints_a_bin=100)
mutual_information=mutual_information[0]

gene_names=pd.read_csv('gene_names.csv')
gene_names=gene_names.iloc[res,:].reset_index(drop=True)

print(mutual_information)
mutual_information=mutual_information.join(gene_names)


mutual_information_sorted=mutual_information.sort_values(by=["mutual information"], ascending=False)
mutual_information_sorted.to_csv('gene_mutual_information.csv', index=False)

f = open("principal_features_for_model.txt", "w")
for i in res:
    f.write(str(i)+str(","))
f.close()

