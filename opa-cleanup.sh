#!/usr/bin/env bash

set -x

kubectl delete externaladmissionhookconfigurations admission.openpolicyagent.org
kubectl delete -f manifests/alpine-privileged.yaml
kubectl -n production delete -f manifests/alpine-privileged.yaml
kubectl delete -f manifests/opa-service.yaml
kubectl delete -f manifests/opa-deployment.yaml
kubectl -n opa delete configmap --all
kubectl delete namespace opa
