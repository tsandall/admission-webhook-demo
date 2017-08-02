package kubernetes.admission

initialize = merge {

  input.kind = "Deployment"
  input.metadata.annotations["requires-opa"]

  merge = {
    "spec": {
      "template": {
        "spec": {
          "containers": [
            {
              "name": "opa",
              "image": "openpolicyagent/opa",
              "args": [
                "run",
                "--server",
              ]
            }
          ]
        }
      }
    }
  }

}
