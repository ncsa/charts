#!/bin/bash

helm package ncsa/$1
helm push -u pusher -p ncsarocks $(ls -1rt $1-*.tgz | tail -1) ncsa
