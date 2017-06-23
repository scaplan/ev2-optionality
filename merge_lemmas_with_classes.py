#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, math
reload(sys)
sys.setdefaultencoding('utf-8')
import unicodedata
from unicodedata import normalize

lemmaToClassMap = {}

def accessDictEntry(dictToCheck, entryToCheck):
	if entryToCheck in dictToCheck:
		toReturn = ' '.join(dictToCheck[entryToCheck])
		toReturn += '\n'
		return toReturn
	else:
		return "EMPTY"

# iterate over class file and map lemma to info
def readInLemmaClassInfo(classesData):
	global lemmaToClassMap
	with open(classesData, 'r') as f:
		headerInfoRaw = f.readline().strip().split(' ')
		headerInfoClean = headerInfoRaw[1:]
		headerInfo = ' '.join(headerInfoClean).strip()
		for currLine in f:
			if not currLine:
				continue
			currLineTokens = currLine.rstrip().split(' ')
			lemma = currLineTokens[0]
			lineInfo = currLineTokens[1:]
			if (lemma in lemmaToClassMap):
				print 'double entry for: ' + lemma
			#	sys.exit()
			lemmaToClassMap[lemma] = lineInfo
			#print 'Map: ' + lemma + ' ' + str(lineInfo)
	return headerInfo

def readInputFile(inputData, newHeader, outputFilePath):
	global lemmaToClassMap
	with open(inputData, 'r') as f:
		with open(outputFilePath, 'w') as outFile:
			oldHeader = f.readline().strip()
			outFile.write(oldHeader + ' ' + newHeader + '\n')
			for currLine in f:
				if not currLine:
					continue
				currLineTokens = currLine.rstrip().split(' ')
				currLemma = currLineTokens[0]
				classInfo = accessDictEntry(lemmaToClassMap, currLemma)
				if classInfo != 'EMPTY':
					newLine = currLine.rstrip() + ' ' + classInfo
					outFile.write(newLine)
	outFile.close()

def intersectionFiles(fileOne, fileTwo, outputFileOne, outputFileTwo):
	fileOneLemmas = {}
	with open(outputFileOne, 'w') as outOne:
		with open(outputFileTwo, 'w') as outTwo:
			with open(fileOne, 'r') as f:
				oldHeader = f.readline()
				outOne.write(oldHeader)
				for currLine in f:
					if not currLine:
						continue
					currLineTokens = currLine.rstrip().split(' ')
					currLemma = currLineTokens[0]
					fileOneLemmas[currLemma] = currLine

			with open(fileTwo, 'r') as f:
					oldHeader = f.readline()
					outTwo.write(oldHeader)
					for currLine in f:
						if not currLine:
							continue
						currLineTokens = currLine.rstrip().split(' ')
						currLemma = currLineTokens[0]
						if currLemma in fileOneLemmas:
							outTwo.write(currLine)
							outOne.write(fileOneLemmas[currLemma])


def createLongFormFile(outputFileReadable, outputFileLongForm):
	with open(outputFileReadable, 'r') as inputFile:
		with open(outputFileLongForm, 'w') as outputFile:
			outputFile.write('1.lemma,2.negated,3.raised,4.factive,5.category\n')
			## Need to handle negation (and non-neg) cases
			for currLine in inputFile:
				if not currLine:
					continue
				currLineTokens = currLine.split()
				if len(currLineTokens) == 0 or currLineTokens[0] == '1.lemma':
					continue
				lemma = currLineTokens[0]
				count = int(currLineTokens[1])
				diagnostic = int(currLineTokens[5])
				countEV2 = int(currLineTokens[6])
				negatedDignostic = int(currLineTokens[8])
				nonnegDiagnostic = int(currLineTokens[9])
				negatedEV2Count = int(currLineTokens[10])
				nonNegEV2Count = int(currLineTokens[11])
				category = currLineTokens[18]
				factive = currLineTokens[19]

				negatedNonRaisedCount = negatedDignostic - negatedEV2Count
				nonnegNonRaisedCount = nonnegDiagnostic - nonNegEV2Count

				if (diagnostic > 0):
					negRaisedStr = lemma + ',negated,EV2,' + factive + ',' + category + '\n'
					negInSituStr = lemma + ',negated,inSitu,' + factive + ',' + category + '\n'
					nonnegRaisedStr = lemma + ',nonneg,EV2,' + factive + ',' + category + '\n'
					nonnegInSituStr = lemma + ',nonneg,inSitu,' + factive + ',' + category + '\n'

					for i in xrange(negatedEV2Count):
						outputFile.write(negRaisedStr)
					for i in xrange(negatedNonRaisedCount):
						outputFile.write(negInSituStr)
					for i in xrange(nonNegEV2Count):
						outputFile.write(nonnegRaisedStr)
					for i in xrange(nonnegNonRaisedCount):
						outputFile.write(nonnegInSituStr)

					# counter = 0
					# while (counter < diagnostic):
					# 	#print counter, diagnostic
					# 	if counter < countEV2:
					# 		outString = lemma + ',EV2,' + factive + ',' + category + '\n'
					# 	#	print outString
					# 		outputFile.write(outString)
					# 	else:
					# 		outString = lemma + ',inSitu,' + factive + ',' + category + '\n'
					# 	#	print outString
					# 		outputFile.write(outString)
					# 	counter += 1
					outputFile.flush()
		outputFile.close()



# iterate over inputData and append class info when retrived from lemmaMap (and just dashed when absent)
# write these new lines to outputFile

##
## Main method block
##
if __name__=="__main__":

	if (len(sys.argv) != 5):
		print('incorrect number of arguments')
		exit(0)

	inputData = sys.argv[1]
	classesData = sys.argv[2]
	outputFileReadable = sys.argv[3]
	outputFileLongForm = sys.argv[4]

	#outTwo = sys.argv[4]

	headerToAdd = readInLemmaClassInfo(classesData)
	readInputFile(inputData, headerToAdd, outputFileReadable)

	createLongFormFile(outputFileReadable, outputFileLongForm)

	#intersectionFiles(inputData, classesData, outputFile, outTwo)