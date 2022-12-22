# uses data from: https://singlecell.broadinstitute.org/single_cell/study/SCP1376/a-single-cell-atlas-of-human-and-mouse-white-adipose-tissue

# load libraries
library(Seurat)
library(SeuratDisk)
library(tidyverse)

# create directories
dir.create("Documentation")
dir.create("Output")

# import data ----
# .RDS format
rds_obj <- readRDS('human_all.rds') # rds_obj <- readRDS(<Path/to/RDS.file>)
str(rds_obj)
View(rds_obj@meta.data)

# rownames as column "sampleName" 
rds_obj$sampleName <- rownames(rds_obj@meta.data)

# check contents
colnames(rds_obj@meta.data)

# select groups ----
# e.g. cell types from meta.data column "cell_type2"
(Celltypes <- unique(rds_obj@meta.data$cell_type2)) # (Celltypes <- unique(rds_obj@meta.data$<COLUMN NAME>))
Celltypes_df <- as.data.frame(Celltypes)
write_csv(Celltypes_df,"Documentation/Celltypes_df.csv")

# each cell type sorted as rds file
for (i in seq(nrow(Celltypes_df))){
  # print(Celltypes_df[i,])
  CT <- Celltypes_df[i,]
  # print(CT)
  CT_subset <- subset(rds_obj,subset = cell_type2 == CT)   # CT_subset <- subset(rds_obj,subset = <COLUMN NAME> == CT)
  CT_name <- paste0("Output/",CT,".rds")
  mypath = file.path(CT_name)
  saveRDS(CT_subset, file = CT_name)
}
