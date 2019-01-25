Configuration SDWS2012R2 {
    param (
        $Servers = '192.168.33.10'
    )

    Import-DscResource -Module cChoco
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $Servers {
        # Configure LCM - check Set-DscLocalConfigurationManager in comments below to apply it
        LocalConfigurationManager {
            ConfigurationMode = "ApplyAndAutocorrect"
            ConfigurationModeFrequencyMins = 120
            RefreshMode = "PUSH"
            RebootNodeIfNeeded = $true
        }
        # Install .NET 3.5
        WindowsFeature NetFrameworkCore {
            Ensure    = "Present" 
            Name      = "NET-Framework-Core"
        }
        
        # Install .NET 4.5
        WindowsFeature NetFramework {
            Ensure    = "Present" 
            Name      = "NET-Framework-45-Core"
        }

        # Install Chocolatey
        cChocoInstaller installChoco {
            InstallDir = "C:\ProgramData\Chocolatey"
            DependsOn = "[WindowsFeature]NetFramework"
        }

        # Update .NET to 4.6
        cChocoPackageInstaller dotnet46 {
            Ensure = "Present"
            Name = "dotnet4.6.1"
            DependsOn = "[cChocoInstaller]installChoco"
        }

        # Install JDK8
        cChocoPackageInstaller installJdk8 {
            Ensure = "Present"
            Name = "jdk8"
            DependsOn = "[cChocoInstaller]installChoco"
        }

        # Install GIT
        cChocoPackageInstaller installGit {
            Ensure = "Present"
            Name = "git"
            DependsOn = "[cChocoInstaller]installChoco"
        }

        # Install Gauge
        cChocoPackageInstaller installGauge {
            Ensure = "Present"
            Name = "gauge"   # all other required plugins for gauge are installed by Jenkins job for every user apart
            DependsOn = "[cChocoInstaller]installChoco"
        } 

        # Install Nuget
        cChocoPackageInstaller installNuget {
            Ensure = "Present"
            Name = "nuget.commandline"
            DependsOn = "[cChocoInstaller]installChoco"
        }

        # Install Chrome
        cChocoPackageInstaller installChrome {
            Ensure = "Present"
            Name = "googlechrome"
            DependsOn = "[cChocoInstaller]installChoco"
        }

        # Restarting server
        # Script systemRestart {
        #     GetScript = { }
        #     TestScript = { $False }
        #     SetScript = { 
        #         Write-Verbose 'Provision complete. Restarting the server'
        #         Restart-Computer -Force 
        #     }
        #     DependsOn = "[cChocoPackageInstaller]installChrome"
        # }
    }
}

<# 
MANDATORY:
    on remote machine:
    - to check PowerShell 5.0 version if not - INSTALL PowerShell VERSION 5!!!
        $PSVersionTable

    - to increase the maximum envelope size that is allowed:
        Set-WSManInstance -ValueSet @{MaxEnvelopeSizekb = "1000"} -ResourceURI winrm/config

    - to enable ps remoting:
        Enable-PSRemoting

    Commands on local computer:
        $cs = New-CimSession -ComputerName 192.168.33.10 -Credential vagrant
        $S = New-PSSession -ComputerName 192.168.33.10 -Credential vagrant
        Invoke-Command -session $S -ScriptBlock {Install-Module -Name cChoco -Force}
        . .\srv-config-dsc.ps1
        SDWS2012R2
        Start-DscConfiguration -Path .\SDWS2012R2 -CimSession $cs -Wait -Verbose -Force
OPTIONAL:
        Set-DscLocalConfigurationManager -Path .\SDWS2012R2 -CimSession $cs -Verbose
With this option, DSC applies any new configurations, sent by you directly to the target node.
Thereafter, if the configuration of the target node drifts from the configuration file, DSC reports the discrepancy in logs, 
and then attempts to adjust the target node configuration to bring in compliance with the configuration file.

After configuration succeed and reboot run these commands on remote computer:
    git config --system --unset credential.helper
or reopen session to remote from local computer and run:
    Invoke-Command -session $S -ScriptBlock {git config --system --unset credential.helper}
#>

