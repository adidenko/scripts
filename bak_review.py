from pygerrit.rest import GerritRestAPI
users = ['dilyin']

rest = GerritRestAPI(url='https://review.openstack.org')
template = '/changes/?q=project:^stackforge/fuel-.*+owner:".*<%s@mirantis.com>"+message:"bug:+"'

for user in users:
    changes = rest.get(template % user)
    print "==============\n"
    print changes
