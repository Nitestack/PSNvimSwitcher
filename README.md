# Neovim Configuration Switcher

Neovim Switcher is a utility PowerShell module for switching between different Neovim configuration environments.

## 🛠️ Installation

### Windows (Powershell)

#### Clone the repository

```pwsh
git clone --depth 1 https://github.com/Nitestack/Nvim-Switcher $env:USERPROFILE\Documents\PowerShell\Modules\Nvim-Switcher
```

#### Include it in your PowerShell config:

```pwsh
Import-Module Nvim-Switcher
```

## 📖 Documentation

### Commands

- `nvims` or `nvs`: Select configuration to start Neovim with
- `nvims-add` or `nvs-add`: Download a Neovim configuration
- `nvims-del` or `nvs-del`: Uninstalls a Neovim configuration
- `nvims-c` or `nvc`: Configure a Neovim configuration
