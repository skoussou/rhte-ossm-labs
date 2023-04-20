#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Namespace                      : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo '---------------------------------------------------------------------------'

echo "############# Creating jaeger-small-production Resource in Namespace [$SM_CP_NS ] #############"

echo "apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: jaeger-small-production
spec:
  strategy: production
  storage:
    type: elasticsearch
    esIndexCleaner:
      enabled: true                                 // turn the cron job deployment on and off
      numberOfDays: 7                               // number of days to wait before deleting a record
      schedule: 55 23 * * *                       // cron expression for it to run
    elasticsearch:
      nodeCount: 1                                    // 1 Elastic Search Node
      storage:
        size: 1Gi
      resources:
        requests:
          cpu: 200m
          memory: 1Gi
        limits:
          memory: 1500Mi
      redundancyPolicy: ZeroRedundancy              // Index redundancy"

echo "apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: jaeger-small-production
spec:
  strategy: production
  storage:
    type: elasticsearch
    esIndexCleaner:
      enabled: true
      numberOfDays: 7
      schedule: '55 23 * * *'
    elasticsearch:
      nodeCount: 1
      storage:
        size: 1Gi
      resources:
        requests:
          cpu: 200m
          memory: 1Gi
        limits:
          memory: 1500Mi
      redundancyPolicy: ZeroRedundancy"| oc apply -n $SM_CP_NS -f -


echo
echo "------------------------------------ CHECK ELASTIC SEARCH STATUS ------------------------------------"
echo
espod="False"
while [ "$espod" != "True" ]; do
  sleep 5
  espod=$(oc -n $SM_CP_NS get pods -l component=elasticsearch -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}')
  echo "Elastic Search POD Ready => "$espod
done
sleep 1
echo
echo "------------------------------------ CHECK JAEGER COLLECTOR STATUS ------------------------------------"
echo
jaegercollectorpod="False"
while [ "$jaegercollectorpod" != "True" ]; do
  sleep 5
  jaegercollectorpod=$(oc -n $SM_CP_NS get pods -l app.kubernetes.io/component=collector -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}')
  echo "Jaeger Collector POD Ready => "$jaegercollectorpod
done
sleep 1
echo
echo "------------------------------------ CHECK JAEGER QUERY STATUS ------------------------------------"
echo
jaegerquerypod="False"
while [ "$jaegerquerypod" != "True" ]; do
  sleep 5
  jaegerquerypod=$(oc -n $SM_CP_NS get pods -l app.kubernetes.io/component=query -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}')
  echo "Jaeger Query POD Ready => "$jaegerquerypod
done
sleep 1
echo
oc -n $SM_CP_NS get deployment
echo
oc -n $SM_CP_NS get jaeger/jaeger-small-production
echo
echo
echo
echo
sleep 10
echo "############# Creating SM Tenant [$SM_TENANT_NAME] in Namespace [$SM_CP_NS ] #############"
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

travelurl=https://$(oc get route travel -o jsonpath='{.spec.host}' -n $SM_CP_NS)
kialiurl=https://$(oc get route kiali -o jsonpath='{.spec.host}' -n $SM_CP_NS)

echo "============================================================================================================================================"
echo "Check that the Travel Dashboard is accessible at the secured $travelurl"
echo "Login at $kialiurl as emma/emma and verify the App Graph shows traffic via istio-ingress gateway"
echo "============================================================================================================================================"