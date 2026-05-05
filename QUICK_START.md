# Quick Start Checklist - AWS Learners Lab

## What Changed?
✅ **Jenkins** → **GitHub Actions** (no server maintenance needed)
✅ **Kubernetes** → **Docker Compose** (simpler, single server)
✅ **2x t2.medium** → **1x t2.micro** (saves ~70% costs)

---

## Immediate Action Items (15 minutes)

### 1. Add Credentials to GitHub
- [ ] Go to: https://github.com/Bee-eep/Devops_project_2/settings/secrets/actions
- [ ] Click **New repository secret**
- [ ] Add 3 secrets:
  ```
  Name: DOCKER_USERNAME
  Value: <your-dockerhub-username>
  
  Name: DOCKER_PASSWORD
  Value: <your-dockerhub-token-or-password>
  
  Name: SERVER_SSH_KEY
  Value: <contents-of-My_Key.pem-file>
  ```

### 2. Deploy Infrastructure
```bash
cd terraform_files
terraform init
terraform plan
terraform apply
```
- **Wait 2-3 minutes** for EC2 to initialize

### 3. Get Server IP
```bash
terraform output
```
- Note `APP_SERVER_PUBLIC_IP` value

### 4. Add Server Credentials to GitHub
- Go to GitHub Secrets (same place as step 1)
- Add:
  ```
  Name: SERVER_HOST
  Value: <your-APP_SERVER_PUBLIC_IP>
  
  Name: SERVER_USER
  Value: ec2-user
  ```

### 5. Clone Repo on Server
```bash
ssh -i My_Key.pem ec2-user@<APP_SERVER_PUBLIC_IP>
cd /opt/devops-project
git clone https://github.com/Bee-eep/Devops_project_2.git .
```

### 6. Trigger CI/CD
```bash
git add .
git commit -m "Add GitHub Actions and Docker Compose"
git push origin main
```

### 7. Watch GitHub Actions
- Go to: https://github.com/Bee-eep/Devops_project_2/actions
- Click the workflow run to see status

### 8. Test Your App
- Open: `http://<APP_SERVER_PUBLIC_IP>`
- You should see your Spring Boot app!

---

## Files Created/Updated

### ✅ New Files (GitHub Actions)
```
.github/workflows/ci.yml   - Build, test, scan, push Docker image
.github/workflows/cd.yml   - Deploy to server
docker-compose.yml         - Container orchestration
```

### ⚠️ Deprecated Files (Keep for reference, not used)
```
deployment.yaml           - Was for Kubernetes
service.yaml              - Was for Kubernetes
Jenkinsfile-CI            - Was for Jenkins
Jenkinsfile-CD            - Was for Jenkins
terraform_files/node.tf   - Was for Kubernetes node
```

### 🔄 Updated Files
```
terraform_files/main.tf   - Now deploys single EC2 + Docker Compose
```

---

## Cost Breakdown (AWS Learners Lab)

| Component | Cost | Notes |
|-----------|------|-------|
| EC2 t2.micro | ~$0-3/month | Free tier eligible |
| EBS 15GB | ~$1-2/month | Reduced from 30GB |
| Data Transfer | ~$0 | Free tier generous |
| GitHub Actions | **$0** | Free for public repos |
| **Total** | **~$1-5/month** | Very budget-friendly |

---

## ⚠️ CRITICAL: Clean Up When Done!

**AWS Learners Lab charges even for stopped instances!**

When you're finished with the project:
```bash
# Option 1: Destroy Terraform resources (RECOMMENDED)
terraform destroy

# Option 2: Manual cleanup
# AWS Console → EC2 → Right-click instance → Terminate
```

**Check your Learners Lab billing dashboard regularly!**

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Terraform fails to create instance | Check AWS credentials, region is us-east-1, key pair exists |
| SSH connection timeout | Wait 3 mins, check security group allows port 22 |
| Docker Compose won't start | SSH to server, run `docker-compose logs` |
| GitHub Actions fails | Check secrets are added correctly (no extra spaces) |
| Out of credits | Immediately destroy resources and contact AWS Learners Lab |

---

## Full Guide
See `SETUP_GUIDE_LEARNERS_LAB.md` for detailed instructions and troubleshooting.

---

**Status: Ready to Deploy** ✅
