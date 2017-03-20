#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, math
reload(sys)
sys.setdefaultencoding('utf-8')
import unicodedata
from unicodedata import normalize

subjectWhitelist = {"NN":1,	# NN	Substantiv	Noun
					"PM":1,	# PM	Egennamn	Proper Noun
					"PN":1, # PN	Pronomen	Pronoun
					"DT":1, # DT	Determinerare, bestämningsord	Determiner
					"JJ":1,	# JJ	Adjektiv	Adjective
					"PS":1,	# PS	Possessivuttryck	Possessive
					"RG":1,	# RG	Räkneord: grundtal	Cardinal Number
					"RO":1,	# RO	Räkneord: ordningstal	Ordinal Number
					"HD":1,	# HD	Frågande/relativ bestämning	Interrogative/Relative Determiner
					"HP":1,	# HP	Frågande/relativt pronomen	Interrogative/Relative Pronoun
					}

# msdBlacklist = {}

# AB.POS, KOM, SUV (is good, better, best), as well as those with w/ nominal morphology: NOM, GEN, SMS, URT, NEU, MAS, SIN, PLU, IND, DEF.

def findAll(lst, value):
    return [i for i, x in enumerate(lst) if value==x]

def findAllComp(words, value, tags):
	toReturn = []
	for index, word in enumerate(words):
		if word == 'att' and tags[index] == "SN":
			toReturn.append(index)
	return toReturn

