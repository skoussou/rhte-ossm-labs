#!/bin/bash

FED_1_SMCP_NAMESPACE=$1 #prod-istio-system
FED_1_SMCP_NAME=$2 #production
FED_2_SMCP_NAMESPACE=$3 #partner-istio-system
FED_2_SMCP_NAME=$4 #partner
NAMESPACE=$5 #premium-broker

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
echo '---------------------------------------------------------------------------'
echo
echo

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
  namespace: prod-travel-agency
spec:
  host: insurances
  subsets:
  - name: v1
    labels:
      version: v1
  - name: premium
    labels:
      version: premium"

echo "apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: dr-insurances-versions
  namespace: prod-travel-agency
spec:
  host: insurances
  subsets:
  - name: v1
    labels:
      version: v1
  - name: premium
    labels:
      version: premium"|oc apply -f -

echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
 name: vs-insurances-split
 namespace: prod-travel-agency
spec:
 hosts:
   - insurances.prod-travel-agency.svc.cluster.local
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
            host: insurances.prod-travel-agency.svc.cluster.local
            subset: v1
          weight: 100"

echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
 name: vs-insurances-split
 namespace: prod-travel-agency
spec:
 hosts:
   - insurances.prod-travel-agency.svc.cluster.local
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
            host: insurances.prod-travel-agency.svc.cluster.local
            subset: v1
          weight: 100" |oc apply -f -