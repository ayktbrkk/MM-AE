param(
	[string]$ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
	[string]$KeytoolExe,
	[string]$OutputDir,
	[string]$Alias = "mmae_rc_local",
	[switch]$ForceRegenerate
)

$ErrorActionPreference = "Stop"

function Resolve-KeytoolExe {
	param([string]$RequestedPath)

	if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
		if (-not (Test-Path -LiteralPath $RequestedPath)) {
			throw "keytool bulunamadi: $RequestedPath"
		}
		return (Resolve-Path -LiteralPath $RequestedPath).Path
	}

	$keytoolCommand = Get-Command keytool -ErrorAction SilentlyContinue
	if ($keytoolCommand) {
		return $keytoolCommand.Source
	}

	$defaultCandidates = @(
		"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe",
		"C:\Program Files\Android\Android Studio\jre\bin\keytool.exe"
	)
	foreach ($candidate in $defaultCandidates) {
		if (Test-Path -LiteralPath $candidate) {
			return $candidate
		}
	}

	return $null
}

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
	$OutputDir = Join-Path $ProjectPath "artifacts\local\release_signing"
}

$resolvedKeytool = Resolve-KeytoolExe -RequestedPath $KeytoolExe
if ([string]::IsNullOrWhiteSpace($resolvedKeytool)) {
	throw "Yerel RC keystore olusturulamadi: keytool bulunamadi."
}

if (-not (Test-Path -LiteralPath $OutputDir)) {
	New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$configPath = Join-Path $OutputDir "release_signing.local.json"
$keystorePath = Join-Path $OutputDir "mmae_rc_local.keystore"


if ($ForceRegenerate) {
	if (Test-Path -LiteralPath $configPath) {
		Remove-Item -LiteralPath $configPath -Force
	}
	if (Test-Path -LiteralPath $keystorePath) {
		Remove-Item -LiteralPath $keystorePath -Force
	}
}

if (-not (Test-Path -LiteralPath $configPath)) {
	$storePass = [Guid]::NewGuid().ToString("N")
	$keyPass = $storePass

	& $resolvedKeytool -genkeypair -v `
		-keystore $keystorePath `
		-alias $Alias `
		-keyalg RSA `
		-keysize 2048 `
		-validity 10000 `
		-storepass $storePass `
		-keypass $keyPass `
		-dname "CN=MMAE RC Local, OU=Development, O=MMAE, L=Ankara, ST=Turkey, C=TR"
	if ($LASTEXITCODE -ne 0) {
		throw "Yerel RC keystore olusturma basarisiz."
	}

	@{
		keystore_path = ($keystorePath -replace '\\', '/')
		keystore_user = $Alias
		keystore_password = $storePass
	} | ConvertTo-Json | Out-File -FilePath $configPath -Encoding utf8

	Write-Host "LOCAL_RELEASE_SIGNING_CREATED"
	Write-Host ("LOCAL_RELEASE_SIGNING_CONFIG={0}" -f $configPath)
	return
}

Write-Host "LOCAL_RELEASE_SIGNING_READY"
Write-Host ("LOCAL_RELEASE_SIGNING_CONFIG={0}" -f $configPath)