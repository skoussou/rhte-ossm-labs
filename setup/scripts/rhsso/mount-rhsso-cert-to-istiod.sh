#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2
CLUSTERNAME=$3
BASEDOMAIN=$4

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Namespace                      : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo 'OCP Cluster Name                           : '$CLUSTERNAME
echo 'OCP Cluster BaseDomain Name                : '$BASEDOMAIN
echo '---------------------------------------------------------------------------'

echo
echo
sleep 7
echo "Retrieve the CA certificate from secret in openshift-ingress-operator project"
echo "-----------------------------------------------------------------------------"
rm -rf /tmp/$SM_TENANT_NAME
mkdir -p /tmp/$SM_TENANT_NAME
echo "oc extract secret/router-ca -n openshift-ingress-operator --to=/tmp/$SM_TENANT_NAME"
sleep 5
oc extract secret/router-ca -n openshift-ingress-operator --confirm --to=/tmp/$SM_TENANT_NAME
sleep 3
echo

echo "Create a secret from this CA certificate in $SM_CP_NS project"
echo "-----------------------------------------------------------------------------"
oc -n $SM_CP_NS delete secret/openshift-wildcard
echo "oc -n $SM_CP_NS create secret generic openshift-wildcard --from-file=extra.pem=/tmp/$SM_TENANT_NAME/tls.crt"
#sleep 2
oc -n $SM_CP_NS create secret generic openshift-wildcard --from-file=extra.pem=/tmp/$SM_TENANT_NAME/tls.crt
sleep 1
echo

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
#podname=$(echo podname| sed '1d')
#echo "2nd time [$podname]"
sleep 2

# RSH to istiod pod
#echo "oc -n $SM_CP_NS rsh $podname"
#oc -n $SM_CP_NS rsh $podname
echo
echo
echo "Check connection to RHSSO without the CA"
#[pod] sh-4.4$ curl -I https://keycloak-rhsso.apps.<CLUSTERNAME>.<BASEDOMAIN>/auth/
echo "oc -n $SM_CP_NS exec $podname -- curl -I https://keycloak-rhsso.apps.$CLUSTERNAME.$BASEDOMAIN/auth/"
sleep 7
oc -n $SM_CP_NS exec $podname -- curl -I https://keycloak-rhsso.apps.$CLUSTERNAME.$BASEDOMAIN/auth/
#curl: (60) SSL certificate problem: self signed certificate in certificate chain
echo
echo
sleep 3

echo "Check connection to RHSSO with the CA"
#[pod] sh-4.4$ curl --cacert /cacerts/extra.pem -I https://keycloak-rhsso.apps.<CLUSTERNAME>.<BASEDOMAIN>/auth/
echo "oc -n $SM_CP_NS exec $podname -- curl --cacert /cacerts/extra.pem -I https://keycloak-rhsso.apps.$CLUSTERNAME.$BASEDOMAIN/auth/"
sleep 3
oc -n $SM_CP_NS exec $podname -- curl --cacert /cacerts/extra.pem -I https://keycloak-rhsso.apps.$CLUSTERNAME.$BASEDOMAIN/auth/
#HTTP/1.1 200 OK
echo
echo





