#!/usr/bin/env python
# script that queries github api for ssh keys.
# deletes keys not used in 3 months or never used

import os
import urllib2
from base64 import b64encode, b64decode
import json
from datetime import datetime, timedelta
from python.lib import typed_message, COLORS

base_gh_url = 'https://api.github.com'
__dir = os.path.dirname(__file__)
local_env = {}
env_vars_file = open('%s/../.env' % __dir, 'r')

for line in env_vars_file:
  prop = line.split('=')
  local_env[prop[0]] = prop[1].strip()

get_keys_query = {
  "query": "query { user(login: \"%s\") { publicKeys(first: 100) { edges { node { id \naccessedAt\n fingerprint } } } } }" % (local_env['username'])
}

def make_request(url_path, data = None, method = None):

  request = urllib2.Request(base_gh_url + url_path)
  request.add_header('Content-Type', 'application/json')
  auth_str = 'bearer %s' % (local_env['pw']) if 'graphql' in url_path else 'Basic %s' % (b64encode(local_env['username'] + ':' + local_env['pw']))
  request.add_header('Authorization', auth_str)

  if method:
    request.get_method = lambda: method

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

get_github_keys_req = make_request('/graphql', get_keys_query, 'POST')
if get_github_keys_req.getcode() == 200:
  data = json.load(get_github_keys_req)['data']['user']['publicKeys']['edges']

  def criteria(value):
    orig_date = value['node']['accessedAt']
    if orig_date == None:
      return True

    date_accessed = datetime.strptime(orig_date, '%Y-%m-%dT%H:%M:%SZ')
    time_between_insertion = datetime.now() - date_accessed
    return time_between_insertion.days > 90

  to_be_deleted = [ b64decode(item['node']['id']) for item in data if criteria(item)]

  typed_message("%s of %s" % (len(to_be_deleted), len(data)), "CLEANUP")

  for item in to_be_deleted:
    key = item.split(':')[1].split('PublicKey')[1]
    delete_github_key_req = make_request('/user/keys/%s' % key, None, 'DELETE')
    if delete_github_key_req.getcode() == 204:
      typed_message("old ssh key deleted in github.com %s" % key, 'CLEANUP')
