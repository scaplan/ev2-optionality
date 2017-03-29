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
				sys.exit()
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



# iterate over inputData and append class info when retrived from lemmaMap (and just dashed when absent)
# write these new lines to outputFile

##
## Main method block
##
if __name__=="__main__":

	if (len(sys.argv) != 4):
		print('incorrect number of arguments')
		exit(0)

	inputData = sys.argv[1]
	classesData = sys.argv[2]
	outputFile = sys.argv[3]

	headerToAdd = readInLemmaClassInfo(classesData)
	readInputFile(inputData, headerToAdd, outputFile)
