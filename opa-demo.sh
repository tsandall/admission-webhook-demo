#!/usr/bin/env bash

export DEMO_RUN_FAST=1
source util.sh
clear

run "kubectl create namespace opa"
run "kubectl create -f manifests/opa-service.yaml"
run "kubectl create -f manifests/opa-deployment.yaml"
run "watch kubectl get pod"
run "watch kubectl get externaladmissionhookconfigurations admission.openpolicyagent.org -o yaml"
run "kubectl create -f manifests/alpine-privileged.yaml"
run "kubectl -n production create -f manifests/alpine-privileged.yaml"
desc "Load a policy that restrict's exec access accordingly."
run "kubectl -n opa create configmap privileged-exec --from-file policies/privileged-exec.rego"
run "watch kubectl -n opa get configmap privileged-exec -o json | jq '.metadata'"
run "kubectl exec -i -t alpine sh"
run "kubectl -n production exec -i -t alpine sh"
run "view policies/privileged-exec.rego"
desc "OMG. Everything is on fire."
run "cat policies/break-glass.rego"
run "kubectl -n opa create configmap break-glass --from-file policies/break-glass.rego"
run "kubectl -n production exec -i -t alpine sh"
desc "Restore the calm."
run "kubectl -n opa delete configmap break-glass"
run "kubectl -n production exec -i -t alpine sh"
desc "🙏 demo gods🙏 "
