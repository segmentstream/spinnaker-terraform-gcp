FROM gcr.io/spinnaker-marketplace/halyard:1.22.2

# Changing back to rood (as in base image it is "spinnaker")
USER root

# Install supervisord
RUN apt-get update && apt-get install -y supervisor && \
  chown spinnaker -R /var/log/supervisor/ && \
  chown spinnaker -R /var/run/

# Install gcloud
RUN apt-get update -y && apt-get install lsb-release -y && \
  export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
  echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  apt-get update -y && apt-get install google-cloud-sdk -y

# Install jq (util for working with json files)
RUN wget http://stedolan.github.io/jq/download/linux64/jq
RUN chmod +x ./jq
RUN mv jq /usr/bin/jq

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD spinnaker-install.sh /home/spinnaker/spinnaker-install.sh
ADD secrets/credentials.json /home/spinnaker/credentials.json

# required for cloudbuild setup
ADD igor-local.yml /home/spinnaker/igor-local.yml

USER spinnaker

CMD ["/usr/bin/supervisord"]