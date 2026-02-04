terraform {
  backend "s3" {
    bucket       = "tf-three-tier-7afc2a05"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

