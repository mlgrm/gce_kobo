#!/bin/bash -xe

gcloud compute instances create kobo \
	--project=survey-tools \
	--zone=europe-west3-a \
	--machine-type=e2-medium \
	--network-interface=address=34.89.142.168,network=default,network-tier=PREMIUM,stack-type=IPV4_ONLY \
	--maintenance-policy=MIGRATE \
	--provisioning-model=STANDARD \
	--service-account=957001946476-compute@developer.gserviceaccount.com \
	--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
	--tags=http-server,https-server \
	--create-disk=auto-delete=yes,boot=yes,device-name=instance-20240521-101917,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240515,mode=rw,size=20,type=projects/survey-tools/zones/europe-west3-a/diskTypes/pd-balanced \
	--create-disk=device-name=kobo-data,disk-resource-policy=projects/survey-tools/regions/europe-west3/resourcePolicies/doc,mode=rw,name=kobo-data,size=100,type=projects/survey-tools/zones/europe-west3-a/diskTypes/pd-balanced \
	--no-shielded-secure-boot \
	--shielded-vtpm \
	--shielded-integrity-monitoring \
	--labels=goog-ec-src=vm_add-gcloud \
	--reservation-affinity=any

# wait for server to boot
sleep 10
until gcloud compute ssh kobo --command="echo server online."
do
	sleep 5
done
gcloud compute ssh kobo < prep_server_step1.sh
gcloud compute ssh kobo < prep_server_step2.sh

