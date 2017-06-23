## Import (packages)
library(scales)
library(dplyr)
library(tidyr)
library(ggplot2)
#library(Hmisc)

## Parse input args
args = commandArgs(trailingOnly=TRUE)
orig_csv = args[1]
output_title = args[2]
output_name = args[3]

output_factives = paste(output_name,'-factive-vs-nonfactive-ev2Mean.png',sep="")
output_class_name = paste(output_name,'-verbSemanticClass-plot.png',sep="")
output_sampleAssertNonAssert = paste(output_name,'-assert-vs-nonassert-negation-individualVerbs-ev2Mean.png',sep="")
output_assertNonAssert = paste(output_name,'-assert-vs-nonassert-negation-ev2Mean.png',sep="")

output_A_verbs = paste(output_name,'-A-verbs-ev2ByRank.png',sep="")
output_B_verbs = paste(output_name,'-B-verbs-ev2ByRank.png',sep="")
output_C_verbs = paste(output_name,'-C-verbs-ev2ByRank.png',sep="")
output_D_verbs = paste(output_name,'-D-verbs-ev2ByRank.png',sep="")
output_E_verbs = paste(output_name,'-E-verbs-ev2ByRank.png',sep="")

## Read in data
dat=read.csv(orig_csv,header=T,sep = ",")
#head(data)

output_title
# corporaList=("academy-humanities" "attasidor" "familjeliv-allmanna-noje" "kubhist-gotlandstidning-1870" "kubhist-postochinrikestidning-1860" "familjeliv-adoption" "familjeliv-kansliga" "familjeliv-expert" "sweacsam" "rd-skfr" "rd-bet" "rd-ds" "rd-eun" "rd-fpm" "bloggmix-merged")

if (output_title == 'flashback-politik') {
	graph_title = "Online Forum"
} else {
	graph_title = output_title
}

colnames(dat)


definedFactRows <- dat[which( dat$X4.factive == 'fact' | dat$X4.factive == 'nf'), ]

definedFactRows %>%
  group_by(X4.factive)%>%
  mutate(raised = -as.numeric(X3.raised)+2,
         sd = sd(raised),
         se = sd(raised)/sqrt(length(raised))) %>%
  count(raised, sd, se) %>%
  ungroup() %>%
  group_by(X4.factive) %>%
  mutate(prop = n/sum(n)) -> dat2

myplot <- ggplot(data=subset(dat2, raised==1), aes(x=X4.factive, y=prop, fill=X4.factive)) +
  geom_bar(stat='identity', alpha=.5) +
  geom_errorbar(aes(ymin=prop-se, ymax=prop+se), width=.5, size=.5) +
  labs(x='\nFactivity', y='Proportion EV2\n', title=graph_title) +
  scale_fill_manual(name="Factivity", 
                    labels=c("Factive", "Non-Factive"),
                    breaks=c("fact", "nf"),
                    values=c("blue", "red")) +
  theme_bw() +
  theme(text=element_text(size=20))

png(output_factives, height=600, width=900)
print(myplot)
dev.off()

#quit()

definedClassRows <- dat[which( dat$X5.category == 'A' | dat$X5.category == 'B' | dat$X5.category == 'C' | dat$X5.category == 'D' | dat$X5.category == 'E'), ]
definedClassRows %>%
  group_by(X5.category)%>%
  mutate(raised = -as.numeric(X3.raised)+2,
         sd = sd(raised),
         se = sd(raised)/sqrt(length(raised))) %>%
  count(raised, sd, se) %>%
  ungroup() %>%
  group_by(X5.category) %>%
  mutate(prop = n/sum(n)) -> datCategory

categoryPlot <- ggplot(data=subset(datCategory, raised==1), aes(x=X5.category, y=prop, fill=X5.category)) +
  geom_bar(stat='identity', alpha=.5) +
  geom_errorbar(aes(ymin=prop-se, ymax=prop+se), width=.5, size=.5) +
  labs(x='\nSemantic Category (H&T)', y='Proportion EV2\n', title=graph_title) +
  scale_fill_manual(name="Category", 
  					labels=c("Say(A)", "Believe(B)","Deny(C)","Resent(D)","Know(E)"),
  					breaks=c("A", "B","C","D","E"),
  					values=c("blue","blue","red","red","blue")) +
  theme_bw() +
  theme(text=element_text(size=20))

png(output_class_name, height=600, width=900)
print(categoryPlot)
dev.off()



definedAssertRows <- dat[which( dat$X5.category == 'A' | dat$X5.category == 'B'), ]
definedAssertRows %>%
  group_by(X2.negated)%>%
  mutate(raised = -as.numeric(X3.raised)+2,
         sd = sd(raised),
         se = sd(raised)/sqrt(length(raised))) %>%
  count(raised, sd, se) %>%
  ungroup() %>%
  group_by(X2.negated) %>%
  mutate(prop = n/sum(n)) -> datAssertNegNonNeg

assertNegationNonNegPlot <- ggplot(data=subset(datAssertNegNonNeg, raised==1), aes(x=X2.negated, y=prop, fill=X2.negated)) +
  geom_bar(stat='identity', alpha=.5) +
  geom_errorbar(aes(ymin=prop-se, ymax=prop+se), width=.5, size=.5) +
  labs(x='\nNegated and Non-negated Volunteer Stance Predicates', y='Proportion EV2\n', title=graph_title) +
  scale_fill_manual(name="Negation", 
  					labels=c("Non-Negated", "Negated"),
  					breaks=c("nonneg", "negated"),
  					values=c("blue","red")) +
  theme_bw() +
  theme(text=element_text(size=20))

png(output_assertNonAssert, height=600, width=900)
print(assertNegationNonNegPlot)
dev.off()