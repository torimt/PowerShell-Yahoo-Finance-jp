write-output "Remove-Item -force .\d060‹ÆÑî•ñ.csv"
foreach( $r in $input ){
    write-output "Get-Content -path $r -Encoding UTF8 | .\d055_gys.ps1 >> .\d060‹ÆÑî•ñ.csv"
}
