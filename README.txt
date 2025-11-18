# Secure IaC Project with Terraform, AWS, and Jenkins CI/CD
---

## Architecture Overview

Terraform provisions secure AWS components:

- **S3 Bucket**
  - Server-side encryption (AES-256)
  - Public access fully blocked
- **IAM Role + IAM Policy**
  - Allows EC2 *only* Get/Put/List access to this specific bucket
- **Instance Profile**
  - Binds IAM role to an EC2 instance (for future use)

Jenkins performs the full IaC pipeline:

1. Checkout Terraform repo  
2. Terraform init & validate  
3. Security scanning (tfsec / checkov)  
4. Terraform plan  
5. Terraform apply  
6. Archive security reports  

---

## 📁 Project Structure

                  (AWS Global Services)
                 +---------------------+
                 |         S3          |
                 +---------------------+
                          ▲
                          │  (public internet or VPC endpoint)
                          │
+--------------------------------------------------------------+
|                           VPC                                |
|   +------------------+                                       |
|   |     Subnet       |                                       |
|   |   +----------+   |                                       |
|   |   |   EC2    |   |                                       |
|   |   +----------+   |                                       |
|   +------------------+                                       |
+--------------------------------------------------------------+

