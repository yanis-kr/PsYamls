# Constants
$templateFile = "template.yaml"
$csvFile = "environments.csv"
$outputFolder = "output"

# Clean up output folder before generating new files
if (Test-Path $outputFolder) {
    Get-ChildItem $outputFolder -File | Remove-Item -Force
} else {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

function Update-YamlTemplatePlaceholders {
    param (
        [string]$content,
        [string]$value
    )

    # Replace only exact case-sensitive "TEMPLATE" with UPPERCASE
    $content = [regex]::Replace($content, '\bTEMPLATE\b', { $value.ToUpper() }, 'None')

    # Replace only exact case-sensitive "template" with lowercase
    $content = [regex]::Replace($content, '\btemplate\b', { $value.ToLower() }, 'None')

    return $content
}

function Generate-YamlFiles {
    param (
        [string]$proxyName,
        [string]$proxyUrl
    )

    $csvData = Import-Csv $csvFile

    foreach ($row in $csvData) {
        $fileSuffix = $row.fileSuffix
        $env = $row.env
        $cluster = $row.cluster
        $url = $row.url

        $content = Get-Content $templateFile -Raw

        # Replace CSV and function parameters
        $content = $content -replace 'env:\s*".*?"', "env: `"$env`""
        $content = $content -replace 'cluster:\s*\w+', "cluster: $cluster"
        $content = $content -replace 'url:\s*".*?"', "url: `"$url`""
        $content = $content -replace 'proxyUrl:\s*".*?"', "proxyUrl: `"$proxyUrl`""

        # Replace all 'TEMPLATE' and 'template' in content
        $content = Update-YamlTemplatePlaceholders -content $content -value $proxyName

        $outputFile = Join-Path $outputFolder "$proxyName$fileSuffix.yaml"
        Set-Content -Path $outputFile -Value $content
        Write-Host "Created: $outputFile"
    }
}

# # Example usage
# Generate-YamlFiles -proxyName "aaa" -proxyUrl "aaa.com"
# Read the proxy list
$proxyList = Import-Csv "proxies.csv"

foreach ($proxy in $proxyList) {
    $proxyName = $proxy.proxyName
    $proxyUrl = $proxy.proxyUrl

    Generate-YamlFiles -proxyName $proxyName -proxyUrl $proxyUrl
}