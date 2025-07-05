variable "resource_group_name" {
  default = "aks-lab-rg"
}

variable "location" {
  default = "East US"
}

variable "aks_name" {
  default = "aks-lab-cluster"
}

variable "node_count" {
  default = 1
}

variable "max_node_count" {
  default = 3
}
