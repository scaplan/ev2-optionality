#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, math
reload(sys)
sys.setdefaultencoding('utf-8')
import unicodedata
from unicodedata import normalize


def corpusGrep(searchString, fileName):
	
	with open(fileName, 'r') as currFile:
		currSentenceMarkup = []
		currSentenceClean = ""
		for currLine in currFile:
			if not currLine:
				continue
			currLineTokens = currLine.split()
			if not currLineTokens[0] == "</text>":
				currSentenceMarkup.append(currLine)
			if currLineTokens[0] == "</sentence>":
				if searchString in currSentenceClean:
					print "\n----- " + currSentenceClean + " -----"
					for markupLine in currSentenceMarkup:
						sys.stdout.write(markupLine)
					sys.stdout.flush()
				currSentenceMarkup = []
				currSentenceClean = ""

			# check if we're reading in a word
			if currLineTokens[0] == "<w":
				currWordRaw = currLineTokens[-1]
				currWordClean = currWordRaw[currWordRaw.find(">")+1:currWordRaw.find("<")]
				currWordClean = currWordClean.lower()
				currSentenceClean = currSentenceClean + " " + currWordClean

##
## Main method block
##
if __name__=="__main__":

	if (len(sys.argv) < 3):
		print('incorrect number of arguments')
		exit(0)

	searchString = sys.argv[1]
	fileName = sys.argv[2]

	searchString = searchString.lower()
	corpusGrep(searchString, fileName)
