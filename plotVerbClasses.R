## Import (packages)
library(scales)
library(ggplot2)
library(Hmisc)

## Parse input args
args = commandArgs(trailingOnly=TRUE)
orig_csv = args[1]
output_name = args[2]



## Read in data
data=read.csv(orig_csv,header=T,sep = "")

colnames(data)
cat(sprintf("Total verbs: %s\n", nrow(data)))

a_verbs <- data[data[,13] == 'A',]
b_verbs <- data[data[,13] == 'B',]
c_verbs <- data[data[,13] == 'C',]
d_verbs <- data[data[,13] == 'D',]
e_verbs <- data[data[,13] == 'E',]

means<-aggregate(data,by=list(data$Category),mean)
extractedMeans<-means[,c(1,9)]

x <- c('A','B','C','D','E')
y <- c(mean(a_verbs$X8.p.ev2.matrix.), mean(b_verbs$X8.p.ev2.matrix.), mean(c_verbs$X8.p.ev2.matrix.), mean(d_verbs$X8.p.ev2.matrix.), mean(e_verbs$X8.p.ev2.matrix.))

x_name <- "Class"
y_name <- "ev2"
df <- data.frame(x,y)
names(df) <- c(x_name,y_name)

# cat(sprintf("a_verbs: %s\n", nrow(a_verbs)))
# cat(sprintf("b_verbs: %s\n", nrow(b_verbs)))
# cat(sprintf("c_verbs: %s\n", nrow(c_verbs)))
# cat(sprintf("d_verbs: %s\n", nrow(d_verbs)))
# cat(sprintf("e_verbs: %s\n", nrow(e_verbs)))

# mean(a_verbs$X8.p.ev2.matrix.)
# mean(b_verbs$X8.p.ev2.matrix.)
# mean(c_verbs$X8.p.ev2.matrix.)
# mean(d_verbs$X8.p.ev2.matrix.)
# mean(e_verbs$X8.p.ev2.matrix.)

png(output_name)
qplot(x=Class, y=ev2, stat="identity", data=df, geom="bar", fill=factor(Class)) + theme(legend.position="none") + 
						coord_cartesian(ylim=c(0,0.3)) + xlab("Verb Class (H&T)") + ylab("p(ev2|matrix)")