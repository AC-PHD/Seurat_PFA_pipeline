# load libraries
library(Seurat)
library(SeuratDisk)
library(tidyverse)

# create directories
dir.create("Documentation")
dir.create("Output")
dir.create("Output/03_Step")

# Which cell type are you analyzing?
CellType <- c("Fibroblast") # in this example Macrophage

# load RDS object for one of the groups you're interested in
rds_obj <- readRDS("01. Fibroblast I.rds")

# check for unique cell types (required for DoubletFinder step)
# get column names and the rds object
colnames(rds_obj@meta.data)
View(rds_obj@meta.data)

# check whether columns of interest contain more than one value
unique(rds_obj@meta.data$disease__ontology_label) # difference between disease and control? no only normal cells
unique(rds_obj@meta.data$cell_type__ontology_label) # more than 1 cell type? no, only macrophage
unique(rds_obj@meta.data$organ__ontology_label) # more than 1 organ? yes, "ascending aorta" and "descending aorta"

# better to split in 2 groups for the DoubletFinder step
(subtypes <- unique(rds_obj@meta.data$organ__ontology_label)) # (reason <- unique(rds_obj@meta.data$<COLUMN WITH SUB GROUPS>))
subtypes_df <- as.data.frame(subtypes)
write_csv(subtypes_df,"Documentation/subtypes_df.csv")

# each subtype sorted as rds file in a separate directory
for (i in seq(nrow(subtypes_df))){
  # print(Celltypes_df[i,])
  ST <- subtypes_df[i,]
  # print(CT)
  ST_subset <- subset(rds_obj,subset = organ__ontology_label == ST) # ST_subset <- subset(rds_obj,subset = <COLUMN WITH SUB GROUPS> == ST)
  ST_dir <- paste0("Output/",CellType,"_",ST)
  dir.create(ST_dir)
  ST_name <- paste0(ST_dir,"/",CellType,"_",ST,".rds")
  mypath = file.path(ST_name)
  saveRDS(ST_subset, file = ST_name)
}

# the next step is performed in the newly created subdirectories in "Output"
# the step after that is performed in the directory "03_Step" in "Output"
# the final step is performed in 04_CreateInputTable
