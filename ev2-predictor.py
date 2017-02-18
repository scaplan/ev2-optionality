#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, math
reload(sys)
sys.setdefaultencoding('utf-8')
import unicodedata
from unicodedata import normalize

def evalSentence(words, tags, sentenceWithTags):
	if ("att" in words) and (tags.count("VB") > 1):
		global numRetainedSentences
		numRetainedSentences += 1

		for currWord, currPOS in sentenceWithTags:
			print currWord + ' ' + str(currPOS)

	else:
		global numDiscardedSentences
		numDiscardedSentences += 1

def interateCorpus(fileName):
	totalTokens = 0
	typeDict = {}

	with open(fileName, 'r') as currFile:
		currSentence = []
		currTags = []
		currSentenceWithPOS = []
		for currLine in currFile:
			if not currLine:
				continue
			currLineTokens = currLine.split()
			if currLineTokens[0] == "</sentence>":
				# we've finished the previous sentence so we should 
				# pass the sentence to the evaluation function
				# and then clear the "currSentence" list
				evalSentence(currSentence, currTags, currSentenceWithPOS)
				currSentence = []
				currTags = []
				currSentenceWithPOS = []

			# check if we're reading in a word
			if currLineTokens[0] == "<w":
				currPosRaw = currLineTokens[1]
				currWordRaw = currLineTokens[-1]

				currWordClean = currWordRaw[currWordRaw.find(">")+1:currWordRaw.find("<")]
				currWordClean = currWordClean.lower()
				currPosClean = currPosRaw[currPosRaw.find("\"")+1:-1]
				currPair = (currWordClean, currPosClean)

				if (currWordRaw in typeDict):
					typeDict[currWordRaw] = typeDict[currWordRaw] + 1
				else:
					typeDict[currWordRaw] = 1
				totalTokens += 1
				currSentence.append(currWordClean)
				currTags.append(currPosClean)
				currSentenceWithPOS.append(currPair)
			# else continue
			# print currLine
	print (str(totalTokens) + ' total tokens')
	print (str(len(typeDict)) + ' total types')

##
## Main method block
##
if __name__=="__main__":

	if (len(sys.argv) < 2):
		print('incorrect number of arguments')
		exit(0)

	fileName = sys.argv[1]

	numRetainedSentences = 0
	numDiscardedSentences = 0
	
	interateCorpus(fileName)

	print (str(numRetainedSentences) + " sentences contain overt \'att\' and multiple verbs")
	print (str(numDiscardedSentences) + " sentences do not")