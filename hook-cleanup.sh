#!/usr/bin/env bash

set -x

kubectl -n production delete -f manifests/alpine-privileged.yaml
kubectl delete -f manifests/alpine-privileged.yaml
kubectl delete -f manifests/admission-controller-deployment.yaml
kubectl delete externaladmissionhookconfigurations admission-webhook-demo
