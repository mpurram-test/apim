# APIM Platform Repository (v2)

This repository owns **all shared Azure API Management (APIM) configuration**:

- **Policy fragments** (reusable XML) and **global/product policies**
- **Products** and **regex‑driven Product→API links**
- **Subscriptions (keys) per product**
- **Named Values** (supports **Key Vault** references)
- **Backends** (upstream service endpoints)

> This repo **does not** import APIs or OpenAPI specs. API import lives in API repositories.

## Environment Support
- `stage`
- `prod`

`EIS-APIM-Platform` is the central shared APIM repository. API repositories are expected to manage API deployment, API version sets, API-level policy, and API-level subscription settings.

## Structure
```
apim_platform_enterprise_v2/
  policies/
    fragments/
      global-error-handling.xml
      jwt-error-handling.xml
      seacoast-oauth.xml
      debug-error-response.xml
    product-policies/
      quavo.xml
  terraform/
    modules/
      backends/
      global_policy/
      named_values/
      policy_fragments/
      product_api_links/
      product_policies/
      products/
      subscriptions/
    envs/
      stage/
        providers.tf
        variables.tf
        main.tf
        terraform.tfvars
        backend.tfvars
      prod/
        providers.tf
        variables.tf
        main.tf
        terraform.tfvars
        backend.tfvars
  Jenkinsfile
```

## Usage
1. Fill `terraform/envs/<env>/terraform.tfvars` with the environment-specific platform configuration.
2. Fill `terraform/envs/<env>/backend.tfvars` with the remote state backend details.
3. Run via Jenkins (see included Jenkinsfile) or locally:
   ```bash
   terraform -chdir=terraform/envs/<env> init -backend-config=backend.tfvars
   terraform -chdir=terraform/envs/<env> plan -var-file=terraform.tfvars -out=tfplan.out
   terraform -chdir=terraform/envs/<env> apply -auto-approve tfplan.out
   ```

## Important notes
- **Fragments are uploaded once** and referenced from product/global/API policies via `<include-fragment fragment-id="..."/>`.
- **Product→API links** use **regex** patterns to match API names; re-run the platform pipeline any time to reconcile links.
- Use **`strict_min_match`** when you want the plan to **fail** if an expected number of APIs aren’t matched.
- Keep product ownership in this repository; do not duplicate product configuration in API repos.

## Recommendations
- Keep authentication secret-based for now (`ARM_CLIENT_SECRET`) until workload identity federation is approved and ready.
- Keep `plan -detailed-exitcode` and `-lock-timeout=5m` in CI to reduce state lock contention and handle no-change plans cleanly.
- Keep production approval gate enabled before apply.
- Keep fail-fast apply behavior; avoid automated `destroy -target` rollback in shared environments.
- Keep backend tfvars files as templates/placeholders in git and inject real values through CI/CD or secure variables.
- Optional next hardening: enable `tfsec` and `tflint` as a separate pipeline stage when tooling/runtime support is available.
