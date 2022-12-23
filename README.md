# Seurat_PFA_pipeline
# This ReadMe contains a short version of the ReadMe for the data preparation
# If you decide to use other data sets, you will need to change the scripts accordingly
# everything you need to know is described in detail in the data_prepartion_ReadMe

# The first four steps are R scripts
# step 05 and beyond are python scripts


1.) 01_Input 
-> import data in R 
--> 01_Input/a_RDS_file for RDS files => Step1_RDS 
====> use result in 02_Preparation/Subset_1 and 02_Preparation/Subset_2

--> 01_Input/b_H5AD_file for H5AD files => Step1_H5AD 
====> use result in 02_Preparation/Subset_1 and 02_Preparation/Subset_2

2.) 02_Preparation
-> prepare data (filter for quality, DoubletFinder to remove doublets)

First:
# perform for all subsets (here for Fibroblast and Macrophage)

--> 02_Preparation/Subset_1 => Step2a_SortingBySubset 
====> perform next step in 02_Preparation/Subset_1/Output (will be generated automatically by running Step2a_SortingBySubset)

--> 02_Preparation/Subset_2 => Step2a_SortingBySubset
====> perform next step in 02_Preparation/Subset_2/Output (will be generated automatically by running Step2a_SortingBySubset)

Second:
# perform for all subsets (here for Fibroblast and Macrophage)
# if the subset contains more than one group (e.g., Macrophage contains different organ ontologies (ascending and descending aorta)) 
# will remove doublets 

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

3.) Joining groups
# perform for all subsets (here for Fibroblast and Macrophage)

--> 02_Preparation/Subset_1/Output/03_Step
===> perform Step3_joiningSubGroups
========> perform next step in 04_CreateInputTable (will be generated automatically by running Step3_joiningSubGroups,
                                                    result of Step3_joiningSubGroups = required input for next step will be saved there)

--> 02_Preparation/Subset_2/Output/03_Step
===> perform Step3_joiningSubGroups
========> perform next step in 04_CreateInputTable (will be generated automatically by running Step3_joiningSubGroups,
                                                    result of Step3_joiningSubGroups = required input for next step will be saved there)

4.) Create input table for Randomizer script
# joins the two tables (one for each SubSet, e.g. one for all Macrophage data and the second for all Fibroblast data)
# the required input files will appear here

--> 04_CreateInputTable
===> perform Step4_Combining_Groups_for_InputTable
=====>  will create a new directory "Output" where the resulting table will be saved
========> perform next step in 05_Randomizer 

5.) Randomizer  
!!! This step will take some time !!!

-> create a directory called Randomizer on your harddrive
-> copy the table generated above (e.g., Macrophage_asc_as_0_Macrophage_desc_as_0_Fibroblast_asc_as_1_Fibroblast_desc_as_1.csv)
	into the directory
-> copy the python script in the directory
-> run the python script

=====> your data is now ready for PFA



