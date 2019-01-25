# CI with Test Automation Framework

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

## Prerequisites and configuration

- Windows Server Machine - Server/8/10
- Jenkins server with installed plugins - 
    - Pipeline
    - PowerShell plugin
    - Build Pipeline Plugin
    - Credentials Plugin
    - HTML Publisher Plugin
- Windows Client Machine (your own computer which configurations are pushed from)
- Powershell 5.0 or later installed on both machines (you can use this [link](https://www.microsoft.com/en-us/download/details.aspx?id=50395) to install)
- User credentials with admin rights on Windows server machine where tests are built \
P.S. All needed scripts are in "scripts" directory


### Configure the windows server machine for PowerShell DSC

Step by step series that tell you how to configure windows server machine using PowerShell Desired State Configuration
- Increase the maximum envelope size that is allowed on windows machine:
```
Set-WSManInstance -ValueSet @{MaxEnvelopeSizekb = "1000"} -ResourceURI winrm/config
```
- Enable PowerShell remoting on server machine:
```
Enable-PSRemoting
```

## Running DSC Configuration

Run these commands to establish connection from your own windows client machine to windows server. Change "ip-address" to ip address of your windows server machine and "user" with username that has admin rights on the server:

```
$cs = New-CimSession -ComputerName ip-address -Credential user
$S = New-PSSession -ComputerName ip-address -Credential user
```
Run below command to install Choco module (we will use it in DSC) on remote server machine:
```
Invoke-Command -session $S -ScriptBlock {Install-Module -Name cChoco -Force}
```
*Optional: you can install choco module on client machine*
```
Install-Module -Name cChoco
```
Run the DSC script:
```
. .\srv-config-dsc.ps1
```
Then invoke the configuration name (method name after "Configuration" in the script) with IP addresses passed:
```
SDWS2012R2 -Servers <IP-address>
```
If multiple servers - comma separated \
You can edit configuration name in *srv-config-dsc.ps1* as you want \
**Directory with the name of method will be created.** 

Start the DSC configuration:
## Warning! To apply the changes you should reboot the server after configuration finishes!
```
Start-DscConfiguration -Path .\SDWS2012R2 -CimSession $cs -Wait -Verbose -Force
```

After reboot run last command on server to unset credential helper of git
```
git config --system --unset credential.helper
```
### Congratulations! Server is configured for project.

## Configuring Jenkins Build

Clone the repo on your Jenkins Linux server machine. \
Locate where jenkins is installed on your server \
Run the script [jenkins-jobconfig.sh](scripts/jenkins-jobconfig.sh) with needed parameters

```
bash jenkins-jobconfig.sh <path-to-jenkins> <build-name>
```
Example 
```
bash jenkins-jobconfig.sh /var/lib/jenkins CI-Build
```
Reload Configuration from Disk on Jenkins. See on Google how to do it

## Jenkins Slave setup
Use [this jenkins wiki](https://wiki.jenkins.io/display/JENKINS/Step+by+step+guide+to+set+up+master+and+slave+machines+on+Windows) guide to configure Jenkins master and slave machines on Windows. \
 Make sure that:
 - Press Start, type *Services* and Select the *Services* program.
 - Find *Jenkins Slave* in the list, Double click to open.
 - Select Startup type --> Automatic.
 - Go to the Log On tab, **change the Log on as to a user** of your choice (Special user account Jenkins recommended).
 - Make sure that auto login is set for the slave machine for the user account, then the VM (or physical computer) should connect and be available when needed.
## Before Running tests:
#### change label to your slave machine label in Jenkinsfile
```
agent { 
    label 'windows-vagrant'
}
```
#### In Jenkinsfile set your credentialsID - *jks_cred* variable

### Optional 
You can configure triggering builds by Bitbucket server on every push \
Read [this](https://support.cloudbees.com/hc/en-us/articles/226568007-How-to-Trigger-Non-Multibranch-Jobs-from-BitBucket-Server-) guide how to do so. ...and if you have any questions - check [Google](google.com) :D

## Built With

* [Powershell DSC](https://docs.microsoft.com/en-us/powershell/dsc/overview) - Management platform in PowerShell
* [Gauge](https://getgauge.io/) - The Test Automation Framework used
* [Jenkins](https://jenkins.io/) - Continious Integration tool

## Author

*Endava DevOps Engineer* - **Maxim Tacu**