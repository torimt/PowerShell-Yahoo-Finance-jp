write-output "Remove-Item -force .\d060�Ɛя��.csv"
foreach( $r in $input ){
    write-output "Get-Content -path $r -Encoding UTF8 | .\d055_gys.ps1 >> .\d060�Ɛя��.csv"
}
