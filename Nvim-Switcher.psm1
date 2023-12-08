# Neovim Config Switcher
$nvim_env_name = "NVIM_DISTRIBUTIONS"
$nvim_main_config = "Main"

Set-Alias nvims Open-NvimDistribution
Set-Alias nvs Open-NvimDistribution
Set-Alias nvims-add Import-NvimDistribution
Set-Alias nvs-add Import-NvimDistribution
Set-Alias nvims-del Remove-NvimDistribution
Set-Alias nvs-del Remove-NvimDistribution
Set-Alias nvimconfig Open-NvimDistributionConfig
Set-Alias nvc Open-NvimDistributionConfig

# Switcher
function Open-NvimDistribution()
{
  $nvim_configs = @(Get-EnvNvimDistributions)
  [string]$distribution = $nvim_configs | fzf --prompt=" Select Neovim Distribution  " --height=~50% --layout=reverse --border --exit-0

  # If the string is either empty or "Main" was selected, set the env to an empty string
  if ([string]::IsNullOrEmpty($distribution) -or ($distribution.ToLower() -eq $nvim_main_config.ToLower()))
  {
    $distribution = ""
  }

  $env:NVIM_APPNAME="$distribution"
  nvim $args
  $env:NVIM_APPNAME=""
}

function Open-NvimDistributionConfig()
{
  $nvim_configs = @(Get-EnvNvimDistributions)
  [string]$config = $nvim_configs | fzf --prompt=" Edit Neovim Config  " --height=~50% --layout=reverse --border --exit-0

  # If the string is either empty or "Main" was selected, set the config to an empty string
  if ([string]::IsNullOrEmpty($config) -or ($config.ToLower() -eq $nvim_main_config.ToLower())) 
  {
    $config = "nvim"
  }

  $originalLocation = Get-Location

  Set-Location "$env:LOCALAPPDATA\$config"

  Open-NvimDistribution @args

  Set-Location $originalLocation
}

function Get-EnvNvimDistributions()
{
  $envValue = [System.Environment]::GetEnvironmentVariable($nvim_env_name, [System.EnvironmentVariableTarget]::User)
  
  $unresolved_array = @()
  
  # If it doesn't exist, create it
  if ($null -eq $envValue)
  {
    $initial_value = @($nvim_main_config)

    [System.Environment]::SetEnvironmentVariable($nvim_env_name, $initial_value -join ",", [System.EnvironmentVariableTarget]::User)

    $unresolved_array = $initial_value

    Write-Host "Created non-existing user environment variable ..."
  } else
  {
    $unresolved_array = $envValue -split ","
  }

  # Resolve to an array
  if ($unresolved_array.GetType().Name -eq "String")
  {
    return @($unresolved_array)
  } else
  {
    return $unresolved_array
  }
}

function Add-EnvNvimDistribution([string]$distribution)
{
  $arrayValue = @(Get-EnvNvimDistributions)
  $arrayValue += $distribution

  [System.Environment]::SetEnvironmentVariable($nvim_env_name, $arrayValue -join ",", [System.EnvironmentVariableTarget]::User)

  Write-Host "Added '$distribution' distribution to user environment variable ..."
}

function Remove-EnvNvimDistribution([string]$distribution)
{
  $arrayValue = @(Get-EnvNvimDistributions)
  $arrayValue += $distribution

  $arrayValue = $arrayValue | Where-Object { $_ -ne $distribution }

  [System.Environment]::SetEnvironmentVariable($nvim_env_name, $arrayValue -join ",", [System.EnvironmentVariableTarget]::User)

  Write-Host "Removed '$distribution' distribution from user environment variable ..."
}

function Import-NvimDistribution([string]$repository, [string]$distribution)
{
  # If the string is either empty or "Main" was selected, set the env to an empty string
  if ([string]::IsNullOrEmpty($distribution) -or ($distribution.ToLower() -eq "main"))
  {
    $distribution = ""
  }

  git clone "$repository" "$env:LOCALAPPDATA\$distribution" $args

  Add-EnvNvimDistribution $distribution

  Write-Host "Successfully added the '$distribution' distribution!"

  Set-Location "$env:LOCALAPPDATA\$distribution"
  "Going to '$env:LOCALAPPDATA\$distribution' ..."
}

function Remove-NvimDistribution()
{
  $nvim_configs = @(Get-EnvNvimDistributions) | Where-Object { $_ -ne $nvim_main_config }
  [string]$distribution = $nvim_configs | fzf --prompt=" Remove Neovim Distribution  " --height=~50% --layout=reverse --border --exit-0

  # If the string is either empty or "Main" was selected, close prompt
  if ([string]::IsNullOrEmpty($distribution)) 
  {
    Write-Host "Cancelled!"
    break
  }

  $nvim_config_path = "$env:LOCALAPPDATA\$distribution"
  $nvim_data_path = "$nvim_config_path-data"

  Remove-Item $nvim_config_path -Recurse -Force
  Remove-Item $nvim_data_path -Recurse -Force
  Write-Host "Removed '$nvim_config_path' and '$nvim_data_path' folders ..."

  Remove-EnvNvimDistribution $distribution

  Write-Host "Successfully removed the '$distribution' distribution!"
}

Export-ModuleMember -Alias * -Function Open-NvimDistribution, Open-NvimDistributionConfig, Import-NvimDistribution, Remove-NvimDistribution
