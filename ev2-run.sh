#!/bin/bash  

scriptSource='/home/spencer/Dropbox/penn_CS_account/ev2-optionality/'
directorySource='/home/spencer/Documents/Swedish-ev2-corpora/'
resultSource='/home/spencer/Dropbox/penn_CS_account/ev2-optionality/output/'

declare -a corporaList
corporaList=("attasidor")

cd $scriptSource

currCorpusSource=''

for currCorpus in "${corporaList[@]}"; do

	currCorpus=$directorySource$currCorpus".xml"
	echo 'Evaluating over: ' $currCorpus

	python ev2-predictor.py $currCorpus

done