# dev-env

This repository was created using [cloud-tek/ops-repo-template](https://github.com/cloud-tek/ops-repo-template)

## Usage (MacOS / Linux)

Ensure `~/.config/powershell/profile.ps1` is set to to the following content to enable the self-updating `dev-env`, using this 1 line pwsh command.

<details>

```pwsh
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/cloud-tek/dev-env/main/scripts/profile.ps1" -OutFile "~/.config/powershell/profile.ps1";
```

</details>
<summary>Instructions</summary>