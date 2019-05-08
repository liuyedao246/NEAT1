## step0 Load data
rm(list = objects(all = TRUE))
if (!is.null(dev.list()))dev.off()

# step1 normal tissue
Rdata_file <- './data/GTEx.PAN.NEAT1.Rdata'
if(!file.exists(Rdata_file)){
  destfile <- './raw_data/GTEx_Analysis_2016-01-15_v7_RNASeQCv1.1.8_gene_reads.gct.gz'
  library(R.utils)
  gunzip(destfile, remove = F)
  
  library(data.table)
  raw_data <- fread('./raw_data/GTEx_Analysis_2016-01-15_v7_RNASeQCv1.1.8_gene_reads.gct',
                    sep = '\t',header = T)
  raw_data <- as.data.frame(raw_data)
  raw_data <- raw_data[raw_data[,2]=='NEAT1',]
  raw_data[1,1:10]
  rownames(raw_data) <- 'NEAT1'
  raw_data <- raw_data[,-1]
  raw_data <- raw_data[,-1]
  raw_data[1,1:10]
  dim(raw_data)
  save(raw_data, file = Rdata_file)
}else{
  load(Rdata_file)
}


Rdata_file <- './data/GTEx.Pheno.Rdata'
if(!file.exists(Rdata_file)){
  destfile <- './raw_data/GTEx_v7_Annotations_SampleAttributesDS.txt'
  
  phenoData <- read.table(destfile,
                          header = T,
                          sep = "\t",
                          quote = "")
  phenoData[1:5,1:5]
  dim(phenoData)
  rownames(phenoData) <- phenoData[, 1]
  dim(phenoData)
  phenoData[1,]
  colnames(phenoData)
  save(phenoData,file = Rdata_file)
}else{
  load(Rdata_file)
}

pheno_num <- c()
  invisible(
  lapply(1:ncol(phenoData),
         function(col_num){
           if(1 < dim(table(phenoData[,col_num]))&
              dim(table(phenoData[, col_num]))<50){
             pheno_num <<- append(pheno_num, col_num,
                                 after = length(pheno_num))
           }
         })
)

for(i in pheno_num){
  print( colnames(phenoData)[i])
  print(table(phenoData[,i]))
}

table(phenoData[,"SMATSSCR"])
Sever_ID <-  rownames(phenoData)[phenoData[, "SMATSSCR"] == 3]
table(phenoData[Sever_ID, "SMTS"])

Moderate_ID <-  rownames(phenoData)[phenoData[, "SMATSSCR"]==2]
table(phenoData[Moderate_ID, "SMTS"])

Mild_ID <-  rownames(phenoData)[phenoData[, "SMATSSCR"] == 1]
table(phenoData[Mild_ID, "SMTS"])

raw_data <- as.data.frame(t(log10(raw_data + 1)))
raw_data$SMTSD <- phenoData$SMTSD

raw_data <- raw_data[!(rownames(raw_data) %in% Sever_ID),]

library(ggpubr)
ggbarplot(raw_data, x = "SMTSD", y = "NEAT1",
          fill = "grey",
          color = "black",
          add = c("mean_range", "point"),
          error.plot = "upper_errorbar",
          desc_stat = "mean_sd",
          x.text.angle = 75,
          title = "NEAT1 expression in different normal human tissues",
          ylab = "Relative expression of NEAT1",
          xlab = "",
          width = 0.6
          )+
  ylim(0, 7.5) +
  theme(axis.title = element_text(size = 11, color = "black", face = "bold"),
        axis.text = element_text(size = 9, color = "black"),
        title = element_text(size = 15, color = "black"),
        plot.title = element_text(hjust = 0.5))

# step2 Tumor

Rdata_file <- './data/TCGA.PAN.NEAT1.Rdata'
if(!file.exists(Rdata_file)){
  destfile <-  './raw_data/EB++AdjustPANCAN_IlluminaHiseq_RNASeqV2.genExp.xena.gz'
  library(R.utils)
  gunzip(destfile, remove = FALSE)
  
  library(data.table)
  raw_data <- fread('./raw_data/EB++AdjustPANCAN_IlluminaHiseq_RNASeqV2.genExp.xena.gz',
                    sep = ' ',header = T)
  raw_data <- as.data.frame(raw_data)
  raw_data <- raw_data[raw_data[,1] == 'NEAT1',]
  raw_data[1,1:10]
  rownames(raw_data) <- 'NEAT1'
  raw_data <- raw_data[,-1]
  raw_data[1,1:10]
  dim(raw_data)
  save(raw_data, file = Rdata_file)
}else{
  load(Rdata_file)
}

Rdata_file <- './data/TCGA.Pheno.Rdata'
if(!file.exists(Rdata_file)){
  destfile <-  './raw_data/TCGA_phenotype_denseDataOnlyDownload.tsv.gz'
  
  phenoData <-  read.table(destfile,
                           header = T,
                           sep = ' ',
                           quote = '')
  phenoData[1:5, 1:4]
  dim(phenoData)
  rownames(phenoData) <-phenoData[,1]
  phenoData <- phenoData[colnames(raw_data),]
  dim(phenoData)
  phenoData[1:10, ]
  colnames(phenoData)
  save(phenoData, file = Rdata_file)
}else{
  load(Rdata_file)
}

for(i in 1:4){
  print(colnames(phenoData)[i])
  print(table(phenoData[, i]))
}

raw_data <- as.data.frame(t(raw_data))
raw_data$type <-  ifelse(phenoData$sample_type_id < 10, "tumor", "normal")
table(raw_data$type)
raw_data$disease <- phenoData$X_primary_disease

raw_data[1:6, 1:3]

raw_data <- raw_data[!is.na(raw_data$type), ]

sub.disease <-  split(raw_data, raw_data$disease)
length(sub.disease)

# graph in part
for(i in 1:length(sub.disease)){
  if(length(table(sub.disease[[i]]$type)) == 2){
    p.v <-  compare_means(NEAT1~type, data = sub.disease[[i]])$p
    if(p.v <0.05){
      disease <- sub.disease[[i]]$disease[1]
      title <- paste('The expression of NEAT1 in', disease, sep = '')
      p <- ggboxplot(sub.disease[[i]], x = "type", y = "NEAT1",
                     title = title,
                     ylab = "Relative expression of NEAT1",
                     xlab = "",
                     color = "type",
                     palette = "jco")
      p + stat_compare_means(label.y = 18) +
        theme(plot.title = element_text(hjust = 0.5))
      ggsave(filename = paste('./fig/tmp', i, '.png', sep = ''))
    }
  }
}


# graph in sum
new_data <-  data.frame(NEAT1 = 0, type = '', disease = '')
new_data = new_data[-1,]
for(i in 1:length(sub.disease)){
  if(length(table(sub.disease[[i]]$type)) == 2){
    p.v <- compare_means(NEAT1~type, data = sub.disease[[i]])$p
    if(p.v <0.05){
      new_data <- rbind(sub.disease[[i]], new_data)
    }
  }
}

library(ggpubr)
ggboxplot(new_data, x = "type", y = "NEAT1",
          title = "The expression of NEAT1 in different tumors leveraging RNA-seq data from TCGA",
          ylab = "Relative expression of NEAT1",
          xlab = "",
          facet.by = "diseaes",
          color = "type",
          palette = "jco")+
  stat_compare_means(label.y = 6) +
  ylim(5, 18)+
  theme(plot.title = element_text(hjust = 0.5))