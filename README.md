# YAML Generator

This tool creates environment-specific YAML files using a common template, environment config, and proxy list.

## How It Works

- `template.yaml` contains placeholders like `TEMPLATE`, `template`, `env`, `url`, etc.
- `environments.csv` defines env values (e.g. Dev, QA) and file suffixes.
- `proxies.csv` lists proxy names and URLs.

The script:

1. Replaces `TEMPLATE` with UPPERCASE `proxyName`
2. Replaces `template` with lowercase `proxyName`
3. Fills in CSV values like `env`, `cluster`, `url`, and `proxyUrl`
4. Saves files to `/output` as `proxyName-suffix.yaml` (e.g., `AAA-dev.yaml`)

## Usage

1. Update template.yaml, environments.csv, and proxies.csv as needed.

2. Install Powershell module (run this once per user)

```powershell
Install-Module -Name powershell-yaml -Scope CurrentUser
```

3. Run the script:

```powershell
.\generate.ps1
```
