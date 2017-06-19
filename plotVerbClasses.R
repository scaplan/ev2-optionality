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

output_factives = paste(output_class_name,'_factive_vs_nonfactive_ev2Mean.png',sep="")
output_sampleAssertNonAssert = paste(output_class_name,'_assert_vs_nonassert_negation_individualVerbs_ev2Mean.png',sep="")
output_assertNonAssert = paste(output_class_name,'_assert_vs_nonassert_negation_ev2Mean.png',sep="")

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


a_verbs <- data[data$Category == 'A', ]
#a_verbs <- data[data[,13] == 'A',]
a_verbs_ev2Raw = a_verbs$X8.p.ev2.matrix.
a_verbs_ev2Sorted  = sort(a_verbs_ev2Raw, decreasing = TRUE)
b_verbs <- data[data$Category == 'B', ] #<- data[data[,13] == 'B',]
b_verbs_ev2Raw = b_verbs$X8.p.ev2.matrix.
b_verbs_ev2Sorted  = sort(b_verbs_ev2Raw, decreasing = TRUE)
c_verbs <- data[data$Category == 'C', ]
c_verbs_ev2Raw = c_verbs$X8.p.ev2.matrix.
c_verbs_ev2Sorted  = sort(c_verbs_ev2Raw, decreasing = TRUE)
d_verbs <- data[data$Category == 'D', ]
d_verbs_ev2Raw = d_verbs$X8.p.ev2.matrix.
d_verbs_ev2Sorted  = sort(d_verbs_ev2Raw, decreasing = TRUE)
e_verbs <- data[data$Category == 'E', ]
e_verbs_ev2Raw = e_verbs$X8.p.ev2.matrix.
e_verbs_ev2Sorted  = sort(e_verbs_ev2Raw, decreasing = TRUE)


## Assertion_verbs A,B,E
#assert_verbs <- data[which( data$Category == 'A' | data$Category == 'B' | data$Category == 'E'), ]
assert_verbs <- data[which( data$Category == 'A' | data$Category == 'B'), ]
## Non-assert_verbs C,D
nonassert_verbs <- data[which( data$Category == 'C' | data$Category == 'D'), ]

cat(sprintf("assert_verbs mean rate ev2: %s\n", mean(assert_verbs$X8.p.ev2.matrix.)))
cat(sprintf("nonassert_verbs mean rate ev2: %s\n", mean(nonassert_verbs$X8.p.ev2.matrix.)))

assert_neg_total_diagnostic = sum(assert_verbs$X9.NegatedCanTellIfRaised)
assert_neg_raised = sum(assert_verbs$X11.c.ev2.NegatedMatrix.)
assert_neg_ev2 = assert_neg_raised / assert_neg_total_diagnostic
cat(sprintf("assert_neg_total_diagnostic: %s\n", assert_neg_total_diagnostic))
cat(sprintf("assert_neg_raised: %s\n", assert_neg_raised))
cat(sprintf("assert_neg_ev2: %s\n", assert_neg_ev2))

assert_nonneg_total_diagnostic = sum(assert_verbs$X10.nonNegCanTellIfRaised)
assert_nonneg_raised = sum(assert_verbs$X12.c.ev2.NonNegMatrix.)
assert_nonneg_ev2 = assert_nonneg_raised / assert_nonneg_total_diagnostic
cat(sprintf("assert_nonneg_total_diagnostic: %s\n", assert_nonneg_total_diagnostic))
cat(sprintf("assert_nonneg_raised: %s\n", assert_nonneg_raised))
cat(sprintf("assert_nonneg_ev2: %s\n", assert_nonneg_ev2))


nonassert_neg_total_diagnostic = sum(nonassert_verbs$X9.NegatedCanTellIfRaised)
nonassert_neg_raised = sum(nonassert_verbs$X11.c.ev2.NegatedMatrix.)
nonassert_neg_ev2 = nonassert_neg_raised / assert_neg_total_diagnostic
cat(sprintf("nonassert_neg_total_diagnostic: %s\n", nonassert_neg_total_diagnostic))
cat(sprintf("nonassert_neg_raised: %s\n", nonassert_neg_raised))
cat(sprintf("nonassert_neg_ev2: %s\n", nonassert_neg_ev2))

