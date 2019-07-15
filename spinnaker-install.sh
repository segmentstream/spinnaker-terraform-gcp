#!/bin/bash

SPINNAKER_KEY_FILE=/home/spinnaker/credentials.json

IFS='|' read -r -a gke_cluster_names <<< "$SPINNAKER_GKE_CLUSTER_NAME|$GKE_CLUSTER_NAMES"
IFS='|' read -r -a gke_cluster_zones <<< "$SPINNAKER_GKE_CLUSTER_ZONE|$GKE_CLUSTER_ZONES"
IFS='|' read -r -a gke_cluster_projects <<< "$SPINNAKER_GKE_CLUSTER_PROJECT|$GKE_CLUSTER_PROJECTS"
IFS='|' read -r -a gke_cluster_read_roles <<< "$SPINNAKER_GKE_CLUSTER_READ_ROLES|$GKE_CLUSTER_READ_ROLES"
IFS='|' read -r -a gke_cluster_write_roles <<< "$SPINNAKER_GKE_CLUSTER_WRITE_ROLES|$GKE_CLUSTER_WRITE_ROLES"

sleep 15

# clean previous deployment config
rm /home/spinnaker/.hal/config

gcloud auth activate-service-account \
  $(jq -r '.client_email' $SPINNAKER_KEY_FILE) \
  --key-file $SPINNAKER_KEY_FILE

# enable hal kubernetes provider
hal config provider kubernetes enable

# setup hal kubernetes accounts for each cluster
for i in "${!gke_cluster_names[@]}"; do
  gcloud container clusters get-credentials ${gke_cluster_names[i]} \
    --zone ${gke_cluster_zones[i]} \
    --project ${gke_cluster_projects[i]}

  CONTEXT=$(kubectl config current-context)

  # This service account uses the ClusterAdmin role -- this is not necessary, 
  # more restrictive roles can by applied.
  kubectl apply --context $CONTEXT \
    -f https://spinnaker.io/downloads/kubernetes/service-account.yml

  TOKEN=$(kubectl get secret --context $CONTEXT \
    $(kubectl get serviceaccount spinnaker-service-account \
        --context $CONTEXT \
        -n spinnaker \
        -o jsonpath='{.secrets[0].name}') \
    -n spinnaker \
    -o jsonpath='{.data.token}' | base64 --decode)

  kubectl config set-credentials $CONTEXT-token-user --token $TOKEN
  kubectl config set-context $CONTEXT --user $CONTEXT-token-user
  kubectl config unset users.$CONTEXT

  hal config provider kubernetes account add ${gke_cluster_names[i]} \
    --namespaces default \
    --provider-version v2 \
    --read-permissions "${gke_cluster_read_roles[i]}" \
    --write-permissions "${gke_cluster_write_roles[i]}" \
    --context $CONTEXT
done

# setup persistent storage in GCS
hal config storage gcs edit --project $SPINNAKER_GKE_CLUSTER_PROJECT \
  --bucket-location $SPINNAKER_STORAGE_BUCKET_LOCATION \
  --bucket $SPINNAKER_STORAGE_BUCKET_NAME \
  --json-path $SPINNAKER_KEY_FILE
hal config storage edit --type gcs

# enable artifact support and setup CGS artifacts
hal config features edit --artifacts true
hal config artifact gcs account add gcs-artifacts-account \
  --json-path $SPINNAKER_KEY_FILE
hal config artifact gcs enable

# setup cloudbuld integrations
hal config pubsub google subscription add $CLOUDBUILD_PROJECT-cloud-builds \
  --project $CLOUDBUILD_PROJECT \
  --subscription-name cloudBuildSpinnakerIntegration-cloud-builds \
  --json-path $SPINNAKER_KEY_FILE \
  --message-format GCB
hal config pubsub google enable

# setup docker registry
hal config provider docker-registry enable
hal config provider docker-registry account add docker_registry \
 --address $DOCKER_REGISTRY_ADDRESS \
 --cache-interval-seconds 300 \
 --username _json_key \
 --password-file $SPINNAKER_KEY_FILE

# setup public access
hal config security authn oauth2 edit --provider google \
  --client-id $OAUTH2_CLIENT_ID \
  --client-secret $OAUTH2_CLIENT_SECRET \
  --user-info-requirements hd=$DOMAIN
hal config security authn oauth2 edit \
  --pre-established-redirect-uri https://spinnaker-api.$DOMAIN/login
hal config security authn oauth2 enable

hal config security ui edit \
  --override-base-url https://spinnaker.$DOMAIN
hal config security api edit \
  --override-base-url https://spinnaker-api.$DOMAIN

# setup authorization using google suit
hal config security authz google edit \
  --admin-username $ADMIN \
  --credential-path $SPINNAKER_KEY_FILE \
  --domain $DOMAIN
   
hal config security authz edit --type google
hal config security authz enable

# setup slack
hal config notification slack enable
echo $SLACK_TOKEN | hal config notification slack edit --bot-name $SLACK_BOT_NAME --token

# deploy
hal version list
hal config version edit --version $SPINNAKER_VERSION
hal config deploy edit --type distributed --account-name $SPINNAKER_GKE_CLUSTER_NAME

hal deploy apply

cat /home/spinnaker/.hal/config

kill 1
exit 0
