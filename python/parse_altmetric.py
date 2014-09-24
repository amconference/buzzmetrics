#!/usr/bin/python
# encoding: utf-8

import os
import sys
import json
import time
import codecs


seen_dois = set()

def parse(filename, output_file):
	with codecs.open(output_file, 'w', 'utf-8') as out:
		# headers
		out.write('doi,title,pub_date,score,tweets,posts,mendeley\n')
		with codecs.open(filename, 'r', 'utf-8') as f:
			data = json.loads(f.read())
			if 'results' in data:
				for res in data['results']:
					fields = parse_entry(res)
					if fields:
						out.write(','.join(fields) + '\n')


def parse_entry(res):
	nlm_id = res.get('nlmid', None)
	if nlm_id == 'na':
		nlm_id = None
	doi = res.get('doi', None)
	title = clean_title(res.get('title'))
	try:
		pub_date = convert_date(res.get('published_on'))
	except ValueError:
		print 'Invalid date, ignoring entry:', res.get('published_on')
		return
	score = str(res.get('score', 0.0))
	mendeley = str(res['readers'].get('mendeley', 0))
	tweets = str(res.get('cited_by_tweeters_count', 0))
	posts = str(res.get('cited_by_posts_count', 0))
	altmetric_id = res.get('altmetric_id')

	if doi and title and doi not in seen_dois:
		seen_dois.add(doi)
		return ['"' + doi + '"', '"' + title + '"', pub_date, score, tweets, posts, mendeley]


def convert_date(epoch):
	return time.strftime('%Y-%m-%dT%H:%M:%SZ', time.localtime(epoch))


def clean_title(title):
	if title:
		return title.replace('\n', ' ').replace('"', '""').replace('\\', '')
	return title


if __name__ == '__main__':
	if len(sys.argv) != 3:
		print 'Usage: %s input_file output_file\n' % sys.argv[0]
		exit(1)

	input_file = sys.argv[1]
	output_file = sys.argv[2]
	parse(input_file, output_file)
