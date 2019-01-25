$process = Start-Process "java" "-jar C:\Jenkins\activeadmin-demo.war" -PassThru
sleep (15)
Set-Location -Path "gauge"
Invoke-Command -ScriptBlock { nuget restore }
Invoke-Command -ScriptBlock { nuget install }
Invoke-Command -ScriptBlock { gauge run specs }
taskkill /F /pid $process.Id
Compress-Archive -Path (Get-ChildItem reports\html-report\20*) -DestinationPath ('html-report' + (get-date -Format yyyyMMdd-HHmmss) + '.zip') -Update
Compress-Archive -Path (Get-ChildItem reports\xml-report\20*) -DestinationPath ('xml-report' + (get-date -Format yyyyMMdd-HHmmss) + '.zip') -Update
Get-ChildItem -Path "reports/html-report" -Filter "20*" -Recurse | Rename-Item -NewName {'test-report'}