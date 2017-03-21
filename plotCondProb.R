## Import (packages)
library(scales)
library(ggplot2)
library(Hmisc)
source("these-are-our-r-functions.R")

## Parse input args
args = commandArgs(trailingOnly=TRUE)
orig_csv = args[1]
output_name = args[2]

## Read in data
data=read.csv(orig_csv,header=T,sep = "")

colnames(data)
cat(sprintf("Total verbs: %s\n", nrow(data)))
#print(data$ev2GivenMatrix)

dataClean <- data[data[,5]>1,]
cat(sprintf("Verbs with ev2: %s\n", nrow(dataClean)))

png(output_name)

dataClean$logEcGivenMatrix = log(dataClean$ecGivenMatrix)
dataClean$logEv2GivenMatrixProb = log(dataClean$ev2GivenMatrixProb)

#agroed_data = aggrdata_exact_numgroups(dataClean$logEcGivenMatrix, dataClean$logEv2GivenMatrixProb, 20)
#print(agroed_data)
#colnames(agroed_data)

attach(dataClean)
#ggplot(dataClean, aes(ev2GivenMatrixProb, ecGivenMatrix), size=2, position = position_jitter(x = 2,y = 2) ) + geom_jitter(colour=alpha("black",0.15)) + geom_smooth(method=lm)
ggplot(dataClean, aes(logEv2GivenMatrixProb, logEcGivenMatrix), size=2, position = position_jitter(x = 2,y = 2) ) + geom_jitter(colour=alpha("black",0.15)) + geom_smooth(method=lm)

dev.off()

#lm(formula = ecGivenMatrix ~ ev2GivenMatrixProb, data = dataClean)