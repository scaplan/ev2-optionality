#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, math, os, subprocess, glob, nltk, re
from nltk import word_tokenize
reload(sys)
sys.setdefaultencoding('utf-8')
import unicodedata
from unicodedata import normalize


##
## Main method block
##
if __name__=="__main__":
	inputName = sys.argv[1]
	outputName = sys.argv[2]
	with open(inputName, 'r') as inputFile:
		with open(outputName, 'w') as outputFile:
			outputFile.write('1.lemma,2.diagnostic,3.raised,4.factive,5.category\n')
			for currLine in inputFile:
				if not currLine:
					continue
				currLineTokens = currLine.split()
				if len(currLineTokens) == 0 or currLineTokens[0] == '1.lemma':
					continue
				print currLine
				lemma = currLineTokens[0]
				count = int(currLineTokens[1])
				diagnostic = int(currLineTokens[5])
				countEV2 = int(currLineTokens[6])
				category = currLineTokens[18]
				factive = currLineTokens[19]

				counter = 0
				while (counter < diagnostic):
					#print counter, diagnostic
					if counter < countEV2:
						outString = lemma + ',' + str(diagnostic) + ',EV2,' + factive + ',' + category + '\n'
					#	print outString
						outputFile.write(outString)
					else:
						outString = lemma + ',' + str(diagnostic) + ',inSitu,' + factive + ',' + category + '\n'
					#	print outString
						outputFile.write(outString)
					counter += 1
				outputFile.flush()
		outputFile.close()

	print 'Completed.'