def evalSentence(words, tags, sentenceWithTags):
	global numOptionalEv2
	global numOptionalNonEinSitu
	global proCases
	global overtSubj
	global cantTellRaised
	global numDiscardedSentences
	global matrixVerbTotalMap, matrixVerbECMap, matrixVerbeV2
	compInstances = findAllComp(words, 'att', tags)
	origSentence = ""
	for currWord in words:
		origSentence += currWord + " "
	if (len(compInstances) > 0):

		# delete any instances of 'att' followed directly by VB (since that's a control structure rather than a complement)
		# also delete any instance of 'kommer att' since that's future marking rather than a complement
		for index in compInstances:
			if index < len(words) - 1:
				followingTag = tags[index+1]
				precedingWord = words[index-1]
				if precedingWord == "kommer":
					del words[index]
					del words[index-1]
					del tags[index]
					del tags[index-1]
					del sentenceWithTags[index]
					del sentenceWithTags[index-1]
				elif followingTag == "VB":
					del words[index+1]
					del words[index]
					del tags[index+1]
					del tags[index]
					del sentenceWithTags[index+1]
					del sentenceWithTags[index]
				

		nonControlCompInstances = findAllComp(words, 'att', tags)
		verbInstances = findAll(tags, 'VB')

		# Add to verb totals
		for verbIndex in verbInstances:
			currVerb = words[verbIndex]
			if currVerb in matrixVerbTotalMap:
				matrixVerbTotalMap[currVerb] = (matrixVerbTotalMap[currVerb] + 1)
			else:
				matrixVerbTotalMap[currVerb] = 1

		if len(verbInstances) > len(nonControlCompInstances):
			if (len(nonControlCompInstances) > 1):
				global multipleComp
				multipleComp += 1
				numDiscardedSentences += 1
			elif (len(nonControlCompInstances) == 1):
				# just to keep things simple for now
				# this is considering only instances with one posited complementizer
				# this was we don't have to figure out where the boundaries of too many different domains are
				global numRetainedSentences
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

					# gather all the material between the compIndex and the embeddedVerbIndex
					# check that it contains at least element from the subject whitelist
					containsOvertSubject = False
					for index in xrange(compIndex+1, embeddedVerbIndex):
						if tags[index] in subjectWhitelist:
							containsOvertSubject = True
							break

					if containsOvertSubject:
						numRetainedSentences += 1
						overtSubj += 1
				#		print "OvertSubj:\t" + origSentence

						# tabulate matrix verb information with embedded clause
						if matrixVerb in matrixVerbECMap:
							matrixVerbECMap[matrixVerb] = (matrixVerbECMap[matrixVerb] + 1)
						else:
							matrixVerbECMap[matrixVerb] = 1

						# Now given the index of the embedded verb I want to only look at cases with {neg, adv} directly before and/or after that VB slot
						# THEN if {neg, adv} appears directly before VB then clause is in situ, otherwise if {neg, adv} doesn't appear directly before VB then it's ev2.
						precedeVerbPOS = tags[embeddedVerbIndex - 1]
						precedeVerbWord = words[embeddedVerbIndex - 1]
						if (embeddedVerbIndex == (len(tags) - 1)):
							followVerbPOS = ""
							followVerbWord = ""
						else:
							followVerbPOS = tags[embeddedVerbIndex + 1] #make sure we're not at the end
							followVerbWord = words[embeddedVerbIndex + 1]
						#if ((precedeVerbPOS == "AB") or (followVerbPOS == "AB")):
						if ((precedeVerbWord == "inte") or (followVerbWord == "inte")):
							#if precedeVerbPOS == "AB":
							if precedeVerbWord == "inte":
								numOptionalNonEinSitu = numOptionalNonEinSitu + 1
				#				print "inSitu:\t" + origSentence
							else:
								numOptionalEv2 = numOptionalEv2 + 1
								if matrixVerb in matrixVerbeV2:
									matrixVerbeV2[matrixVerb] = (matrixVerbeV2[matrixVerb] + 1)
								else:
									matrixVerbeV2[matrixVerb] = 1
				#				print "ev2:\t" + origSentence
						else:
							cantTellRaised += 1
						#	print "can'tTell\t" + origSentence
					else:
						proCases += 1
				#		print "PRO:\t" + origSentence
		else:
			numDiscardedSentences += 1


	#	for currWord, currPOS in sentenceWithTags:
	#		print currWord + ' ' + str(currPOS)

	else:
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

	if (len(sys.argv) < 5):
		print('incorrect number of arguments')
		exit(0)

	inputCorpus = sys.argv[1]
	outputStatsPath = sys.argv[2]
	outputEv2Path = sys.argv[3]
	verboseMode = False
	if (sys.argv[4] == 'True'):
		verboseMode = True

	numRetainedSentences = 0
	numDiscardedSentences = 0
	numOptionalEv2 = 0
	numOptionalNonEinSitu = 0
	multipleComp = 0
	overtSubj = 0
	proCases = 0
	cantTellRaised = 0

	matrixVerbTotalMap = {}
	matrixVerbECMap = {}
	matrixVerbeV2 = {}
	
	interateCorpus(inputCorpus)

	print (str(numRetainedSentences) + " candidate sentences (single overt complementizer)")
	print (str(numDiscardedSentences) + " sentences discarded (no complementizer)")
	print (str(multipleComp) + ' Multiple Complementizers')
	print (str(proCases) + ' proCases')
	print (str(overtSubj) + ' overtSubj')
	print (str(numOptionalEv2) + " optional ev2")
	print (str(numOptionalNonEinSitu) + " embedded verb in situ")
	print (str(cantTellRaised) + " can't tell if raised")

	counter = 0
	for verb in sorted(matrixVerbTotalMap, key=matrixVerbTotalMap.get, reverse=True):
		verbCount = matrixVerbTotalMap[verb]
		numEC = 0
		ecGivenMatrix = 0.0
		if verb in matrixVerbECMap:
			numEC = matrixVerbECMap[verb]
			ecGivenMatrix = (numEC / (verbCount * 1.0))
		print (verb + " : " + str(verbCount) + " : " + str(numEC) + " --- " + str(ecGivenMatrix))
		counter += 1
		if counter > 1000:
			break

	print "\n"

	counter = 0
	for matrixVerb in sorted(matrixVerbeV2, key=matrixVerbeV2.get, reverse=True):
		verbCount = matrixVerbTotalMap[matrixVerb]
		numEV2 = 0
		ev2GivenMatrixVerbCount = matrixVerbeV2[matrixVerb]
		ev2GivenMatrixVerbProb = (ev2GivenMatrixVerbCount / (verbCount * 1.0))
		print (matrixVerb + " : " + str(verbCount) + " : " + str(ev2GivenMatrixVerbCount) + " --- " + str(ev2GivenMatrixVerbProb))
		counter += 1
		if counter > 1000:
			break