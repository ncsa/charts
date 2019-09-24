#!/bin/bash

cd $(dirname $0)

# create postgis chart
helm package -d charts ncsa/postgis

# create bety chart (after copying requirements)
cp charts/postgis-0.1.0.tgz ncsa/bety/charts
helm package -d charts ncsa/bety

# create pecan chart (after copying requirements)
cp charts/bety-0.1.0.tgz  ncsa/pecan/charts
cp charts/rabbitmq-6.4.5.tgz ncsa/pecan/charts
helm package -d charts ncsa/pecan

# create clowder chart (after copying requirements)
#cp charts/rabbitmq-6.4.5.tgz ncsa/pecan/charts
helm package -d charts ncsa/clowder

# create index of charts
helm repo index charts

# copy charts to isda
#rsync -av --delete charts/ snuffy:public_html/charts/
