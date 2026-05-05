# New Project Structure - Simplified Tech Stack

## 📁 Repository Structure

```
DevopsProject2.main/
│
├── 📄 QUICK_START.md                    ⭐ START HERE - 15 min setup guide
├── 📄 SETUP_GUIDE_LEARNERS_LAB.md      📚 Detailed setup guide
├── 📄 BEFORE_AND_AFTER.md               📊 Architecture comparison
│
├── 🐳 docker-compose.yml                ✨ NEW - Docker Compose config
│   └── Replaces: deployment.yaml + service.yaml
│
├── .github/                             ✨ NEW - GitHub Actions CI/CD
│   └── workflows/
│       ├── ci.yml                       Build, test, scan, push
│       └── cd.yml                       Deploy to server
│
├── 📁 terraform_files/                  🔄 UPDATED - Simplified
│   ├── main.tf                          🔄 UPDATED - Single EC2 + SG
│   ├── node.tf                          ⚠️  DEPRECATED - Kubernetes removed
│   ├── provider.tf                      ✓ No changes needed
│   └── README.md                        (original)
│
├── 📁 src/                              ✓ No changes
│   ├── main/
│   │   ├── java/com/javatechie/
│   │   │   └── DevopsIntegrationApplication.java
│   │   └── resources/
│   │       ├── application.properties
│   │       └── application.yml
│   └── test/
│       └── java/com/javatechie/
│           └── DevopsIntegrationApplicationTests.java
│
├── pom.xml                              ✓ No changes
├── Dockerfile                           ✓ No changes
│
├── ⚠️  Jenkinsfile-CI                    DEPRECATED - Replaced by .github/workflows/ci.yml
├── ⚠️  Jenkinsfile-CD                    DEPRECATED - Replaced by .github/workflows/cd.yml
├── ⚠️  deployment.yaml                   DEPRECATED - Replaced by docker-compose.yml
├── ⚠️  service.yaml                      DEPRECATED - Replaced by docker-compose.yml
│
└── mvnw, mvnw.cmd, ...                  ✓ No changes
```

---

## 🆕 New Files Explained

### 1. **QUICK_START.md** ⭐ START HERE
- **Purpose**: Checklist for immediate 15-minute setup
- **Use when**: You want to deploy as quickly as possible
- **Contains**: Step-by-step commands and GitHub secret setup

### 2. **.github/workflows/ci.yml**
- **Purpose**: GitHub Actions workflow for building & testing
- **Triggers**: On every push to main/develop branches
- **Does**:
  - ✅ Runs Maven unit tests
  - ✅ Runs Maven integration tests
  - ✅ Builds Docker image with build number tag
  - ✅ Scans image with Trivy security tool
  - ✅ Pushes image to Docker Hub (latest + numbered)
- **No server needed** - Runs on GitHub's infrastructure

### 3. **.github/workflows/cd.yml**
- **Purpose**: GitHub Actions workflow for deployment
- **Triggers**: When CI pipeline succeeds on main branch
- **Does**:
  - ✅ SSHs into your EC2 server
  - ✅ Pulls latest code from GitHub
  - ✅ Pulls latest Docker image from Docker Hub
  - ✅ Stops old container with `docker-compose down`
  - ✅ Starts new container with `docker-compose up -d`
- **Requires**: SERVER_HOST, SERVER_USER, SERVER_SSH_KEY secrets

### 4. **docker-compose.yml**
- **Purpose**: Defines how your application container runs
- **Replaces**: Kubernetes deployment.yaml + service.yaml
- **Contains**:
  ```yaml
  services:
    devops-project-app:
      image: beeeeeep/ci-pipeline:latest  # Pulls latest from Docker Hub
      container_name: devops-project-1
      ports:
        - "80:8080"                        # External port 80 → App port 8080
      environment:                         # JVM memory settings
        - JAVA_OPTS=-Xmx512m -Xms256m
      restart: unless-stopped              # Auto-restart if crashes
      healthcheck:                         # Monitors app health
        test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
  ```
- **Usage**: `docker-compose up -d` (start) / `docker-compose down` (stop)

### 5. **terraform_files/main.tf** (UPDATED)
- **Changed from**: 2 EC2 instances + Jenkins + Kubernetes setup
- **Changed to**: 1 EC2 instance + Docker + Docker Compose
- **Instance Type**: t2.micro (cost-optimized for Learners Lab)
- **What it creates**:
  - 1 Security Group (allows SSH, HTTP, HTTPS)
  - 1 EC2 instance with Docker pre-installed
  - Docker Compose pre-installed
  - Git pre-installed
  - Outputs: Server IP address
