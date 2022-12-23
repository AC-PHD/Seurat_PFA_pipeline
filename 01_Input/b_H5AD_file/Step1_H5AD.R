# uses data from: https://singlecell.broadinstitute.org/single_cell/study/SCP1265/deep-learning-enables-genetic-analysis-of-the-human-thoracic-aorta

# load libraries
library(Seurat)
library(SeuratDisk)
library(tidyverse)

# create directories
dir.create("Documentation")
dir.create("Output")

# import data ----
#  .h5ad format
# AnnData to h5Seurat file
Convert("ascending_descending_human_aorta_v1.h5ad", dest = "h5seurat", overwrite = TRUE) # Convert("<FILE NAME.h5ad>", dest = "h5seurat", overwrite = TRUE)
# Load h5Seurat file into a Seurat object 
rds_obj <- LoadH5Seurat("ascending_descending_human_aorta_v1.h5seurat")

# rownames as column "sampleName" 
rds_obj$sampleName <- rownames(rds_obj@meta.data) # rds_obj <- LoadH5Seurat(<FILE NAME.h5seurat>")

# check contents
colnames(rds_obj@meta.data)

# select groups ----
# e.g. cell types from meta.data column "cell_type_leiden"
(Celltypes <- unique(rds_obj@meta.data$cell_type_leiden)) # (Celltypes <- unique(rds_obj@meta.data$<COLUMN NAME>))
Celltypes_df <- as.data.frame(Celltypes)
write_csv(Celltypes_df,"Documentation/Celltypes_df.csv")

# each cell type sorted as rds file
for (i in seq(nrow(Celltypes_df))){
  # print(Celltypes_df[i,])
  CT <- Celltypes_df[i,]
  # print(CT)
  CT_subset <- subset(rds_obj,subset = cell_type_leiden == CT)   # CT_subset <- subset(rds_obj,subset = <COLUMN NAME> == CT)
  CT_name <- paste0("Output/",CT,".rds")
  mypath = file.path(CT_name)
  saveRDS(CT_subset, file = CT_name)
}