# Create .oci directory in your home folder if it doesn't exist
mkdir ~/.oci

# Generate private key (no password protection)
openssl genrsa -out ~/.oci/oci_api_key.pem 2048

# Generate public key
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem

# Set the correct permissions
chmod 600 ~/.oci/oci_api_key.pem
chmod 600 ~/.oci/oci_api_key_public.pem