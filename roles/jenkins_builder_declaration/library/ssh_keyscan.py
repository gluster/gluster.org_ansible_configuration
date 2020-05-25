#!/usr/bin/python
# coding: utf-8 -*-

# (c) 2017, Michael Scherer <mscherer@redhat.com>
#
# This module is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this software.  If not, see <http://www.gnu.org/licenses/>.



from ansible.module_utils.basic import AnsibleModule

def main():
    module = AnsibleModule(
        argument_spec=dict(
            name=dict(required=True),
            ip=dict(required=True),
            port=dict(default='22')
        ),
        supports_check_mode=False
    )

    name = module.params['name']
    ip = module.params['ip']
    port = module.params['port']
    results = {}

    keyscan = module.get_bin_path('ssh-keyscan', True)
    rc, out, err = module.run_command([keyscan, '-p', port, ip])
    for l in out.split('\n'):
        if len(l.split()) > 2:
            t = l.split(' ')[1]
            k = l.split(' ')[2]
            results[t] = k

    module.exit_json(changed=False, keys=results)


main()
