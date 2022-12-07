#!/bin/bash

SM_CP_NS_ORIGINAL=$1
SM_TENANT_NAME_ORIGINAL=$2
PARTICIPANTID=$3

SM_CP_NS=user-$PARTICIPANTID-$SM_CP_NS_ORIGINAL
SM_TENANT_NAME=user-$PARTICIPANTID-$SM_TENANT_NAME

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Namespace                      : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo '---------------------------------------------------------------------------'

echo "Delete Dataplane Namespaces"
oc delete project user-$PARTICIPANTID-travel-control
oc delete project user-$PARTICIPANTID-travel-portal
oc delete project user-$PARTICIPANTID-travel-agency

echo "Delete SMCP Resource [$SM_TENANT_NAME.$SM_CP_NS]"
oc delete smcp/$SM_TENANT_NAME -n $SM_CP_NS

echo "Delete Jaeger Resource [jaeger-small-production.$SM_CP_NS]"
oc delete jaeger jaeger-small-production -n $SM_CP_NS

echo "Delete Controlplane Namespace"
oc delete project SM_CP_NS