function Register-NuGet() {
    Write-Host "`n";
    Write-Host "Registering nuget PSRepository ..." -ForegroundColor Gray;
    [string]$nuget = "https://api.nuget.org/v3/index.json";

    [hashtable]$arguments = @{
      Name = "nuget"
      SourceLocation = $nuget
      PublishLocation = $nuget
      InstallationPolicy = "Untrusted"
      ErrorAction = "SilentlyContinue"
    };

    Unregister-PSRepository "nuget";
    Register-PSRepository @arguments;

    Get-PSRepository;

    Write-Host "Done" -ForegroundColor Green;
  }

  function Import-Modules([hashtable]$modules, [string]$source) {
      Write-Host "`n";
      Write-Host "Importing modules from $source ..." -ForegroundColor Gray;
      $modules.Keys | % {
          Write-Host "Installing $($_):$($modules[$_]) ..." -ForegroundColor Gray;
          [bool]$preRelease = $modules[$_].Contains("-");

          if(-not(Get-InstalledModule -Name $_ -RequiredVersion $modules[$_] -AllowPreRelease:$preRelease)) {
            Install-Module $_ -RequiredVersion $modules[$_] -Repository $source -AllowPreRelease:$preRelease -AllowClobber -Scope CurrentUser -Force;
          }

          Import-Module $_ -RequiredVersion $modules[$_].Split("-")[0];
      }
      Write-Host "Done" -ForegroundColor Green;
  }

  [hashtable]$modules = @{
      "PowershellGet"     = "3.0.19-beta19"
      "posh-git"          = "1.1.0"
      "powershell-yaml"   = "0.4.7"
      "1Pwd"              = "1.0.0"
  };

  [string]$version = "0.9.3"
  [hashtable]$packages = @{
    "CloudTek.Automation.Shell"     = $version
    "CloudTek.Automation.K8S"       = $version
    "CloudTek.Automation.Utilities" = $version
    "CloudTek.Automation.Git"       = $version
    "CloudTek.Automation.ArgoCD"    = $version
  };

  Write-Host "Starting cloud-tek.io dev env ..." -ForegroundColor Blue;

  Register-NuGet;
  Import-Modules -Modules $modules  -Source PSGallery;
  Import-Modules -Modules $packages -Source nuget;
