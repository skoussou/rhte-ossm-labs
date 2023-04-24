#!/bin/bash

SM_CP_NS=$1
PREFIX=$2
TOKEN=$3

GATEWAY_URL=$(oc get route $PREFIX -o jsonpath='{.spec.host}' -n $SM_CP_NS)
echo GATEWAY_URL:  $GATEWAY_URL
echo
sleep 3

for i in {1..1}
do

curl -v --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/cars/Tallinn |jq
curl -s --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/travels/Tallinn |jq
curl -s --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/flights/Tallinn |jq
curl -s --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/insurances/Tallinn |jq
curl -s --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/hotels/Tallinn |jq

curl -s --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/cars/Brussels |jq
curl -s --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/travels/Brussels |jq
curl -s --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/flights/Brussels |jq
curl -s --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/insurances/Brussels |jq
curl -s --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/hotels/Brussels |jq

curl -s --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/cars/London |jq
curl -s --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/travels/London |jq
curl -s--cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/flights/London |jq
curl -s --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/insurances/London |jq
curl -s --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/hotels/London |jq

done