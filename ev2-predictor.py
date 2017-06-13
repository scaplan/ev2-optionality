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

adverbClausalList = {"så":1,
					 "därför":1,
					 "för":1,
					 "eftersom":1,
					 "med":1,
					 "orsaken":1,
					 "utsträckning":1,
					 "sedan":1,
					 "sen":1,
					 "det":1,
					 "av":1,
					 "grad":1,
					 }

inteSet = {"inte":1,
		   "icke":1,
		   "ikke":1,
		   "ej":1,
		}

verboseInvestigationSet = {"säga":1,
						   "tänka":1,
						   "tala":1,
						   "känna":1,
						   "lova":1,
						   "gå":1,
						  }


def findAll(lst, value):
    return [i for i, x in enumerate(lst) if value==x]

def findAllComp(words, value, tags):
	toReturn = []
	for index, word in enumerate(words):
		if word == 'att' and tags[index] == "SN":
			toReturn.append(index)
	return toReturn

def catchAdverbialClausalComplement():
	print 'write fuction here'

def evalSentence(words, lemmas, tags, msds, sentenceWithTags, outputEv2File):
	global numOptionalEv2, numOptionalNonEinSitu, proCasesOrMatrixCopula, overtSubj, adverbClausalList
	global cantTellRaised, numDiscardedSentences, matrixVerbECMap, matrixVerbeV2, verboseMode, allVerbFullTotalMap, allLemmaFullTotalMap
	global matrixLemmaECMap, matrixLemmaeV2, embedVerbeV2, embedLemmaeV2, totalEmbedVerbMap, totalEmbedLemmaMap, highestEmbedVerbMap, highestEmbedLemmaMap
	global matrixVerbCanTellIfRaised, matrixLemmaCanTellIfRaised, embedVerbCanTellIfRaised, embedLemmaCanTellIfRaised
	global interveningMaterialEV2, interveningMaterialCanTellIfRaised, matrixLemmaPosEV2, matrixLemmaNegEV2, matrixLemmaPosCanTellIfRaised, matrixLemmaNegCanTellIfRaised
	compInstances = findAllComp(words, 'att', tags)
	origSentence = ""
	for currWord in words:
		origSentence += currWord + " "

	verbInstances = findAll(tags, 'VB')
	# Add to verb totals
	for verbIndex in verbInstances:
		currVerb = words[verbIndex]
		currLemma = lemmas[verbIndex]
		allVerbFullTotalMap = updateCountMap(allVerbFullTotalMap, currVerb)
		allLemmaFullTotalMap = updateCountMap(allLemmaFullTotalMap, currLemma)

	if (len(compInstances) > 0):

		# delete any instances of 'att' followed directly by VB (since that's a control structure rather than a complement)
		# also delete any instance of 'kommer att' since that's future marking rather than a complement
		for index in compInstances:
			if index < len(words) - 1:
				followingTag = tags[index+1]
				precedingWord = words[index-1]
				precedingTag = tags[index-1]
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
				elif precedingWord in adverbClausalList:
					del words[index]
					del words[index-1]
					del tags[index]
					del tags[index-1]
					del sentenceWithTags[index]
					del sentenceWithTags[index-1]			

		nonControlCompInstances = findAllComp(words, 'att', tags)
		verbInstances = findAll(tags, 'VB')

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
						totalEmbedVerbMap = updateCountMap(totalEmbedVerbMap, words[verbIndex])
						totalEmbedLemmaMap = updateCountMap(totalEmbedLemmaMap, lemmas[verbIndex])
				if (len(matrixDomain) > 0 and len(embeddedDomain) > 0):

					matrixVerbIndex = matrixDomain[-1]
					directlyBeforeMatrix = lemmas[matrixVerbIndex-1]
					matrixVerb = words[matrixVerbIndex]
					matrixLemma = lemmas[matrixVerbIndex]
					
				#	if directlyBeforeMatrix == 'inte':
				#		print directlyBeforeMatrix, matrixLemma, '\n'
					embeddedVerbIndex = embeddedDomain[0]
					embeddedVerb = words[embeddedVerbIndex]
					embeddedLemma = lemmas[embeddedVerbIndex]

					### figure out how much intervening material there is
					interveneLength = (compIndex - matrixVerbIndex) - 1

					# gather all the material between the compIndex and the embeddedVerbIndex
					# check that it contains at least element from the subject whitelist
					containsOvertSubject = False
					for index in xrange(compIndex+1, embeddedVerbIndex):
						if tags[index] in subjectWhitelist:
							containsOvertSubject = True
							break

					# Make sure that the lowest matrix verb is not the copula
					# so that there's not some sort of other clausal complement here..
					matrixCopula = False
					if matrixLemma == 'vara' or matrixLemma == 'e':
						matrixCopula = True

					if containsOvertSubject and not matrixCopula:
						numRetainedSentences += 1
						overtSubj += 1
				#		print "OvertSubj:\t" + origSentence

						# tabulate matrix verb information with embedded clause
						matrixVerbECMap = updateCountMap(matrixVerbECMap, matrixVerb)
						matrixLemmaECMap = updateCountMap(matrixLemmaECMap, matrixLemma)

						# Search over embedded subject domain (between 'att' and the highest embedded verb) for 'som' (or what 'som' is tagged as)
						# if 'som' is found then there's a relative clause subject -- and I need to set the embedded verb to be the second verb
						for index in xrange(compIndex+1, embeddedVerbIndex):
							if words[index] == 'som':
						#		print 'relClsSub: ' + origSentence
						#		print '--OldEmbed--: ' + embeddedVerb
								# newly set embeddedVerbIndex and embeddedVerb
								embeddedVerbIndex = -1
						#		print embeddedDomain
								if len(embeddedDomain) > 1:
									for embedIndexCheck in xrange(1,len(embeddedDomain)):
						#				print embedIndexCheck, words[embeddedDomain[embedIndexCheck]], msds[embeddedDomain[embedIndexCheck]]
										if 'INF' not in msds[embeddedDomain[embedIndexCheck]] and 'SUP' not in msds[embeddedDomain[embedIndexCheck]]:
											embeddedVerbIndex = embeddedDomain[embedIndexCheck]
											embeddedVerb = words[embeddedVerbIndex]
											embeddedLemma = lemmas[embeddedVerbIndex]
											break
						#		if embeddedVerbIndex != -1:
						#			print '--NewEmbed--: ' + embeddedVerb
						#		else:
						#			print '--TOSS--'
						if embeddedVerbIndex != -1:
							highestEmbedVerbMap = updateCountMap(highestEmbedVerbMap, embeddedVerb)
							highestEmbedLemmaMap = updateCountMap(highestEmbedLemmaMap, embeddedLemma)

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
							if ((precedeVerbWord in inteSet) or (followVerbWord in inteSet)):
								#if precedeVerbPOS == "AB":

								matrixVerbCanTellIfRaised = updateCountMap(matrixVerbCanTellIfRaised, matrixVerb)
								matrixLemmaCanTellIfRaised = updateCountMap(matrixLemmaCanTellIfRaised, matrixLemma)
								embedVerbCanTellIfRaised = updateCountMap(embedVerbCanTellIfRaised, embeddedVerb)
								embedLemmaCanTellIfRaised  = updateCountMap(embedLemmaCanTellIfRaised, embeddedLemma)
								interveningMaterialCanTellIfRaised = updateCountMap(interveningMaterialCanTellIfRaised, interveneLength)
								if directlyBeforeMatrix in inteSet:
									matrixLemmaNegCanTellIfRaised = updateCountMap(matrixLemmaNegCanTellIfRaised, matrixLemma)
								else:
									matrixLemmaPosCanTellIfRaised = updateCountMap(matrixLemmaPosCanTellIfRaised, matrixLemma)

								if precedeVerbWord in inteSet:
									numOptionalNonEinSitu = numOptionalNonEinSitu + 1
									if verboseMode:
										if matrixLemma in verboseInvestigationSet:
											if directlyBeforeMatrix in inteSet:
												# negated
												outputEv2File.write("inSitu (negated):\t" + origSentence + "\n")
											else:
												outputEv2File.write("inSitu (non-neg):\t" + origSentence + "\n")
								else:
									numOptionalEv2 += 1
									matrixVerbeV2 = updateCountMap(matrixVerbeV2, matrixVerb)
									matrixLemmaeV2 = updateCountMap(matrixLemmaeV2, matrixLemma)
									embedVerbeV2 = updateCountMap(embedVerbeV2, embeddedVerb)
									embedLemmaeV2  = updateCountMap(embedLemmaeV2, embeddedLemma)
									interveningMaterialEV2 = updateCountMap(interveningMaterialEV2, interveneLength)
									if directlyBeforeMatrix in inteSet:
										matrixLemmaNegEV2 = updateCountMap(matrixLemmaNegEV2, matrixLemma)
									else:
										matrixLemmaPosEV2 = updateCountMap(matrixLemmaPosEV2, matrixLemma)
								#	print origSentence
								#	print 'interveneLength: ' + str(interveneLength) + '\n'

									if verboseMode:
										if matrixLemma in verboseInvestigationSet:
											if directlyBeforeMatrix in inteSet:
												# negated
												outputEv2File.write("ev2 (negated):\t" + origSentence + "\n")
											else:
												outputEv2File.write("ev2 (non-neg):\t" + origSentence + "\n")
							else:
								cantTellRaised += 1
						#	if verboseMode:
						#		outputEv2File.write("can'tTell:\t" + origSentence + "\n")
					else:
						proCasesOrMatrixCopula += 1
		else:
			numDiscardedSentences += 1


	#	for currWord, currPOS in sentenceWithTags:
	#		print currWord + ' ' + str(currPOS)

	else:
		numDiscardedSentences += 1

