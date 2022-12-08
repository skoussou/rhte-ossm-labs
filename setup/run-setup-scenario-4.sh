#!/bin/bash

USERNAME=$1
PASSWORD=$2
CLUSTER_API=$3
CLUSTERNAME=$4
BASEDOMAIN=$5
LABPARTICIPANTS=$6


set -e

echo '-------------------------------------------------------------------------'
echo 'CLUSTER_API                   : '$CLUSTER_API
echo 'CLUSTER NAME                  : '$CLUSTERNAME
echo 'BASE DOMAIN                   : '$BASEDOMAIN
echo 'No. of LAB PARTICIPANTS       : '$LABPARTICIPANTS
echo '-------------------------------------------------------------------------'
sleep 10
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

sleep 3
echo "==============================================================="
echo " Setup Red Hat Signle Sign-On Server (RHSSO)"
echo "==============================================================="
echo

ls ./scripts/rhsso/prerequisites-setup.sh
echo './scripts/rhsso/prerequisites-setup.sh <CLUSTERNAME> <BASEDOMAIN> (eg.for apps.ocp4.example.com  prerequisites-setup.sh ocp4 example.com)'
echo './scripts/rhsso/prerequisites-setup.sh <CLUSTERNAME> <BASEDOMAIN> (eg.for apps.cluster-f4fbs.f4fbs.sandbox354.opentlc.com  prerequisites-setup.sh cluster-f4fbs.f4fbs.sandbox354 opentlc.com)'
echo
sleep 3
#echo ./scripts/rhsso/prerequisites-setup.sh cluster-f4fbs.f4fbs.sandbox354 opentlc.com 5
#./scripts/rhsso/prerequisites-setup.sh cluster-f4fbs.f4fbs.sandbox354 opentlc.com 5
echo './scripts/rhsso/prerequisites-setup.sh $CLUSTERNAME $BASEDOMAIN $LABPARTICIPANTS'
./scripts/rhsso/prerequisites-setup.sh $CLUSTERNAME $BASEDOMAIN $LABPARTICIPANTS

Create a secret from the OCP Ingress cert in each prod-istio-system namespace
(see: https://gitlab.consulting.redhat.com/servicemesh-in-action/ossm-heading-to-production-and-day-2/-/blob/main/scenario-4-onboard-new-portal-with-authentication/scripts/mount-rhsso-cert-to-istiod.sh#L18)


sleep 3
echo "==============================================================="
echo " Setup Red Hat Signle Sign-On Server (RHSSO)"
echo "==============================================================="
echo
