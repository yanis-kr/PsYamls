## Script to generate YAML files from a template and CSV data
## Run this script in PowerShell
## Ensure you have the 'powershell-yaml' module installed:
## Install-Module -Name powershell-yaml -Scope CurrentUser

# Constants
$templateFile = "template.yaml"
$environmentsCsv = "environments.csv"
$proxiesCsv = "proxies.csv"
$outputFolder = "output"

# Load YAML module
Import-Module powershell-yaml

# Read templates content once
$templateRawContent = Get-Content $templateFile -Raw

$envRows = Import-Csv $environmentsCsv

$proxies = Import-Csv $proxiesCsv

# Ensure clean output folder
if (Test-Path $outputFolder) {
    Get-ChildItem $outputFolder -File | Remove-Item -Force
} else {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# -- Utility Functions --

function Update-TemplateTokens {
    param (
        [string]$content,
        [string]$value
    )
    $content = [regex]::Replace($content, '\bTEMPLATE\b', { $value.ToUpper() }, 'None')
    $content = [regex]::Replace($content, '\btemplate\b', { $value.ToLower() }, 'None')
    return $content
}

function Update-YamlFromCsvRow {
    param (
        [hashtable]$yaml,
        [psobject]$row
    )
    foreach ($col in $row.PSObject.Properties) {
        if ($col.Name -ne 'fileSuffix') {
            $yaml[$col.Name] = $col.Value
        }
    }
    return $yaml
}

# replace the second impl host with the new URL from the CSV proxies file
#impl:
#- host: a1.b.c
#- host: a2.b.c <-- this one
function Update-SecondImplHost {
    param (
        [hashtable]$yaml,
        [string]$newUrl
    )
    if ($yaml.impl.Count -ge 2) {
        $yaml.impl[1].host = $newUrl
    }
    return $yaml
}

function Save-YamlToFile {
    param (
        [hashtable]$yaml,
        [string]$proxyName,
        [string]$fileSuffix
    )
    $yamlText = ConvertTo-Yaml $yaml
    $yamlText = Update-TemplateTokens -content $yamlText -value $proxyName

    $filePath = Join-Path $outputFolder "$proxyName$fileSuffix.yaml"
    Set-Content -Path $filePath -Value $yamlText
    Write-Host "Created: $filePath"
}

# -- Main Generator Function --

function New-YamlFiles {
    param (
        [string]$proxyName,
        [string]$proxyUrl
    )

    foreach ($row in $envRows) {
        $yaml = ConvertFrom-Yaml $templateRawContent
        $yaml = Update-YamlFromCsvRow -yaml $yaml -row $row
        $yaml = Update-SecondImplHost -yaml $yaml -newUrl $proxyUrl
        Save-YamlToFile -yaml $yaml -proxyName $proxyName -fileSuffix $row.fileSuffix
    }
}

# -- Run for all proxies --
foreach ($proxy in $proxies) {
    New-YamlFiles -proxyName $proxy.proxyName -proxyUrl $proxy.proxyUrl
}
