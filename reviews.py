from pygerrit.rest import GerritRestAPI
import datetime

start_date = '2015-06-22'
report_date = '2015-07-25'
branch = 'master'

users = {}
users['fuel'] = ['adidenko', 'akislitsky', 'rprikhodchenko', 'agordeev',
                 'omolchanov', 'ddmitriev', 'dilyin', 'vsharshov']
users['service'] = ['mgrygoriev', 'sflorczak', 'pstefanski']
users['partner'] = ['aarzhanov', 'igajsin']

##########################

one_week_ago_date = datetime.datetime.strptime(report_date, '%Y-%m-%d') - datetime.timedelta(weeks=1)
two_weeks_ago_date = datetime.datetime.strptime(report_date, '%Y-%m-%d') - datetime.timedelta(weeks=2)

print str(one_week_ago_date)
print str(two_weeks_ago_date)

rest = GerritRestAPI(url='https://review.openstack.org')
projects = ['^stackforge/fuel-.*', '^stackforge/python-fuel.*']
template = '/changes/?q=project:%s+owner:".*<%s@mirantis.com>"+message:"bug:+"'

total_merged = 0
total_merged_last_week = 0
total_merged_prev_week = 0

total_open = 0
total_open_last_week = 0
total_open_prev_week = 0

for group in users:
    print "\n#####################"
    print "# %s" % group
    for user in users[group]:
        print "=================="
        print user
        fixes_merged = 0
        fixes_merged_last_week = 0
        fixes_merged_prev_week = 0
        fixes_open = 0
        fixes_open_last_week = 0
        fixes_open_prev_week = 0
        for project in projects:
          changes = rest.get(template % (project, user))
          for change in changes:
              if change['branch'] != branch or change['status'] == 'ABANDONED':
                  continue
              if change['created'] > start_date and change['created'] < report_date:
                  if change['status'] == 'MERGED':
                      fixes_merged += 1
                      total_merged += 1
                      if change['created'] > str(one_week_ago_date):
                          fixes_merged_last_week += 1
                          total_merged_last_week += 1
                      elif change['created'] > str(two_weeks_ago_date):
                          fixes_merged_prev_week += 1
                          total_merged_prev_week += 1
                  else:
                      fixes_open += 1
                      total_open += 1
                      if change['created'] > str(one_week_ago_date):
                          fixes_open_last_week += 1
                          total_open_last_week += 1
                      elif change['created'] > str(two_weeks_ago_date):
                          fixes_open_prev_week += 1
                          total_open_prev_week += 1
        print "Fixes open:               %s" % fixes_open
        print "Fixes merged:             %s" % fixes_merged
        print "Fixes open (this week):   %s" % fixes_open_last_week
        print "Fixes merged (this week): %s" % fixes_merged_last_week
        print "Fixes open (last week):   %s" % fixes_open_prev_week
        print "Fixes merged (last week): %s" % fixes_merged_prev_week

print "\n#####################"
print "Total open:               %s" % total_open
print "Total merged:             %s" % total_merged
print "Total open (this week):   %s" % total_open_last_week
print "Total merged (this week): %s" % total_merged_last_week
print "Total open (last week):   %s" % total_open_prev_week
print "Total merged (last week): %s" % total_merged_prev_week

