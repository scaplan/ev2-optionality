#!/bin/bash  

scriptSource='/home1/s/spcaplan/Dropbox/penn_CS_account/ev2-optionality/'
directorySource='/mnt/nlpgridio2/nlp/users/spcaplan/swed-corpora/'
#directorySource='/mnt/nlpgridio2/nlp/users/spcaplan/swed-corpora/flashback-politik/'
#resultSource='/home1/s/spcaplan/Dropbox/penn_CS_account/ev2-optionality/output/'
resultSource='/mnt/nlpgridio2/nlp/users/spcaplan/swed-output-ev2/'
verbClassSource=$scriptSource'verb_classes_KDSC.csv'

input="$1"

declare -a corporaList
#corporaList=("flashback-politik" "academy-humanities" "attasidor" "familjeliv-allmanna-noje" "kubhist-gotlandstidning-1870" "kubhist-postochinrikestidning-1860")
corporaList=("flashback-politik")
#corporaList=($input)

cd $scriptSource

currCorpusSource=''

for currCorpusName in "${corporaList[@]}"; do

	currCorpusPath=$directorySource$currCorpusName".xml"
	outputStatsFile=$resultSource$currCorpusName"_outputStats.txt"
	outputEv2File=$resultSource$currCorpusName"_ev2-vs-inSitu.txt"
	outputMatrixConditionsVerbFile=$resultSource$currCorpusName"_matrixVerbs-condition-relation.csv"
	outputMatrixConditionsLemmaFile=$resultSource$currCorpusName"_matrixLemmas-condition-relation.csv"
	outputMatrixConditionsLemmaFileWithClassInfo=$resultSource$currCorpusName"_matrixLemmas-condition-relation_withClassInfo.csv"
	outputPlotVerbsFile=$resultSource$currCorpusName"_verbs_plot"
	outputPlotLemmasFile=$resultSource$currCorpusName"_lemmas_plot"
	echo 'Evaluating over: ' $currCorpusPath

	#python ev2-predictor.py $currCorpusPath $outputStatsFile $outputEv2File $outputMatrixConditionsVerbFile $outputMatrixConditionsLemmaFile 'False'
	#python ev2-predictor.py $currCorpusPath $outputStatsFile $outputEv2File $outputMatrixConditionsVerbFile $outputMatrixConditionsLemmaFile 'True'

	python merge_lemmas_with_classes.py $outputMatrixConditionsLemmaFile $verbClassSource $outputMatrixConditionsLemmaFileWithClassInfo

	#Rscript plotCondProb.R $outputMatrixConditionsVerbFile $outputPlotVerbsFile
	#Rscript plotCondProb.R $outputMatrixConditionsLemmaFile $outputPlotLemmasFile

	verbClassPlot=$resultSource$currCorpusName'_verbSemanticClass_plot.png'

	Rscript plotVerbClasses.R $outputMatrixConditionsLemmaFileWithClassInfo $currCorpusName $verbClassPlot

done