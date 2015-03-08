write-output "Remove-Item -force .\c060基本情報.csv"
write-output '"CD,市場,業種,社名,株価,日付(株価),時価総額,日付(時価総額),発行済株式数,日付(発行済株式数),配当利回り,日付(配当利回り),1株配当,日付(1株配当),PER区分,PER値,日付(PER),PBR区分,PBR値,日付(PBR),EPS区分,EPS値,日付(EPS),BPS区分,BPS値,日付(BPS),単元株数,年初来高値,日付(年初来高値),年初来安値,日付(年初来安値)" | Out-File -FilePath .\c060基本情報.csv'
foreach( $rt in $input ){
  write-output "Get-Content -path $rt -encoding UTF8 | .\c050b_gsym.ps1 | out-file -filepath .\c060基本情報.csv -encoding unicode -append"
}
