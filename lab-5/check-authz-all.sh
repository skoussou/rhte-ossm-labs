#!/bin/bash

POLICY=$1
SM_CP_NS=$2 #eg. prod-istio-system
OCP_DOMAIN=$3
SSO_CLIENT_SECRET=$4
PARTICIPANTID=$5
CERTS_LOCATION=../lab-4


echo "####################################################################"
echo "#                                                                  #"
echo "#           CHECKING $POLICY ALL AUTHZ DEFAULT POLICY                #"
echo "#                                                                  #"
echo "####################################################################"

echo "---------------------------------------------------------------------------------------"
GATEWAY_URL=$(oc get route gto-user-$PARTICIPANTID -o jsonpath='{.spec.host}' -n $SM_CP_NS)
echo GATEWAY_URL:  $GATEWAY_URL
echo
TOKEN=$(curl -sLk --data "username=gtouser&password=gtouser&grant_type=password&client_id=istio-user-$PARTICIPANTID&client_secret=$SSO_CLIENT_SECRET" https://keycloak-rhsso.$OCP_DOMAIN/auth/realms/servicemesh-lab/protocol/openid-connect/token | jq .access_token)
echo TOKEN: $TOKEN
echo "---------------------------------------------------------------------------------------"
echo
sleep 4

travels=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/travels/Tallinn |jq)
cars=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/cars/Tallinn |jq)
flights=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/flights/Tallinn |jq)
insurances=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/insurances/Tallinn |jq)
hotels=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/hotels/Tallinn |jq)

echo "Authorization $SM_CP_NS --> user-$PARTICIPANTID-prod-travel-agency"
echo "-------------------------------------------------------------------"

if [[ $travels -eq 200 ]]
then
  echo "[ALLOW] gto-user-$PARTICIPANTID --> travels.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] gto-user-$PARTICIPANTID --> travels.user-$PARTICIPANTID-prod-travel-agency"
fi
if [[ cars -eq 200 ]]
then
  echo "[ALLOW] gto-user-$PARTICIPANTID --> cars.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] gto-user-$PARTICIPANTID --> cars.user-$PARTICIPANTID-prod-travel-agency"
fi
if [[ flights -eq 200 ]]
then
  echo "[ALLOW] gto-user-$PARTICIPANTID --> flights.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] gto-user-$PARTICIPANTID --> flights.user-$PARTICIPANTID-prod-travel-agency"
fi
if [[ insurances -eq 200 ]]
then
  echo "[ALLOW] gto-user-$PARTICIPANTID --> insurances.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] gto-user-$PARTICIPANTID --> insurances.user-$PARTICIPANTID-prod-travel-agency"
fi
if [[ hotels -eq 200 ]]
then
  echo "[ALLOW] gto-user-$PARTICIPANTID --> hotels.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] gto-user-$PARTICIPANTID --> hotels.user-$PARTICIPANTID-prod-travel-agency"
fi


echo
echo "Authorization user-$PARTICIPANTID-prod-travel-control --> user-$PARTICIPANTID-prod-travel-agency"
echo "-------------------------------------------------------------------"
podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
travels=$(oc -n user-$PARTICIPANTID-prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET travels.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/travels/Tallinn)
#echo travels
sleep 5
if [[ travels -eq 200 ]]
then
  echo "[ALLOW] control.user-$PARTICIPANTID-prod-travel-control --> travels.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] control.user-$PARTICIPANTID-prod-travel-control --> travels.user-$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
cars=$(oc -n user-$PARTICIPANTID-prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET cars.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/cars/Tallinn)
#echo cars
sleep 5
if [[ cars -eq 200 ]]
then
  echo "[ALLOW] control.user-$PARTICIPANTID-prod-travel-control --> cars.prod-travel-agency"
else
  echo "[DENY] control.user-$PARTICIPANTID-prod-travel-control --> cars.prod-travel-agency"
fi

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
flights=$(oc -n user-$PARTICIPANTID-prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET flights.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/flights/Tallinn)
#echo flights
sleep 5
if [[ flights -eq 200 ]]
then
  echo "[ALLOW] control.user-$PARTICIPANTID-prod-travel-control --> flights.prod-travel-agency"
else
  echo "[DENY] control.user-$PARTICIPANTID-prod-travel-control --> flights.prod-travel-agency"
fi

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
insurances=$(oc -n user-$PARTICIPANTID-prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET insurances.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/insurances/Tallinn)
#echo insurances
sleep 5
if [[ insurances -eq 200 ]]
then
  echo "[ALLOW] control.user-$PARTICIPANTID-prod-travel-control --> insurances.prod-travel-agency"
else
  echo "[DENY] control.user-$PARTICIPANTID-prod-travel-control --> insurances.prod-travel-agency"
