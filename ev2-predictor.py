#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, math
reload(sys)
sys.setdefaultencoding('utf-8')
import unicodedata
from unicodedata import normalize

def interateCorpus(fileName):
	with open(fileName, 'r') as currFile:
		for currLine in currFile:
			if not currLine:
				continue
			currLineTokens = currLine.split()
			print currLine

##
## Main method block
##
if __name__=="__main__":
	if (len(sys.argv) < 2):
		print('incorrect number of arguments')
		exit(0)

	fileName = sys.argv[1]
	
	interateCorpus(fileName)