def updateCountMap(inputMap, inputEntry):
	if inputEntry in inputMap:
		inputMap[inputEntry] = (inputMap[inputEntry] + 1)
	else:
		inputMap[inputEntry] = 1
	return inputMap

def accessDictEntry(dictToCheck, entryToCheck):
	if entryToCheck in dictToCheck:
		return dictToCheck[entryToCheck]
	else:
		return 0

def safeDivide(numerator, denominator):
	if denominator > 0:
		return (numerator / (denominator * 1.0))
	else:
		return 0.0

def iterateCorpus(inputName, outputName):
	totalTokens = 0
	typeDict = {}

	with open(inputName, 'r') as currInputFile:
		with open(outputName, 'w') as outputEv2File:
			currSentence = []
			currLemmas = []
			currMsds = []
			currTags = []
			currSentenceWithPOS = []
			for currLine in currInputFile:
				if not currLine:
					continue
				currLineTokens = currLine.split()
				if currLineTokens[0] == "</sentence>":
					# we've finished the previous sentence so we should 
					# pass the sentence to the evaluation function
					# and then clear the "currSentence" list
					evalSentence(currSentence, currLemmas, currTags, currMsds, currSentenceWithPOS, outputEv2File)
					currSentence = []
					currLemmas = []
					currMsds = []
					currTags = []
					currSentenceWithPOS = []

				# check if we're reading in a word
				if currLineTokens[0] == "<w":
					currPosRaw = currLineTokens[1]
					currMsdRaw = currLineTokens[2]
					currLemmaRaw = currLineTokens[3]
					currWordRaw = currLineTokens[-1]

					currWordClean = currWordRaw[currWordRaw.find(">")+1:currWordRaw.find("<")]
					currWordClean = currWordClean.lower()

					# if currLemmaRaw contains two pipes, then extract between the pipes
					# otherwise there's no lemma entry, so set (currLemmaClean = currWordClean)
					currLemmaClean = currWordClean
					if currLemmaRaw.count('|') == 2:
						currLemmaParts = currLemmaRaw.split('|')
						currLemmaClean = currLemmaParts[1]

					#print len(currMsdRaw)
					#print currMsdRaw.split('msd="')
					# print out which line we're on
					# or check that when splitting we have enough resulting elements
					currMsdTemp = currMsdRaw.split('msd="')
					if len(currMsdTemp) > 1:
						currMsdClean = currMsdTemp[1]
						currMsdClean = currMsdClean[:-1]

						currPosClean = currPosRaw[currPosRaw.find("\"")+1:-1]
						currPair = (currWordClean, currPosClean)

						if (currWordRaw in typeDict):
							typeDict[currWordRaw] = typeDict[currWordRaw] + 1
						else:
							typeDict[currWordRaw] = 1
						totalTokens += 1
						currSentence.append(currWordClean)
						currLemmas.append(currLemmaClean)
						currMsds.append(currMsdClean)
						currTags.append(currPosClean)
						currSentenceWithPOS.append(currPair)
	outputEv2File.close()
	outputStatsFile.write(str(totalTokens) + ' total tokens\n')
	outputStatsFile.write(str(len(typeDict)) + ' total types\n')

