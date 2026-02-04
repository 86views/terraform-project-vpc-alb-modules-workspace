# 3-Tier AWS Infrastructure with Terraform + Packer

This repository contains Terraform code to deploy a **3-tier architecture** on AWS, featuring a VPC, Application Load Balancer (ALB), EC2 instances (or Auto Scaling Groups), and an RDS database. The project is structured using **Terraform modules** and **workspaces** for multiple environments (e.g., dev, staging, prod). Packer is used to build custom AMIs for the application tier. Terraform state is stored remotely in an **S3 bucket** with DynamoDB locking for safety.

## Architecture Overview

The infrastructure follows a classic 3-tier pattern:

1. **Presentation Tier**  
   - Application Load Balancer (ALB) in public subnets  
   - Distributes traffic to the application tier  
   - HTTPS termination with ACM certificate (optional)

2. **Application Tier**  
   - Auto Scaling Group (ASG) of EC2 instances in private subnets  
   - Uses custom AMI built with Packer  
   - Security groups restrict traffic from ALB only

3. **Data Tier**  
   - RDS instance (MySQL/PostgreSQL) in private subnets  
   - Multi-AZ for high availability (optional)

4. **Networking**  
   - Custom VPC with public and private subnets across multiple AZs  
   - NAT Gateway for outbound internet access from private subnets  
   - Internet Gateway for public access

### Diagram (Mermaid)

```mermaid
graph TD
    A[Internet] --> IGW[Internet Gateway]
    IGW --> VPC[VPC]
    subgraph VPC
        ALB[Application Load Balancer<br>(Public Subnets)] --> ASG[Auto Scaling Group<br>(Private Subnets<br>Custom AMI via Packer)]
        ASG --> RDS[RDS Database<br>(Private Subnets)]
    end
    ALB -->|HTTPS/HTTP| Users[Users]