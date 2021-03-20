variable "name" {
  type = string
}

variable "description" {
  type = string
  default = ""
}

variable "path" {
  type = string
  default = ""
}

variable "urls_prefix" {
  type = set(string)
  default = []
}
