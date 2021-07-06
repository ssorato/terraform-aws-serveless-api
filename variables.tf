variable "lab_name" {
  type = string
  description = "Lab name"
}

variable "common_tag" {
  type = map(string)
  description = "Common resource tags"
}
