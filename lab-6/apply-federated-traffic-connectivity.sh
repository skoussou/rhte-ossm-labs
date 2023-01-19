#!/bin/bash

FED_1_SMCP_NAMESPACE=$1 #prod-istio-system
FED_1_SMCP_NAME=$2 #production
FED_2_SMCP_NAMESPACE=$3 #partner-istio-system
FED_2_SMCP_NAME=$4 #partner
NAMESPACE=$5 #premium-broker
LAB_PARTICPAND_ID=$6

echo
echo
echo
echo
echo 'Starting Federation Setup ...'
echo
sleep 2
echo
echo '---------------------------------------------------------------------------'
echo 'Federated ServiceMesh Control Plane 1 Namespace        : '$FED_1_SMCP_NAMESPACE
echo 'Federated ServiceMesh Control Plane 1 Tenant Name      : '$FED_1_SMCP_NAME
echo 'Federated ServiceMesh Control Plane 2 Namespace        : '$FED_2_SMCP_NAMESPACE
echo 'Federated ServiceMesh Control Plane 2 Tenant Name      : '$FED_2_SMCP_NAME
echo 'Partner Dataplane Namespace                            : '$NAMESPACE
echo 'LAB Participant Id                                     : '$LAB_PARTICPAND_ID
echo '---------------------------------------------------------------------------'
echo
echo

echo
EXECUTE_FEDERATION="False"
espod=$(oc -n $FED_2_SMCP_NAMESPACE get ServiceMeshPeer/$FED_1_SMCP_NAME -o 'jsonpath={..metadata.name}')
echo "espod: $espod"
sleep 5
if [[ "$espod" == "$FED_1_SMCP_NAME" ]]; then
  EXECUTE_FEDERATION="True"
fi
echo "Apply Federation Setup => "$EXECUTE_FEDERATION
echo
echo
sleep 7

#VAR="no"
#if [[ "$VAR" == "yes" ]]
#then
#fi

echo '###########################################################################'
echo '#                                                                         #'
echo '#   STAGE 3 - Federated Connectivity                                      #'
echo '#                                                                         #'
echo '###########################################################################'

echo
echo
echo '---------------------- Step 4 - Apply Routing Rules  ----------------------'

echo "apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: dr-insurances-versions
  namespace: user-$LAB_PARTICPAND_ID-prod-travel-agency
spec:
  host: insurances
  subsets:
  - name: v1
    labels:
      version: v1
  - name: premium
    labels:
      version: premium"

if [[ "$EXECUTE_FEDERATION" == "True" ]]; then
echo "apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: dr-insurances-versions
  namespace: user-$LAB_PARTICPAND_ID-prod-travel-agency
spec:
  host: insurances
  subsets:
  - name: v1
    labels:
      version: v1
  - name: premium
    labels:
      version: premium"|oc apply -f -
fi
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
 name: vs-insurances-split
 namespace: user-$LAB_PARTICPAND_ID-prod-travel-agency
spec:
 hosts:
   - insurances.user-$LAB_PARTICPAND_ID-prod-travel-agency.svc.cluster.local
 http:
    - match:
        - uri:
            exact: /insurances/London
        - uri:
            exact: /insurances/Rome
        - uri:
            exact: /insurances/Paris
        - uri:
            exact: /insurances/Berlin
        - uri:
            exact: /insurances/Munich
        - uri:
            exact: /insurances/Dublin
      route:
        - destination:
            host: insurances.$NAMESPACE.svc.$FED_2_SMCP_NAME-imports.local
          weight: 100
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: insurances.user-$LAB_PARTICPAND_ID-prod-travel-agency.svc.cluster.local
            subset: v1
          weight: 100"

if [[ "$EXECUTE_FEDERATION" == "True" ]]; then
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
 name: vs-insurances-split
 namespace: user-$LAB_PARTICPAND_ID-prod-travel-agency
spec:
 hosts:
   - insurances.user-$LAB_PARTICPAND_ID-prod-travel-agency.svc.cluster.local
 http:
    - match:
        - uri:
            exact: /insurances/London
        - uri:
            exact: /insurances/Rome
        - uri:
            exact: /insurances/Paris
        - uri:
            exact: /insurances/Berlin
        - uri:
            exact: /insurances/Munich
        - uri:
            exact: /insurances/Dublin
      route:
        - destination:
            host: insurances.$NAMESPACE.svc.$FED_2_SMCP_NAME-imports.local
          weight: 100
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: insurances.user-$LAB_PARTICPAND_ID-prod-travel-agency.svc.cluster.local
            subset: v1
          weight: 100" |oc apply -f -
fi