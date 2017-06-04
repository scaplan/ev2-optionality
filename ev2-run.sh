#!/bin/bash  

scriptSource='/home1/s/spcaplan/Dropbox/penn_CS_account/ev2-optionality/'
directorySource='/mnt/nlpgridio2/nlp/users/spcaplan/swed-corpora/'
#directorySource='/mnt/nlpgridio2/nlp/users/spcaplan/swed-corpora/flashback-politik/'
#resultSource='/home1/s/spcaplan/Dropbox/penn_CS_account/ev2-optionality/output/'
resultSource='/mnt/nlpgridio2/nlp/users/spcaplan/swed-output-ev2/'
#verbClassSource=$scriptSource'verb_classes_KDSC.csv'
#verbClassSource=$scriptSource'verb_classes_lit_KDSC.csv'
verbClassSource=$scriptSource'verb_classes_all_KDSC.csv'

input="$1"

declare -a corporaList
#corporaList=("familjeliv-adoption" "familjeliv-kansliga" "familjeliv-expert" "sweacsam" "rd-skfr" "rd-bet" "rd-ds" "rd-eun" "rd-fpm" "bloggmix-merged")
#corporaList=("flashback-politik" "academy-humanities" "attasidor" "familjeliv-allmanna-noje" "kubhist-gotlandstidning-1870" "kubhist-postochinrikestidning-1860" "familjeliv-adoption" "familjeliv-kansliga" "familjeliv-expert" "sweacsam" "rd-skfr" "rd-bet" "rd-ds" "rd-eun" "rd-fpm" "bloggmix-merged")
#corporaList=("flashback-politik")
corporaList=("flashback-politik-mini")
#corporaList=($input)

cd $scriptSource

currCorpusSource=''

for currCorpusName in "${corporaList[@]}"; do

	currCorpusPath=$directorySource$currCorpusName".xml"
	outputStatsFile=$resultSource$currCorpusName"_outputStats.txt"
	outputEv2File=$resultSource$currCorpusName"_ev2-vs-inSitu.txt"
	outputMatrixConditionsVerbFile=$resultSource$currCorpusName"_matrixVerbs-condition-relation.csv"
	outputMatrixConditionsLemmaFile=$resultSource$currCorpusName"_matrixLemmas-condition-relation.csv"
	outputMatrixConditionsLemmaFileWithClassInfo=$resultSource$currCorpusName"_matrixLemmas-condition-relation_withClassInfo_all.csv"
	outputInterveneFile=$resultSource$currCorpusName"_interveningMaterial.csv"
	outputPlotVerbsFile=$resultSource$currCorpusName"_verbs_plot"
	outputPlotLemmasFile=$resultSource$currCorpusName"_lemmas_plot"
	echo 'Evaluating over: ' $currCorpusPath

	python ev2-predictor.py $currCorpusPath $outputStatsFile $outputEv2File $outputMatrixConditionsVerbFile $outputMatrixConditionsLemmaFile $outputInterveneFile 'False'
	#python ev2-predictor.py $currCorpusPath $outputStatsFile $outputEv2File $outputMatrixConditionsVerbFile $outputMatrixConditionsLemmaFile $outputInterveneFile 'True'

#	python merge_lemmas_with_classes.py $outputMatrixConditionsLemmaFile $verbClassSource $outputMatrixConditionsLemmaFileWithClassInfo

#	Rscript plotCondProb.R $outputMatrixConditionsVerbFile $outputPlotVerbsFile
#	Rscript plotCondProb.R $outputMatrixConditionsLemmaFile $outputPlotLemmasFile

#	verbClassPlotRoot=$resultSource$currCorpusName'_all'
#	verbClassPlot=$verbClassPlotRoot'_verbSemanticClass_plot.png'
	
#	Rscript plotVerbClasses.R $outputMatrixConditionsLemmaFileWithClassInfo $currCorpusName $verbClassPlot $verbClassPlotRoot

done