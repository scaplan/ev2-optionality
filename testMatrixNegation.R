## Import (packages)
library(scales)
library(ggplot2)
library(Hmisc)

## Parse input args
args = commandArgs(trailingOnly=TRUE)
orig_csv = args[1]

data=read.csv(orig_csv,header=T,sep = "")

#data

totalNumDiagnostic = sum(data$X6.numCanTellIfRaised)
totalRaised = sum(data$X7.c.ev2.matrix.)
totalProbEV2 = as.numeric(totalRaised) / as.numeric(totalNumDiagnostic)

cat(sprintf("totalRaised: %s\n", totalRaised))
cat(sprintf("totalNumDiagnostic: %s\n", totalNumDiagnostic))
cat(sprintf("totalProbEV2: %s\n", totalProbEV2))

totalNegatedDiagnostic = sum(data$X9.NegatedCanTellIfRaised)
totalNonNegDiagnostic = sum(data$X10.nonNegCanTellIfRaised)
totalNegatedRaised = sum(data$X11.c.ev2.NegatedMatrix.)
totalNonNegRaised = sum(data$X12.c.ev2.NonNegMatrix.)
totalNegatedInSitu = totalNegatedDiagnostic - totalNegatedRaised
totalNonNegInSitu = totalNonNegDiagnostic - totalNonNegRaised

totalNegatedProbEV2 = totalNegatedRaised / totalNegatedDiagnostic
totalNonNegProbEV2 = totalNonNegRaised / totalNonNegDiagnostic

cat(sprintf("totalNegatedRaised: %s\n", totalNegatedRaised))
cat(sprintf("totalNegatedInSitu: %s\n", totalNegatedInSitu))
cat(sprintf("totalNegatedDiagnostic: %s\n", totalNegatedDiagnostic))
cat(sprintf("totalNegatedProbEV2: %s\n", totalNegatedProbEV2))

cat(sprintf("totalNonNegRaised: %s\n", totalNonNegRaised))
cat(sprintf("totalNonNegDiagnostic: %s\n", totalNonNegDiagnostic))
cat(sprintf("totalNonNegProbEV2: %s\n", totalNonNegProbEV2))

data.allMatNeg <- c(totalNegatedInSitu, totalNegatedRaised, totalNonNegInSitu, totalNonNegRaised)
matrix.allMatNeg <- matrix(data.allMatNeg, nrow = 2, ncol = 2, byrow = TRUE)
matrix.allMatNeg
fisher.test(matrix.allMatNeg, alternative="two.sided")
cat(sprintf("\n\n"))

### -------------------------------------------------

fisherTestRow <- function(x) {

 currNegatedDiagnostic = x$X9.NegatedCanTellIfRaised
 currNonNegDiagnostic = x$X10.nonNegCanTellIfRaised
 currNegatedRaised = x$X11.c.ev2.NegatedMatrix.
 currNonNegRaised = x$X12.c.ev2.NonNegMatrix.
 currNegatedInSitu = currNegatedDiagnostic - currNegatedRaised
 currNonNegInSitu = currNonNegDiagnostic - currNonNegRaised

 currData <- c(currNegatedInSitu, currNegatedRaised, currNonNegInSitu, currNonNegRaised)
 currMatNeg <- matrix(currData, nrow = 2, ncol = 2, byrow = TRUE)
 fisherOutput <- fisher.test(currMatNeg, alternative="two.sided")
 pValue = fisherOutput$p.value
 confInt = fisherOutput$conf.int
 estimate = fisherOutput$estimate

 if(pValue < 0.05) {
 	cat(sprintf("Matrix Lemma: %s\n", x$X1.lemma))
	cat(sprintf("------------------------\n"))

	currNegatedProbEV2 = currNegatedRaised / currNegatedDiagnostic
 	currNonNegProbEV2 = currNonNegRaised / currNonNegDiagnostic

	cat(sprintf("currNegatedRaised: %s\n", currNegatedRaised))
 	cat(sprintf("currNegatedInSitu: %s\n", currNegatedInSitu))
 	cat(sprintf("currNegatedProbEV2: %s\n", currNegatedProbEV2))

 	cat(sprintf("currNonNegRaised: %s\n", currNonNegRaised))
 	cat(sprintf("currNonNegInSitu: %s\n", currNonNegInSitu))
 	cat(sprintf("currNonNegProbEV2: %s\n", currNonNegProbEV2))

 	out <- capture.output(currMatNeg)
 	cat(paste(out, collapse = "\n"))
 	cat(sprintf("\n"))

 	cat(sprintf("Fisher Test P-value: %s\n", pValue))
 	cat(sprintf("Confidence Interval: %s\n", confInt))
 	cat(sprintf("Estimated Odds Ratio: %s\n", estimate))
 	cat(sprintf("\n\n"))
 }

 return(pValue)
}


### -------------------------------------------------

invisible(by(data, 1:nrow(data), fisherTestRow))