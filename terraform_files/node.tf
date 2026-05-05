# Simplified node configuration removed
# All infrastructure is now managed by single APP-SERVER in main.tf
# This file is kept for reference but node resources are no longer used
#
# The new simplified stack uses:
# - Single t2.small EC2 instance (APP-SERVER)
# - Docker Compose for container orchestration
# - GitHub Actions for CI/CD (no server needed)