- **Usage**: `terraform apply` to create infrastructure

---

## ⚠️ Deprecated Files (Keep for Reference Only)

### **Jenkinsfile-CI** 
- ❌ No longer used - Jenkins server is gone
- 📝 Replaced by: `.github/workflows/ci.yml`
- 💡 Note: GitHub Actions is now faster and free

### **Jenkinsfile-CD**
- ❌ No longer used - Jenkins server is gone
- 📝 Replaced by: `.github/workflows/cd.yml`
- 💡 Note: GitHub Actions directly SSH into EC2

### **deployment.yaml**
- ❌ No longer used - Kubernetes is gone
- 📝 Replaced by: `docker-compose.yml`
- 💡 Note: Kubernetes was overkill for a single application

### **service.yaml**
- ❌ No longer used - Kubernetes is gone
- 📝 Replaced by: `docker-compose.yml` (ports section)
- 💡 Note: Docker Compose handles networking simply

### **terraform_files/node.tf**
- ❌ No longer used - Kubernetes worker nodes are gone
- 📝 Replaced by: Single server in `main.tf`
- 💡 Note: All infrastructure is now in main.tf

---

## 🚀 Workflow: How It All Works Together

### Step 1: You Push Code
```bash
git add .
git commit -m "Update API"
git push origin main
```

### Step 2: GitHub Actions CI Kicks In (Automatic)
```
GitHub detects push to main
↓
Runs .github/workflows/ci.yml
├─ Maven test & build
├─ Docker build
├─ Trivy scan
└─ Push to Docker Hub
↓
Build succeeds/fails
```

### Step 3: GitHub Actions CD Kicks In (If CI Passed)
```
CI pipeline succeeded
↓
Runs .github/workflows/cd.yml
├─ SSH into EC2 server
├─ Git pull latest code
├─ Docker pull latest image
├─ Stop old container (docker-compose down)
└─ Start new container (docker-compose up -d)
↓
Your app is now live!
```

### Step 4: Your App Runs
```
Docker container starts
├─ Runs Spring Boot application
├─ Listens on port 8080 (inside container)
├─ Exposed as port 80 (external)
├─ Health checks run every 30 seconds
└─ Auto-restarts if it crashes
```

---

## 📊 Cost Breakdown by Component

| Component | Type | Cost | Managed by |
|-----------|------|------|-----------|
| GitHub Actions CI | Compute | **FREE** | GitHub |
| GitHub Actions CD | Compute | **FREE** | GitHub |
| Docker Hub | Storage | **FREE** (public) | Docker |
| EC2 t2.micro | Compute | ~$0.0116/hr | AWS/Terraform |
| EBS 15GB | Storage | ~$1.50/month | AWS/Terraform |
| Data Transfer | Network | **FREE** (mostly) | AWS |
| **TOTAL** | | **~$4/month** | |

---

## ✅ Pre-Deployment Checklist

- [ ] Read QUICK_START.md
- [ ] Have AWS Learners Lab access
- [ ] Have GitHub account with repo push access
- [ ] Have Docker Hub account + token
- [ ] Have My_Key.pem (AWS SSH key) in terraform_files/
- [ ] Added DOCKER_USERNAME & DOCKER_PASSWORD to GitHub secrets
- [ ] Terraform files are in place (main.tf, provider.tf)

---

## 🆘 Quick Troubleshooting

| Issue | File to Check |
|-------|---------------|
| GitHub Actions won't start | `.github/workflows/ci.yml` exists and is valid YAML |
| Docker image won't build | `Dockerfile` and `pom.xml` are correct |
| Deployment fails | Check `.github/workflows/cd.yml` and GitHub secrets |
| App won't start on server | SSH to EC2 and check `docker-compose logs` |
| Can't SSH to server | Check security group and My_Key.pem permissions |
| Out of AWS credits | Run `terraform destroy` immediately! |

---

## 📚 Next Steps

1. Read **QUICK_START.md** (you are here → this is it!)
2. Go through the **SETUP_GUIDE_LEARNERS_LAB.md** for full details
3. Run `terraform apply` to create your server
4. Add GitHub secrets (Docker Hub + Server credentials)
5. Push code to trigger CI/CD
6. Monitor at GitHub Actions tab
7. Visit your app at `http://<server-ip>`

---

**Good luck! 🚀 You've now got a modern, simple, cost-effective DevOps setup!**
