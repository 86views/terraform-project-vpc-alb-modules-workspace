terraform {
  backend "s3" {
    bucket       = "my-tf-demo-harish-bucket-2025"
    key          = "s3-bucket/${terraform.workspace}.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
