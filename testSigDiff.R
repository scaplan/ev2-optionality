## Import (packages)
library(scales)
library(ggplot2)
library(Hmisc)

## Parse input args
args = commandArgs(trailingOnly=TRUE)
orig_csv_A = args[1]
orig_csv_B = args[2]

data_A=read.csv(orig_csv_A,header=T,sep = "")
data_B=read.csv(orig_csv_B,header=T,sep = "")

#data_A

#dataClean_A <- data_A[data_A[,7]>2,]
#dataClean_A <- data_A[data_B[,7]>-1,]
#cat(sprintf("data_A Verbs with ev2 at least three times: %s\n", nrow(dataClean_A)))
#dataClean_B <- data_B[data_B[,7]>-1,]
#cat(sprintf("data_B Verbs with ev2 at least three times: %s\n", nrow(dataClean_B)))

#dataDoubleClean_A <- dataClean_A[dataClean_A[,6]>=50,]
dataDoubleClean_A <- data_A[data_B[,6]>=15,]
cat(sprintf("data_A lemmas with numCanTellIfRaised at least 10: %s\n", nrow(dataDoubleClean_A)))
dataDoubleClean_B <- data_B[data_B[,6]>=15,]
cat(sprintf("data_B lemmas with numCanTellIfRaised at least 10: %s\n", nrow(dataDoubleClean_B)))

ev2_A = dataDoubleClean_A$X8.p.ev2.matrix.
ev2_B = dataDoubleClean_B$X8.p.ev2.matrix.

mean(ev2_A)
mean(ev2_B)

wilcox.test(ev2_A,ev2_B, paired=TRUE)

#ev2RankDataRaw = dataCleanMinEC$X8.p.ev2.matrix.