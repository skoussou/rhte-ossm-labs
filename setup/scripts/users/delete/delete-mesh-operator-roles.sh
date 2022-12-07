#!/bin/bash

USERNAME=$1
SM_CP_NAMESPACE=$2
DATAPLANE_NAMESPACES=$3

echo
echo "#######################################################################################################################################"
echo "  USAGE: "
echo "          ./delete-mesh-operator-roles.sh <USERNAME> <SERVICEMESH_CP_NAMESPACE> <COLON_DELIMITED_DATAPLANE_NAMESPACES>"
echo "	   eg.  ./delete-mesh-operator-roles.sh nick istio-system travel-agency:travel-control,travel-portal"
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

echo "oc adm policy remove-cluster-role-from-user servicemesh-operator-controlplane $USERNAME"
oc adm policy remove-cluster-role-from-user servicemesh-operator-controlplane $USERNAME
echo "oc adm policy remove-role-from-user view $USERNAME -n $SM_CP_NAMESPACE"
oc adm policy remove-role-from-user view $USERNAME -n $SM_CP_NAMESPACE
echo "oc adm policy remove-role-from-user servicemesh-operator-pods $USERNAME -n $SM_CP_NAMESPACE"
oc adm policy remove-role-from-user servicemesh-operator-pods $USERNAME -n $SM_CP_NAMESPACE
echo "oc adm policy remove-role-from-user servicemesh-operator-pods $USERNAME -n openshift-operators"
oc adm policy remove-role-from-user servicemesh-operator-pods $USERNAME -n openshift-operators

set -f                      # avoid globbing (expansion of *).
array=(${DATAPLANE_NAMESPACES//:/ })
for i in "${!array[@]}"
do
    echo "$i=> oc adm policy remove-role-from-user servicemesh-operator-pods $USERNAME -n ${array[i]}"
    oc adm policy remove-role-from-user servicemesh-operator-pods $USERNAME -n ${array[i]}
done


