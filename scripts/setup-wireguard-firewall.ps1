# Script para configurar el firewall de Windows para WireGuard
# Ejecutar como Administrador: PowerShell (Run as Administrator)
# Uso: .\setup-wireguard-firewall.ps1

Write-Host "=== Configurando Firewall para WireGuard ===" -ForegroundColor Green

# Regla para WireGuard UDP (puerto VPN)
New-NetFirewallRule -DisplayName "WireGuard VPN" `
    -Direction Inbound `
    -Protocol UDP `
    -LocalPort 51820 `
    -Action Allow `
    -Profile Any
Write-Host "[OK] Regla WireGuard UDP 51820 creada" -ForegroundColor Cyan

# Regla para puertos del sistema distribuido (coordinador + workers)
New-NetFirewallRule -DisplayName "Distributed System TCP" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 8080-8090 `
    -Action Allow `
    -Profile Any
Write-Host "[OK] Regla TCP 8080-8090 creada" -ForegroundColor Cyan

# Configurar Hyper-V firewall para que WSL2 reciba trafico
$wslVMCreatorId = '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}'
Set-NetFirewallHyperVVMSetting -Name $wslVMCreatorId -DefaultInboundAction Allow
Write-Host "[OK] Hyper-V WSL2 inbound permitido" -ForegroundColor Cyan

# Regla especifica de Hyper-V para WireGuard
New-NetFirewallHyperVRule -Name "WireGuard-WSL2" `
    -DisplayName "WireGuard WSL2 UDP" `
    -Direction Inbound `
    -VMCreatorId $wslVMCreatorId `
    -Protocol UDP `
    -LocalPorts 51820 `
    -Action Allow
Write-Host "[OK] Regla Hyper-V WireGuard creada" -ForegroundColor Cyan

Write-Host ""
Write-Host "=== TODAS LAS REGLAS CREADAS EXITOSAMENTE ===" -ForegroundColor Green
