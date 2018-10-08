#!/usr/bin/env python
# script that queries github api for ssh keys.
# compares local key to each key
# if exists. we are good.
# if title contains machine name but doesn't match delete and create
# if does not exist. create.
# uses python 2 because that is default mac version today.

import os
import urllib2
import urllib
import json
from base64 import b64encode
import base64
import re
import hashlib

__dir = os.path.dirname(__file__)
base_gh_url = 'https://api.github.com'
local_env = {}
hostname = os.uname()[1]
ssh_key = open('%s/.ssh/id_rsa.pub' % os.environ['HOME'], 'r').read()
env_vars_file = open('%s/../.env' % __dir, 'r')

for line in env_vars_file:
	prop = line.split('=')
	local_env[prop[0]] = prop[1].strip()

headers = {
	"Content-Type": "application/json"
}


def line_to_fingerprint(line):
    key = base64.b64decode(line.strip().split()[1].encode('ascii'))
    fp_plain = hashlib.md5(key).hexdigest()
    return ':'.join(a+b for a,b in zip(fp_plain[::2], fp_plain[1::2]))

def make_request(url_path, data = None, method = None):
	request = urllib2.Request(base_gh_url + url_path + '?per_page=150')
	request.add_header('Authorization', 'Basic ' + b64encode(local_env['username'] + ':' + local_env['password']))
	if method:
		print "Deleting %s" % url_path
		request.get_method = lambda: 'DELETE'
	# r = urllib2.urlopen(request)
	
	try:
		if (data):
			post_data = json.dumps(data)
			request.add_data(post_data)

		r = urllib2.urlopen(request)

		return r
	except urllib2.URLError as e:
		print e
		print e.reason


print 'git/update-ssh-key.py | configure github.com ...'

get_github_keys_req = make_request('/user/keys')
if get_github_keys_req.getcode() == 200:
	# print r.headers
	data = json.load(get_github_keys_req)

	key_found = False
	hostname_found = None
	for key in data:
		# if key exists exactly
		if key['key'] in ssh_key:
			key_found = True
			print "[SKIP] ... ssh key already exists in github: %s" % key['title']
			print "github.com\t\tkey fingerprint: %s" % line_to_fingerprint(key['key'])
		else:
			if hostname.lower() in key['title'].lower():
				hostname_found = key['id']


	
	if key_found is False:
		# if hostname is in key title
		if hostname_found:
			print "[MATCH] ... ssh key contains %s but doesn't match fingerprint. deleting old key." % hostname
			delete_github_key_req = make_request('/user/keys/%s' % key['id'], None, 'DELETE')
			if delete_github_key_req.getcode() == 204:
				print "[DELETE] ... old ssh key deleted in github.com %s" % hostname_found

		# key doesn't exist. add.
		print "[CREATE] ... adding key to github.com."
		post_github_key_req = make_request('/user/keys', { 'title': hostname, 'key': ssh_key })
			
	print "%s ssh\t\tkey fingerprint: %s" % (hostname, line_to_fingerprint(ssh_key))

print ''
