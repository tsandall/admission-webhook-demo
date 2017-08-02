#!/usr/bin/env bash

export DEMO_RUN_FAST=1

source util.sh

clear

# Create service and deploy webhook.
run "cat manifests/admission-controller-service.yaml"
run "kubectl create -f manifests/admission-controller-service.yaml"
run "cat manifests/admission-controller-deployment.yaml"
run "kubectl create -f manifests/admission-controller-deployment.yaml"
run "watch kubectl get pods"
run "watch kubectl get externaladmissionhookconfigurations admission-webhook-demo -o yaml"

# What's running?
run "view main.go"

# Let's try this out.
run "cat manifests/alpine-privileged.yaml"

run "kubectl create -f manifests/alpine-privileged.yaml"
run "kubectl -n production create -f manifests/alpine-privileged.yaml"

desc "Exec into container in default namespace."
run "kubectl exec -i -t alpine sh"

desc "Try to exec into container in production namespace."
run "kubectl -n production exec -i -t alpine sh"

# Success!
desc "🙏 demo gods🙏 "
read

./hook-cleanup.sh
