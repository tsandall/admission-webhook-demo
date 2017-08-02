package system

import data.kubernetes.break_glass

blacklist["cannot exec into privileged container in production namespace"] {
    input.spec.operation = "CONNECT"
    input.spec.namespace = "production"
    is_privileged(input.spec.namespace, input.spec.name, true)
    not break_glass
}

is_privileged(namespace, name) {
    pod = data.kubernetes.pods[namespace][name]
    container = pod.spec.containers[_]
    container.securityContext.privileged
}

# boilerplate -- not shown during final demo
#main = {
#    "apiVersion": "admission.k8s.io/v1alpha1",
#    "kind": "AdmissionReview",
#    "status": status,
#}
#
#default status = {"allowed": true}
#
#status = {
#    "allowed": false,
#    "status": {
#        "reason": reason,
#    },
#} {
#    concat(", ", blacklist, reason)
#    reason != ""
#}
