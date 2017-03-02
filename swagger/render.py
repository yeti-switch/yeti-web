#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys, yaml, jinja2

if len(sys.argv) < 4 or sys.argv[1] in ['-h','--help']:
	print '''
usage: %s v.yml t.j2 version
  v.yml - YAML file with variables for template
  t.j2  - jinja2 template to render
  version - version string to insert into specs
''' % sys.argv[0]
	raise SystemExit(1)

a = yaml.load(open(sys.argv[1]))
a['version'] = sys.argv[3]

e = jinja2.Environment()
e.loader = jinja2.FileSystemLoader('.')

print e.get_template(sys.argv[2]).render(a).encode('utf-8')
