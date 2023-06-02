## Seurat_PFA_pipeline
#### This ReadMe contains a short version of the ReadMe for the data preparation
####  and serves as an example on how to analyze the data.
####  If you decide to use other data sets or other tools or prefer to use a python-based dataset preparation, 
####  you will need to change the scripts accordingly
####  everything you need to know is described in detail in the data_prepartion_ReadMe

The first four steps are R scripts
step 05 and beyond are python scripts


## 1.) 01_Input 
-> import data in R 
--> 01_Input/a_RDS_file for RDS files => Step1_RDS 
====> use result in 02_Preparation/Subset_1 and 02_Preparation/Subset_2

--> 01_Input/b_H5AD_file for H5AD files => Step1_H5AD 
====> use result in 02_Preparation/Subset_1 and 02_Preparation/Subset_2

## 2.) 02_Preparation
-> prepare data (filter for quality, DoubletFinder to remove doublets)

First:
perform for all subsets (here for Fibroblast and Macrophage)

--> 02_Preparation/Subset_1 => Step2a_SortingBySubset 
====> perform next step in 02_Preparation/Subset_1/Output (will be generated automatically by running Step2a_SortingBySubset)

--> 02_Preparation/Subset_2 => Step2a_SortingBySubset
====> perform next step in 02_Preparation/Subset_2/Output (will be generated automatically by running Step2a_SortingBySubset)

Second:
perform for all subsets (here for Fibroblast and Macrophage)
if the subset contains more than one group (e.g., Macrophage contains different organ ontologies (ascending and descending aorta)) 
will remove doublets 

--> 02_Preparation/Subset_1/Output/<firstSubset e.g. Macrophage_ascending aorta>
====> perform Step2b_RemovingDoublets 
========> perform next step in 02_Preparation/Subset_1/Output/Step_03 (will be generated automatically by running Step2b_RemovingDoublets,
                                          result of Step2b = required input for next step will be saved there)

--> 02_Preparation/Subset_2/Output/<secondSubset e.g. Macrophage_descending aorta>
========> perform next step in 02_Preparation/Subset_1/Output/Step_03 (will be generated automatically by running Step2b_RemovingDoublets,
                                          result of Step2b = required input for next step will be saved there)



--> 02_Preparation/Subset_2/Output/<firstSubset e.g. Fibroblast_ascending aorta>
====> perform Step2b_RemovingDoublets 
========> perform next step in 02_Preparation/Subset_2/Output/Step_03 (will be generated automatically by running Step2b_RemovingDoublets,
                                                                       result of Step2b = required input for next step will be saved there)

--> 02_Preparation/Subset_2/Output/<secondSubset e.g. Fibroblast_descending aorta>
====> perform Step2b_RemovingDoublets 
========> perform next step in 02_Preparation/Subset_2/Output/Step_03 (will be generated automatically by running Step2b_RemovingDoublets,
                                                                       result of Step2b = required input for next step will be saved there)

## 3.) Joining groups
perform for all subsets (here for Fibroblast and Macrophage)

--> 02_Preparation/Subset_1/Output/03_Step
===> perform Step3_joiningSubGroups
========> perform next step in 04_CreateInputTable (will be generated automatically by running Step3_joiningSubGroups,
                                                    result of Step3_joiningSubGroups = required input for next step will be saved there)

--> 02_Preparation/Subset_2/Output/03_Step
===> perform Step3_joiningSubGroups
========> perform next step in 04_CreateInputTable (will be generated automatically by running Step3_joiningSubGroups,
                                                    result of Step3_joiningSubGroups = required input for next step will be saved there)

## 4.) Create input table for Randomizer script
joins the two tables (one for each SubSet, e.g. one for all Macrophage data and the second for all Fibroblast data)
the required input files will appear here

--> 04_CreateInputTable
===> perform Step4_Combining_Groups_for_InputTable
=====>  will create a new directory "Output" where the resulting table will be saved
========> perform next step in 05_Randomizer 

## 5.) Randomizer  
!!! This step will take some time !!!

-> create a directory called Randomizer on your harddrive
-> copy the table generated above (e.g., Macrophage_asc_as_0_Macrophage_desc_as_0_Fibroblast_asc_as_1_Fibroblast_desc_as_1.csv)
	into the directory
-> copy the python script in the directory
-> change the initial path to the name of your input data (e.g., initial_path = 'Fib_I_asc_as_0_Fib_I_desc_as_0_VSMC_I_asc_as_1_VSMC_I_desc_as_1.csv')
-> run the python script

=====> your data is now ready for PFA

## 6.) PFA (original version)
predicts genes for cell type identification 
divided in three steps: 
	1.) preparing the data set (01_Prepare_Data_Set), 
	2.) PFA gene selection (02_PFA_gene_selection),
	3.) validating the PFA results (03_Validate_PFA_Results)

-> Randomizer will generate n results files (depends on the size of your original data set)
--> generate a directory for each PFA run (e.g., 3 directories if you intend to use "result_1.csv", "result_2.csv", and "result_3.csv")

copy all 3 pyhton scripts in these directories
-> Copy the python files of 06_PFA/01_Prepare_Data_Set into your PFA directory (for the first step)
-> Copy the python files of 06_PFA/02_PFA_gene_selection into your PFA directory (for the second step)
-> Copy the python files of 06_PFA/03_Validate_PFA_Results into your PFA directory (for the third step)

### 1.) 01_Prepare_Data_Set
prepares the data set for PFA

requires a "result_n.csv" file (eg., result_1.csv)
and the python script available in 06_PFA/01_Prepare_Data_Set

-> the default path is result_1.csv => if required, change the path according to the result file (e.g., result_2.csv)

-> run the python script

==> will generate: "gene_names.csv" and "PFA_analysis_data.csv" which are required for the next steps

### 2.) 02_PFA_gene_selection 
selects the PFA genes
!!! This step will take some time !!!

requires "gene_names.csv" and "PFA_analysis_data.csv" (generated in the first step)
and the python script available in 06_PFA/02_PFA_gene_selection

-> run the python script

==> will generate: "gene_mutual_information.csv" (containing the genes selected by PFA)

### 3.) 03_Validate_PFA_Results
validates the PFA results

requires "gene_names.csv", "PFA_analysis_data.csv" (generated in the first step), 
and "gene_mutual_information.csv" (containing the genes selected by PFA, generated in the second step)
and the python script available in 03_Validate_PFA_Results

-> run the python script

Note: If you prefer running the validation using another gene set instead of "gene_mutual_information.csv", you can do so by changing the respecitve parameter.
	
## 7.) 07_merge_mutual_information
to get the mutual information with the names of the genes 

-> create a new directory and copy paste the files into the directory:
	* "result_1.csv"
	* "gene_mutual_information.csv"

--> run the script 

