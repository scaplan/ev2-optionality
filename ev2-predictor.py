#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, math
reload(sys)
sys.setdefaultencoding('utf-8')
import unicodedata
from unicodedata import normalize

def findAll(lst, value):
    return [i for i, x in enumerate(lst) if value==x]

def evalSentence(words, tags, sentenceWithTags):
	compInstances = findAll(words, 'att')
	origSentence = ""
	for currWord in words:
		origSentence += currWord + " "
	if (len(compInstances) > 0):

		# delete any instances of 'att' followed directly by VB (since that's a control structure rather than a complement)
		for index in compInstances:
			if index < len(words) - 1:
				followingTag = tags[index+1]
				if followingTag == "VB":
					del words[index+1]
					del words[index]
					del tags[index+1]
					del tags[index]
					del sentenceWithTags[index+1]
					del sentenceWithTags[index]

		nonControlCompInstances = findAll(words, 'att')
		verbInstances = findAll(tags, 'VB')

		if len(verbInstances) > len(nonControlCompInstances):
			if (len(nonControlCompInstances) > 1):
				global multipleComp
				multipleComp += 1
			elif (len(nonControlCompInstances) == 1):
				# just to keep things simple for now
				global numRetainedSentences
				numRetainedSentences += 1
				compIndex = nonControlCompInstances[0]
				matrixDomain = []
				embeddedDomain = []
				for verbIndex in verbInstances:
					if verbIndex < compIndex:
						matrixDomain.append(verbIndex)
					else:
						embeddedDomain.append(verbIndex)
				if (len(matrixDomain) > 0 and len(embeddedDomain) > 0):


					matrixVerbIndex = matrixDomain[-1]
					matrixVerb = words[matrixVerbIndex]
					embeddedVerbIndex = embeddedDomain[0]
					embeddedVerb = words[embeddedVerbIndex]
					if (embeddedVerbIndex == (compIndex + 2)):
						global numOptionalEv2
						numOptionalEv2 += 1
						print "ev2---:\t" + origSentence
					else:
						global numOptionalNonEinSitu
						numOptionalNonEinSitu += 1
						print "embed in situ---\t" + origSentence


	#	for currWord, currPOS in sentenceWithTags:
	#		print currWord + ' ' + str(currPOS)

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
	numOptionalEv2 = 0
	numOptionalNonEinSitu = 0
	multipleComp = 0
	
	interateCorpus(fileName)

	print (str(numRetainedSentences) + " sentences contain overt \'att\' and multiple verbs")
	print (str(numDiscardedSentences) + " sentences do not")
	#print ('Multiple Complementizers: ' + str(multipleComp))
	print(str(numOptionalEv2) + " optional ev2")
	print(str(numOptionalNonEinSitu) + " embedded verb in situ")