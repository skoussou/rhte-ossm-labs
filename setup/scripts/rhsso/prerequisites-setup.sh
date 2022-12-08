#!/bin/bash

CLUSTERNAME=$1
BASEDOMAIN=$2
LABPARTICIPANTS=$3

#VAR="no"
#if [[ "$VAR" == "yes" ]]
#then
#fi

echo "============================================================"
echo "|                                                           |"
echo "|  Replace <CLUSTERNAME> for [$CLUSTERNAME]                 |"
echo "|  Replace <BASEDOMAIN> for [$BASEDOMAIN]                   |"
echo "|                                                           |"
echo "============================================================"

echo "find . -type f -name *.yaml |xargs sed -i 's@<CLUSTERNAME>@$CLUSTERNAME@g'"
find . -type f -name "*.yaml" |xargs sed -i "s@<CLUSTERNAME>@$CLUSTERNAME@g"
echo
echo "find . -type f -name *.yaml |xargs sed -i 's@<BASEDOMAIN>@$BASEDOMAIN@g'"
find . -type f -name "*.yaml" |xargs sed -i "s@<BASEDOMAIN>@$BASEDOMAIN@g"
echo
echo "proceeding ..."

while true; do

read -p "Replacing <CLUSTERNAME> and <BASEDOMAIN> successful? (yes/no) " yn

case $yn in
	yes ) echo ok, we will proceed;
		break;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac
done

echo "============================================================"
echo "|                                                           |"
echo "|  Deploy RHSSO using the RHSSO operator                    |"
echo "|                                                           |"
echo "============================================================"

ls scripts/rhsso/prerequisites/yaml/rhsso/01_rhsso.yaml
sleep 5

#We'll deploy a very simple, non-prod ready, RHSSO platform using the RHSSO platform.
# This RHSSO platform can be enhanced later to use a remote database (e.g. Amazon RDS), run multiple instances and use identity provider such as Github.

echo "Create the rhsso namespace"
echo "------------------------------------------------"
echo
echo "oc new-project rhsso"
oc new-project rhsso
sleep 3

echo "MANUAL: Install the RHSSO operator in the rhsso namespace"
echo "See Official docs: https://access.redhat.com/documentation/en-us/red_hat_single_sign-on/7.6/html/server_installation_and_configuration_guide/operator#install_by_olm"
echo "------------------------------------------------"
echo
echo "WARNING: This step is not automated. You need to choose one of the manual manners in the docs. Once done proceed with a yes on the following prompt"
sleep 12
echo
echo
while true; do

read -p "The RHSSO Operator has been installed in the [rhsso] namespace? (yes/no) " yn

case $yn in
	yes ) echo ok, we will proceed;
		break;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac
done

echo
#echo "################# Adding Operator rhsso-operator #################"

#echo "apiVersion: operators.coreos.com/v1alpha1
#kind: Subscription
#metadata:
#  name: rhsso-operator
#  namespace: rhsso
#spec:
#  channel: stable
#  installPlanApproval: Automatic
#  name: rhsso-operator
#  source: redhat-operators
#  sourceNamespace: openshift-marketplace
#  startingCSV: rhsso-operator.7.6.1-opr-002"

#echo "apiVersion: operators.coreos.com/v1alpha1
#kind: Subscription
#metadata:
#  name: rhsso-operator
#  namespace: rhsso
#spec:
#  channel: stable
#  installPlanApproval: Automatic
#  name: rhsso-operator
#  source: redhat-operators
#  sourceNamespace: openshift-marketplace
#  startingCSV: rhsso-operator.7.6.1-opr-002" | oc apply -f -

#echo 'waiting 20s for operator to be installed'
#sleep 20

echo
echo "------------------------------------ CHECK RHSSO Operator STATUS ------------------------------------"
echo
jop="False"
while [ "$jop" != "Succeeded" ]; do
  sleep 5
  jop=$(oc get csv/rhsso-operator.7.6.1-opr-002 -n rhsso -o 'jsonpath={..status.phase}')
  echo "Rhsso Operator Status => "$jop
done
sleep 1
echo

echo
echo "Create an RHSSO Deployment"
echo "------------------------------------------------"
echo
echo oc -n rhsso apply -n rhsso -f scripts/rhsso/prerequisites/yaml/rhsso/01_rhsso.yaml
oc -n rhsso apply -n rhsso -f scripts/rhsso/prerequisites/yaml/rhsso/01_rhsso.yaml

echo "    ------- CHECK RHSSO DEPLOYMENT "
echo
#rhssostatuspod="False"
#while [ "rhssostatuspod" != "True" ]; do
#  sleep 5
#  rhssostatuspod=$(oc -n rhsso get pods -l app=keycloak -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}')
#  echo "RHSSO POD Ready => "$rhssostatuspod
#done

