variable "name" {

}

variable "namespace" {

}

variable "url" {

}

variable "image_name" {
  default = "ghost:3-alpine"
}

variable "storage_size" {
  default = "10Gi"
}

variable "resource_limit_cpu" {
  default = "1"
}

variable "resource_limit_mem" {
  default = "500Mi"
}

variable "resource_req_cpu" {
  default = "100m"
}

variable "resource_req_mem" {
  default = "50Mi"
}

variable "image_pull_policy" {
  default = "IfNotPresent"
}