nonassert_nonneg_total_diagnostic = sum(nonassert_verbs$X10.nonNegCanTellIfRaised)
nonassert_nonneg_raised = sum(nonassert_verbs$X12.c.ev2.NonNegMatrix.)
nonassert_nonneg_ev2 = nonassert_nonneg_raised / nonassert_nonneg_total_diagnostic
cat(sprintf("nonassert_nonneg_total_diagnostic: %s\n", nonassert_nonneg_total_diagnostic))
cat(sprintf("nonassert_nonneg_raised: %s\n", nonassert_nonneg_raised))
cat(sprintf("nonassert_nonneg_ev2: %s\n", nonassert_nonneg_ev2))

### Sig Testing
ev2_assert = assert_verbs$X14.p.ev2.NonNegMatrix.
ev2_negAssert = assert_verbs$X13.p.ev2.NegatedMatrix.
wilcox.test(ev2_assert,ev2_negAssert, paired=FALSE)

ev2_nonassert = nonassert_verbs$X14.p.ev2.NonNegMatrix.
ev2_negnonAssert = nonassert_verbs$X13.p.ev2.NegatedMatrix.
wilcox.test(ev2_nonassert,ev2_negnonAssert, paired=FALSE)

x <- c('1.Volunteer Stance', '2.Volunteer Stance (Negated)', '3.Response Stance', '4.Response-Stance (Negated)')
y <- c(assert_nonneg_ev2, assert_neg_ev2, nonassert_nonneg_ev2, nonassert_neg_ev2)
x_name <- "Stance"
y_name <- "ev2"
df <- data.frame(x,y)
names(df) <- c(x_name,y_name)
png(output_assertNonAssert, width=900, height=600)

theme_set(theme_gray(base_size = 20))
qplot(x=Stance, y=ev2, stat="identity", data=df, geom="bar", main=output_title, fill=factor(Stance)) + theme(legend.position="none") + 
						coord_cartesian(ylim=c(0,0.20)) + ylab("p(ev2|matrix)")

say <- data[data$X1.lemma == 'säga', ]
think <- data[data$X1.lemma == 'tänka', ]
know <- data[data$X1.lemma == 'veta', ]
forget <- data[data$X1.lemma == 'glömma', ]

x <- c('1.Say', '2.Not say', '3.Think', '4.Not think', '5.Know', '6.Not know', '7.Forget', '8.Not forget')
y <- c(say$X14.p.ev2.NonNegMatrix., say$X13.p.ev2.NegatedMatrix., think$X14.p.ev2.NonNegMatrix., think$X13.p.ev2.NegatedMatrix., know$X14.p.ev2.NonNegMatrix., know$X13.p.ev2.NegatedMatrix., forget$X14.p.ev2.NonNegMatrix., forget$X13.p.ev2.NegatedMatrix.)
x_name <- "Verb"
y_name <- "ev2"
df <- data.frame(x,y)
names(df) <- c(x_name,y_name)
png(output_sampleAssertNonAssert, width=900, height=600)

theme_set(theme_gray(base_size = 20))
qplot(x=Verb, y=ev2, stat="identity", data=df, geom="bar", main=output_title, fill=factor(Verb)) + theme(legend.position="none") + 
						coord_cartesian(ylim=c(0,0.25)) + ylab("p(ev2|matrix)")


fact_verbs <- data[data$Factive == 'fact',]
nonfact_verbs <- data[data$Factive == 'nf',]
cat(sprintf("Total fact_verbs: %s\n", nrow(fact_verbs)))
cat(sprintf("fact_verbs mean rate ev2: %s\n", mean(fact_verbs$X8.p.ev2.matrix.)))
cat(sprintf("Total nonfact_verbs: %s\n", nrow(nonfact_verbs)))
cat(sprintf("nonfact_verbs mean rate ev2: %s\n", mean(nonfact_verbs$X8.p.ev2.matrix.)))

ev2_factive = fact_verbs$X8.p.ev2.matrix.
ev2_nonfactive = nonfact_verbs$X8.p.ev2.matrix.
wilcox.test(ev2_factive,ev2_nonfactive, paired=FALSE)

x <- c('Factive','Non-Factive')
y <- c(mean(fact_verbs$X8.p.ev2.matrix.), mean(nonfact_verbs$X8.p.ev2.matrix.))
x_name <- "Factivity"
y_name <- "ev2"
df <- data.frame(x,y)
names(df) <- c(x_name,y_name)

png(output_factives)

