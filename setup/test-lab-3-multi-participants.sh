#!/bin/bash

OCP_DOMAIN=$1 #apps.cluster-w4h2j.w4h2j.sandbox2385.opentlc.com
LABPARTICIPANTS=$2

echo "OCP_DOMAIN         $OCP_DOMAIN"
echo "LABPARTICIPANTS    $LABPARTICIPANTS"

set -e

echo ""
cd ../lab-3

#ls -la
#echo ""
#sleep 5

#./login-as.sh emma

#for LAB_PARTICIPANT_ID in $( seq 1 $LABPARTICIPANTS )
#do
#  ./create-prod-smcp-1-tracing.sh user-$LAB_PARTICIPANT_ID-prod-istio-system user-$LAB_PARTICIPANT_ID-production
#done

sleep 10

for LAB_PARTICIPANT_ID in $( seq 1 $LABPARTICIPANTS )
do
  ./login-as.sh farid
  ./create-membership.sh user-$LAB_PARTICIPANT_ID-prod-istio-system user-$LAB_PARTICIPANT_ID-production user-$LAB_PARTICIPANT_ID-prod-travel-agency
  sleep 12
  ./check-project-labels.sh user-$LAB_PARTICIPANT_ID-prod-travel-agency
  ./deploy-travel-services-domain.sh prod prod-istio-system $LAB_PARTICIPANT_ID
done

sleep 90

for LAB_PARTICIPANT_ID in $( seq 1 $LABPARTICIPANTS )
do
  ./login-as.sh cristina
  ./create-membership.sh user-$LAB_PARTICIPANT_ID-prod-istio-system user-$LAB_PARTICIPANT_ID-production user-$LAB_PARTICIPANT_ID-prod-travel-control
  sleep 7
  ./check-project-labels.sh user-$LAB_PARTICIPANT_ID-prod-travel-control
  ./create-membership.sh user-$LAB_PARTICIPANT_ID-prod-istio-system user-$LAB_PARTICIPANT_ID-production user-$LAB_PARTICIPANT_ID-prod-travel-portal
  sleep 7
  ./check-project-labels.sh user-$LAB_PARTICIPANT_ID-prod-travel-portal
  ./deploy-travel-portal-domain.sh prod prod-istio-system $OCP_DOMAIN $LAB_PARTICIPANT_ID
  sleep 10
done

for LAB_PARTICIPANT_ID in $( seq 1 $LABPARTICIPANTS )
do
  ./login-as.sh emma
  ./create-https-ingress-gateway.sh prod-istio-system $OCP_DOMAIN $LAB_PARTICIPANT_ID
  ./update-prod-smcp-2-prometheus.sh user-$LAB_PARTICIPANT_ID-prod-istio-system
  sleep 10
  ./update-prod-smcp-3-final.sh user-$LAB_PARTICIPANT_ID-prod-istio-system user-$LAB_PARTICIPANT_ID-production
done