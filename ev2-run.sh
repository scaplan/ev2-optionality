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

for currCorpus in "${corporaList[@]}"; do

	currCorpus=$directorySource$currCorpus".xml"
	echo 'Evaluating over: ' $currCorpus

	python ev2-predictor.py $currCorpus

done