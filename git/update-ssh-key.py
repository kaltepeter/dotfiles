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
from python.lib import typed_message, COLORS

__dir = os.path.dirname(__file__)
base_gh_url = 'https://api.github.com'
local_env = {}
hostname = os.uname()[1]
ssh_key = open('%s/.ssh/id_rsa.pub' % os.environ['HOME'], 'r').read()
env_vars_file = open('%s/../.env' % __dir, 'r')

for line in env_vars_file:
  prop = line.split('=')
  local_env[prop[0]] = prop[1].strip()


def line_to_fingerprint(line):
  key = base64.b64decode(line.strip().split()[1].encode('ascii'))
  fp_plain = hashlib.md5(key).hexdigest()
  return ':'.join(a+b for a,b in zip(fp_plain[::2], fp_plain[1::2]))

def make_request(url_path, data = None, method = None):
  headers = {
    "Content-Type": "application/json"
  }

  request = urllib2.Request(base_gh_url + url_path + '?per_page=150')
  request.add_header('Authorization', 'Basic ' + b64encode(local_env['username'] + ':' + local_env['pw']))
  if method:
    print "Deleting %s" % url_path
    request.get_method = lambda: 'DELETE'

  try:
    if (data):
      post_data = json.dumps(data)
      request.add_data(post_data)

    r = urllib2.urlopen(request)
    return r
  except urllib2.URLError as e:
    print e
    print e.reason
    os._exit(1)

def main():
  print('%s git/update-ssh-key.py | configure github.com ...%s' % (COLORS['STATUS'], COLORS['DEFAULT']))

  get_github_keys_req = make_request('/user/keys')

  if get_github_keys_req.getcode() == 200:
    data = json.load(get_github_keys_req)

    key_found = False
    hostname_found = None

    for key in data:
      # if key exists exactly
      if key['key'] in ssh_key:
        key_found = True
        typed_message('ssh key already exists in github: %s' % key['title'], 'SKIP')
        print "github.com\t\tkey fingerprint: %s" % line_to_fingerprint(key['key'])
      else:
       if hostname.lower() in key['title'].lower():
        hostname_found = key['id']

    if key_found is False:
      # if hostname is in key title
      if hostname_found:
        typed_message("ssh key contains %s but doesn't match fingerprint. deleting old key." % hostname, 'MATCH')
        delete_github_key_req = make_request('/user/keys/%s' % key['id'], None, 'CLEANUP')
        if delete_github_key_req.getcode() == 204:
          typed_message("old ssh key deleted in github.com %s" % hostname_found, 'CLEANUP')

      # key doesn't exist. add.
      typed_message("adding key to github.com.", 'CREATE')
      post_github_key_req = make_request('/user/keys', { 'title': hostname, 'key': ssh_key })

    print "%s ssh\t\tkey fingerprint: %s" % (hostname, line_to_fingerprint(ssh_key))

    print ''

main()
