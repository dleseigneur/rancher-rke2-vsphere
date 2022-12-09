data "vsphere_datacenter" "dc" {
    name = var.vsphere-datacenter
}

data "vsphere_compute_cluster" "clusters" {
    for_each = var.vsphere-cluster
    name = each.value
    datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastores" {
    for_each = var.vm-datastore
    name = each.value
    datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_distributed_virtual_switch" "dvs" {
  for_each = var.dvs
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}
resource "vsphere_folder" "folder" {
  path          = var.rancher2_nom_cluster
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networks" {
    for_each = var.dvs
    name = var.vm-network
    datacenter_id = data.vsphere_datacenter.dc.id
    distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs[each.key].id
}


resource "rancher2_machine_config_v2" "masters" {
    for_each = var.vsphere-cluster
    generate_name = "master-${each.key}"

    vsphere_config {
        clone_from = "/${var.vsphere-datacenter}/vm/templates/${var.vm-template-name}"
        datastore = "/${var.vsphere-datacenter}/datastore/${data.vsphere_datastore.datastores[each.key].name}"
        cpu_count = var.vm-cpu-master
        creation_type = "template"
        datacenter = var.vsphere-datacenter
        vcenter = var.vsphere-vcenter
        folder = "/${var.vsphere-datacenter}/vm/${vsphere_folder.folder.path}"
        memory_size = var.vm-ram-master
        disk_size = var.vm-disk-data-size
        pool = "/${var.vsphere-datacenter}/host/${data.vsphere_compute_cluster.clusters[each.key].name}/Resources"
        network = ["/${var.vsphere-datacenter}/network/${var.dvs[each.key]}/${data.vsphere_network.networks[each.key].name}"]
        
    }

}

resource "rancher2_machine_config_v2" "workers" {
    for_each = var.vsphere-cluster
    generate_name = "workers-${each.key}"
    vsphere_config {
        clone_from = "/${var.vsphere-datacenter}/vm/templates/${var.vm-template-name}"
        datastore = "/${var.vsphere-datacenter}/datastore/${data.vsphere_datastore.datastores[each.key].name}"
        cpu_count = var.vm-cpu-worker
        creation_type = "template"
        datacenter = var.vsphere-datacenter
        vcenter = var.vsphere-vcenter
        folder = "/${var.vsphere-datacenter}/vm/${vsphere_folder.folder.path}"
        memory_size = var.vm-ram-worker
        disk_size = var.vm-disk-data-size
        pool = "/${var.vsphere-datacenter}/host/${data.vsphere_compute_cluster.clusters[each.key].name}/Resources"
        network = ["/${var.vsphere-datacenter}/network/${var.dvs[each.key]}/${data.vsphere_network.networks[each.key].name}"]

    }

}