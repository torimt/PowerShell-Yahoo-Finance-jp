foreach( $rt in $input ){
	write-output "Invoke-WebRequest -Uri http://stocks.finance.yahoo.co.jp/stocks/detail/?code=$rt -OutFile ..\\A010基本\\$rt.html"
}
