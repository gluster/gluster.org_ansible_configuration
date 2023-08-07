import boto3

zone_id = 'Z3RC2FKCAES5SW'
region = 'us-east-2'
debug = 1

servers = {}
records_ok = []
ec2 = boto3.client('ec2', region_name=region)
route53 = boto3.client('route53', region_name=region)

response = ec2.describe_instances()
for r in response['Reservations']:
    for i in r['Instances']:
        # this can happen when a host is being erased
        if not 'Tags' in i:
            continue
        name = i['Tags'][0]['Value']
        if 'PublicIpAddress' in i:
            ip = i['PublicIpAddress']
            if name.endswith('int.aws.gluster.org'):
                name = name.split('.')[0] + '.aws.gluster.org'
                if not name in servers:
                    servers[name] = {}
                servers[name]['4'] = ip
            if len(i['NetworkInterfaces'][0]['Ipv6Addresses']):
                ip6 = i['NetworkInterfaces'][0]['Ipv6Addresses'][0]['Ipv6Address']
                servers[name]['6'] = ip6

if debug:
    print(servers)

records = response = route53.list_resource_record_sets(
    HostedZoneId=zone_id,
)
# TODO fix this for IP v6
for r in records['ResourceRecordSets']:
    if r['Type'] == 'A':
        hostname = r['Name'][:-1]
        if hostname in servers.keys():
            if r['ResourceRecords'][0]['Value'] == servers[hostname]:
                records_ok.append(hostname)
if debug:
    print(records_ok)
for s in servers:
    if not s in records_ok:
        response = route53.change_resource_record_sets(
            ChangeBatch={'Changes': [
                {
                    'Action': 'UPSERT',
                    'ResourceRecordSet': {
                        'Name': s,
                        'ResourceRecords': [ {
                            'Value': servers[s]['4'],
                        }, ],
                        'TTL': 60,
                        'Type': 'A',
                    },
                }, {
                    'Action': 'UPSERT',
                    'ResourceRecordSet': {
                        'Name': s,
                        'ResourceRecords': [ {
                            'Value': servers[s]['6'],
                        }, ],
                        'TTL': 60,
                        'Type': 'AAAA',
                       },
                }, ] ,
            'Comment': 'Record managed by a script, do not touch',
        },
        HostedZoneId=zone_id,
        )
        if debug:
            print(response)
