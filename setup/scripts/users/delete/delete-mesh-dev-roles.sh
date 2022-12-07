#!/bin/bash

USERNAME=$1
SM_CP_NAMESPACE=$2
DATAPLANE_NAMESPACES=$3

echo
echo "#######################################################################################################################################"
echo "  USAGE: "
echo "          ./delete-mesh-dev-roles.sh <USERNAME> <SERVICEMESH_CP_NAMESPACE> <COLON_DELIMITED_DATAPLANE_NAMESPACES>"
echo "	   eg.  ./delete-mesh-dev-roles.sh nick istio-system travel-agency:travel-control,travel-portal"
echo ""
echo " WARNING: Multiple Namespaces [$DATAPLANE_NAMESPACES] must be seperated by colon `:`"
echo "#######################################################################################################################################"
echo
echo
echo '---------------------------------------------------------------------------'
echo 'USERNAME             : '$USERNAME
echo 'SM_CP_NAMESPACE      : '$SM_CP_NAMESPACE
echo 'DATAPLANE_NAMESPACES : '$DATAPLANE_NAMESPACES
echo '---------------------------------------------------------------------------'
echo
sleep 7
echo

echo "oc adm policy remove-role-from-user view $USERNAME -n $SM_CP_NAMESPACE"
oc adm policy remove-role-from-user view $USERNAME -n $SM_CP_NAMESPACE

echo "oc policy remove-role-from-user --role-namespace $SM_CP_NAMESPACE mesh-user $USERNAME -n $SM_CP_NAMESPACE"
oc policy remove-role-from-user --role-namespace $SM_CP_NAMESPACE mesh-user $USERNAME -n $SM_CP_NAMESPACE

set -f                      # avoid globbing (expansion of *).
array=(${DATAPLANE_NAMESPACES//:/ })
for i in "${!array[@]}"
do
    echo "$i=> oc adm policy remove-role-from-user servicemesh-developer $USERNAME -n ${array[i]}"
    oc adm policy remove-role-from-user servicemesh-developer $USERNAME -n ${array[i]}
done

