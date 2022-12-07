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

echo "==============================================================="
echo " Delete PROD Environment and Users/Roles"
echo "==============================================================="
echo


echo "Delete $ENV Namespaces"
echo "-------------------------------------------------"
echo

for PARTICIPANTID in $( seq 1 $LABPARTICIPANTS )
do
  echo
  echo "Deleting user-$PARTICIPANTID $ENV namespaces"
  echo "----------------------------------------"

  echo "oc delete ns user-$PARTICIPANTID-$ENV-travel-control"
  #oc delete ns user-$PARTICIPANTID-$ENV-travel-control --dry-run=client -o yaml | oc apply -f -
  echo "oc delete ns user-$PARTICIPANTID-$ENV-travel-portal"
  #oc delete ns user-$PARTICIPANTID-$ENV-travel-portal --dry-run=client -o yaml | oc apply -f -
  echo "oc delete ns user-$PARTICIPANTID-$ENV-travel-portal"
  #oc delete ns user-$PARTICIPANTID-$ENV-travel-agency --dry-run=client -o yaml | oc apply -f -
  echo "oc delete ns user-$PARTICIPANTID-$ENV-istio-system"
  #oc delete ns user-$PARTICIPANTID-$ENV-istio-system --dry-run=client -o yaml | oc apply -f -

  sleep 2
done

echo
echo "Deleting Service Mesh Persona Cluster Roles"
echo "-------------------------------------------------"
echo
ls ./resources/roles-resources
#oc apply -f ./resources/roles-resources/mesh-operator.yaml
#oc apply -f ./resources/roles-resources/mesh-developer.yaml
#oc apply -f ./resources/roles-resources/mesh-app-viewer.yaml
#oc get ClusterRole |grep servicemesh

#echo oc delete ClusterRole servicemesh-app-viewer
#echo oc delete ClusterRole servicemesh-developer
#echo oc delete ClusterRole servicemesh-operator-controlplane
#sleep 2

#echo
#echo "Deleting Service Mesh Persona Users"
#echo "-------------------------------------------------"
#ls  ./scripts/users/orig.htpasswd
#cat ./scripts/users/orig.htpasswd
#echo 'oc create secret generic $HTTPASSWD_SECRET --from-file=htpasswd=orig.htpasswd --dry-run=client -o yaml -n openshift-config | oc replace -f -'
#echo

# Maybe not required since namespaces will be deleted
#echo
#echo "Deleting Service Mesh Persona User to Cluster Role Bindings"
#echo "------------------------------------------------------------"
#echo
#ls ./scripts/users/delete/delete-mesh-operator-roles.sh
#ls ./scripts/users/delete/delete-mesh-dev-roles.sh
#ls ./scripts/users/delete/delete-mesh-viewer-roles.sh
#
#for id in $( seq 1 $LABPARTICIPANTS )
#do
#  echo
#  echo "Deleting user/role bindings in user-$id $ENV namespaces"
#  echo "------------------------------------------------------------------"
#  echo
#  echo ./scripts/users/delete-mesh-operator-roles.sh emma	user-$id-dev-istio-system  user-$id-dev-travel-portal:user-$id-dev-travel-control:user-$id-dev-travel-agency
#  sleep 1
#  echo ./scripts/users/delete-mesh-dev-roles.sh cristina user-$id-dev-istio-system  user-$id-dev-travel-portal:user-$id-dev-travel-control
#  sleep 1
#  echo ./scripts/users/delete-mesh-dev-roles.sh farid user-$id-dev-istio-system  user-$id-dev-travel-agency
#  sleep 1
#  echo ./scripts/users/delete-mesh-viewer-roles.sh john user-$id-dev-travel-portal:user-$id-dev-travel-control:user-$id-dev-istio-system
#  sleep 1
#  echo ./scripts/users/delete-mesh-viewer-roles.sh mia user-$id-dev-travel-agency:user-$id-dev-istio-system
#  sleep 1
#  echo ./scripts/users/delete-mesh-viewer-roles.sh mus user-$id-dev-travel-portal:user-$id-dev-travel-control:user-$id-dev-travel-agency:user-$id-dev-istio-system
#
#  sleep 3
#done