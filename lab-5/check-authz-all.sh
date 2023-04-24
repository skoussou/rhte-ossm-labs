#!/bin/bash

POLICY=$1
SM_CP_NS=$2 #eg. prod-istio-system
OCP_DOMAIN=$3
SSO_CLIENT_SECRET=$4
PARTICIPANTID=$5
CERTS_LOCATION=../lab-4

oc project $SM_CP_NS

echo "####################################################################"
echo "#                                                                  #"
echo "#           CHECKING $POLICY ALL AUTHZ DEFAULT POLICY                #"
echo "#                                                                  #"
echo "####################################################################"

echo "---------------------------------------------------------------------------------------"
GATEWAY_URL=$(oc get route gto-$PARTICIPANTID -o jsonpath='{.spec.host}' -n $SM_CP_NS)
echo GATEWAY_URL:  $GATEWAY_URL
echo
TOKEN=$(curl -sLk --data "username=gtouser&password=gtouser&grant_type=password&client_id=istio-$PARTICIPANTID&client_secret=$SSO_CLIENT_SECRET" https://keycloak-rhsso.$OCP_DOMAIN/auth/realms/servicemesh-lab/protocol/openid-connect/token | jq .access_token)
echo TOKEN: $TOKEN
echo "---------------------------------------------------------------------------------------"
echo
sleep 4

travels=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/travels/Tallinn |jq)
cars=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/cars/Tallinn |jq)
flights=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/flights/Tallinn |jq)
insurances=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/insurances/Tallinn |jq)
hotels=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/hotels/Tallinn |jq)

echo "Authorization $SM_CP_NS --> $PARTICIPANTID-prod-travel-agency"
echo "-------------------------------------------------------------------"

if [[ $travels -eq 200 ]]
then
  echo "[ALLOW] gto-$PARTICIPANTID --> travels.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] gto-$PARTICIPANTID --> travels.$PARTICIPANTID-prod-travel-agency"
fi
if [[ cars -eq 200 ]]
then
  echo "[ALLOW] gto-$PARTICIPANTID --> cars.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] gto-$PARTICIPANTID --> cars.$PARTICIPANTID-prod-travel-agency"
fi
if [[ flights -eq 200 ]]
then
  echo "[ALLOW] gto-$PARTICIPANTID --> flights.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] gto-$PARTICIPANTID --> flights.$PARTICIPANTID-prod-travel-agency"
fi
if [[ insurances -eq 200 ]]
then
  echo "[ALLOW] gto-$PARTICIPANTID --> insurances.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] gto-$PARTICIPANTID --> insurances.$PARTICIPANTID-prod-travel-agency"
fi
if [[ hotels -eq 200 ]]
then
  echo "[ALLOW] gto-$PARTICIPANTID --> hotels.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] gto-$PARTICIPANTID --> hotels.$PARTICIPANTID-prod-travel-agency"
fi


