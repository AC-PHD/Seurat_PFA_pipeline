# load libraries
library(tidyverse)

# create directories
dir.create("Output")

# creating the input table by joining the two groups that will be compared in the subsequent analysis  
# load the Groups
Group_1 <- read.csv("Macrophage_asc_as_0_Macrophage_desc_as_0.csv", header = FALSE) # the first group: Group_1 <- read.csv(<name of first group.CSV>, header = FALSE) 
Group_2 <- read.csv("Fibroblast_asc_as_1_Fibroblast_desc_as_1.csv", header = FALSE) # the second group: Group_1 <- read.csv(<name of second group.CVS>, header = FALSE) 

# Group names as variables
Group_1_name <-c("Macrophage_asc_as_0_Macrophage_desc_as_0")   # Group_1_name <- c("<NAME of first group>", header = FALSE) 
Group_2_name <- c("Fibroblast_asc_as_1_Fibroblast_desc_as_1") # Group_2_name <- c("<NAME of second group">, header = FALSE)  

View(Group_1)
View(Group_2)

Group_1_merger <- Group_1
rownames(Group_1_merger) <- Group_1_merger$V1
# View(Group_1_merger)
names(Group_1_merger)[1] <- c("Group_1_info")
# View(Group_1_merger)

Group_2_merger <- Group_2
rownames(Group_2_merger) <- Group_2_merger$V1
# View(Group_2_merger)
names(Group_2_merger)[1] <- c("Group_2_info")
# View(Group_2_merger)

Merged_table <- dplyr::left_join(Group_1_merger, Group_2_merger, 
                                 by = c('Group_1_info' = 'Group_2_info'))

View(Merged_table)

head(Merged_table$Group_2_info)
head(Merged_table$Group_1_info)

Merged_Table_Final <- Merged_table
rownames(Merged_Table_Final) <- Merged_Table_Final$Group_1_info
# View(Merged_Table_Final)
Merged_Table_Final <- Merged_Table_Final %>% dplyr::select(-Group_1_info)  
# View(Merged_Table_Final) 

# save the table => This table will be the input for the Randomizer script (the next step of the workflow)
TableName <- paste0("Output/",Group_1_name,"_",Group_2_name,".csv")
write.table(Merged_Table_Final, file = TableName , sep=",",  col.names=FALSE)