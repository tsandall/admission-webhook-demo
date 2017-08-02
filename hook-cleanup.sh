#!/usr/bin/env bash

set -x

kubectl delete externaladmissionhookconfigurations admission-webhook-demo
kubectl -n production delete -f manifests/alpine-privileged.yaml
kubectl delete -f manifests/alpine-privileged.yaml
kubectl delete -f manifests/admission-controller-deployment.yaml
kubectl delete -f manifests/admission-controller-service.yaml
