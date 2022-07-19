
// Cronjob monitoramento pod em EVICTED

resource "kubernetes_service_account" "sa-monitor-evicted" {
  metadata {
    name = "sa-monitor-evicted"
    namespace = "default"
  }
}

resource "kubernetes_cluster_role" "cr-monitor-evicted" {
  metadata {
    name = "cr-monitor-evicted"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "delete"]
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["list"]
  }
}

resource "kubernetes_cluster_role_binding" "crb-monitor-evicted" {
  metadata {
    name = "crb-monitor-evicted"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cr-monitor-evicted"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "sa-monitor-evicted"
    namespace = "default"
  }

}

resource "kubernetes_cron_job_v1" "ronjob-monitor-evicted" {
  metadata {
    name = "cronjob-monitor-evicted"
  }
  spec {
    
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 1
    schedule                      = "0 18 * * *"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 1
    job_template {
      metadata {}
      spec {
        backoff_limit              = 1
        ttl_seconds_after_finished = 900
        template {
          metadata {}
          spec {
            service_account_name = "sa-monitor-evicted"
            container {
              name    = "kubectl-runner"
              image   = "bitnami/kubectl:1.24.2"
              command = ["sh", "-c"]
              args = ["pod=$(kubectl get pods -A | grep  'Evicted\\|Error\\|ContainerStatusUnknown\\|Completed'  |awk '{print $2 \" --namespace=\" $1}')\nif [ -n \"$pod\" ]; then curl -fsSL -X POST --data-urlencode \"payload={\\\"channel\\\": \\\"#devops-saas\\\", \\\"username\\\": \\\"webhookbot\\\", \\\"text\\\": \\\" @here , k8s - DEV - Eviction triggada para o(s) pod(s): $pod.\\\", \\\"icon_emoji\\\": \\\":ghost:\\\"}\" https://Inserir-a-url-do-webhook-do-discord-ou-slack; fi \nif [ -n \"$pod\" ]; then kubectl get pods --all-namespaces | grep  'Evicted\\|Error\\|ContainerStatusUnknown\\|Completed'  | awk '{print $2 \" --namespace=\" $1}' | xargs kubectl delete pod; fi\n"]
            }
            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}