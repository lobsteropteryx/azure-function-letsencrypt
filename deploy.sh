#!/usr/bin/env bash
set -e

APP_NAME=azure-functions-ssl-test
RESOURCE_GROUP=azure-functions-ssl-test
CNAME=ssl-test.yourdomain.com

terraform apply \
-var "subscription_id=${ARM_SUBSCRIPTION_ID}" \
-var "tenant_id=${ARM_TENANT_ID}" \
-var "client_id=${ARM_CLIENT_ID}" \
-var "client_secret=${ARM_CLIENT_SECRET}" \
-auto-approve

az webapp config hostname add \
--webapp-name "${APP_NAME}" \
--resource-group "${RESOURCE_GROUP}" \
--hostname "${CNAME}"

rm -f function.zip

pushd Test/Hello
npm install
popd

pushd Test/letsencrypt
npm install
popd

pushd Test
zip ../function.zip -r .
popd

az functionapp deployment source config-zip \
    -g "${RESOURCE_GROUP}" \
    -n "${APP_NAME}" \
    --src function.zip