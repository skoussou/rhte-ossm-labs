#!/bin/bash

NAMESPACE=$1
SM_CP_NS=$2
DOMAIN_NAME=$3 #eg. apps.ocp4.rhlab.de
PREFIX=$4

cd scripts/federation

./create-premium-insurance-broker.sh premium-broker partner-istio-system $OCP_DOMAIN partner