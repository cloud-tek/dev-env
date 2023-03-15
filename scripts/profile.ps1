[string]$hostname = "https://raw.githubusercontent.com";
[string]$organization = "cloud-tek";
[string]$repository = "dev-env";
[string]$branch = "main"

[string]$global:address = "$hostname/$organization/$repository/$branch"

function Initialize-Folder([string]$path) {
  if (-not(Test-Path $path)) {
    Write-Host "Creating $path ..." -ForegroundColor Gray;
    New-Item $path -ItemType Directory
    Write-Host "Done" -ForegroundColor Green;
  }
}

function Download-File([string]$url, [string]$file, [bool]$autoupdate) {
  [bool]$download = $false;
  if($autoupdate -and (Test-Path $file -PathType Leaf)) {
    $localHash = Get-FileHash $file -Algorithm MD5;
    $wc = [System.Net.WebClient]::new()
    try {
      $remoteHash = Get-FileHash -InputStream ($wc.OpenRead($url)) -Algorithm MD5;
      if(-not($localHash.Hash -eq $remoteHash.Hash)) {
        Write-Host "Newer version of $file found at $url ..." -ForegroundColor Gray;
        $download = $true;
      }
    }
    finally {
      $wc.Dispose();
    }
  } else {
    $download = $true;
  }

  if($download) {
    Write-Host "Downloading $file <=== $url ..." -ForegroundColor Gray;
    Invoke-WebRequest -Uri $url -OutFile $file;
  }
}

function Initialize-Manifest([string]$path) {
  Download-File -url "$($global:address)/manifest.json" -file "$($path)/manifest.json" -autoupdate $true;
}

function Initialize-DevEnv([string]$path) {
  $manifest = Get-Content "$($path)/manifest.json" | ConvertFrom-Json;

  $manifest.scripts | % {
    Download-File -url "$($global:address)/scripts/$($_.file)" -file "$($path)/$($_.file)" -autoupdate $_.autoUpdate;
  }

  & "$path/Initialize.ps1";
}

function Initialize-EnvVars([string]$path) {
  Write-Host "`n";
  Write-Host "Initializing env vars ..." -ForegroundColor Gray;

  $manifest = Get-Content "$($path)/manifest.json" | ConvertFrom-Json;

  $manifest.config | % {
    [string]$file = "$path/$_";
    Download-File -url "$($global:address)/config/$($_.file)" -file "$($path)/$($_.file)" -autoupdate $_.autoUpdate;

    foreach($line in Get-Content "$($path)/$($_.file)") {
      [string[]]$tokens = $line.Split("=");
      if($tokens.Length -ne 2) {
        throw "Malformed ENV file $file at line: $line";
      }

      Write-Host $line
      [System.Environment]::SetEnvironmentVariable($tokens[0], $tokens[1]);
    }
  }

  Write-Host "Done" -ForegroundColor Green;
}



[string]$path;
if($IsLinux -or $IsMacOs) {
  $path = "~/.cloud-tek"
} else {
  throw "OS Not supported";
}

Initialize-Folder   -path $path;
Initialize-Manifest -path $path;
Initialize-DevEnv   -path $path;
Initialize-EnvVars  -path $path;