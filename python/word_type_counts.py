#!/usr/bin/python
# encoding: utf-8

import os
import sys
import codecs

from textblob import TextBlob

POS_TAGS = {
	'NN': 'noun',
	'JJ': 'adjective',
	'VB': 'verb',
	'RB': 'adverb',
	'IN': 'preposition',
	'PR': 'pronoun'
}

def analyse(input_file, output_dir):
	
	out = {}
	for tag, word_type in POS_TAGS.items():
		out[word_type] = codecs.open(os.path.join(output_dir, word_type + '.csv'), 'w', 'utf-8')
		out[word_type].write('doi,' + word_type + '_count,' + 'total_words\n')

	with codecs.open(input_file, encoding='utf-8') as f:
		ignore_line = f.readline()
		print 'ignore line', ignore_line
		# TODO need to ignore commas inside quotes in split
		for line in f:
			cols = line.split(',')
			if len(cols) < 2:
				continue
			doi = cols[0]
			title = cols[1]

			counts = counts_dict()
			blob = TextBlob(title)
			for word, tag in blob.tags:
				for type_tag, word_type in POS_TAGS.items():
					if tag.startswith(type_tag):
						counts[word_type] += 1

			for word_type, count in counts.items():
				fields = [doi, str(count), str(len(blob.words))]
				out[word_type].write(','.join(fields) + '\n')

	for o in out.values():
		o.close()

def counts_dict():
	d = {}
	for tag, word_type in POS_TAGS.items():
		d[word_type] = 0
	return d


if __name__ == '__main__':
	if len(sys.argv) != 3:
		print 'Usage: %s input_file output_dir' % sys.argv[0]
		exit(1)

	input_file = sys.argv[1]
	output_dir = sys.argv[2]
	analyse(input_file, output_dir)