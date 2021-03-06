# 区分毎の取り込み処理 サブルーチン


# 数値、日付 の２項目の取り込み。
# 　取り込みの条件は、><で囲われた、パターンマッチしたもののみ
function mpattern_a ( [string]$gs ) { 

    # まず、はじめにカンマカット
    $gs = $gs -replace "," ,""
    
    $rg_all01 = [regex]">([0-9,（）/`.-]+)<"　　# 条件 初めの文字& not < 
    $rl = $rg_all01.matches( $gs ) 
    if( $rl.count -eq 0 ) {
        return ",,"
    } else {
        $rla = $rl.groups[1].value
        # 結果が、"---" の場合は、null へ
        if( $rla -eq "---" ) { $rla = "" }
        $rlb = $rl.groups[3].value
        return ",$rla,$rlb"
    }
}

#  ３項目の取り込み。出力：１項目、２項目＋３項目 の変則パターン
# 　取り込みの前提条件は、初めの > < で囲われた２項目のみ
function mpattern_b ( [string]$gs ) { 

    # まず、はじめにカンマカット
    $gs = $gs -replace "," ,""
    
    $rg_all01 = [regex]">([^&|~<]+)<"
    $rl = $rg_all01.matches( $gs ) 
    if( $rl.count -eq 0 ) {
        return ",,"
    } else {
        $rla = $rl.groups[1].value
        # 結果が、"---" の場合は、null へ
        if( $rla -eq "---" ) { $rla = "" }
        $rlb = $rl.groups[3].value
        $rlc = $rl.groups[5].value
        return ",$rla,$rlb$rlc"
    }
}




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
            $rl = mpattern_a ( $r2 )
            $ot01 = $ot01 + $rl
            break
        }

        # 時価総額
        ">時価総額<" {
            $rl = mpattern_b ( $r2 )
            $ot01 = $ot01 + $rl
            break
        }

        # 発行済株式数
        ">発行済株式数<" {
            $rl = mpattern_b ( $r2 )
            $ot01 = $ot01 + $rl
            break
        }

        # 配当利回り
        ">配当利回り" {
            $rl = mpattern_b( $r2 )
            $ot01 = $ot01 + $rl
            break
        }

        # 一株配当    （通常パターン）
        ">1株配当<" {
            $rl = mpattern_a( $r3 ) # 取りこみ対象は２行前
            $ot01 = $ot01 + $rl
            break
        }

        # 1株配当　（特殊出現パターン）稀に、tag が崩れている事があるので、その対応版
        "^1株配当<" {
            $rl = mpattern_a( ">" + $r3 )  # 取り込み行も崩れているので、強補正して関数へ文字列を渡す
            $ot01 = $ot01 + $rl
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
            $rl = mpattern_a( $r2 )
            $rla = ($rl.split( ',' ))[1] # 強制的に初めの項目のみを取り出す
            $ot01 = $ot01 + ",$rla"
            break
        }

        # 年初来高値（２項目）
        ">年初来高値<a" {
            $rl = mpattern_a( $r2 )
            $ot01 = $ot01 + $rl
            break
        }

        # 年初来安値（２項目）
        ">年初来安値<a" {
            $rl = mpattern_a( $r2 )
            $ot01 = $ot01 + $rl

            write-output $ot01
            $ot01 = ""
            break
        }

    }  # switch文の最後


    # ループの最終処理
    # 読み込み済の行をバッファへ保存
    $r3 = $r2
    $r2 = $r


} catch [Exception] {
    write-output "エラーをトラック"
    write-output $ot01
    exit
}


} #　ここが、ループの最終

