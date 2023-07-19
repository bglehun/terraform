variable "app_name" {
  type    = string
  default = "chat-server"
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "subnet_count" {
  type    = number
  default = 2
}

variable "app_count" {
  type    = number
  default = 1
}

variable "tag_name" {
  type    = string
  default = "service"
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "host_port" {
  type    = number
  default = 80
}

variable "container_image" {
  type    = string
  default = "registry.gitlab.com/architect-io/artifacts/nodejs-hello-world:latest"
}

variable "redis_host" {
  type    = string
  default = "localhost"
}

variable "redis_port" {
  type    = number
  default = 6379
}

variable "mysql_host" {
  type = string
}

variable "mysql_port" {
  type    = number
  default = 3306
}

variable "mysql_db_name" {
  type = string
}

variable "mysql_user" {
  type    = string
  default = "admin"
}

variable "mysql_password" {
  type    = string
  default = "chatserveradmin"
}
