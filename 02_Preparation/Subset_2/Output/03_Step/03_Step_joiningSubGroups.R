# load libraries
library(tidyverse)

# create directories
dir.create("Output")

# joining the sub groups, assuming a total of 2 sub groups 
SubGroup_1 <- read.csv("Fibroblast_asc_as_1.csv", header = FALSE) # the first sub group: SubGroup_1 <- read.csv(<name of first sub group.CSV>, header = FALSE) 
SubGroup_2 <- read.csv("Fibroblast_desc_as_1.csv", header = FALSE) # the second sub group: SubGroup_2 <- read.csv(<name of second sub group.CSV>, header = FALSE) 

SubGroup_1_name <-c("Fibroblast_asc_as_1") # SubGroup_1_name <- c("<NAME of first sub group>", header = FALSE) 
SubGroup_2_name <- c("Fibroblast_desc_as_1") # SubGroup_2_name <- c("<NAME of second sub group>", header = FALSE) 

View(SubGroup_1)
View(SubGroup_2)

SubGroup_1_merger <- SubGroup_1
rownames(SubGroup_1_merger) <- SubGroup_1_merger$V1
# View(SubGroup_1_merger)
names(SubGroup_1_merger)[1] <- c("SubGroup_1_info")
# View(SubGroup_1_merger)

SubGroup_2_merger <- SubGroup_2
rownames(SubGroup_2_merger) <- SubGroup_2_merger$V1
# View(SubGroup_2_merger)
names(SubGroup_2_merger)[1] <- c("SubGroup_2_info")
# View(SubGroup_2_merger)

Merged_table <- dplyr::left_join(SubGroup_1_merger, SubGroup_2_merger, 
                                 by = c('SubGroup_1_info' = 'SubGroup_2_info'))

View(Merged_table)

head(Merged_table$SubGroup_2_info)
head(Merged_table$SubGroup_1_info)

Merged_Table_Final <- Merged_table
rownames(Merged_Table_Final) <- Merged_Table_Final$SubGroup_1_info
# View(Merged_Table_Final)
Merged_Table_Final <- Merged_Table_Final %>% dplyr::select(-SubGroup_1_info)  
# View(Merged_Table_Final) 

TableName <- paste0("Output/",SubGroup_1_name,"_",SubGroup_2_name,".csv")

# save the table in the directory "03_CreateInputTable", where the final step of the preparation is performed
dir.create("../../../../04_CreateInputTable")
TableName <- paste0("../../../../04_CreateInputTable/",SubGroup_1_name,"_",SubGroup_2_name,".csv")
write.table(Merged_Table_Final, file = TableName , sep=",",  col.names=FALSE)