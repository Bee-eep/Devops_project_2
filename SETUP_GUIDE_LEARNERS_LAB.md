# Tech Stack Setup Guide - AWS Learners Lab Edition

## Overview
This guide configures your DevOps project for AWS Learners Lab using:
- **Docker Compose** for application runtime
- **GitHub Actions** for CI/CD
- **1x t2.micro** EC2 instance for deployment

---

## OPTION 1: Full Terraform Deployment (Recommended)

### Prerequisites
1. **AWS Learners Lab credentials** with access to us-east-1
2. **GitHub account** with your repository
3. **Docker Hub account** with credentials (free)
4. **SSH Key** - ensure `My_Key.pem` is in the terraform_files directory

### Step 1: Set Up GitHub Actions (FREE - No Infrastructure Cost)

GitHub Actions handles your CI/CD without any server. This is **included in your repository** and costs nothing.

#### 1.1 Add Docker Hub Credentials to GitHub
1. Go to your GitHub repository → **Settings → Secrets and variables → Actions**
2. Create these secrets:
   - `DOCKER_USERNAME`: your Docker Hub username
   - `DOCKER_PASSWORD`: your Docker Hub access token (or password)

#### 1.2 Verify Workflows
The workflows are already created:
- `.github/workflows/ci.yml` - Runs tests, builds Docker image, pushes to Docker Hub
- `.github/workflows/cd.yml` - Deploys to your server

### Step 2: Deploy Single EC2 Server with Terraform

#### 2.1 Prepare Terraform
```bash
cd terraform_files
```

Make sure you have `My_Key.pem` in the `terraform_files` directory (your AWS Learners Lab SSH key).

#### 2.2 Initialize Terraform
```bash
terraform init
```

#### 2.3 Plan the Deployment
```bash
terraform plan
```
This shows you what will be created (1 EC2 instance, 1 security group).

#### 2.4 Apply Terraform
```bash
terraform apply
```

**Output will show:**
```
APP_SERVER_PUBLIC_IP = <your-public-ip>
APP_SERVER_PRIVATE_IP = <your-private-ip>
ACCESS_YOUR_APP_HERE = http://<your-public-ip>:80
```

**Save these values!** You'll need them for deployment.

### Step 3: Configure Your Server

After Terraform completes, wait **2-3 minutes** for the EC2 instance initialization.

#### 3.1 SSH into Your Server
```bash
ssh -i My_Key.pem ec2-user@<APP_SERVER_PUBLIC_IP>
```

#### 3.2 Clone Your Repository
```bash
cd /opt/devops-project
git clone https://github.com/Bee-eep/Devops_project_2.git .
```

#### 3.3 Configure GitHub Actions Deployment Credentials

Add these secrets to your GitHub repository for deployment:
1. Go to **Settings → Secrets and variables → Actions**
2. Add:
   - `SERVER_HOST`: Your `APP_SERVER_PUBLIC_IP` from terraform output
   - `SERVER_USER`: `ec2-user`
   - `SERVER_SSH_KEY`: Contents of your `My_Key.pem` file (entire key, including BEGIN/END lines)

### Step 4: Push Code to Trigger CI/CD

```bash
git add .
git commit -m "Add GitHub Actions and Docker Compose"
git push origin main
```

**GitHub Actions will:**
1. Run unit tests
2. Build Docker image
3. Scan with Trivy
4. Push to Docker Hub
5. Deploy to your server with Docker Compose

---

## OPTION 2: Manual Setup (If Terraform Fails or Budget is Tight)

If Terraform has issues, you can manually set up in 5 minutes:

### 2.1 Create EC2 Instance Manually
1. Go to **AWS Console → EC2 → Launch Instance**
2. Select: **Amazon Linux 2 AMI** (or latest)
3. Instance Type: **t2.micro** (free tier eligible)
4. Storage: **15 GB gp2**
5. Security Group - Allow:
   - Port 22 (SSH)
   - Port 80 (HTTP)
   - Port 443 (HTTPS)
6. Launch with your existing key pair

### 2.2 Setup Instance (SSH in and run):
```bash
#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
sudo yum install git -y

# Create project directory
mkdir -p /opt/devops-project
sudo chown -R ec2-user:ec2-user /opt/devops-project
```

### 2.3 Clone and Deploy
```bash
cd /opt/devops-project
git clone https://github.com/Bee-eep/Devops_project_2.git .
docker-compose up -d
```

---

## OPTION 3: Cost-Saving Tips (IMPORTANT!)

### Stop Instances When Not Using
**AWS Learners Lab charges even for stopped instances!** Delete when done:

```bash
# Option A: Destroy Terraform resources (safest)
terraform destroy

# Option B: Stop instance manually
# AWS Console → EC2 → Right-click instance → Instance State → Stop
```

### Alternative: AWS Lightsail
If you want a simpler, more predictable cost:
- **AWS Lightsail**: Fixed $3.50/month for t2.micro equivalent
- Includes 1TB bandwidth
- Better for learning/demos

---

## File Structure

```
.github/
  workflows/
    ci.yml          # GitHub Actions CI pipeline
    cd.yml          # GitHub Actions CD pipeline
docker-compose.yml  # Docker Compose configuration
deployment.yaml     # [DEPRECATED - no longer used]
service.yaml        # [DEPRECATED - no longer used]
Jenkinsfile-CI      # [DEPRECATED - no longer used]
Jenkinsfile-CD      # [DEPRECATED - no longer used]
terraform_files/
  main.tf           # Single EC2 + Security Group (SIMPLIFIED)
  node.tf           # [DEPRECATED - Kubernetes removed]
  provider.tf       # AWS configuration
```

---

## Troubleshooting

### GitHub Actions Workflow Won't Run
- Check `.github/workflows/ci.yml` is in the repository
- Go to **Actions tab** and enable GitHub Actions
- Verify Docker Hub credentials are correct

### SSH Into Server Fails
```bash
# Check key permissions
chmod 600 My_Key.pem

# Verify security group allows port 22
aws ec2 describe-security-groups --region us-east-1
```

### Docker Compose Won't Start
```bash
# SSH into server and check logs
ssh -i My_Key.pem ec2-user@<IP>
cd /opt/devops-project
docker-compose logs
```

### Out of Credits
- **Stop/delete resources immediately** to avoid overage charges
- Check AWS Learners Lab billing dashboard
- Consider requesting lab extension

---

## Next Steps

1. ✅ Update GitHub secrets (Docker Hub + Server credentials)
2. ✅ Run `terraform apply` to create the server
3. ✅ Wait for instance to be ready (~3 minutes)
4. ✅ Push code to trigger GitHub Actions
5. ✅ Monitor Actions tab for build/deploy status
6. ✅ Visit `http://<APP_SERVER_PUBLIC_IP>` to see your app
7. ✅ **Remember to destroy resources when done to save credits!**

---

## Quick Commands Reference

```bash
# Check terraform status
terraform show

# Get outputs (IP addresses)
terraform output

# Deploy latest code
ssh -i My_Key.pem ec2-user@<IP> "cd /opt/devops-project && git pull && docker-compose pull && docker-compose up -d"

# View app logs
ssh -i My_Key.pem ec2-user@<IP> "docker-compose logs -f"

# Destroy infrastructure (IMPORTANT - saves credits!)
terraform destroy
```

---

**Estimated setup time: ~15 minutes**  
**Monthly Cost with Learners Lab: ~$3-8 (t2.micro + EBS)**  
**CI/CD Cost: $0 (GitHub Actions is free for public repos)**
