#!/bin/bash

curl -s https://raw.githubusercontent.com/stackforge/gerrit-dash-creator/master/gerrit-dash-creator > /tmp/gerrit-dash-creator 
curl -s https://raw.githubusercontent.com/angdraug/gerrit-dash-creator/fuel-dashboard/dashboards/fuel.dash > /tmp/fuel.dash
python /tmp/gerrit-dash-creator /tmp/fuel.dash
