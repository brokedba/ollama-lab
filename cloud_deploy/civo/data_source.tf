data "civo_kubernetes_cluster" "cluster" {
  name =  civo_kubernetes_cluster.cluster.name
}

# Query instance sizes with 16 GB of RAM
data "civo_size" "ai" {
    filter {
    key    = "cpu"
    values = ["4"]
    }
  filter {
    key    = "ram"
    values = ["16384"]  # RAM in MB
  }

  filter {
    key    = "type"
    values = ["kubernetes"]
  }
}

data "civo_kubernetes_version" "latest_talos" {
  filter {
    key    = "type"
    values = ["talos"]
  }

  filter {
    key    = "default"
    values = ["true"]
  }
  sort {
    key       = "version"
    direction = "desc"
  }
}
