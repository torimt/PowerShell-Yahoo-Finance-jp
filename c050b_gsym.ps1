

[string]$ot01 = ""
[string]$r2 = ""     # 読み込んだ行の前１行
[string]$r3 = ""     # 読み込んだ業の２行前

foreach( $r in $input ){

    # まず、はじめにカンマカット
    $r = $r -replace "," ,""

try{

    switch -regex ( $r )  {

        # CD
        "<dt>([0-9]{4})</dt>" {
            $rl = $Matches[1]
            $ot01 = "$rl,$sijyou01"  # 「市場」が先に現れるので、ここでまとめて出力
            break
        }
          
        # 市場
        "class=`"stockMainTabName`">([^>]+)</span>"{
            $rl = $matches[1]
            # 市場は一旦保存する なぜかここだけ出現順が変則な為？
            $sijyou01 = $rl
            break
        }

            # 業種
        ">([^>]+)</a></dd>" {
            $rl = $Matches[1]
            $ot01 = $ot01 + ",$rl"
            break
        }

           # 社名
         "<h1>(.+)</h1></th>"{
            $rl = $Matches[1] 
            # 出力バッファへ書き込み
            $ot01 = $ot01 + ",$rl"
            break
        }

        # 前日終値
        ">前日終値<" {
            $rg_all01 = [regex]">([`.0-9/（）]+)<"
            $rl = $rg_all01.matches( $r2 )
            $rla = $rl.groups[1].value
            $rlb = $rl.groups[3].value
            $ot01 = $ot01 + ",$rla,$rlb"
            break
        }

        # 時価総額
        ">時価総額<" {
            $rg_all01 = [regex]">([^&|~<]+)<"
            $rl = $rg_all01.matches( $r2 )
            $rla = $rl.groups[1].value
            if( $rla -eq "---" ) {  $rla = "" }
            $rlb = $rl.groups[3].value + $rl.groups[5].value

            $ot01 = $ot01 + ",$rla,$rlb"
            break
        }

        # 発行済株式数
        ">発行済株式数<" {
            $rg_all01 = [regex]">([^&|~<]+)<"
            $rl = $rg_all01.matches( $r2 )
            $rla = $rl.groups[1].value
            if( $rla -eq "---" ) { $rla = "" }
            $rlb = $rl.groups[3].value + $rl.groups[5].value
            $ot01 = $ot01 + ",$rla,$rlb"
            break
        }

        # 配当利回り
        ">配当利回り" {
            $rg_all01 = [regex]">([^&|~<]+)<"
            $rl = $rg_all01.matches( $r2 )
            $rla = $rl.groups[1].value
            if( $rla -eq "---" ){ $rla = "" }
            $rlb = $rl.groups[3].value + $rl.groups[5].value
            $ot01 = $ot01 + ",$rla,$rlb"
            break
        }

        # 一株配当
        ">1株配当<" {
            $rg_all01 = [regex]">([^&|~<]+)<"
            $rl = $rg_all01.matches( $r2 )
            $rla = $rl.groups[1].value
            if( $rla -eq "---" ){ $rla = "" }
            $rlb = $rl.groups[3].value + $rl.groups[5].value
            $ot01 = $ot01 + ",$rla,$rlb"
            break
        }

        # PER
        ">PER<" {
            $rg_all01 = [regex]">([^&|~<]+)<"
            $rl = $rg_all01.matches( $r2 )
            $rla = $rl.groups[1].value
            $rlb = $rl.groups[3].value + $rl.groups[5].value

            $rg_all01 = [regex]"(`(.+`) )([0-9.]+)"
            $rl = $rg_all01.matches( $rla )
            if( $rl.count -eq 0 ){
                # 結果数値がマッチしない！ 即アウトプット
                $ot01 = $ot01 +",,,$rlb"
            }else{
                # 通常の結果
                $rlc = $rl.groups[1].value
                $rla = $rl.groups[3].value
                $ot01 = $ot01 + ",$rlc,$rla,$rlb"
            }
            break
        }

        # PBR
        ">PBR<" {
            $rg_all01 = [regex]">([^&|~<]+)<"
            $rl = $rg_all01.matches( $r2 )
            $rla = $rl.groups[1].value
            $rlb = $rl.groups[3].value + $rl.groups[5].value

            $rg_all01 = [regex]"(`(.+`) )([0-9.]+)"  #取得数値の分解
            $rl = $rg_all01.matches( $rla )

            if( $rl.count -eq 0 ){
                $ot01 = $ot01 + ",,,$rlb"
            } else {
                $rlc = $rl.groups[1].value
                $rla = $rl.groups[3].value
                $ot01 = $ot01 + ",$rlc,$rla,$rlb"
            }
            break
        }

        # EPS ( ２項目　）
        ">EPS<" {
            $rg_all01 = [regex]">([^&|~<]+)<"
#            $rl = $rg_all01.matches( $r2 )

            $rl = $rg_all01.matches( $r3 ) # ２行前が処理対象

            $rla = $rl.groups[1].value
            $rlb = $rl.groups[3].value

            $rg_all01 = [regex]"(`(.+`) )([-0-9.]+)"
            $rl = $rg_all01.matches( $rla )
            if( $rl.count -eq 0 ){
                $ot01 = $ot01 + ",,,$rb"
            } else {
                $rlc = $rl.groups[1].value
                $rla = $rl.groups[3].value
                if( $rla -eq "---" ){ $rla = "" }
                $ot01 = $ot01 + ",$rlc,$rla,$rlb"
            }
            break
        }

        # BPS ( ２項目　）
        ">BPS<" {
            $rg_all01 = [regex]">([^&|~<]+)<"
#            $rl = $rg_all01.matches( $r2 )
            $rl = $rg_all01.matches( $r3 ) # ２行前が処理対象

            $rla = $rl.groups[1].value
            $rlb = $rl.groups[3].value

            $rg_all01 = [regex]"(`(.+`) )([-0-9.]+)"
            $rl = $rg_all01.matches( $rla )
            if( $rl.Count -eq 0 ){
                $ot01 = $ot01 + ",,,$rlb"
            } else {
                $rlc = $rl.groups[1].value
                $rla = $rl.groups[3].value
                $ot01 = $ot01 + ",$rlc,$rla,$rlb"
            }
            break
        }

        # 単元株数（２項目）
        ">単元株数<" {
            $rg_all01 = [regex]">([^&|~<]+)<"
            $rl = $rg_all01.matches( $r2 )
            $rla = $rl.groups[1].value # 単元株
            if( $rla -eq "---" ){ $rla = "" }
            $ot01 = $ot01 + ",$rla"
            break
        }

        # 年初来高値（２項目）
        ">年初来高値<a" {
            $rg_all01 = [regex]">([0-9`./（）]+)<"
            $rl = $rg_all01.matches( $r2 ) 
            $rla = $rl.groups[1].value
            $rlb = $rl.groups[3].value
            $ot01 = $ot01 +",$rla,$rlb"
            break
        }

        # 年初来安値（２項目）
        ">年初来安値<a" {
            $rg_all01 = [regex]">([0-9`./（）]+)<"
            $rl = $rg_all01.matches( $r2 ) 
            $rla = $rl.groups[1].value
            $rlb = $rl.groups[3].value          
            $ot01 = $ot01 +",$rla,$rlb"

            write-output $ot01
            $ot01 = ""
            break
        }

    }  # switch文の終了
    
    # どこの行にもマッチしない場合は、前行として保存
    # 念の為、switch分の外で保存
    $r3 = $r2
    $r2 = $r


} catch [Exception] {
    write-output "エラーをトラック"
    write-output $ot01
    exit
}

}