##
## Main method block
##
if __name__=="__main__":

	if (len(sys.argv) < 7):
		print('incorrect number of arguments')
		exit(0)

	inputCorpus = sys.argv[1]
	outputStatsPath = sys.argv[2]
	outputEv2Path = sys.argv[3]
	matrixConditionsVerbPath = sys.argv[4]
	verboseMode = False
	matrixConditionsLemmaPath = sys.argv[5]
	interveneLengthPath = sys.argv[6]
	if (sys.argv[7] == 'True'):
		verboseMode = True

	numRetainedSentences = 0
	numDiscardedSentences = 0
	numOptionalEv2 = 0
	numOptionalNonEinSitu = 0
	multipleComp = 0
	overtSubj = 0
	proCasesOrMatrixCopula = 0
	cantTellRaised = 0

	allVerbFullTotalMap = {}
	allLemmaFullTotalMap = {}

	matrixVerbECMap = {}
	matrixLemmaECMap = {}

	totalEmbedVerbMap = {}
	totalEmbedLemmaMap = {}
	highestEmbedVerbMap = {}
	highestEmbedLemmaMap = {}

	matrixVerbeV2 = {}
	matrixLemmaeV2 = {}
	embedVerbeV2 = {}
	embedLemmaeV2 = {}
	interveningMaterialEV2 = {}

	matrixVerbCanTellIfRaised = {}
	matrixLemmaCanTellIfRaised = {}
	embedVerbCanTellIfRaised = {}
	embedLemmaCanTellIfRaised = {}
	interveningMaterialCanTellIfRaised = {}

	matrixLemmaPosEV2 = {}
	matrixLemmaNegEV2 = {}
	matrixLemmaPosCanTellIfRaised = {}
	matrixLemmaNegCanTellIfRaised = {}

	with open(outputStatsPath,'w') as outputStatsFile:
	
		iterateCorpus(inputCorpus, outputEv2Path)

		outputStatsFile.write(str(numRetainedSentences) + " candidate sentences (single overt complementizer)\n")
		outputStatsFile.write(str(numDiscardedSentences) + " sentences discarded (no complementizer)\n")
		outputStatsFile.write(str(multipleComp) + ' Multiple Complementizers\n')
		outputStatsFile.write(str(proCasesOrMatrixCopula) + ' proCasesOrMatrixCopula\n')
		outputStatsFile.write(str(overtSubj) + ' overtSubj\n')
		outputStatsFile.write(str(numOptionalEv2) + " optional ev2\n")
		outputStatsFile.write(str(numOptionalNonEinSitu) + " embedded verb in situ\n")
		outputStatsFile.write(str(cantTellRaised) + " can't tell if raised\n")

	outputStatsFile.close()

