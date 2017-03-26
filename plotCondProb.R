## Import (packages)
library(scales)
library(ggplot2)
library(Hmisc)
source("these-are-our-r-functions.R")

## Parse input args
args = commandArgs(trailingOnly=TRUE)
orig_csv = args[1]
output_name = args[2]

output_nameMin1 = paste(output_name,'_min1.png',sep="")
output_nameMin2 = paste(output_name,'_min2.png',sep="")
output_nameMin5 = paste(output_name,'_min5.png',sep="")
output_nameMin10 = paste(output_name,'_min10.png',sep="")

## Read in data
data=read.csv(orig_csv,header=T,sep = "")

#data$ev2GivenMatrixCorrectProb=data$ev2GivenMatrix/data$numEC

colnames(data)
cat(sprintf("Total verbs: %s\n", nrow(data)))
#print(data$ev2GivenMatrix)

dataCleanMin1 <- data[data[,6]!=0,]
dataCleanMin2 <- data[data[,6]>1,]
dataCleanMin5 <- data[data[,6]>4,]
dataCleanMin10 <- data[data[,6]>9,]
cat(sprintf("Verbs with ev2 at least once: %s\n", nrow(dataCleanMin1)))
cat(sprintf("Verbs with ev2 at least twice: %s\n", nrow(dataCleanMin2)))
cat(sprintf("Verbs with ev2 at least five times: %s\n", nrow(dataCleanMin5)))
cat(sprintf("Verbs with ev2 at least five times: %s\n", nrow(dataCleanMin10)))

# dataCleanMin1$logX5.p.ec.matrix. = log(dataCleanMin1$X5.p.ec.matrix.)
# dataCleanMin1$logX7.p.ev2.matrix. = log(dataCleanMin1$ev2GivenMatrixCorrectProb)
# dataCleanMin2$logX5.p.ec.matrix. = log(dataCleanMin2$X5.p.ec.matrix.)
# dataCleanMin2$logX7.p.ev2.matrix. = log(dataCleanMin2$ev2GivenMatrixCorrectProb)
# dataCleanMin5$logX5.p.ec.matrix. = log(dataCleanMin5$X5.p.ec.matrix.)
# dataCleanMin5$logX7.p.ev2.matrix. = log(dataCleanMin5$ev2GivenMatrixCorrectProb)
# dataCleanMin10$logX5.p.ec.matrix. = log(dataCleanMin10$X5.p.ec.matrix.)
# dataCleanMin10$logX7.p.ev2.matrix. = log(dataCleanMin10$ev2GivenMatrixCorrectProb)

dataCleanMin1$logX5.p.ec.matrix. = log(dataCleanMin1$X5.p.ec.matrix.)
dataCleanMin1$logX7.p.ev2.matrix. = log(dataCleanMin1$X7.p.ev2.matrix.)
dataCleanMin2$logX5.p.ec.matrix. = log(dataCleanMin2$X5.p.ec.matrix.)
dataCleanMin2$logX7.p.ev2.matrix. = log(dataCleanMin2$X7.p.ev2.matrix.)
dataCleanMin5$logX5.p.ec.matrix. = log(dataCleanMin5$X5.p.ec.matrix.)
dataCleanMin5$logX7.p.ev2.matrix. = log(dataCleanMin5$X7.p.ev2.matrix.)
dataCleanMin10$logX5.p.ec.matrix. = log(dataCleanMin10$X5.p.ec.matrix.)
dataCleanMin10$logX7.p.ev2.matrix. = log(dataCleanMin10$X7.p.ev2.matrix.)

png(output_nameMin1)
#ggplot(dataCleanMin1, aes(X7.p.ev2.matrix., X5.p.ec.matrix.), size=2, position = position_jitter(x = 2,y = 2) ) + geom_jitter(colour=alpha("black",0.15)) + geom_smooth(method=lm)
ggplot(dataCleanMin1, aes(dataCleanMin1$logX7.p.ev2.matrix., dataCleanMin1$logX5.p.ec.matrix.), size=2, position = position_jitter(x = 2,y = 2) ) + geom_jitter(colour=alpha("black",0.15)) + geom_smooth(method=lm)
dev.off()
png(output_nameMin2)
#ggplot(dataCleanMin2, aes(X7.p.ev2.matrix., X5.p.ec.matrix.), size=2, position = position_jitter(x = 2,y = 2) ) + geom_jitter(colour=alpha("black",0.15)) + geom_smooth(method=lm)
ggplot(dataCleanMin2, aes(dataCleanMin2$logX7.p.ev2.matrix., dataCleanMin2$logX5.p.ec.matrix.), size=2, position = position_jitter(x = 2,y = 2) ) + geom_jitter(colour=alpha("black",0.15)) + geom_smooth(method=lm)
dev.off()
png(output_nameMin5)
#ggplot(dataCleanMin5, aes(X7.p.ev2.matrix., X5.p.ec.matrix.), size=2, position = position_jitter(x = 2,y = 2) ) + geom_jitter(colour=alpha("black",0.15)) + geom_smooth(method=lm)
ggplot(dataCleanMin5, aes(dataCleanMin5$logX7.p.ev2.matrix., dataCleanMin5$logX5.p.ec.matrix.), size=2, position = position_jitter(x = 2,y = 2) ) + geom_jitter(colour=alpha("black",0.15)) + geom_smooth(method=lm)
dev.off()
png(output_nameMin10)
#ggplot(dataCleanMin5, aes(X7.p.ev2.matrix., X5.p.ec.matrix.), size=2, position = position_jitter(x = 2,y = 2) ) + geom_jitter(colour=alpha("black",0.15)) + geom_smooth(method=lm)
ggplot(dataCleanMin10, aes(dataCleanMin10$logX7.p.ev2.matrix., dataCleanMin10$logX5.p.ec.matrix.), size=2, position = position_jitter(x = 2,y = 2) ) + geom_jitter(colour=alpha("black",0.15)) + geom_smooth(method=lm)
dev.off()


#lm(formula = X5.p.ec.matrix. ~ X7.p.ev2.matrix., data = dataClean)