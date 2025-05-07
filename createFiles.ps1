# Constants
$templateFile = "template.yaml"
$csvFile = "environments.csv"
$outputFolder = "output"

# Ensure output directory exists
if (-not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# Function to generate YAML files
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

        # Read template and replace placeholders
        $content = Get-Content $templateFile -Raw
        $content = $content -replace 'env:\s*".*?"', "env: `"$env`""
        $content = $content -replace 'cluster:\s*\w+', "cluster: $cluster"
        $content = $content -replace 'proxyName:\s*TEMPLATE\(\)', "proxyName: $proxyName"
        $content = $content -replace 'proxyPath:\s*/template/1', "proxyPath: /$proxyName/1"
        $content = $content -replace 'url:\s*".*?"', "url: `"$url`""
        $content = $content -replace 'proxyUrl:\s*".*?"', "proxyUrl: `"$proxyUrl`""

        $outputFile = Join-Path $outputFolder "$proxyName$fileSuffix.yaml"
        Set-Content -Path $outputFile -Value $content
        Write-Host "Created: $outputFile"
    }
}

# Example usage
Generate-YamlFiles -proxyName "aaa" -proxyUrl "aaa.com"
