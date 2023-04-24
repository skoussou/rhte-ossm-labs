#!/bin/bash

SSO_CLIENT_SECRET=$1
OCP_DOMAIN=$2 #apps.cluster-w4h2j.w4h2j.sandbox2385.opentlc.com
LAB_PARTICIPANT_ID=$3


echo
echo "---Values Used-----------------------------------------------"
echo "OCP_DOMAIN:            $OCP_DOMAIN"
echo "LAB_PARTICIPANT_ID:    $LAB_PARTICIPANT_ID"
echo "-------------------------------------------------------------"
set -e

sleep 5

echo
echo "Task 3: Applying default authorization policies"
echo "#################################################"
echo
echo
sleep 3

echo "Step 1 - Verify current default AUTHZ is ALLOW all"
echo "-----------------------------------------------------------"
sleep 3

./login-as.sh emma
echo
echo "----------"

./check-authz-all.sh ALLOW $LAB_PARTICIPANT_ID-prod-istio-system $OCP_DOMAIN $SSO_CLIENT_SECRET $LAB_PARTICIPANT_ID
echo
echo
echo
echo
sleep 2

echo "Step 2 - Apply best practice security pattern to DENY all"
echo "-----------------------------------------------------------"


./login-as.sh farid
echo
echo "----------"
echo "apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-nothing
  namespace: $LAB_PARTICIPANT_ID-prod-travel-agency
spec:
  {}"
echo

echo "apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-nothing
  namespace: $LAB_PARTICIPANT_ID-prod-travel-agency
spec:
  {}" | oc apply -f -


./login-as.sh cristina
echo
echo "----------"
echo "apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-nothing
  namespace: $LAB_PARTICIPANT_ID-prod-travel-control
spec:
  {}  "
echo

echo "apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-nothing
  namespace: $LAB_PARTICIPANT_ID-prod-travel-control
spec:
  {}  " | oc apply -f -

echo
echo
echo
sleep 5

echo "Step 3 - Verify DENY all is applied"
echo "-----------------------------------------------------------"
sleep 3

./login-as.sh emma
echo
echo "----------"
echo
./check-authz-all.sh DENY $LAB_PARTICIPANT_ID-prod-istio-system $OCP_DOMAIN $SSO_CLIENT_SECRET $LAB_PARTICIPANT_ID
echo
echo
echo
echo
sleep 2

echo "Step 4 - Authz policy to allow Travel Dashboard UI access"
echo "-----------------------------------------------------------"
echo
echo "Access Dashboard (RBAC: access denied)"
echo "---------------------------------------"
curl -k https://travel-$LAB_PARTICIPANT_ID.$OCP_DOMAIN/
echo "----------------"
sleep 3
echo
echo
echo "apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: authpolicy-istio-ingressgateway
  namespace: ${LAB_PARTICIPANT_ID}-prod-istio-system
spec:
  selector:
    matchLabels:
      app: istio-ingressgateway
  rules:
    - to:
        - operation:
            paths: [\"*\"]"
echo
echo "apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: authpolicy-istio-ingressgateway
  namespace: ${LAB_PARTICIPANT_ID}-prod-istio-system
spec:
  selector:
    matchLabels:
      app: istio-ingressgateway
  rules:
    - to:
        - operation:
            paths: [\"*\"]" |oc apply -f -
echo
echo
echo
echo "apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-selective-principals-travel-control
  namespace: $LAB_PARTICIPANT_ID-prod-travel-control
spec:
  action: ALLOW
  rules:
    - from:
        - source:
            principals: [\"cluster.local/ns/$LAB_PARTICIPANT_ID-prod-istio-system/sa/istio-ingressgateway-service-account\"]"
echo
echo "apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-selective-principals-travel-control
  namespace: $LAB_PARTICIPANT_ID-prod-travel-control
spec:
  action: ALLOW
  rules:
    - from:
        - source:
            principals: [\"cluster.local/ns/$LAB_PARTICIPANT_ID-prod-istio-system/sa/istio-ingressgateway-service-account\"]"|oc apply -f -

echo
echo
sleep 1
echo
echo "Access Dashboard (200)"
echo "---------------------------------------"
curl -k https://travel-$LAB_PARTICIPANT_ID.$OCP_DOMAIN/
echo "----------------"
echo
echo
sleep 3

echo "Step 5 - Apply fine grained business Authz policies for service to service communications"
echo "------------------------------------------------------------------------------------------"
echo
./login-as.sh farid
echo
echo "----------"
echo "apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
 name: allow-selective-principals-travel-agency
 namespace: $LAB_PARTICIPANT_ID-prod-travel-agency
spec:
 action: ALLOW
 rules:
   - from:
       - source:
           principals: [\"cluster.local/ns/$LAB_PARTICIPANT_ID-prod-istio-system/sa/gto-$LAB_PARTICIPANT_ID-ingressgateway-service-account\",\"cluster.local/ns/$LAB_PARTICIPANT_ID-prod-travel-agency/sa/default\",\"cluster.local/ns/$LAB_PARTICIPANT_ID-prod-travel-portal/sa/default\"]"
sleep 2
echo
echo "apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
 name: allow-selective-principals-travel-agency
 namespace: $LAB_PARTICIPANT_ID-prod-travel-agency
spec:
 action: ALLOW
 rules:
   - from:
       - source:
           principals: [\"cluster.local/ns/$LAB_PARTICIPANT_ID-prod-istio-system/sa/gto-$LAB_PARTICIPANT_ID-ingressgateway-service-account\",\"cluster.local/ns/$LAB_PARTICIPANT_ID-prod-travel-agency/sa/default\",\"cluster.local/ns/$LAB_PARTICIPANT_ID-prod-travel-portal/sa/default\"]" |oc apply -f -


echo "Verify applied business authz policies"
echo "---------------------------------------"
sleep 3

./login-as.sh emma
echo
echo "----------"
echo
./check-authz-all.sh 'ALLOW intra' $LAB_PARTICIPANT_ID-prod-istio-system $OCP_DOMAIN $SSO_CLIENT_SECRET $LAB_PARTICIPANT_ID
echo
echo
echo
