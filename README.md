# Import .env values into Azure Key Vault using PowerShell Script

## Overview

This document describes how to import am application's Environment variables from a **`.env` file** into an existing **Azure Key Vault** using **PowerShell**.

This approach is useful when developers share application configuration values and the DevOps/Cloud team needs to securely store them in Azure Key Vault.

---

## Prerequisites

### Azure Access for the User

Ensure you have one of the following permissions on the Azure Key Vault:

* Key Vault Administrator
* Key Vault Secrets Officer
* Contributor with appropriate Key Vault permissions
* Ensure that your IP gets whitelisted to access Secrets in Azure Keyvault

### Install Azure PowerShell Module in local

Install the Azure PowerShell module if not already installed:

```powershell
Install-Module -Name Az -Scope CurrentUser -Force
```

Verify installation:

```powershell
Get-Module -ListAvailable Az*
```

---

## Login to Azure through PowerShell/CMD

```powershell
Connect-AzAccount
```

Verify available subscriptions:

```powershell
Get-AzSubscription
```

Select the required subscription:

```powershell
Set-AzContext -SubscriptionId "<subscription-id>"
```

---

## Keep Sample .env File in local

```env
DB_HOST=myserver.postgres.database.azure.com
DB_PORT=5432
DB_NAME=mydb
DB_USER=admin
DB_PASSWORD=MyPassword123
REDIS_HOST=myredis.redis.cache.windows.net
REDIS_PASSWORD=RedisSecret
JWT_SECRET=jwt-secret-value
```

---

## Create PowerShell Script in local

```powershell
$vaultName = "my-keyvault"
$envFile = "C:\Path\To\.env"

Get-Content $envFile | ForEach-Object {

    if ($_ -match '^\s*$' -or $_ -match '^\s*#') {
        return
    }

    $parts = $_ -split '=', 2

    if ($parts.Count -eq 2) {

        # Azure Key Vault secret names support only letters, numbers and hyphens
        $secretName = $parts[0].Trim().Replace('_','-')

        $secretValue = $parts[1].Trim()

        $secureValue = ConvertTo-SecureString `
            $secretValue `
            -AsPlainText `
            -Force

        Set-AzKeyVaultSecret `
            -VaultName $vaultName `
            -Name $secretName `
            -SecretValue $secureValue

        Write-Host "Added secret: $secretName"
    }
}
```

---

## Verify Imported Secrets

List all secrets:

```powershell
Get-AzKeyVaultSecret -VaultName "<keyvault-name>"
```

View a specific secret:

```powershell
Get-AzKeyVaultSecret `
    -VaultName "<keyvault-name>" `
    -Name "DB-PASSWORD"
```

---

## Important Notes

### Secret Naming Restrictions

Azure Key Vault secret names must match:

```text
^[0-9a-zA-Z-]+$
```

Allowed:

```text
DB-PASSWORD
REDIS-PASSWORD
JWT-SECRET
```

Not Allowed:

```text
DB_PASSWORD
REDIS_PASSWORD
JWT_SECRET
```

Therefore, the script automatically converts underscores (`_`) to hyphens (`-`).

### Secret Encryption

No manual encryption is required.

Azure Key Vault automatically encrypts all secrets at rest.

### Secret Versioning

If a secret already exists:

* Azure Key Vault creates a new version.
* Existing applications continue to retrieve the latest version by default.

---

## Recommended Use Cases

Use this approach when:

* Developers provide a `.env` file.
* Existing Azure Key Vaults are already created.
* A one-time migration of secrets is required.
* DevOps teams need to quickly onboard application secrets into Azure Key Vault.

---

## Terraform Consideration

Terraform can technically create Azure Key Vault secrets.

However, for importing developer-provided `.env` files into an existing Key Vault, PowerShell or Azure CLI is generally the preferred approach because:

* Faster for one-time imports.
* Simpler operational workflow.
* No need to store secret values in Terraform code or state files.
* Easier for DevOps engineers handling application onboarding activities.

For routine secret migrations and operational tasks, PowerShell remains the recommended method.
