#!/bin/bash  

#scriptSource='/home/spencer/Dropbox/penn_CS_account/ev2-optionality/'
#directorySource='/home/spencer/Documents/Swedish-ev2-corpora/'
#resultSource='/home/spencer/Dropbox/penn_CS_account/ev2-optionality/output/'

scriptSource='/home1/s/spcaplan/Dropbox/penn_CS_account/ev2-optionality/'
#directorySource='/mnt/nlpgridio2/nlp/users/spcaplan/swed-corpora/attasidor/'
directorySource='/mnt/nlpgridio2/nlp/users/spcaplan/swed-corpora/flashback-politik/'
resultSource='/home1/s/spcaplan/Dropbox/penn_CS_account/ev2-optionality/output/'

declare -a corporaList
#corporaList=("attasidor")
corporaList=("flashback-politik")

cd $scriptSource

currCorpusSource=''

for currCorpusName in "${corporaList[@]}"; do

	currCorpusPath=$directorySource$currCorpusName".xml"
	outputStatsFile=$resultSource$currCorpusName"_outputStats.txt"
	outputEv2File=$resultSource$currCorpusName"_ev2-vs-inSitu.txt"
	outputMatrixConditionsFile=$resultSource$currCorpusName"_matrixVerbs-condition-relation.csv"
	outputPlotFile=$resultSource$currCorpusName"_plot_newDenom"
	echo 'Evaluating over: ' $currCorpusPath

	python ev2-predictor.py $currCorpusPath $outputStatsFile $outputEv2File $outputMatrixConditionsFile 'False'

	Rscript plotCondProb.R $outputMatrixConditionsFile $outputPlotFile

done