echo
echo "Authorization $PARTICIPANTID-prod-travel-control --> $PARTICIPANTID-prod-travel-agency"
echo "-------------------------------------------------------------------"
podname=$(oc get pods -n $PARTICIPANTID-prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
travels=$(oc -n $PARTICIPANTID-prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET travels.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/travels/Tallinn)
#echo travels
sleep 2
if [[ travels -eq 200 ]]
then
  echo "[ALLOW] control.$PARTICIPANTID-prod-travel-control --> travels.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] control.$PARTICIPANTID-prod-travel-control --> travels.$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
cars=$(oc -n $PARTICIPANTID-prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET cars.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/cars/Tallinn)
#echo cars
sleep 2
if [[ cars -eq 200 ]]
then
  echo "[ALLOW] control.$PARTICIPANTID-prod-travel-control --> cars.prod-travel-agency"
else
  echo "[DENY] control.$PARTICIPANTID-prod-travel-control --> cars.prod-travel-agency"
fi

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
flights=$(oc -n $PARTICIPANTID-prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET flights.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/flights/Tallinn)
#echo flights
sleep 2
if [[ flights -eq 200 ]]
then
  echo "[ALLOW] control.$PARTICIPANTID-prod-travel-control --> flights.prod-travel-agency"
else
  echo "[DENY] control.$PARTICIPANTID-prod-travel-control --> flights.prod-travel-agency"
fi

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
insurances=$(oc -n $PARTICIPANTID-prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET insurances.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/insurances/Tallinn)
#echo insurances
sleep 2
if [[ insurances -eq 200 ]]
then
  echo "[ALLOW] control.$PARTICIPANTID-prod-travel-control --> insurances.prod-travel-agency"
else
  echo "[DENY] control.$PARTICIPANTID-prod-travel-control --> insurances.prod-travel-agency"
fi

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
hotels=$(oc -n $PARTICIPANTID-prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET hotels.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/hotels/Tallinn)
#echo $hotels
sleep 2
if [[ hotels -eq 200 ]]
then
  echo "[ALLOW] control.$PARTICIPANTID-prod-travel-control --> hotels.prod-travel-agency"
else
  echo "[DENY] control.$PARTICIPANTID-prod-travel-control --> hotels.prod-travel-agency"
fi

echo
echo "Authorization $PARTICIPANTID-prod-travel-portal --> $PARTICIPANTID-prod-travel-agency"
echo "-------------------------------------------------------------------"

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
travels=$(oc -n $PARTICIPANTID-prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET travels.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/travels/Tallinn)
#echo travels
sleep 2
if [[ travels -eq 200 ]]
then
  echo "[ALLOW] viaggi.$PARTICIPANTID-prod-travel-portal --> travels.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] viaggi.$PARTICIPANTID-prod-travel-portal --> travels.$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
cars=$(oc -n $PARTICIPANTID-prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET cars.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/cars/Tallinn)
#echo cars
sleep 2
if [[ cars -eq 200 ]]
then
  echo "[ALLOW] viaggi.$PARTICIPANTID-prod-travel-portal --> cars.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] viaggi.$PARTICIPANTID-prod-travel-portal --> cars.$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
flights=$(oc -n $PARTICIPANTID-prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET flights.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/flights/Tallinn)
#echo flights
sleep 2
if [[ flights -eq 200 ]]
then
  echo "[ALLOW] viaggi.$PARTICIPANTID-prod-travel-portal --> flights.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] viaggi.$PARTICIPANTID-prod-travel-portal --> flights.$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
insurances=$(oc -n $PARTICIPANTID-prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET insurances.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/insurances/Tallinn)
#echo insurances
sleep 2
if [[ insurances -eq 200 ]]
then
  echo "[ALLOW] viaggi.$PARTICIPANTID-prod-travel-portal --> insurances.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] viaggi.$PARTICIPANTID-prod-travel-portal --> insurances.$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
hotels=$(oc -n $PARTICIPANTID-prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET hotels.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/hotels/Tallinn)
#echo $hotels
sleep 2
if [[ hotels -eq 200 ]]
then
  echo "[ALLOW] viaggi.$PARTICIPANTID-prod-travel-portal --> hotels.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] viaggi.$PARTICIPANTID-prod-travel-portal --> hotels.$PARTICIPANTID-prod-travel-agency"
fi


echo
echo "Authorization $PARTICIPANTID-prod-travel-agency --> $PARTICIPANTID-prod-travel-agency"
echo "-------------------------------------------------------------------"

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
travels=$(oc -n $PARTICIPANTID-prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET travels.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/travels/Tallinn)
#echo travels
sleep 2
if [[ travels -eq 200 ]]
then
  echo "[ALLOW] travels.$PARTICIPANTID-prod-travel-portal --> discounts.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] travels.$PARTICIPANTID-prod-travel-portal --> discounts.$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
cars=$(oc -n $PARTICIPANTID-prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET cars.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/cars/Tallinn)
#echo cars
sleep 2
if [[ cars -eq 200 ]]
then
  echo "[ALLOW] travels.$PARTICIPANTID-prod-travel-portal --> cars.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] travels.$PARTICIPANTID-prod-travel-portal --> cars.$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
flights=$(oc -n $PARTICIPANTID-prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET flights.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/flights/Tallinn)
#echo flights
sleep 2
if [[ flights -eq 200 ]]
then
  echo "[ALLOW] travels.$PARTICIPANTID-prod-travel-portal --> flights.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] travels$PARTICIPANTID-.prod-travel-portal --> flights.$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
insurances=$(oc -n $PARTICIPANTID-prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET insurances.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/insurances/Tallinn)
#echo insurances
sleep 2
if [[ insurances -eq 200 ]]
then
  echo "[ALLOW] travels.$PARTICIPANTID-prod-travel-portal --> insurances.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] travels.$PARTICIPANTID-prod-travel-portal --> insurances.$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n $PARTICIPANTID-prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
hotels=$(oc -n $PARTICIPANTID-prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET hotels.$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/hotels/Tallinn)
#echo $hotels
sleep 2
if [[ hotels -eq 200 ]]
then
  echo "[ALLOW] travels.$PARTICIPANTID-prod-travel-portal --> hotels.$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] travels.$PARTICIPANTID-prod-travel-portal --> hotels.$PARTICIPANTID-prod-travel-agency"
fi