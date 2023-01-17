#!/bin/bash

OCP_DOMAIN=$1 #apps.cluster-w4h2j.w4h2j.sandbox2385.opentlc.com
LABPARTICIPANTS=$2

echo "OCP_DOMAIN         $OCP_DOMAIN"
echo "LABPARTICIPANTS    $LABPARTICIPANTS"

set -e

echo ""
cd ../lab-3

#ls -la
echo ""
sleep 5

./login-as.sh emma

for LAB_PARTICIPANT_ID in $( seq 1 $LABPARTICIPANTS )
do
  #./create-prod-smcp-1-tracing.sh user-$LAB_PARTICIPANT_ID-prod-istio-system user-$LAB_PARTICIPANT_ID-production


  SM_CP_NS=user-$LAB_PARTICIPANT_ID-prod-istio-system
  SM_TENANT_NAME=user-$LAB_PARTICIPANT_ID-production

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

done
