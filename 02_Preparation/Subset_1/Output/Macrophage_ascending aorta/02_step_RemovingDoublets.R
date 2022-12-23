# libraries
library(Seurat)
library(SeuratDisk)
library(tidyverse)
library(DoubletFinder)

# directories
dir.create("Output")
dir.create("Documentation")

# # import data ----
# read in 
Input_name <- c("Macrophage_asc") # the name will be used for the output file
as_Number <- 0 # one group has to be labeled as "0", the other as "1", 
# if a group contains subgroups, the sub groups need to have the same label number
# e.g. Macrophage contains cells from the ascending aorta and the descending aorta
# group Macrophage labeled as "0" 
# => both sub groups "Macrophage_ascending aorta" and "Macrophage_descending aorta" need to be labeled as "0"
Input_RDS <- readRDS("Macrophage_ascending aorta.rds") # name / path to subgroup created in the step before

## check ----
# View(Input_RDS)
View(Input_RDS@meta.data)

# you need the columns containing:
# * nCount_RNA (Counts, often named nCount_RNA)
# * nFeature_RNA (Features, often named nFeature_RNA)
# * percent_mito (percent of mitochondrial DNA, name varies, could be sth. like "percent_mito", "mito.percent", ...)
# (names may vary, check the colnames for the correct input)
colnames(Input_RDS@meta.data)

# filter out low quality cells ----
Input_RDS_filtered <- subset(Input_RDS, subset = nCount_RNA > 800 &
                               nFeature_RNA > 500 &
                               percent_mito < 5)

# Input_RDS_filtered <- subset(Input_RDS, subset = <nCount_RNA or the respective name from the meta.data> > 800 &
#                                <nFeature_RNA or the respective name from the meta.data> > 500 &
#                                <percent_mito or the respective name from the meta.data> > < 5)


saveName <- paste0("Documentation/",Input_name,"_filtered.rds")
saveRDS(Input_RDS_filtered, file = saveName)

# preprocessing for Doublet Finder
Input_RDS_filtered <- NormalizeData(object = Input_RDS_filtered)
Input_RDS_filtered <- FindVariableFeatures(object = Input_RDS_filtered)
Input_RDS_filtered <- ScaleData(object = Input_RDS_filtered)
Input_RDS_filtered <- RunPCA(object = Input_RDS_filtered)

# Check dimensionality of data set----
(elbow_plot <- ElbowPlot(Input_RDS_filtered))

pic_name <- paste0("Documentation/elbowPlot_",Input_name,".png")
ggsave(elbow_plot, file=pic_name, dpi=600)

# here all 20 dimensions
Input_RDS_filtered <- FindNeighbors(object = Input_RDS_filtered, dims = 1:20)
Input_RDS_filtered <- FindClusters(object = Input_RDS_filtered)
Input_RDS_filtered <- RunUMAP(object = Input_RDS_filtered, dims = 1:20)

saveName <- paste0("Output/",Input_name,"_filtered_for_DoubletFinder.rds")
saveRDS(Input_RDS_filtered, file = saveName)

# DoubletFinder ----
# pK identification (no ground truth) from github of DoubletFinder ----
sweep_res_Input_RDS_filtered <- paramSweep_v3(Input_RDS_filtered, PCs = 1:20, sct = FALSE)
sweep_stats_res_Input_RDS_filtered <- summarizeSweep(sweep_res_Input_RDS_filtered, GT = FALSE)
findingPK_res_Input_RDS_filtered <- find.pK(sweep_stats_res_Input_RDS_filtered)

(pkPlot <- ggplot(findingPK_res_Input_RDS_filtered, aes(pK, BCmetric, group =1)) +
    geom_point() +
    geom_line())

pic_name <- paste0("Output/pkPlot_",Input_name,".png")
ggsave(pkPlot, file=pic_name, dpi=600)

# select and save optimal pK value
optimal_pK  <- findingPK_res_Input_RDS_filtered  %>% 
  filter(BCmetric == max(BCmetric)) %>%
  select(pK)
optimal_pK  <- as.numeric(as.character(optimal_pK[[1]]))

pkTitle <- paste0("Optimal pK for ",Input_name," = ",optimal_pK )
(pkPlot2 <- ggplot(findingPK_res_Input_RDS_filtered, aes(pK, BCmetric, group =1)) +
    geom_point() +
    geom_line() +
    ggtitle(pkTitle))

pic_name <- paste0("Output/pkPlot_",Input_name,"_with_title.png")
ggsave(pkPlot2, file=pic_name, dpi=600)

# Homotypic Doublet Proportion Estimate ----
annotations_Input_RDS_filtered <- Input_RDS_filtered@meta.data$seurat_clusters
homotypic_prop_Input_RDS_filtered <- modelHomotypic(annotations_Input_RDS_filtered)

# number of cells loaded and recovered:
# before filtering:
Input_RDS
# after filtering:
Input_RDS_filtered

sink(file = "Output/number_of_cells_loaded_and_recovered.txt")
print("before filtering:")
Input_RDS
print("after filtering:")
Input_RDS_filtered
sink(file = NULL)

