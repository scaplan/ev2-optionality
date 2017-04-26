## Import (packages)
library(scales)
library(ggplot2)
library(Hmisc)

## Parse input args
args = commandArgs(trailingOnly=TRUE)
orig_csv = args[1]
output_title = args[2]
output_name = args[3]
output_class_name = args[4]

output_A_verbs = paste(output_class_name,'_A_verbs_ev2ByRank.png',sep="")
output_B_verbs = paste(output_class_name,'_B_verbs_ev2ByRank.png',sep="")
output_C_verbs = paste(output_class_name,'_C_verbs_ev2ByRank.png',sep="")
output_D_verbs = paste(output_class_name,'_D_verbs_ev2ByRank.png',sep="")
output_E_verbs = paste(output_class_name,'_E_verbs_ev2ByRank.png',sep="")

## Read in data
data=read.csv(orig_csv,header=T,sep = "")

output_title

colnames(data)
cat(sprintf("Total verbs: %s\n", nrow(data)))

a_verbs <- data[data[,13] == 'A',]
a_verbs_ev2Raw = a_verbs$X8.p.ev2.matrix.
a_verbs_ev2Sorted  = sort(a_verbs_ev2Raw, decreasing = TRUE)
b_verbs <- data[data[,13] == 'B',]
b_verbs_ev2Raw = b_verbs$X8.p.ev2.matrix.
b_verbs_ev2Sorted  = sort(b_verbs_ev2Raw, decreasing = TRUE)
c_verbs <- data[data[,13] == 'C',]
c_verbs_ev2Raw = c_verbs$X8.p.ev2.matrix.
c_verbs_ev2Sorted  = sort(c_verbs_ev2Raw, decreasing = TRUE)
d_verbs <- data[data[,13] == 'D',]
d_verbs_ev2Raw = d_verbs$X8.p.ev2.matrix.
d_verbs_ev2Sorted  = sort(d_verbs_ev2Raw, decreasing = TRUE)
e_verbs <- data[data[,13] == 'E',]
e_verbs_ev2Raw = e_verbs$X8.p.ev2.matrix.
e_verbs_ev2Sorted  = sort(e_verbs_ev2Raw, decreasing = TRUE)


fact_verbs <- data[data[,14] == 'fact',]
nonfact_verbs <- data[data[,14] == 'nf',]
cat(sprintf("Total fact_verbs: %s\n", nrow(fact_verbs)))
cat(sprintf("Total nonfact_verbs: %s\n", nrow(nonfact_verbs)))

means<-aggregate(data,by=list(data$Category),mean)
extractedMeans<-means[,c(1,9)]

#x <- c('A','B','C','D','E') Change this to be the labels I want
x <- c('say(-class)','believe(-class)','deny(-class)','resent(-class)','know(-class)')
y <- c(mean(a_verbs$X8.p.ev2.matrix.), mean(b_verbs$X8.p.ev2.matrix.), mean(c_verbs$X8.p.ev2.matrix.), mean(d_verbs$X8.p.ev2.matrix.), mean(e_verbs$X8.p.ev2.matrix.))

#x <- c('Factive','Non-Factive')
#y <- c(mean(fact_verbs$X8.p.ev2.matrix.), mean(nonfact_verbs$X8.p.ev2.matrix.))

x_name <- "Class"
y_name <- "ev2"
df <- data.frame(x,y)
names(df) <- c(x_name,y_name)

cat(sprintf("a_verbs: %s\n", nrow(a_verbs)))
mean(a_verbs$X8.p.ev2.matrix.)
sd(a_verbs$X8.p.ev2.matrix.)

cat(sprintf("b_verbs: %s\n", nrow(b_verbs)))
mean(b_verbs$X8.p.ev2.matrix.)
sd(b_verbs$X8.p.ev2.matrix.)

cat(sprintf("c_verbs: %s\n", nrow(c_verbs)))
mean(c_verbs$X8.p.ev2.matrix.)
sd(c_verbs$X8.p.ev2.matrix.)

cat(sprintf("d_verbs: %s\n", nrow(d_verbs)))
mean(d_verbs$X8.p.ev2.matrix.)
sd(d_verbs$X8.p.ev2.matrix.)

cat(sprintf("e_verbs: %s\n", nrow(e_verbs)))
mean(e_verbs$X8.p.ev2.matrix.)
sd(e_verbs$X8.p.ev2.matrix.)

png(output_name)

qplot(x=Class, y=ev2, stat="identity", data=df, geom="bar", main=output_title, fill=factor(Class)) + theme(legend.position="none") + 
						coord_cartesian(ylim=c(0,0.2)) + xlab("Verb Class (H&T)") + ylab("p(ev2|matrix)")
			#			coord_cartesian(ylim=c(0,0.3)) + xlab("Verb Class (Factivity)") + ylab("p(ev2|matrix)")

# also plot verb class ranks here
png(output_A_verbs)
plot(seq_along(a_verbs_ev2Sorted), unclass(a_verbs_ev2Sorted), xlab="Rank", ylab="P(ev2|matrix)")
title(main = "Rank vs. p(ev2) for Class A (say) verbs")
png(output_B_verbs)
plot(seq_along(b_verbs_ev2Sorted), unclass(b_verbs_ev2Sorted), xlab="Rank", ylab="P(ev2|matrix)")
title(main = "Rank vs. p(ev2) for Class B (believe) verbs")
png(output_C_verbs)
plot(seq_along(c_verbs_ev2Sorted), unclass(c_verbs_ev2Sorted), xlab="Rank", ylab="P(ev2|matrix)")
title(main = "Rank vs. p(ev2) for Class C (deny) verbs")
png(output_D_verbs)
plot(seq_along(d_verbs_ev2Sorted), unclass(d_verbs_ev2Sorted), xlab="Rank", ylab="P(ev2|matrix)")
title(main = "Rank vs. p(ev2) for Class D (resent) verbs")
png(output_E_verbs)
plot(seq_along(e_verbs_ev2Sorted), unclass(e_verbs_ev2Sorted), xlab="Rank", ylab="P(ev2|matrix)")
title(main = "Rank vs. p(ev2) for Class E (know) verbs")