write-output "Remove-Item -force .\d060業績情報.csv"
foreach( $r in $input ){
    write-output "Get-Content -path $r -Encoding UTF8 | .\d055_gys.ps1 >> .\d060業績情報.csv"
}
