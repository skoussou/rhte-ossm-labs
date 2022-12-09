#!/bin/bash

USERNAME=$1
PASSWORD=$2
CLUSTER_API=$3
CLUSTERNAME=$4
BASEDOMAIN=$5
LABPARTICIPANT=$6


set -e

echo '-------------------------------------------------------------------------'
echo 'CLUSTER_API                   : '$CLUSTER_API
echo 'CLUSTER NAME                  : '$CLUSTERNAME
echo 'BASE DOMAIN                   : '$BASEDOMAIN
echo 'LAB PARTICIPANT               : '$LABPARTICIPANT
echo '-------------------------------------------------------------------------'
sleep 5
echo ""

echo "==============================================================="
echo " LOGIN"
echo "==============================================================="
echo
echo
echo '--Logging in with-------------------------------------------------------------------------'
echo 'USERNAME         : '$USERNAME
#echo 'PASSWORD         : '$PASSWORD
echo 'CLUSTER_API      : '$CLUSTER_API
echo '------------------------------------------------------------------------------------------'

echo
#echo "oc login -u $USERNAME -p $PASSWORD $CLUSTER_API"
echo
oc login -u $USERNAME -p $PASSWORD $CLUSTER_API
echo

#VAR="no"
#if [[ "$VAR" == "yes" ]]
#then
#fi

echo
echo "=============================================================================="
echo " Create a secret from the OCP Ingress cert in each user-$LABPARTICIPANT-prod-istio-system"
echo "=============================================================================="
echo
sleep 1

echo "./scripts/rhsso/mount-rhsso-cert-to-istiod.sh user-$LABPARTICIPANT-prod-istio-system user-$LABPARTICIPANT-production $CLUSTERNAME $BASEDOMAIN"
./scripts/rhsso/mount-rhsso-cert-to-istiod.sh user-$LABPARTICIPANT-prod-istio-system user-$LABPARTICIPANT-production $CLUSTERNAME $BASEDOMAIN