theme_set(theme_gray(base_size = 20))
qplot(x=Factivity, y=ev2, stat="identity", data=df, geom="bar", main=output_title, fill=factor(Factivity)) + theme(legend.position="none") + 
						coord_cartesian(ylim=c(0,0.3)) + ylab("p(ev2|matrix)") #xlab("Verb Class (Factivity)")

means<-aggregate(data,by=list(data$Category),mean)
extractedMeans<-means[,c(1,9)]

a_verb_freq = sum(a_verbs$X6.numCanTellIfRaised)
b_verb_freq = sum(b_verbs$X6.numCanTellIfRaised)
c_verb_freq = sum(c_verbs$X6.numCanTellIfRaised)
d_verb_freq = sum(d_verbs$X6.numCanTellIfRaised)
e_verb_freq = sum(e_verbs$X6.numCanTellIfRaised)

total_verb_freq = sum(a_verb_freq,b_verb_freq,c_verb_freq,d_verb_freq,e_verb_freq)

a_verb_prop = a_verb_freq / total_verb_freq
b_verb_prop = b_verb_freq / total_verb_freq
c_verb_prop = c_verb_freq / total_verb_freq
d_verb_prop = d_verb_freq / total_verb_freq
e_verb_prop = e_verb_freq / total_verb_freq

x <- c('A(say)','B(believe)','C(deny)','D(resent)','E(know)')
y <- c(a_verb_prop, b_verb_prop, c_verb_prop, d_verb_prop, e_verb_prop)

x_name <- "Class"
y_name <- "Freq"
df <- data.frame(x,y)
names(df) <- c(x_name,y_name)


output_class_prop = paste(output_class_name,'_propportion_of_corpus_by_class.png',sep="")
png(output_class_prop)

theme_set(theme_gray(base_size = 18))
qplot(x=Class, y=Freq, stat="identity", data=df, geom="bar", main=output_title, fill=factor(Class)) + theme(legend.position="none") + 
 						coord_cartesian(ylim=c(0,0.5)) + xlab("Verb Class (H&T)") + ylab("Proportion of tagged corpus") + theme(text = element_text(size=18))
#####

#x <- c('A','B','C','D','E') Change this to be the labels I want
x <- c('A(say)','B(believe)','C(deny)','D(resent)','E(know)')
y <- c(mean(a_verbs$X8.p.ev2.matrix.), mean(b_verbs$X8.p.ev2.matrix.), mean(c_verbs$X8.p.ev2.matrix.), mean(d_verbs$X8.p.ev2.matrix.), mean(e_verbs$X8.p.ev2.matrix.))

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

theme_set(theme_gray(base_size = 18))
qplot(x=Class, y=ev2, stat="identity", data=df, geom="bar", main=output_title, fill=factor(Class)) + theme(legend.position="none") + 
 						coord_cartesian(ylim=c(0,0.15)) + xlab("Verb Class (H&T)") + ylab("p(ev2|matrix)") + theme(text = element_text(size=18))

# # also plot verb class ranks here
png(output_A_verbs)
plot(seq_along(a_verbs_ev2Sorted), unclass(a_verbs_ev2Sorted), xlab="Rank", ylab="P(ev2|matrix)", cex=1.5)
title(main = "Rank vs. p(ev2) for Class A (say) verbs", cex=1.5)
png(output_B_verbs)
plot(seq_along(b_verbs_ev2Sorted), unclass(b_verbs_ev2Sorted), xlab="Rank", ylab="P(ev2|matrix)")
title(main = "Rank vs. p(ev2) for Class B (believe) verbs", cex=1.5)
png(output_C_verbs)
plot(seq_along(c_verbs_ev2Sorted), unclass(c_verbs_ev2Sorted), xlab="Rank", ylab="P(ev2|matrix)")
title(main = "Rank vs. p(ev2) for Class C (deny) verbs", cex=1.5)
png(output_D_verbs)
plot(seq_along(d_verbs_ev2Sorted), unclass(d_verbs_ev2Sorted), xlab="Rank", ylab="P(ev2|matrix)")
title(main = "Rank vs. p(ev2) for Class D (resent) verbs", cex=1.5)
png(output_E_verbs)
plot(seq_along(e_verbs_ev2Sorted), unclass(e_verbs_ev2Sorted), xlab="Rank", ylab="P(ev2|matrix)")
title(main = "Rank vs. p(ev2) for Class E (know) verbs", cex=1.5)