#!/bin/bash

SSO_CLIENT_SECRET=$1
OCP_DOMAIN=$2 #apps.cluster-w4h2j.w4h2j.sandbox2385.opentlc.com
LAB_PARTICIPANT_ID=$3


SM_TENANT_NAME=user-$LAB_PARTICIPANT_ID-production
SM_CP_NS=user-$LAB_PARTICIPANT_ID-prod-istio-system

echo
echo "---Values Used-----------------------------------------------"
echo "OCP_DOMAIN:            $OCP_DOMAIN"
echo "LAB_PARTICIPANT_ID:    $LAB_PARTICIPANT_ID"
echo "SM_TENANT_NAME:        $SM_TENANT_NAME"
echo "SM_CP_NS:              $SM_CP_NS"
echo "-------------------------------------------------------------"
set -e

sleep 5

echo
echo "Task 2: External API integration with mTLS"
echo "###########################################"
echo
echo
sleep 3

./login-as.sh emma

echo ""

echo "############# Creating additionalIngress in SM Tenant [$SM_TENANT_NAME] in Namespace [$SM_CP_NS ] #############"
echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $SM_TENANT_NAME
spec:
  security:
    dataPlane:
      automtls: true
      mtls: true
  tracing:
    sampling: 500
    type: Jaeger
  general:
    logging:
      logAsJSON: true
  profiles:
    - default
  proxy:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 128Mi
    accessLogging:
      file:
        name: /dev/stdout
    networking:
      trafficControl:
        inbound: {}
        outbound:
          policy: REGISTRY_ONLY
  gateways:
    additionalIngress:
      gto-user-$LAB_PARTICIPANT_ID-ingressgateway:
        enabled: true
        runtime:
          deployment:
            autoScaling:
              enabled: false
        service:
          metadata:
            labels:
              app: gto-user-$LAB_PARTICIPANT_ID-ingressgateway
          selector:
            app: gto-user-$LAB_PARTICIPANT_ID-ingressgateway
    egress:
      enabled: true
      runtime:
        deployment:
          autoScaling:
            enabled: true
            maxReplicas: 2
            minReplicas: 2
        pod: {}
      service: {}
    enabled: true
    ingress:
      enabled: true
      runtime:
        deployment:
          autoScaling:
            enabled: true
            maxReplicas: 2
            minReplicas: 2
        pod: {}
      service: {}
    openshiftRoute:
      enabled: false
  policy:
    type: Istiod
  addons:
    grafana:
      enabled: true
      install:
        config:
          env: {}
          envSecrets: {}
        persistence:
          storageClassName: ""
          accessMode: ReadWriteOnce
          capacity:
            requests:
              storage: 5Gi
          enabled: true
        service:
          ingress:
            contextPath: /grafana
            tls:
              termination: reencrypt
    jaeger:
      install:
        ingress:
          enabled: true
        storage:
          type: Elasticsearch
      name: jaeger-small-production
    kiali:
      enabled: true
    prometheus:
      enabled: true
  runtime:
    components:
      pilot:
        deployment:
          replicas: 2
        pod:
          affinity: {}
        container:
          resources:
          limits: {}
          requirements: {}
      grafana:
        deployment: {}
        pod: {}
      kiali:
        deployment: {}
        pod: {}
  version: v2.3
  telemetry:
    type: Istiod"

echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $SM_TENANT_NAME
spec:
  security:
    dataPlane:
      automtls: true
      mtls: true
  tracing:
    sampling: 500
    type: Jaeger
  general:
    logging:
      logAsJSON: true
  profiles:
    - default
  proxy:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 128Mi
    accessLogging:
      file:
        name: /dev/stdout
    networking:
      trafficControl:
        inbound: {}
        outbound:
          policy: REGISTRY_ONLY
  gateways:
    additionalIngress:
      gto-user-$LAB_PARTICIPANT_ID-ingressgateway:
        enabled: true
        runtime:
          deployment:
            autoScaling:
              enabled: false
        service:
          metadata:
            labels:
              app: gto-user-$LAB_PARTICIPANT_ID-ingressgateway
          selector:
            app: gto-user-$LAB_PARTICIPANT_ID-ingressgateway
    egress:
      enabled: true
      runtime:
        deployment:
          autoScaling:
            enabled: true
            maxReplicas: 2
            minReplicas: 2
        pod: {}
      service: {}
    enabled: true
    ingress:
      enabled: true
      runtime:
        deployment:
          autoScaling:
            enabled: true
            maxReplicas: 2
            minReplicas: 2
        pod: {}
      service: {}
    openshiftRoute:
      enabled: false
  policy:
    type: Istiod
  addons:
    grafana:
      enabled: true
      install:
        config:
          env: {}
          envSecrets: {}
        persistence:
          storageClassName: ""
          accessMode: ReadWriteOnce
          capacity:
            requests:
              storage: 5Gi
          enabled: true
        service:
          ingress:
            contextPath: /grafana
            tls:
              termination: reencrypt
    jaeger:
      install:
        ingress:
          enabled: true
        storage:
          type: Elasticsearch
      name: jaeger-small-production
    kiali:
      enabled: true
    prometheus:
      enabled: true
  runtime:
    components:
      pilot:
        deployment:
          replicas: 2
        pod:
          affinity: {}
        container:
          resources:
          limits: {}
          requirements: {}
      grafana:
        deployment: {}
        pod: {}
      kiali:
        deployment: {}
        pod: {}
  version: v2.3
  telemetry:
    type: Istiod"| oc apply -n $SM_CP_NS -f -

sleep 3
echo
echo
echo "oc wait --for condition=Ready -n $SM_CP_NS smcp/$SM_TENANT_NAME --timeout=300s"
echo
echo
oc wait --for condition=Ready -n $SM_CP_NS smcp/$SM_TENANT_NAME --timeout=300s
echo
echo
oc -n $SM_CP_NS  get smcp/$SM_TENANT_NAME