echo 'waiting 120s for RHSSO Deployment to be completed'
sleep 120
echo
rhssostatefulset=0
echo $rhssostatefulset
while [ $rhssostatefulset -le 0 ]; do
  sleep 5
  rhssostatefulset=$(oc -n rhsso get statefulset keycloak -o 'jsonpath={..status.availableReplicas}')
  echo "RHSSO Stateful Set Replicas Ready => $rhssostatefulset"
done
sleep 1

echo
echo
echo "Create the servicemesh-lab realm"
echo "------------------------------------------------"
echo
echo "oc apply -f scripts/rhsso/prerequisites/yaml/rhsso/02_servicemesh-realm.yaml"
oc -n rhsso apply -f scripts/rhsso/prerequisites/yaml/rhsso/02_servicemesh-realm.yaml

echo
echo
echo "Create $PARTICIPANTID clients inside the realm servicemesh-lab"
echo "------------------------------------------------"
echo
#Note:
# the field secret is set randomly and you can leave as it is (we'll used this secret later);
# even if the route matching the redirectUris is currently using http (the route of the Istio default ingress gateway), leave https in the redirectUris field (the route will be patched later in approach 2 and 3);
#echo "oc apply -f scripts/rhsso/prerequisites/yaml/rhsso/03_istio-client.yaml"
#oc -n rhsso apply -f scripts/rhsso/prerequisites/yaml/rhsso/03_istio-client.yaml


for PARTICIPANTID in $( seq 1 $LABPARTICIPANTS )
do
  echo
  echo "Creating KeycloakClient for user-$PARTICIPANTID"
  echo "----------------------------------------"
  echo "    redirectUri[https://gto-user-$PARTICIPANTID.apps.$CLUSTERNAME.$BASEDOMAIN/*]"
  echo

echo "apiVersion: keycloak.org/v1alpha1
kind: KeycloakClient
metadata:
  namespace: rhsso
  name: istio-user-$PARTICIPANTID
  labels:
    app: rhsso-simple
spec:
  realmSelector:
    matchLabels:
      realm: servicemesh-lab
  client:
    clientId: istio-user-$PARTICIPANTID
    secret: bcd06d5bdd1dbaaf81853d10a66aeb989a38dd51
    clientAuthenticatorType: client-secret
    protocol: openid-connect
    publicClient: false
    directAccessGrantsEnabled: true
    standardFlowEnabled: true
    redirectUris:
      - https://gto-user-$PARTICIPANTID.apps.$CLUSTERNAME.$BASEDOMAIN/*" | oc apply -f -

  sleep 4
done

echo
echo
echo "Set the client to confidential manually (due to RHSSO operator)"
echo "---------------------------------------------------------------"
echo
#echo "Retrieve the admin user password""
# Note: the password itself is a base64 string
#echo "RHSSO PASSWORD: $(oc get secret credential-rhsso-simple --template={{.data.ADMIN_PASSWORD}} -n rhsso | base64 --decode)"
echo
#echo "Retrieve the route"
#echo "WEB RHSSO URL: https://$(oc get route keycloak -n rhsso)"
echo
echo "Login at https://$(oc get route keycloak -n rhsso -o jsonpath='{.spec.host}') with admin/$(oc get secret credential-rhsso-simple --template={{.data.ADMIN_PASSWORD}} -n rhsso | base64 --decode) "
echo
echo
while true; do

read -p "Logged in to RHSSO? (yes/no) " yn

case $yn in
	yes ) echo ok, we will proceed;
		break;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac
done

echo
echo
echo "Select the realm \"servicemesh-lab\" (top left of the window), click on Clients in the left menu, then istio:"
echo "* ensure Standard Flow Enabled is enabled for this client;"
echo "* ensure that the Access Type value is set to confidential;"
echo "  if not, set it, click on the button Save at the bottom of the page; a new \"Credentials\" tab has appeared at the top of the page,"
echo "  and you can check in this tab that the client secret is matching the value set in 03_istio-client.yaml (if not, simply use the new value)."
echo
echo
while true; do

read -p "Is Client now Confidential? (yes/no) " yn

case $yn in
	yes ) echo ok, we will proceed;
		break;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac
done

echo
echo
echo "Create the local user localuser:localuser inside the realm servicemesh-lab"
echo "---------------------------------------------------------------"
echo
echo "oc -n rhsso apply -f scripts/rhsso/prerequisites/yaml/rhsso/04_local-user.yaml"
oc -n rhsso apply -f scripts/rhsso/prerequisites/yaml/rhsso/04_local-user.yaml
echo
sleep 7

echo "Test logging in with local user gtouser:gtouser inside the realm servicemesh-lab"
echo "------------------------------------------------------------------------------------"
echo
#You can test to login as gtouser:gtouser by opening https://keycloak-rhsso.apps.<CLUSTERNAME>.<BASEDOMAIN>/auth/realms/servicemesh-lab/account in a browser.
echo "Open in Browser: https://keycloak-rhsso.apps.$CLUSTERNAME.$BASEDOMAIN/auth/realms/servicemesh-lab/account and login as gtouser/gtouser and access realm servicemesh-lab"
