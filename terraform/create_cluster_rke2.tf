# Create a new rancher v2 RKE2 custom Cluster v2
resource "rancher2_cluster_v2" "moncluster" {
  name = var.rancher2_nom_cluster 
  fleet_namespace = "fleet-default"
  kubernetes_version = var.rke2_kubernetes_version
  enable_network_policy = false
#  default_pod_security_policy_template_name = "unrestricted"
  default_cluster_role_for_project_members = "user"
  rke_config {
    etcd {
      disable_snapshots = false
      snapshot_retention = 5
    }
# Pour customiser le paramèter machine_global_config rajouter la variable custom_config dans le tfvars avec les paramèters souhaités
    machine_global_config = var.custom_config
    machine_pools {
        control_plane_role = true
        etcd_role = true
        worker_role = false
        machine_config {
          kind = rancher2_machine_config_v2.masters["az1"].kind
          name = rancher2_machine_config_v2.masters["az1"].name
        }
        name = "masters-az1"
        cloud_credential_secret_name = "cattle-global-data:${var.rancher2_cloud_credential}"
        quantity = 1
        unhealthy_node_timeout_seconds = "5"
        max_unhealthy = "60%"
      }

    machine_pools {
        control_plane_role = true
        etcd_role = true
        worker_role = false
        machine_config {
          kind = rancher2_machine_config_v2.masters["az2"].kind
          name = rancher2_machine_config_v2.masters["az2"].name
        }
        name = "masters-az2"
        cloud_credential_secret_name = "cattle-global-data:${var.rancher2_cloud_credential}"
        quantity = 1
        unhealthy_node_timeout_seconds = "5"
    }

      machine_pools {
          control_plane_role = true
          etcd_role = true
          worker_role = false
          machine_config {
            kind = rancher2_machine_config_v2.masters["az3"].kind
            name = rancher2_machine_config_v2.masters["az3"].name
          }
          name = "masters-az3"
          cloud_credential_secret_name = "cattle-global-data:${var.rancher2_cloud_credential}"
          quantity = 1
          unhealthy_node_timeout_seconds = "5"
        }

      machine_pools {
          control_plane_role = false
          etcd_role = false
          worker_role = true
          machine_config {
            kind = rancher2_machine_config_v2.workers["az1"].kind
            name = rancher2_machine_config_v2.workers["az1"].name
          }
          name = "workers-az1"
          cloud_credential_secret_name = "cattle-global-data:${var.rancher2_cloud_credential}"
          quantity = var.worker-count
          unhealthy_node_timeout_seconds = "5"
          max_unhealthy = "60%"
        }

      machine_pools {
          control_plane_role = false
          etcd_role = false
          worker_role = true
          machine_config {
            kind = rancher2_machine_config_v2.workers["az2"].kind
            name = rancher2_machine_config_v2.workers["az2"].name
          }
          name = "workers-az2"
          cloud_credential_secret_name = "cattle-global-data:${var.rancher2_cloud_credential}"
          quantity = var.worker-count
          unhealthy_node_timeout_seconds = "5"
        }      

      machine_pools {
          control_plane_role = false
          etcd_role = false
          worker_role = true
          machine_config {
            kind = rancher2_machine_config_v2.workers["az3"].kind
            name = rancher2_machine_config_v2.workers["az3"].name
          }
          name = "workers-az3"
          cloud_credential_secret_name = "cattle-global-data:${var.rancher2_cloud_credential}"
          quantity = var.worker-count
          unhealthy_node_timeout_seconds = "5"
          drain_before_delete = true
          node_drain_timeout = 30
          max_unhealthy = "30%"
        }

      registries {
        mirrors {
          hostname = "docker.io"
          endpoints = [ "https://docker.io" ]
        }
        mirrors {
          hostname = "k8s.gcr.io"
          endpoints = [ "https://k8s.gcr.io" ]
        }
        mirrors {
          hostname = "gcr.io"
          endpoints = [ "https://gcr.io" ]
        }
        mirrors {
          hostname = "ghcr.io"
          endpoints = [ "https://ghcr.io" ]
        }
        mirrors {
          hostname = "nvcr.io"
          endpoints = [ "https://nvcr.io" ]
        }
        mirrors {
          hostname = "quay.io"
          endpoints = [ "https://quay.io" ]
        }
      }
      machine_selector_config {
        config = {
          system-default-registry = var.default_registry,
          protect-kernel-defaults = false,
          cloud-provider-name = "rancher-vsphere"
        }
      }
      upgrade_strategy {
        control_plane_concurrency = "10%"
        control_plane_drain_options {
          enabled = false
        }
        worker_concurrency = "10%"
        worker_drain_options {
          enabled = true
          delete_empty_dir_data = true
          disable_eviction = false
          force = false
          grace_period = 0
          ignore_daemon_sets = true
          ignore_errors = false
          skip_wait_for_delete_timeout_seconds = 0
          timeout = 5
        }
      }

    chart_values = <<EOF
rke2-calico: {}
rancher-vsphere-cpi:
  vCenter:
    datacenters: ${var.vsphere-datacenter}
    host: ${var.vsphere-vcenter}
    password: ${var.vsphere-password}
    username: ${var.vsphere-user}
rancher-vsphere-csi:
  csiController:
    csiResizer:
      enabled: false

  vCenter:
    datacenters: ${var.vsphere-datacenter}
    host: ${var.vsphere-vcenter}
    password: ${var.vsphere-password}
    username: ${var.vsphere-user}
EOF
  }
}

resource "local_file" "get-kube" {
  content = rancher2_cluster_v2.moncluster.kube_config
  filename = "../env/vsphere-ti/${var.rancher2_nom_cluster}.yaml"
}