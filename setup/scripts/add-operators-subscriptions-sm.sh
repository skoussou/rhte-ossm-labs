#!/bin/bash

echo "oc create ns openshift-operators-redhat"   
oc create ns openshift-operators-redhat
sleep 4
echo "oc create ns openshift-distributed-tracing"
oc create ns openshift-distributed-tracing
sleep 4
echo "################# Adding Operator elasticsearch-operator #################"
echo "kind: ServiceAccount
apiVersion: v1
metadata:
  name: elasticsearch-operator
  namespace: openshift-operators-redhat" | oc apply -f -
echo "apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  annotations:
    olm.providedAPIs: Elasticsearch.v1.logging.openshift.io,Kibana.v1.logging.openshift.io
  generateName: openshift-operators-redhat-
  namespace: openshift-operators-redhat
spec: {}" |oc create -f -

echo "apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: elasticsearch-operator
  namespace: openshift-operators-redhat
spec:
  channel: stable
  installPlanApproval: Automatic
  name: elasticsearch-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace" | oc apply -f -  

echo 'apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: elasticsearch-operator
  namespace: openshift-operators-redhat
spec:
  channel: stable
  installPlanApproval: Automatic
  name: elasticsearch-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace | oc apply -f -  '

echo 'sleeping 20s'
sleep 20



echo "################# Adding Operator jaeger-product #################"
echo "kind: ServiceAccount
apiVersion: v1
metadata:
  name: jaeger-operator
  namespace: openshift-distributed-tracing" | oc apply -f -
echo "apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  annotations:
    olm.providedAPIs: Elasticsearch.v1.logging.openshift.io,Kibana.v1.logging.openshift.io
  generateName: openshift-distributed-tracing-
  namespace: openshift-distributed-tracing
spec: {}" | oc create -f -

echo "apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: jaeger-product
  namespace: openshift-distributed-tracing
spec:
  channel: stable
  installPlanApproval: Automatic
  name: jaeger-product
  source: redhat-operators
  sourceNamespace: openshift-marketplace
"

echo "apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: jaeger-product
  namespace: openshift-distributed-tracing
spec:
  channel: stable
  installPlanApproval: Automatic
  name: jaeger-product
  source: redhat-operators
  sourceNamespace: openshift-marketplace" | oc apply -f -    

echo 'sleeping 20s'
sleep 20

echo
echo "------------------------------------ CHECK Distributed Tracing Operator STATUS ------------------------------------"
echo
jop="False"
while [ "$jop" != "Succeeded" ]; do
  sleep 5
  jop=$(oc get csv/jaeger-operator.v1.39.0-3 -n openshift-distributed-tracing -o 'jsonpath={..status.phase}')
  echo "Jaeger Operator Status => "$jop
done
sleep 1
echo


echo "################# Adding Operator kiali-ossm #################"   
echo "
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-ossm
  namespace: openshift-operators  
spec:
  channel: stable
  installPlanApproval: Automatic
  name: kiali-ossm
  source: redhat-operators
  sourceNamespace: openshift-marketplace
"

echo "apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-ossm
  namespace: openshift-operators  
spec:
  channel: stable
  installPlanApproval: Automatic
  name: kiali-ossm
  source: redhat-operators
  sourceNamespace: openshift-marketplace" | oc apply -f -   

#echo 'sleeping 20s'
sleep 20

echo
echo "------------------------------------ CHECK KIALI Operator STATUS ------------------------------------"
echo
kop="False"
while [ "$kop" != "Succeeded" ]; do
  sleep 5
  kop=$(oc get csv/kiali-operator.v1.57.3 -n openshift-operators -o 'jsonpath={..status.phase}')
  echo "KIALI Operator Status => "$kop
done
sleep 1
echo

echo "################# Adding Operator servicemeshoperator #################"   
echo "
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: servicemeshoperator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
"

echo "apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: servicemeshoperator
  source: redhat-operators
  sourceNamespace: openshift-marketplace" | oc apply -f -      

echo
echo "------------------------------------ CHECK OSSM Operator STATUS ------------------------------------"
echo
jop="False"
while [ "$oop" != "Succeeded" ]; do
  sleep 5
  oop=$(oc get csv/servicemeshoperator.v2.3.0 -n openshift-operators -o 'jsonpath={..status.phase}')
  echo "OSSM Operator Status => "$oop
done
sleep 1
echo