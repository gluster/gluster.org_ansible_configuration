#!/bin/bash
echo "Keepalived status: $1" > /etc/motd.d/status

{% if address_v6 is defined %}
CMD=del
if [[ $STATUS -eq "master" ]]; then CMD=add; fi;
ip a $CMD {{ address_v6 }} dev {{ interface }}
{% endif %}

{% if notify_script is defined %}
{{ notify_script }} $*
{% endif %}
