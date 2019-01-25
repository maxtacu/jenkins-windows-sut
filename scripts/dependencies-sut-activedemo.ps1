# edit these variables if needed
$env:chocolateyUseWindowsCompression = 'true'
$gaugv = Invoke-Command -ScriptBlock {gauge version -m 2>$null | ConvertFrom-Json | ForEach {$_.plugins.name}}    # json output of gauge plugins
$plugin = @('csharp','html-report','xml-report')                # gauge plugins that are required to be installed
$Chocolist = chocolatey list -localonly
$java = Get-Wmiobject Win32_Product -Filter "Vendor like 'Oracle%'"
$gauge = &{gauge version} 2>$null
$activedemourl = "https://bintray.com/gauge/activeadmin-demo/download_file?file_path=activeadmin-demo.war"

# Chocolatey
if (Test-Path "C:\ProgramData\chocolatey"){
    echo "Choco is installed." 
} else {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Git
if ($Chocolist -Contains "git") {
    choco -y install git
} else {
    echo "Git is installed."
}
# Java
if ($java -ne $null){ 
    "Java is installed." 
} else {
    choco install -y jre8
}

# Gauge
if ($gauge -ne $null){ 
    "Gauge is installed." 
} else {
    choco install -y gauge
}

# Gauge plugins
if ( $plugin | where {$gaugv -notcontains $_} ) {
    Write-Output 'Some of required below plugins are not present.'
    foreach ($item in $plugin) {
        gauge install $item       
    }
    Invoke-Command -ScriptBlock { $gauge }
} else {
    echo 'All GAUGE required plugins are installed.'
    Invoke-Command -ScriptBlock { $gauge }
}

# System under test(SUT)
if (Test-Path "C:\Jenkins\activeadmin-demo.war" ){
    echo "war file exists"
} else {
    echo "Downloading local webserver .war file"
    $output = "C:\Jenkins\activeadmin-demo.war"
    $start_time = Get-Date
    Invoke-WebRequest -Uri $activedemourl -OutFile $output
    Write-Output "Activeadmin-demo.war Downloaded. Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}