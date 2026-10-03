# Bootstrap

Creates the central Cloudflare R2 bucket (`kennethl-tfstate`) that stores all
Terraform remote state. Every other stack writes its state into this bucket
under a unique key:

```text
bootstrap/terraform.tfstate
prod/cloudflare-backup/terraform.tfstate
```

## The chicken-and-egg problem

The state bucket cannot store its own state until the bucket exists. So the
first apply must use **temporary local state**; after the bucket is created the
state is migrated into the bucket itself.

Terraform needs state to *manage* a resource, not to *create* it. Losing the
local state would not delete the bucket, but the bucket would become
unmanaged and require `terraform import` to recover.

## Once, in order

1. Create a Cloudflare API token (`Account → Workers R2 Storage → Edit`) and set:

   ```sh
   export CLOUDFLARE_API_TOKEN="..."
   export TF_VAR_cloudflare_account_id="..."
   ```

2. Copy and fill the variables file:

   ```sh
   cp terraform/bootstrap/terraform.tfvars.example \
      terraform/bootstrap/terraform.tfvars
   ```

3. Create the state bucket with temporary local state:

   ```sh
   just tf-bootstrap
   ```

4. Create R2 **S3** credentials (Object Read & Write, scoped to
   `kennethl-tfstate`) and export them for the backend:

   ```sh
   export AWS_ACCESS_KEY_ID="..."
   export AWS_SECRET_ACCESS_KEY="..."
   ```

5. Copy and fill the backend config with your account ID:

   ```sh
   cp terraform/bootstrap/backend.hcl.example \
      terraform/bootstrap/backend.hcl
   ```

6. Migrate the temporary local state into the bucket:

   ```sh
   terraform -chdir=terraform/bootstrap init \
     -backend-config=backend.hcl -migrate-state
   ```

7. Confirm nothing changed and the state now lives remotely:

   ```sh
   terraform -chdir=terraform/bootstrap plan
   # terraform -chdir=terraform/bootstrap state list  → the bucket resource
   ```

8. Remove the temporary local state file once migration is verified:

   ```sh
   rm -f terraform/bootstrap/terraform.tfstate
   ```

From then on, `bootstrap` is initialized like any other stack:

```sh
terraform -chdir=terraform/bootstrap plan
```

## GitOps note

Migrating bootstrap state does **not** make this less GitOps. The split is:

- **In Git**: Terraform code, `backend.tf`, `backend.hcl.example`, this README.
- **Not in Git**: runtime state, credentials, and the filled `backend.hcl`.

These are Git-managed stacks with **manual** `plan`/`apply`. That is
Infrastructure as Code, but not yet full GitOps — automation (CI, Atlantis, a
Terraform controller) would be required for that.

## Never commit

```text
*.tfstate            terraform.tfvars
backend.hcl          .env
```
