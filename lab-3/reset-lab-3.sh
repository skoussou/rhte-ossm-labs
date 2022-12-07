#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Namespace                      : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo '---------------------------------------------------------------------------'

echo "Delete SMCP Resource [$SM_TENANT_NAME.$SM_CP_NS]"
oc delete smcp/$SM_TENANT_NAME -n $SM_CP_NS

echo "Delete Jaeger Resource [jaeger-small-production.$SM_CP_NS]"
oc delete jaeger jaeger-small-production -n $SM_CP_NS


