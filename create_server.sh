#!/bin/bash -xe

if [ -f .config ]; then source .config; fi
gcloud compute instances create $HOST \
	--project=survey-tools \
	--zone=europe-west3-a \
	--machine-type=e2-medium \
	--network-interface=address=$HOST,network=default,network-tier=PREMIUM,stack-type=IPV4_ONLY \
	--maintenance-policy=MIGRATE \
	--provisioning-model=STANDARD \
	--service-account=957001946476-compute@developer.gserviceaccount.com \
	--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
	--tags=http-server,https-server \
	--create-disk=auto-delete=yes,boot=yes,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240515,mode=rw,size=20,type=projects/survey-tools/zones/europe-west3-a/diskTypes/pd-balanced \
	--create-disk=device-name=$HOST-data,disk-resource-policy=projects/survey-tools/regions/europe-west3/resourcePolicies/doc,mode=rw,name=$HOST-data,size=100,type=projects/survey-tools/zones/europe-west3-a/diskTypes/pd-balanced \
	--no-shielded-secure-boot \
	--shielded-vtpm \
	--shielded-integrity-monitoring \
	--labels=goog-ec-src=vm_add-gcloud \
	--reservation-affinity=any

# wait for server to boot
sleep 10
until gcloud compute ssh $HOST --command="echo server online."
do
	sleep 5
done
gcloud compute ssh $HOST < prep_server_step1.sh
gcloud compute ssh $HOST < prep_server_step2.sh
gcloud compute ssh $HOST --command="cd kobo-install && python3 run.py"
gcloud compute ssh $HOST --command="cd kobo-docker && patch" < kobo-docker/docker-compose.backend.primary.override.yml.patch
gcloud compute ssh $HOST < post_run.sh
