variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Project prefix"
  type        = string
  default     = "secure-iac-demo"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Example AMI, replace with correct AMI per-region (you can look up Amazon Linux 2 AMI)
variable "ami" {
  description = "AMI ID"
  type        = string
  default     = "ami-0cae6d6fe6048ca2c" # Example (change for your region)
}
