# dev-env

This repository was created using [cloud-tek/ops-repo-template](https://github.com/cloud-tek/ops-repo-template)

## Usage (MacOS / Linux)

Ensure `~/.config/powershell/profile.ps1` is set to to the following content to enable the self-updating `dev-env`

<details>

```pwsh
function Initialize-Folder([string]$path) {
  if (-not(Test-Path $path)) {
    Write-Host "Creating $path ..." -ForegroundColor Gray;
    New-Item $path -ItemType Directory
    Write-Host "Done" -ForegroundColor Green;
  }
}

function Download-File([string]$url, [string]$file) {
  [bool]$download = $false;
  if(Test-Path $file -PathType Leaf) {
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

function Initialize-DevEnv([string]$path) {
  [string[]]$files = @(
    "Initialize.ps1"
  );

  $files | % {
    Download-File -url "https://raw.githubusercontent.com/cloud-tek/dev-env/main/scripts/$_" -file "$path/$_"
  }

  & "$path/Initialize.ps1";
}

function Initialize-EnvVars([string]$path) {
  Write-Host "`n";
  Write-Host "Initializing env vars ..." -ForegroundColor Gray;
  [string[]]$files = @(
    "cloud-tek.env"
  );

  $files | % {
    [string]$file = "$path/$_";
    Download-File -url "https://raw.githubusercontent.com/cloud-tek/dev-env/main/config/$_" -file $file;

    foreach($line in Get-Content $file) {
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
Initialize-DevEnv   -path $path;
Initialize-EnvVars  -path $path;
```

</details>
<summary>~/.config/powershell/profile.ps1</summary>