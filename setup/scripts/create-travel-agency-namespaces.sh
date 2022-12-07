#!/bin/bash

ENV=$1
PARTICIPANTID=$2

set -e

echo ""

echo "Creating user-$PARTICIPANTID $ENV namespaces"
echo "----------------------------------------"

echo "oc create ns user-$PARTICIPANTID-$ENV-travel-control"
oc create ns user-$PARTICIPANTID-$ENV-travel-control --dry-run=client -o yaml | oc apply -f -
echo ""
echo "oc create ns user-$PARTICIPANTID-$ENV-travel-portal"
oc create ns user-$PARTICIPANTID-$ENV-travel-portal --dry-run=client -o yaml | oc apply -f -
echo ""
echo "oc create ns user-$PARTICIPANTID-$ENV-travel-agency"
oc create ns user-$PARTICIPANTID-$ENV-travel-agency --dry-run=client -o yaml | oc apply -f -
echo ""
echo "oc create ns user-$PARTICIPANTID-$ENV-istio-system"
oc create ns user-$PARTICIPANTID-$ENV-istio-system --dry-run=client -o yaml | oc apply -f -
echo ""

