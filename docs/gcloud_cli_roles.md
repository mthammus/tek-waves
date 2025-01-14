# Replace test-1-442118 with your project ID if different
gcloud services enable compute.googleapis.com --project=test-1-442118

# Replace [YOUR_EMAIL] with your Google account email
gcloud projects add-iam-policy-binding test-1-442118 \
    --member="user:[YOUR_EMAIL]" \
    --role="roles/compute.networkAdmin"

# Verify your current IAM roles:
gcloud projects get-iam-policy test-1-442118 \
    --flatten="bindings[].members" \
    --format='table(bindings.role)' \
    --filter="bindings.members:$(gcloud config get-value account)"    

# Check current account
gcloud auth list

# Login if needed
gcloud auth application-default login



# Default Project configuration

# Verify your project is set correctly:
gcloud config set project test-1-442118

# First, set up new application default credentials
gcloud auth application-default login

# After login, set the quota project
gcloud auth application-default set-quota-project test-1-442118

# Verify your project setting
gcloud config get-value project