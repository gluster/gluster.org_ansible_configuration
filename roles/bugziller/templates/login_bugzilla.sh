#!/bin/bash
# we try to make sure jenkins can't read this file, even if stealing the cookie might be equivalent
su '{{ user }}' -c 'bugzilla --ensure-logged-in  info  -o GlusterFS >/dev/null' || su '{{ user }}' -c 'bugzilla login {{ bugzilla_user }} {{ bugzilla_pass | regex_escape }}' 
