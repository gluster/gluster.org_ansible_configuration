#!/bin/bash
comment_search_config() {
    sed -i 's/^search/; search/' /etc/resolv.conf
}

