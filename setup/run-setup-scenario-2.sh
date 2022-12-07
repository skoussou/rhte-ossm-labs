#!/bin/bash

USERNAME=$1
PASSWORD=$2
CLUSTER_API=$3
LABPARTICIPANTS=$4
HTTPASSWD_SECRET=$5 #oc get secret  -n openshift-config |grep htpasswd

ENV=prod

set -e

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

VAR="no"
if [[ "$VAR" == "yes" ]]
then


#sleep 3
#echo "==============================================================="
#echo " Setup Operators"
#echo "==============================================================="
#echo
#echo "Adding OSSM Related Operators"

#echo "./scripts/add-operators-subscriptions-sm.sh"
#./scripts/add-operators-subscriptions-sm.sh

echo

sleep 3
echo "==============================================================="
echo " Setup $ENV Environment and Users/Roles"
echo "==============================================================="
echo

echo "Creating Namespaces for $ENV"
echo "-------------------------------------------------"
echo

for id in $( seq 1 $LABPARTICIPANTS )
do
  #echo "./scripts/create-travel-agency-namespaces.sh $ENV $id"
  ./scripts/create-travel-agency-namespaces.sh $ENV $id
  sleep 2
done

#echo
#echo "Creating Service Mesh Persona Cluster Roles"
#echo "-------------------------------------------------"
#echo
#echo 'oc apply -f ./resources/roles-resources/mesh-operator.yaml'
#oc apply -f ./resources/roles-resources/mesh-operator.yaml
#sleep 1
#echo 'oc apply -f ./resources/roles-resources/mesh-developer.yaml'
#oc apply -f ./resources/roles-resources/mesh-developer.yaml
#sleep 1
#echo 'oc apply -f ./resources/roles-resources/mesh-app-viewer.yaml'
#oc apply -f ./resources/roles-resources/mesh-app-viewer.yaml
#sleep 3
#echo
#oc get ClusterRole servicemesh-app-viewer
#sleep 1
#oc get ClusterRole servicemesh-developer
#sleep 1
#oc get ClusterRole servicemesh-operator-controlplane
#sleep 2

echo
echo "Creating Service Mesh Persona Users for $ENV"
echo "-------------------------------------------------"
echo
ls ./scripts/users/add-prod-environment-htpasswd-users.sh
#echo ./scripts/users/add-prod-environment-htpasswd-users.sh $HTTPASSWD_SECRET
./scripts/users/add-prod-environment-htpasswd-users.sh $HTTPASSWD_SECRET
sleep 2

# USING TO TEST WHERE THIS FILE IS SO AS TO DEFINE IT IN THE reset-setup-scenario-1.sh ls  ./scripts/users/orig.htpasswd
#ls  orig.htpasswd
# USING TO TEST WHERE THIS FILE IS SO AS TO DEFINE IT IN THE reset-setup-scenario-1.sh cat ./scripts/users/orig.htpasswd
#cat orig.htpasswd
#sleep 3

fi

echo
echo "Creating Service Mesh Persona User to Cluster Role Bindings"
echo "------------------------------------------------------------"
echo

for id in $( seq 1 $LABPARTICIPANTS )
do
  echo
  echo "Creating user/role bindings in user-$id $ENV namespaces"
  echo "------------------------------------------------------------------"
  echo
  ./scripts/users/create-mesh-operator-roles.sh emma user-$id-$ENV-istio-system  user-$id-$ENV-travel-portal:user-$id-$ENV-travel-control:user-$id-$ENV-travel-agency
  #echo ./scripts/users/create-mesh-operator-roles.sh emma user-$id-$ENV-istio-system  user-$id-$ENV-travel-portal:user-$id-$ENV-travel-control:user-$id-$ENV-travel-agency
  sleep 1
  ./scripts/users/create-mesh-dev-roles.sh cristina user-$id-$ENV-istio-system  user-$id-$ENV-travel-portal:user-$id-$ENV-travel-control
  #echo ./scripts/users/create-mesh-dev-roles.sh cristina user-$id-$ENV-istio-system  user-$id-$ENV-travel-portal:user-$id-$ENV-travel-control
  sleep 1
  ./scripts/users/create-mesh-dev-roles.sh farid user-$id-$ENV-istio-system  user-$id-$ENV-travel-agency
  #echo ./scripts/users/create-mesh-dev-roles.sh farid user-$id-$ENV-istio-system  user-$id-$ENV-travel-agency
  sleep 1
  ./scripts/users/create-mesh-viewer-roles.sh craig user-$id-$ENV-travel-portal:user-$id-$ENV-travel-control:user-$id-$ENV-travel-agency:user-$id-$ENV-istio-system
  #echo ./scripts/users/create-mesh-viewer-roles.sh craig user-$id-$ENV-travel-portal:user-$id-$ENV-travel-control:user-$id-$ENV-travel-agency:user-$id-$ENV-istio-system
  sleep 3
  echo
  echo
done

#echo
#echo "Creating Control Plane for each SM tenant"
#echo "------------------------------------------------------------"
#echo
#
#for id in $( seq 1 $LABPARTICIPANTS )
#do
#  echo
#  echo "Creating SMCP tenant for user-$id"
#  echo "------------------------------------------------------------------"
#  echo
#
#  echo ./scripts/dev/create-dev-smcp.sh user-$id-dev-istio-system user-$id-dev-basic
#  ./scripts/dev/create-dev-smcp.sh user-$id-dev-istio-system user-$id-dev-basic
#
#  sleep 5
#  #sleep 2
#done

#echo
#echo "Creating SMM resources to each tenant"
#echo "------------------------------------------------------------"
#echo
#for id in $( seq 1 $LABPARTICIPANTS )
#do
#  echo
#  echo ./scripts/create-membership.sh user-$id-dev-istio-system user-$id-dev-basic user-$id-dev-travel-agency
#  ./scripts/create-membership.sh user-$id-dev-istio-system user-$id-dev-basic user-$id-dev-travel-agency
#  sleep 1
#  echo ./scripts/create-membership.sh user-$id-dev-istio-system user-$id-dev-basic user-$id-dev-travel-control
#  ./scripts/create-membership.sh user-$id-dev-istio-system user-$id-dev-basic user-$id-dev-travel-control
#  sleep 1
#  echo ./scripts/create-membership.sh user-$id-dev-istio-system user-$id-dev-basic user-$id-dev-travel-portal
#  ./scripts/create-membership.sh user-$id-dev-istio-system user-$id-dev-basic user-$id-dev-travel-portal
#  sleep 2
#done

#echo "Deploy applications into DEV namespaces"
#echo "------------------------------------------------------------"
#echo
#for id in $( seq 1 $LABPARTICIPANTS )
#do
#  echo
#  ./scripts/dev/deploy-travel-services-domain.sh dev dev-istio-system $id
#  ./scripts/dev/deploy-travel-portal-domain.sh dev dev-istio-system $id
#  sleep 2
#done

#echo
#echo "Expose Travel Agency UI externally via Istio Gateway"
#echo "------------------------------------------------------------"
#echo
#for id in $( seq 1 $LABPARTICIPANTS )
#do
#  ./scripts/dev/create-ingress-gateway.sh user-$id-dev-istio-system
#  sleep 1
#  echo
#  echo '------------------------------------------------------------------------------------------------------------------------'
#  echo "user-$id tenant Travel Agency UI URL: http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n user-$id-dev-istio-system)"
#  echo '------------------------------------------------------------------------------------------------------------------------'
#  echo
#done