echo
echo


echo "############# Verify the creation of the additional gateway gto in SM Tenant [$SM_TENANT_NAME] in Namespace [$SM_CP_NS ] #############"

oc get pods -n user-$LAB_PARTICIPANT_ID-prod-istio-system |grep gto
sleep 3
echo
oc get routes -n user-$LAB_PARTICIPANT_ID-prod-istio-system |grep "gto"
sleep 3

echo
echo
echo "############# Setup mtls for additional ingress gateway gto in SM Tenant [$SM_TENANT_NAME] in Namespace [$SM_CP_NS ] #############"
sleep 2
echo
./create-external-mtls-https-ingress-gateway.sh prod-istio-system $OCP_DOMAIN $LAB_PARTICIPANT_ID

sleep 10
echo
echo
echo

echo "############# "
echo "      As Mesh Developer and Travel Services Domain Owner (Tech Lead) farid deploy the Istio Configs in your prod-travel-agency "
echo "      namespace to allow requests via the above defined Gateway to reach the required services cars, insurances, flights, hotels"
echo "      and travels. "
echo "#############"
sleep 3
./login-as.sh farid
./deploy-external-travel-api-mtls-vs.sh user-$LAB_PARTICIPANT_ID-prod user-$LAB_PARTICIPANT_ID-prod-istio-system $LAB_PARTICIPANT_ID

sleep 10

echo
echo
echo
echo
echo

echo "Task 3: Configure Authn and Authz with JWT Tokens"
echo "###########################################"
echo
echo
sleep 3
./login-as.sh emma

echo "-------------TOKEN VERIFICATION--------------------------------------"
echo "apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
 name: jwt-rhsso-gto-external
 namespace: user-$LAB_PARTICIPANT_ID-prod-istio-system
spec:
 selector:
   matchLabels:
     app: gto-user-$LAB_PARTICIPANT_ID-ingressgateway
 jwtRules:
   - issuer: >-
       https://keycloak-rhsso.$OCP_DOMAIN/auth/realms/servicemesh-lab
     jwksUri: >-
       https://keycloak-rhsso.$OCP_DOMAIN/auth/realms/servicemesh-lab/protocol/openid-connect/certs"

sleep 3

echo "apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
 name: jwt-rhsso-gto-external
 namespace: user-$LAB_PARTICIPANT_ID-prod-istio-system
spec:
 selector:
   matchLabels:
     app: gto-user-$LAB_PARTICIPANT_ID-ingressgateway
 jwtRules:
   - issuer: >-
       https://keycloak-rhsso.$OCP_DOMAIN/auth/realms/servicemesh-lab
     jwksUri: >-
       https://keycloak-rhsso.$OCP_DOMAIN/auth/realms/servicemesh-lab/protocol/openid-connect/certs" | oc apply -f -

sleep 3

echo "-------------AUTHZ POLICY WITH TOKEN--------------------------------------"
echo
echo "apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: authpolicy-gto-external
  namespace: user-$LAB_PARTICIPANT_ID-prod-istio-system
spec:
  selector:
    matchLabels:
      app: gto-user-$LAB_PARTICIPANT_ID-ingressgateway
  action: ALLOW
  rules:
  - from:
    - source:
        requestPrincipals: ['*']
    when:
    - key: request.auth.claims[iss]
      values: [\"https://keycloak-rhsso.$OCP_DOMAIN/auth/realms/servicemesh-lab'] "

sleep 3


echo "apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: authpolicy-gto-external
  namespace: user-$LAB_PARTICIPANT_ID-prod-istio-system
spec:
  selector:
    matchLabels:
      app: gto-user-$LAB_PARTICIPANT_ID-ingressgateway
  action: ALLOW
  rules:
  - from:
    - source:
        requestPrincipals: ['*']
    when:
    - key: request.auth.claims[iss]
      values: ['https://keycloak-rhsso.$OCP_DOMAIN/auth/realms/servicemesh-lab'] " | oc apply -f -

sleep 3

echo
echo
echo
echo
echo

echo "Task 4: Test Authn / Authz with JWT"
echo "###################################"
echo
echo
sleep 3
./login-as.sh emma

export GATEWAY_URL=$(oc -n user-$LAB_PARTICIPANT_ID-prod-istio-system get route gto-user-$LAB_PARTICIPANT_ID -o jsonpath='{.spec.host}')
echo $GATEWAY_URL

echo "-------------TESTS WITHOUT TOKEN EXPECTED TO FAIL (403: RBAC: ACCESS DENIED)--------------------------------------"
echo
sleep 3

curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt https://$GATEWAY_URL/cars/Tallinn
sleep 2
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt https://$GATEWAY_URL/travels/Tallinn
sleep 2

echo
echo
echo

echo "-------------TESTS WITH JWT TOKEN --------------------------------------"
echo
sleep 3


TOKEN=$(curl -Lk --data "username=gtouser&password=gtouser&grant_type=password&client_id=istio-user-$LAB_PARTICIPANT_ID&client_secret=$SSO_CLIENT_SECRET" https://keycloak-rhsso.$OCP_DOMAIN/auth/realms/servicemesh-lab/protocol/openid-connect/token | jq .access_token)

echo
echo "----- TOKEN RECEIVED FOR GTO USER BEFORE AUTHZ TESTS-----"
echo $TOKEN
echo "---------------------------------------------------------"
sleep 2

./call-via-mtls-and-jwt-travel-agency-api.sh user-$LAB_PARTICIPANT_ID-prod-istio-system gto-user-$LAB_PARTICIPANT_ID $TOKEN