#	1		2					3				4						5
#	verb	allCount			NonEmbedCount	numEC					p(ec|matrix)
#	verb	allVerbFullTotalMap	(all-embed)		matrixVerbECMap			numEC/(allVerbFullTotalMap - totalEmbedVerbMap)

#	6						7								8						9					10
#	ev2GivenMatrixVerbCount	p(ev2|matrix)					highestEmbedVerbCount	ev2GivenEmbedCount	p(ev2|embed)
#	matrixVerbeV2			ev2GivenMatrixVerbCount/numEC	highestEmbedVerbMap		embedVerbeV2		embedVerbeV2/highestEmbedVerbMap

	with open(matrixConditionsVerbPath,'w') as matrixConditionsFile:
		matrixConditionsFile.write('1.verb 2.totalCount 3.NonEmbedCount 4.numEC 5.p(ec|matrix) 6.numCanTellIfRaised 7.c(ev2|matrix) 8.p(ev2|matrix) 9.highestEmbedVerbCount 10.embedVerbCanTellIfRaised 11.c(ev2|embed) 12.p(ev2|embed)\n')
		for verb in sorted(allVerbFullTotalMap, key=allVerbFullTotalMap.get, reverse=True):
			verbCountAll = allVerbFullTotalMap[verb]
			verbEmbedCount = accessDictEntry(totalEmbedVerbMap, verb)
			verbNonEmbedCount = verbCountAll - verbEmbedCount
			highestEmbedVerbCount = accessDictEntry(highestEmbedVerbMap, verb)

			embedVerbCanTellIfRaisedCount = accessDictEntry(embedVerbCanTellIfRaised, verb)
			ev2GivenEmbedCount = accessDictEntry(embedVerbeV2, verb)
			ev2GivenEmbedVerbProb = safeDivide(ev2GivenEmbedCount, embedVerbCanTellIfRaisedCount)

			numEC = accessDictEntry(matrixVerbECMap, verb)
			numCanTellIfRaised = accessDictEntry(matrixVerbCanTellIfRaised, verb)
			ecGivenMatrix = safeDivide(numEC, verbNonEmbedCount)
			ev2GivenMatrixVerbCount = accessDictEntry(matrixVerbeV2, verb)
			ev2GivenMatrixVerbProb = safeDivide(ev2GivenMatrixVerbCount, numEC)
			

			matrixConditionsFile.write(verb + " " + str(verbCountAll) + " " + str(verbNonEmbedCount) + " " + str(numEC) + " " + str(ecGivenMatrix) + " " + str(numCanTellIfRaised))
			matrixConditionsFile.write(str(ev2GivenMatrixVerbCount) + " " + str(ev2GivenMatrixVerbProb) + " " + str(highestEmbedVerbCount) + " ")
			matrixConditionsFile.write(str(embedVerbCanTellIfRaisedCount) + " " + str(ev2GivenEmbedCount) + " " + str(ev2GivenEmbedVerbProb) + "\n")
	matrixConditionsFile.close()
	
	# output lemma file here
	with open(matrixConditionsLemmaPath,'w') as matrixConditionsFile:
		matrixConditionsFile.write('1.lemma 2.totalCount 3.NonEmbedCount 4.numEC 5.p(ec|matrix) 6.numCanTellIfRaised 7.c(ev2|matrix) 8.p(ev2|matrix) 9.NegatedCanTellIfRaised 10.nonNegCanTellIfRaised 11.c(ev2|NegatedMatrix) 12.c(ev2|NonNegMatrix) 13.p(ev2|NegatedMatrix) 14.p(ev2|NonNegMatrix) 15.highestEmbedVerbCount 16.embedLemmaCanTellIfRaised 17.c(ev2|embed) 18.p(ev2|embed)\n')
		for lemma in sorted(allLemmaFullTotalMap, key=allLemmaFullTotalMap.get, reverse=True):
			lemmaCountAll = allLemmaFullTotalMap[lemma]
			lemmaEmbedCount = accessDictEntry(totalEmbedLemmaMap, lemma)
			lemmaNonEmbedCount = lemmaCountAll - lemmaEmbedCount
			highestEmbedLemmaCount = accessDictEntry(highestEmbedLemmaMap, lemma)

			embedLemmaCanTellIfRaisedCount = accessDictEntry(embedLemmaCanTellIfRaised, lemma)
			ev2GivenEmbedCount = accessDictEntry(embedLemmaeV2, lemma)
			ev2GivenEmbedLemmaProb = safeDivide(ev2GivenEmbedCount, embedLemmaCanTellIfRaisedCount)

			numEC = accessDictEntry(matrixLemmaECMap, lemma)
			numCanTellIfRaised = accessDictEntry(matrixLemmaCanTellIfRaised, lemma)
			ecGivenMatrix = safeDivide(numEC, lemmaNonEmbedCount)
			ev2GivenMatrixLemmaCount = accessDictEntry(matrixLemmaeV2, lemma)
			ev2GivenMatrixLemmaProb = safeDivide(ev2GivenMatrixLemmaCount, numCanTellIfRaised)

			negatedMatrixCanTellIfRaisedCount = accessDictEntry(matrixLemmaNegCanTellIfRaised, lemma)
			nonNegMatrixCanTellIfRaisedCount  = accessDictEntry(matrixLemmaPosCanTellIfRaised, lemma)
			negatedMatrixEV2Count = accessDictEntry(matrixLemmaNegEV2, lemma)
			nonNegMatrixEV2Count = accessDictEntry(matrixLemmaPosEV2, lemma)
			ev2GivenNegatedMatrixProb = safeDivide(negatedMatrixEV2Count, negatedMatrixCanTellIfRaisedCount)
			ev2GivenNonNegMatrixProb = safeDivide(nonNegMatrixEV2Count, nonNegMatrixCanTellIfRaisedCount)

			matrixConditionsFile.write(lemma + " " + str(lemmaCountAll) + " " + str(lemmaNonEmbedCount) + " " + str(numEC) + " " + str(ecGivenMatrix) + " " + str(numCanTellIfRaised) + " ")
			matrixConditionsFile.write(str(ev2GivenMatrixLemmaCount) + " " + str(ev2GivenMatrixLemmaProb) + " " + str(negatedMatrixCanTellIfRaisedCount) + " " + str(nonNegMatrixCanTellIfRaisedCount) + " ")
			matrixConditionsFile.write(str(negatedMatrixEV2Count) + " " + str(nonNegMatrixEV2Count) + " " + str(ev2GivenNegatedMatrixProb) + " " + str(ev2GivenNonNegMatrixProb) + " ")
			matrixConditionsFile.write(str(highestEmbedLemmaCount) + " " + str(embedLemmaCanTellIfRaisedCount) + " " + str(ev2GivenEmbedCount) + " " + str(ev2GivenEmbedLemmaProb) + "\n")
	matrixConditionsFile.close()

	### Output file with data relating to interveningMaterialEV2
	with open(interveneLengthPath,'w') as interveneLengthFile:
		interveneLengthFile.write('1.length 2.numCanTellIfRaised 3.c(ev2|intervene) 4.p(ev2|intervene)\n')
		for currLength in sorted(interveningMaterialEV2, key=interveningMaterialEV2.get, reverse=False):
			numCanTellIfRaised = accessDictEntry(interveningMaterialCanTellIfRaised, currLength)
			ev2GivenInterveneLengthCount = accessDictEntry(interveningMaterialEV2, currLength)
			ev2GivenInterveneLengthProb = safeDivide(ev2GivenInterveneLengthCount, numCanTellIfRaised)
			interveneLengthFile.write(str(currLength) + " " + str(numCanTellIfRaised) + " " + str(ev2GivenInterveneLengthCount) + " " + str(ev2GivenInterveneLengthProb) + "\n")
	interveneLengthFile.close()

