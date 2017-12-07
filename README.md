# Admission Webhook Demo

This repository contains code and examples that demonstrate how to leverage
Kubernetes External Admission Webhooks to enforce custom policies in Kubernetes
clusters.

For more information on policy-based administrative control in Kubernetes with
OPA, check out [openpolicyagent.org](http://openpolicyagent.org).

## Bootstrapping

1. Start minikube cluster with the script:

    ```
    cd cluster; ./up.sh
    ```

1. Once cluster has booted, configure certificates:

    ```
    kubectl create secret generic ca-cert --from-file=ca.crt
    kubectl create secret tls server-cert  --cert=server.crt --key=server.key
    ```

1. Create production namespace for demo:

    ```
    kubectl create namespace production
    ```