# expected number of doublets
## Assuming a doublet formation rate of 7.5% (if applicable, see user guide of reagent kit)
nExp_poi_Input_RDS_filtered <- round(0.076*nrow(Input_RDS_filtered@meta.data))  
# after homolytic adjustment 
nExp_poi.adj_Input_RDS_filtered <- round(nExp_poi_Input_RDS_filtered*(1-homotypic_prop_Input_RDS_filtered))


# run doubletFinder 
Input_RDS_filtered_DoubletFinder <- doubletFinder_v3(Input_RDS_filtered, 
                                                     PCs = 1:20, 
                                                     pN = 0.25, 
                                                     pK = optimal_pK, 
                                                     nExp = nExp_poi.adj_Input_RDS_filtered,
                                                     reuse.pANN = FALSE, sct = FALSE)


saveName <- paste0("Documentation/doubletFinder_",Input_name,"_filtered.rds")
saveRDS(Input_RDS_filtered_DoubletFinder, file = saveName)

# visualize doublets
View(Input_RDS_filtered_DoubletFinder@meta.data)
ColumnNames <- names(Input_RDS_filtered_DoubletFinder@meta.data)
DF_classification <- tail(ColumnNames, n=1)

# check for doublets ----
(dimPlot_doublets <- DimPlot(Input_RDS_filtered_DoubletFinder, 
                             reduction = 'umap', group.by = DF_classification))

pic_name <- paste0("Output/DoubletFinderPlot_",Input_name,"_checkForDoublets.png")
ggsave(dimPlot_doublets, file=pic_name, dpi=600)

# number of singlets and doublets
tableRowNr <- length(Input_RDS_filtered_DoubletFinder@meta.data)
Input_RDS_filtered_DoubletFinder@meta.data[tableRowNr]
table(Input_RDS_filtered_DoubletFinder@meta.data[tableRowNr])

sink(file = "Output/number_of_singlets_and_doublets.txt")
print("number of singlets and doublets:")
table(Input_RDS_filtered_DoubletFinder@meta.data[tableRowNr])
sink(file = NULL)

# keep only singlets ("SortingColumn" required to address the correct column)
Input_RDS_filtered_DoubletFinder@meta.data["SortingColumn"] <-Input_RDS_filtered_DoubletFinder@meta.data[tableRowNr]
# View(Input_RDS_filtered_DoubletFinder@meta.data)
DF_result_table <- Input_RDS_filtered_DoubletFinder@meta.data
write_csv(DF_result_table, "Documentation/DoubletFinder_results_in_metadata.csv")

Input_RDS_filtered_DoubletFinder_cleaned <- subset(Input_RDS_filtered_DoubletFinder, 
                                                   subset = SortingColumn == c("Singlet"))

(dimPlot_cleaned <- DimPlot(Input_RDS_filtered_DoubletFinder_cleaned, 
                            reduction = 'umap', group.by = DF_classification))

pic_name <- paste0("Output/DoubletFinderPlot_",Input_name,"_doublets_removed.png")
ggsave(dimPlot_cleaned, file=pic_name, dpi=600)

saveName <- paste0("Output/doubletFinder_",Input_name,"_filtered_doublets_removed.rds")
saveRDS(Input_RDS_filtered_DoubletFinder_cleaned, file = saveName)

# creating output table of sub group ----
# both sub groups will have the same label number
Seurat_results_file <- Input_RDS_filtered_DoubletFinder_cleaned

# get the counts of the raw RNA counts
Counts_DF <- as.data.frame(Input_RDS_filtered_DoubletFinder_cleaned@assays$RNA@counts) %>%  rownames_to_column()
Counts_DF_names <- colnames(Counts_DF)

# Check that sample names match in both files
checking_Counts_DF <- colnames(Counts_DF)
checking_Counts_DF <- checking_Counts_DF[-1]

# check
all(colnames(checking_Counts_DF) == rownames(Seurat_results_file@meta.data))

# Check for ribosomal and mitochondrial genes
grep("^RP[LS]",Counts_DF$rowname,value = TRUE)
grep("^MT",Counts_DF$rowname,value = TRUE)

# remove ribosomal and mitochondrial genes
Counts_DF_final <- Counts_DF %>% filter(!grepl('^RP[LS]', rowname))
# grep("^RP[LS]",Counts_DF_final$rowname,value = TRUE)
# grep("^MT",Counts_DF_final$rowname,value = TRUE)

Counts_DF_final <- Counts_DF_final %>% filter(!grepl('^MT', rowname))

# ribosomal and mitochondrial genes have been removed
grep("^RP[LS]",Counts_DF_final$rowname,value = TRUE)
grep("^MT",Counts_DF_final$rowname,value = TRUE)

label_row <- c(as_Number)
sub_group_labeled <- rbind(label_row, Counts_DF_final)
sub_group_labeled[1,1] <- c("label")
View(sub_group_labeled)

# save labeled sub group in directory 03_Step
saveName <- paste0("../03_Step/",Input_name,"_as_",as_Number,".csv")
write.table(sub_group_labeled, file = saveName , sep=",",  col.names=FALSE, row.names = FALSE)

# repeat for every subgroup and continue with the next part of the script (joining the sub groups back together) in 03_Step