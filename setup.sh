#!/bin/bash

# ==================== CONFIGURE THESE ====================
PROJECT_ID="fresh-84"           # ← Your GCP project ID
GITHUB_ORG="ccdennar"      # ← Your GitHub org/user
GITHUB_REPO="GKE_Cluster"           # ← Your repository name
# =======================================================

echo "🚀 Setting up Workload Identity Federation for GitHub Actions"

# Get project number
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
echo "📊 Project Number: $PROJECT_NUMBER"

# Step 1: Enable APIs
echo "🔧 Enabling APIs..."
gcloud services enable iamcredentials.googleapis.com --project=$PROJECT_ID

# Step 2: Create Workload Identity Pool
echo "🏊 Creating Workload Identity Pool..."
gcloud iam workload-identity-pools create "github-pool" \
  --project=$PROJECT_ID \
  --location="global" \
  --display-name="GitHub Actions Pool" 2>/dev/null || echo "Pool already exists"

# Step 3: Create GitHub OIDC Provider
echo "🔐 Creating OIDC Provider..."
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project=$PROJECT_ID \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --attribute-condition="assertion.repository == '$GITHUB_ORG/$GITHUB_REPO'" 2>/dev/null || echo "Provider already exists"

# Step 4: Create Terraform Service Account
echo "👤 Creating Service Account..."
TF_SA_EMAIL="terraform@$PROJECT_ID.iam.gserviceaccount.com"
gcloud iam service-accounts create "terraform" \
  --project=$PROJECT_ID \
  --display-name="Terraform" 2>/dev/null || echo "Service account already exists"

# Step 6: Allow GitHub to impersonate SA (THE KEY STEP!)
echo "🔗 Connecting GitHub to Service Account..."
gcloud iam service-accounts add-iam-policy-binding $TF_SA_EMAIL \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/$GITHUB_ORG/$GITHUB_REPO" \
  --quiet > /dev/null

# Step 7: Output the values
echo ""
echo "✅ SETUP COMPLETE! Add these to GitHub:"
echo "================================================"
echo ""
echo "Go to: https://github.com/$GITHUB_ORG/$GITHUB_REPO/settings/variables/actions"
echo ""
echo "Add these VARIABLES (not secrets):"
echo ""
echo "Name: WIF_PROVIDER"
echo "Value: projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
echo ""
echo "Name: TF_SERVICE_ACCOUNT"
echo "Value: $TF_SA_EMAIL"
echo ""
echo "================================================"