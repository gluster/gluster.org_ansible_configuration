#!/bin/bash
echo "Keepalived status: $1" > /etc/motd.d/status

{% if notify_script is defined %}
{{ notify_script }} $*
{% endif %}