fi

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
hotels=$(oc -n user-$PARTICIPANTID-prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET hotels.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/hotels/Tallinn)
#echo $hotels
sleep 5
if [[ hotels -eq 200 ]]
then
  echo "[ALLOW] control.user-$PARTICIPANTID-prod-travel-control --> hotels.prod-travel-agency"
else
  echo "[DENY] control.user-$PARTICIPANTID-prod-travel-control --> hotels.prod-travel-agency"
fi

echo
echo "Authorization user-$PARTICIPANTID-prod-travel-portal --> user-$PARTICIPANTID-prod-travel-agency"
echo "-------------------------------------------------------------------"

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
travels=$(oc -n user-$PARTICIPANTID-prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET travels.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/travels/Tallinn)
#echo travels
sleep 5
if [[ travels -eq 200 ]]
then
  echo "[ALLOW] viaggi.user-$PARTICIPANTID-prod-travel-portal --> travels.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] viaggi.user-$PARTICIPANTID-prod-travel-portal --> travels.user-$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
cars=$(oc -n user-$PARTICIPANTID-prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET cars.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/cars/Tallinn)
#echo cars
sleep 5
if [[ cars -eq 200 ]]
then
  echo "[ALLOW] viaggi.user-$PARTICIPANTID-prod-travel-portal --> cars.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] viaggi.user-$PARTICIPANTID-prod-travel-portal --> cars.user-$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
flights=$(oc -n user-$PARTICIPANTID-prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET flights.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/flights/Tallinn)
#echo flights
sleep 5
if [[ flights -eq 200 ]]
then
  echo "[ALLOW] viaggi.user-$PARTICIPANTID-prod-travel-portal --> flights.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] viaggi.user-$PARTICIPANTID-prod-travel-portal --> flights.user-$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
insurances=$(oc -n user-$PARTICIPANTID-prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET insurances.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/insurances/Tallinn)
#echo insurances
sleep 5
if [[ insurances -eq 200 ]]
then
  echo "[ALLOW] viaggi.user-$PARTICIPANTID-prod-travel-portal --> insurances.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] viaggi.user-$PARTICIPANTID-prod-travel-portal --> insurances.user-$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
hotels=$(oc -n user-$PARTICIPANTID-prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET hotels.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/hotels/Tallinn)
#echo $hotels
sleep 5
if [[ hotels -eq 200 ]]
then
  echo "[ALLOW] viaggi.user-$PARTICIPANTID-prod-travel-portal --> hotels.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] viaggi.user-$PARTICIPANTID-prod-travel-portal --> hotels.user-$PARTICIPANTID-prod-travel-agency"
fi


echo
echo "Authorization user-$PARTICIPANTID-prod-travel-agency --> user-$PARTICIPANTID-prod-travel-agency"
echo "-------------------------------------------------------------------"

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
travels=$(oc -n user-$PARTICIPANTID-prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET travels.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/travels/Tallinn)
#echo travels
sleep 5
if [[ travels -eq 200 ]]
then
  echo "[ALLOW] travels.user-$PARTICIPANTID-prod-travel-portal --> discounts.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] travels.user-$PARTICIPANTID-prod-travel-portal --> discounts.user-$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
cars=$(oc -n user-$PARTICIPANTID-prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET cars.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/cars/Tallinn)
#echo cars
sleep 5
if [[ cars -eq 200 ]]
then
  echo "[ALLOW] travels.user-$PARTICIPANTID-prod-travel-portal --> cars.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] travels.user-$PARTICIPANTID-prod-travel-portal --> cars.user-$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
flights=$(oc -n user-$PARTICIPANTID-prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET flights.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/flights/Tallinn)
#echo flights
sleep 5
if [[ flights -eq 200 ]]
then
  echo "[ALLOW] travels.user-$PARTICIPANTID-prod-travel-portal --> flights.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] travelsuser-$PARTICIPANTID-.prod-travel-portal --> flights.user-$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
insurances=$(oc -n user-$PARTICIPANTID-prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET insurances.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/insurances/Tallinn)
#echo insurances
sleep 5
if [[ insurances -eq 200 ]]
then
  echo "[ALLOW] travels.user-$PARTICIPANTID-prod-travel-portal --> insurances.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] travels.user-$PARTICIPANTID-prod-travel-portal --> insurances.user-$PARTICIPANTID-prod-travel-agency"
fi

podname=$(oc get pods -n user-$PARTICIPANTID-prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
hotels=$(oc -n user-$PARTICIPANTID-prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET hotels.user-$PARTICIPANTID-prod-travel-agency.svc.cluster.local:8000/hotels/Tallinn)
#echo $hotels
sleep 5
if [[ hotels -eq 200 ]]
then
  echo "[ALLOW] travels.user-$PARTICIPANTID-prod-travel-portal --> hotels.user-$PARTICIPANTID-prod-travel-agency"
else
  echo "[DENY] travels.user-$PARTICIPANTID-prod-travel-portal --> hotels.user-$PARTICIPANTID-prod-travel-agency"
fi