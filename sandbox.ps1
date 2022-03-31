
# gestion des erreurs
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction']='Stop'
function ThrowOnNativeFailure {
    if (-not $?)
    {
        throw 'Native Failure'
    }
}

if (Test-Path -Path .\ext4.vhdx  -PathType Leaf) {
    Write-Host "Suppression de la distribution existante"
    .\Sandbox.exe clean
    ThrowOnNativeFailure
}

Write-Host "Installation de la distribution"
.\Sandbox.exe
ThrowOnNativeFailure

Write-Host "Isolation de la VM de de Windows"
.\Sandbox.exe config --append-path 0
ThrowOnNativeFailure

Write-Host "Mise a jour de la VM, installation des commandes de base"
.\Sandbox.exe run apt -y update
ThrowOnNativeFailure
.\Sandbox.exe run apt -y upgrade
ThrowOnNativeFailure
# installer les commandes manquantes
Write-Host "Installation des commandes minimum"
.\Sandbox.exe run apt -y install zsh zip unzip dos2unix
ThrowOnNativeFailure

# fixe l'utilisateur 'sandbox' par défaut
# a partir de là 'sudo' sera nécessaire
Write-Host "Création de l'utilisateur 'sandbox'"
.\Sandbox.exe run useradd -m -s /bin/bash sandbox
ThrowOnNativeFailure
.\Sandbox.exe run passwd sandbox
ThrowOnNativeFailure
.\Sandbox.exe run usermod -aG sudo sandbox
ThrowOnNativeFailure
.\Sandbox.exe config --default-user sandbox
ThrowOnNativeFailure

Write-Host "Installation de la configuration"
.\Sandbox.exe run mkdir -p ~/.config/sandox/install
ThrowOnNativeFailure
.\Sandbox.exe run git clone https://github.com/tgrangeray/sandbox_ubuntu_installs ~/.config/sandox/install
ThrowOnNativeFailure
.\Sandbox.exe run chmod +x ~/.config/sandox/install/*.sh
ThrowOnNativeFailure

# lance la distribution
.\Sandbox.exe
ThrowOnNativeFailure