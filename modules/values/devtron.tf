
resource "helm_release" "devtron" {
  name             = "devtron"
  repository       = "https://helm.devtron.ai"
  chart            = "devtron"
  namespace        = "devtroncd"
  create_namespace = true
  timeout          = 600
  depends_on = [eks.module]

  set {
    name  = "installer.modules"
    value = "cicd"
  }
  set {
    name  = "argo-cd.enabled"
    value = "true"
  }
  set {
    name  = "security.enabled"
    value = "true"
  }

  set {
    name  = "notifier.enabled"
    value = "true"
  }

  set {
    name  = "security.trivy.enabled"
    value = "true"
  }

  set {
    name  = "monitoring.grafana.enabled"
    value = "true"
  }
}

resource "null_resource" "wait_for_devtron" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {

    command = <<EOF
      printf "\nWaiting for the devtron pods to start...\n"
      sleep 5
      until kubectl wait -n ${helm_release.devtron.namespace} --for=condition=Ready pods --all; do
        sleep 2
      done  2>/dev/null
    EOF
  }

  depends_on = [helm_release.devtron]
}
