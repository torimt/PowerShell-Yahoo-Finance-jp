foreach( $rt in $input) {
    write-output "Invoke-WebRequest -Uri http://m.finance.yahoo.co.jp/stock/settlement/consolidate?code=$rt -Outfile ..\A020業績\\$rt.html"
}
