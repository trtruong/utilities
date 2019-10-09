variable "env" {
  type = "string"
}

variable "env_short" {
  type = "map"
  default = {
    "staging" = "s"
    "production" = "p"
    "pre-staging" = "a"
  }
}
