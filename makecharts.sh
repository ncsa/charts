#!/bin/bash

cd $(dirname $0)

# create postgis chart
helm package -d charts ncsa/postgis

# create betydb chart (after copying requirements)
cp charts/postgis-0.1.0.tgz ncsa/betydb/charts
helm package -d charts ncsa/betydb

# create pecan chart (after copying requirements)
cp charts/betydb-0.1.0.tgz  ncsa/pecan/charts
cp charts/rabbitmq-6.4.5.tgz ncsa/pecan/charts
helm package -d charts ncsa/pecan

# create clowder chart (after copying requirements)
#cp charts/rabbitmq-6.4.5.tgz ncsa/pecan/charts
helm package -d charts ncsa/clowder

# create geoserver chart
helm package charts/geoserver -d ncsa/geoserver

# create index of charts
helm repo index charts

# copy charts to opensource
echo rsync -av --delete charts/ opensource:/var/www/charts/

