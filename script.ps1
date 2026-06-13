$vaultName = "kv-keyvault-test-89"
$envFile = "C:\Users\CHITTI\Downloads\.env.txt"

Get-Content $envFile | ForEach-Object {

    if ($_ -match '^\s*$') { return }
    if ($_ -match '^\s*#') { return }

    $parts = $_ -split '=', 2

    if ($parts.Count -eq 2) {

        $secretName = $parts[0].Trim()
        $secretValue = $parts[1].Trim()

        $secureValue = ConvertTo-SecureString $secretValue -AsPlainText -Force

        Set-AzKeyVaultSecret `
            -VaultName $vaultName `
            -Name $secretName `
            -SecretValue $secureValue

        Write-Host "Added secret: $secretName"
    }
}