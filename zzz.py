from launchpadlib.launchpad import Launchpad
import datetime


cachedir = "~/.launchpadlib/cache/"

users = {}
users['fuel'] = ['adidenko']
#users['fuel'] = ['adidenko', 'akislitsky', 'romcheg', 'a-gordeev', 'omolchanov',
#                 'ddmitriev', 'idv1985', 'vsharshov']
#users['service'] = ['mgrygoriev', 'sflorczak']
#users['partner'] = ['aarzhanov', 'igajsin']
start_date = '2015-06-22'

launchpad = Launchpad.login_anonymously('just testing', 'production', cachedir)

bug = launchpad.bugs[1306792]

print dir(bug)
print bug.tags

#for act in bug.activity:
#    print type(act)
