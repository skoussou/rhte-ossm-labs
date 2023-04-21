#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2
BASEDOMAIN=$3

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Namespace                      : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo 'OCP Cluster BaseDomain Name                : '$BASEDOMAIN
echo '---------------------------------------------------------------------------'

echo "Mount the CA secret at the specific location '/cacerts/extra.pem' in istiod pod"
echo "-----------------------------------------------------------------------------"
oc set volume -n $SM_CP_NS deployment/istiod-$SM_TENANT_NAME --remove --name=extracacerts --containers=discovery
echo
echo
sleep 2
echo "oc set volumes -n $SM_CP_NS deployment/istiod-$SM_TENANT_NAME --add  --name=extracacerts  --mount-path=/cacerts  --secret-name=openshift-wildcard  --containers=discovery"
#sleep 3
oc set volumes -n $SM_CP_NS deployment/istiod-$SM_TENANT_NAME --add  --name=extracacerts  --mount-path=/cacerts  --secret-name=openshift-wildcard  --containers=discovery
sleep 5
echo

echo "Verification of the Procedure"
echo "-----------------------------------------------------------------------------"
echo "podname=oc get pods -n $SM_CP_NS | grep istiod-$SM_TENANT_NAME | awk '{print \$1}' | sed '1d'"
#podname=$(oc get pods -n $SM_CP_NS | grep istiod-$SM_TENANT_NAME | awk '{print $1}'  | awk 'NR>1')
podname=$(oc get pods -n $SM_CP_NS | grep istiod-$SM_TENANT_NAME | awk '{print $1}' | sed '1d')
echo
echo "podname=[$podname]"
echo

sleep 2

echo
echo
echo "Check router CA certificate has been loaded in istiod"

echo "oc -n $SM_CP_NS exec $podname -- cat /cacerts/extra.pem"
sleep 7
oc -n $SM_CP_NS exec $podname -- cat /cacerts/extra.pem
