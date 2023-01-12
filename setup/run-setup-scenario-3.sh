#!/bin/bash

OCP_DOMAIN=$1 #apps.cluster-w4h2j.w4h2j.sandbox2385.opentlc.com
LABPARTICIPANTS=$2

echo "OCP_DOMAIN         $OCP_DOMAIN"
echo "LABPARTICIPANTS    $LABPARTICIPANTS"

set -e

echo ""
cd ../lab-3

ls -la
echo ""
sleep 5

./login-as.sh emma

for LAB_PARTICIPANT_ID in $( seq 1 $LABPARTICIPANTS )
do
  ./create-prod-smcp-1-tracing.sh user-$LAB_PARTICIPANT_ID-prod-istio-system user-$LAB_PARTICIPANT_ID-production
done