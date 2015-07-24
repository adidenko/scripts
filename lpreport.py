from launchpadlib.launchpad import Launchpad
import datetime

print datetime.datetime.now()

cachedir = "~/.launchpadlib/cache/"

users = {}
users['fuel'] = ['adidenko', 'akislitsky', 'romcheg', 'a-gordeev', 'omolchanov',
                 'ddmitriev', 'idv1985', 'vsharshov']
users['service'] = ['mgrygoriev', 'sflorczak']
users['partner'] = ['aarzhanov', 'igajsin']
start_date = '2015-06-22'

launchpad = Launchpad.login_anonymously('just testing', 'production', cachedir)

total_fixed = 0
total_closed = 0
for group in users:
    print "\n#####################"
    print "# %s" % group
    for user in users[group]:
        bugs_fixed = 0
        bugs_closed = 0
        print "=================="
        print user
        p = launchpad.people[user]
        list_of_bugs = p.searchTasks(status=["New", "Incomplete", "Invalid",
                                             "Won't Fix", "Confirmed", "Triaged",
                                             "In Progress", "Fix Committed",
                                             "Fix Released", "Opinion", "Expired"],
                                 modified_since=start_date,
                                 milestone='https://api.launchpad.net/1.0/fuel/+milestone/7.0')

        for bug in list_of_bugs:
            bug_milestone = '{0}'.format(bug.milestone).split('/')[-1]
            if bug.assignee is not None and bug.assignee.name == user and bug_milestone == '7.0':
                for task in bug.bug.bug_tasks:
                    milestone = '{0}'.format(task.milestone_link).split('/')[-1]
                    if milestone == '7.0':

                      if (bug.status == "Fix Committed" and str(task.date_fix_committed) > start_date) or \
                              (bug.status == "Fix Released" and str(task.date_fix_released) > start_date):
                          bugs_fixed += 1
                          total_fixed += 1
                          #print "Fixed:  %s" % bug.web_link
                      if bug.status in ["Invalid", "Won't Fix"]:
                          bugs_closed += 1
                          total_closed += 1
                          #print "Closed: %s" % bug.web_link

        print "Bugs fixed:  %s" % bugs_fixed
        print "Bugs closed: %s" % bugs_closed

print "\n#####################"
print "Total fixed:  %s" % total_fixed
print "Total closed: %s" % total_closed

