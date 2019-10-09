variable "regions" {
  type = map(string)

  default = {
    "us-east-1" = "use1"
    "us-east-2" = "use2"
    "us-west-1" = "usw1"
    "us-west-2" = "usw2"
    "eu-west-1" = "uew1"
    "eu-west-2" = "uew2"
  }
}

variable "env" {
  type = "string"
}

variable "bucket_name" {
  type = "map"
  default = {
    "staging" = "s3-use2-s-cops-tfstates"
    "production" = "s3-use2-p-cops-tfstates"
    "pre-staging" = "s3-use2-a-cops-tfstates"
  }
}
