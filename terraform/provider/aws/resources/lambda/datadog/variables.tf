variable "env" {
  type = string
}

variable "bucket-map" {
  default = {
    "staging" = "s3-use2-s-cops-tfstates"
    "production" = "s3-use2-p-cops-tfstates"
    "pre-staging" = "s3-use2-a-cops-tfstates"
  }
}
