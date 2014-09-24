#!/usr/bin/python
# encoding: utf-8

import os
import sys
import json
import urllib2
from time import sleep

import nwutil


# read API key from environment variable
API_KEY = os.environ['ALTMETRIC_API_KEY']
ALTMETRIC_BASE = 'http://api.altmetric.com/v1'

SLEEP_SECONDS = 0  # sleep between API calss
RETRY_SECONDS = 10  # sleep before retying a failed fetch
MAX_REQUESTS = 100

TIME_PERIODS = \
	['at', '1d', '2d', '3d', '4d', '5d', '6d', '1w', '1m', '3m', '1y']



def fetch(time_period, output_dir, num_results=1000, fetch_all=False):
	
	out_filename = os.path.join(output_dir, time_period + '.json')

	if time_period not in TIME_PERIODS:
		raise ValueError("Invald time period '%s', must be one of %s"
			% (time_period, ','.join(TIME_PERIODS)))

	res_total = 0
	output = None
	pages = [1]
	while pages:
		page_num = pages.pop(0)
		url = '%s/citations/%s?key=%s&num_results=%d&page=%d' \
			% (ALTMETRIC_BASE, time_period, API_KEY, num_results, page_num)

		print url
		
		res = fetch_url(url)
		if not output:
			output = json.loads(res)	
			
			res_total = output['query']['total']
			print 'total results:', res_total
			if fetch_all:
				max_page = res_total / num_results
				if res_total % num_results:
					max_page += 1
				pages = range(page_num + 1, min(max_page + 1, MAX_REQUESTS))
			print 'pages:', pages
		else:
			current = json.loads(res)
			output['results'].extend(current['results'])

		sleep(SLEEP_SECONDS)

		with open(out_filename, 'w') as f:
			f.write(json.dumps(output))

	# return the number of results for query and number of requests made
	return res_total, page_num


def fetch_url(url):
	'''
	Fetch data from a url, if an error occurs sleep and try again. Make up to
	three tries.
	'''
	tries = 2
	while tries > 0:
		try:
			res = urllib2.urlopen(url).read()
			tries = 0
		except Exception as e:
			tries -= 1
			print type(e), e
			print('Error fetching from url, waiting %ds. Attempts remaining: %d'
				% (RETRY_SECONDS, tries))
			sleep(RETRY_SECONDS)
	return res


if __name__ == '__main__':
	if len(sys.argv) != 3:
		print 'Usage: %s time_period output_dir\n' % sys.argv[0]
		exit(1)

	time_period = sys.argv[1]
	output_dir = sys.argv[2]
	num_results = int(sys.argv[3]) if len(sys.argv) >= 4 else None

	fetch(time_period, output_dir, fetch_all=True)
