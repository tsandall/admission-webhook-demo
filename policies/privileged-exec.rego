package system

# Prevent exec access to privileged containers in the production namespace if...
blacklist["cannot exec into privileged container in production namespace"] {

    # The incoming request is for a CONNECT operation...
    input.spec.operation = "CONNECT"

    # And the namespace of the incoming request is "production"...
    input.spec.namespace = "production"

    # And the pod referred to by the request is privileged...
    is_privileged(input.spec.namespace, input.spec.name, true)

    # And 'break_glass' is not set.
    not data.kubernetes.break_glass
}

# Returns true if the pod is "privileged"
is_privileged(namespace, name) {
    pod = data.kubernetes.pods[namespace][name]
    container = pod.spec.containers[_]
    container.securityContext.privileged
}

# Entry point to the policy query executed by the webhook client in the
# Kubernetes API server.
main = {
    "apiVersion": "admission.k8s.io/v1alpha1",
    "kind": "AdmissionReview",
    "status": status,
}

# Generates status value that represents the policy decision. If any blacklist
# policies are hit, request will be denied.
status = {
    "allowed": false,
    "status": {
        "reason": reason,
    },
} {
    concat(", ", blacklist, reason)
    reason != ""
}

default status = {"allowed": true}
