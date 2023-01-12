#!/bin/bash

OCP_DOMAIN=$1 #apps.cluster-w4h2j.w4h2j.sandbox2385.opentlc.com
LAB_PARTICIPANT_ID=$2

echo
echo "---Values Used-----------------------------------------------"
echo "OCP_DOMAIN:            $OCP_DOMAIN"
echo "LAB_PARTICIPANT_ID:    $LAB_PARTICIPANT_ID"
echo "-------------------------------------------------------------"

set -e

echo ""

sleep 5

./login-as.sh farid
./create-membership.sh user-$LAB_PARTICIPANT_ID-prod-istio-system user-$LAB_PARTICIPANT_ID-production user-$LAB_PARTICIPANT_ID-prod-travel-agency
echo "waiting for membership annotations to be applied to the user-$LAB_PARTICIPANT_ID-prod-travel-agency"
sleep 10
./check-project-labels.sh user-$LAB_PARTICIPANT_ID-prod-travel-agency
./deploy-travel-services-domain.sh prod prod-istio-system $LAB_PARTICIPANT_ID

sleep 10


./login-as.sh cristina
./create-membership.sh user-$LAB_PARTICIPANT_ID-prod-istio-system user-$LAB_PARTICIPANT_ID-production user-$LAB_PARTICIPANT_ID-prod-travel-control
echo "waiting for membership annotations to be applied to the user-$LAB_PARTICIPANT_ID-prod-travel-control namespace"
sleep 10
./check-project-labels.sh user-$LAB_PARTICIPANT_ID-prod-travel-control
./create-membership.sh user-$LAB_PARTICIPANT_ID-prod-istio-system user-$LAB_PARTICIPANT_ID-production user-$LAB_PARTICIPANT_ID-prod-travel-portal
echo "waiting for membership annotations to be applied to the user-$LAB_PARTICIPANT_ID-prod-travel-portal namespace"
sleep 10
./check-project-labels.sh user-$LAB_PARTICIPANT_ID-prod-travel-portal
./deploy-travel-portal-domain.sh prod prod-istio-system $OCP_DOMAIN $LAB_PARTICIPANT_ID
sleep 10

./login-as.sh emma
./create-https-ingress-gateway.sh prod-istio-system $OCP_DOMAIN $LAB_PARTICIPANT_ID
./update-prod-smcp-2-prometheus.sh user-$LAB_PARTICIPANT_ID-prod-istio-system
sleep 10
./update-prod-smcp-3-final.sh user-$LAB_PARTICIPANT_ID-prod-istio-system user-$LAB_PARTICIPANT_ID-production
