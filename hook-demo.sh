#!/usr/bin/env bash

export DEMO_RUN_FAST=1

source util.sh

clear

echo ""
echo "Hit enter to check minikube..."
echo ""
read
minikube status

echo ""
echo "Hit enter to check service..."
echo ""
read
kubectl get svc admission-webhook-demo -o yaml

echo ""
echo "Hit enter to check deployment..."
echo ""
read
kubectl get deployments admission-webhook-demo -o yaml

echo ""
echo "Hit enter to check registration..."
echo ""
kubectl get externaladmissionhookconfigurations -o yaml
echo ""
read

echo ""
echo "Hit enter to setup demo."
echo ""
read

set -ex

kubectl create -f manifests/admission-controller-deployment.yaml
watch kubectl get pod
watch kubectl get externaladmissionhookconfigurations -o yaml

set +ex

echo ""
echo "Hit enter to start demo."
echo ""
read

clear

run "view main.go"

run "kubectl get services"
run "kubectl get pods"
run "kubectl get externaladmissionhookconfigurations admission-webhook-demo -o yaml"

run "cat manifests/alpine-privileged.yaml"

run "kubectl create -f manifests/alpine-privileged.yaml"
run "kubectl -n production create -f manifests/alpine-privileged.yaml"

desc "Exec into container in default namespace."
run "kubectl exec -i -t alpine sh"

desc "Try to exec into container in production namespace."
run "kubectl -n production exec -i -t alpine sh"

desc "Fin"
read

# cleanup
echo ""
echo "Hit enter to cleanup."
echo ""
read

./hook-cleanup.sh
