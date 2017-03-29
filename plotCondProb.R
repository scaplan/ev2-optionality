## Import (packages)
library(scales)
library(ggplot2)
library(Hmisc)

## Parse input args
args = commandArgs(trailingOnly=TRUE)
orig_csv = args[1]
output_name = args[2]

output_nameMin5 = paste(output_name,'_min5.png',sep="")
output_name_freqRawRank = paste(output_name,'_ev2ByRank.png',sep="")
output_name_embed = paste(output_name,'_embedEv2ByRank.png',sep="")

## Read in data
data=read.csv(orig_csv,header=T,sep = "")

#data$ev2GivenMatrixCorrectProb=data$ev2GivenMatrix/data$numEC

colnames(data)
cat(sprintf("Total verbs: %s\n", nrow(data)))

dataCleanMin5 <- data[data[,7]>4,]
cat(sprintf("Verbs with ev2 at least five times: %s\n", nrow(dataCleanMin5)))

dataCleanMinEC <- data[data[,6]>=100,]
cat(sprintf("Lemmas with numCanTellIfRaised at least 100: %s\n", nrow(dataCleanMinEC)))

ev2RankDataRaw = dataCleanMinEC$X8.p.ev2.matrix.
ev2RankDataRawSorted = sort(ev2RankDataRaw, decreasing = TRUE)
ev2RankDataRawSorted

dataCleanMinEmbed <- data[data[,9]>999,] # X9.highestEmbedVerbCount
cat(sprintf("Lemmas with highestEmbedVerbCount at least 1000: %s\n", nrow(dataCleanMinEmbed)))
ev2EmbedRank = dataCleanMinEmbed$X12.p.ev2.embed.
ev2EmbedRankSorted = sort(ev2EmbedRank, decreasing = TRUE)

# Sort by p(ev2|lemma)
#png(output_name_freqRank)
#plot(seq_along(ev2RankDataSorted), unclass(ev2RankDataSorted), xlab="Rank", ylab="Log transformed P(ev2|matrix)")

png(output_name_freqRawRank)
plot(seq_along(ev2RankDataRawSorted), unclass(ev2RankDataRawSorted), xlab="Rank", ylab="P(ev2|matrix)")

png(output_name_embed)
plot(seq_along(ev2EmbedRankSorted), unclass(ev2EmbedRankSorted), xlab="Rank", ylab="P(ev2|embed)")

#png(output_name_freqRawScaledRank)
#plot(seq_along(ev2RankDataRawSortedScaled), unclass(ev2RankDataRawSortedScaled), xlab="Rank", ylab="P(matrix|ev2) freq. normed")

# Plot log(p(ev2)) by rank
dataCleanMin5$logX5.p.ec.matrix. = log(dataCleanMin5$X5.p.ec.matrix.)
dataCleanMin5$logX8.p.ev2.matrix. = log(dataCleanMin5$X8.p.ev2.matrix.)

png(output_nameMin5)
ggplot(dataCleanMin5, aes(X8.p.ev2.matrix., X5.p.ec.matrix., ) ) + geom_jitter(colour=alpha("black",0.15)) + geom_smooth(method=lm)
#ggplot(dataCleanMin5, aes(logX8.p.ev2.matrix., logX5.p.ec.matrix., ) ) + geom_jitter(colour=alpha("black",0.15)) + geom_smooth(method=lm)

message ("Finished")