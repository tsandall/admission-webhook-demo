#!/usr/bin/env bash

set -ex

minikube start \
    --profile=admission-demo \
    --kubernetes-version=v1.8.0 \
    --extra-config=apiserver.Admission.PluginNames=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,Initializers,GenericAdmissionWebhook,ResourceQuota,DefaultTolerationSeconds \
    --extra-config=apiserver.ProxyClientCertFile=$PWD/certs/client.crt \
    --extra-config=apiserver.ProxyClientKeyFile=$PWD/certs/client.key \
    --cpus 4

minikube docker-env --profile=admission-demo
