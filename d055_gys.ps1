$mp = [regex]"([0-9-‐`.]*)(.+)"

function mpattern_b ( [string]$st ){

    if( $st -match "---" -eq $true ){
        return ",,"
    } else {
        $rts = $mp.matches( $st )
        $rla = $rts.groups[1].value
        $rlb = $rts.groups[2].value
        if( $rla -eq "‐" ){
            return ",,$rlb"
        } else {
            return ",$rla,$rlb"
        }
    }

}

$ot00 = ""
$ot01 = ""
$b01_syamei

$tp_b = ""   # 項目取得スイッチ
$tp_cnt = 0  # 行カウンタ

[boolean]$f_thrue = $true # パターンマッチのスルーフラグ
    # true マッチング処理実行
    # false マッチング不要

[boolean]$tp_f = $false  # 最終行フラグ　（　出力フラグ　）

foreach ( $r in $input ){

try{

    switch ( $tp_b ){

        # １項目そのまま取り出しパターン
        "A" {
            if( $tp_cnt -eq 2 ){
                $r = $r -replace ",",""     # まずは、カンマカット
                $bk = $r -match ">([^>]+)<"
                $rla = $matches[1]
                $ot01 = $ot01 + ",$rla"
                $tp_cnt = 0
                $tp_b = ""
                # 最終行の読み取り完了フラグ をキャッチ
                if( $tp_f -eq $true ){
                    write-output "$ot00$ot01"
                    $ot01 = ""
                    $tp_f = $false
                }
                $f_thrue = $true # パターンマッチ処理を開始する
            } else {
                $tp_cnt = $tp_cnt + 1
            }
            continue
        }

        # １項目を取り出して、数値とその後を分離
        "B" {
            if( $tp_cnt -eq 2 ){
                $r = $r -replace ",",""      # 先にカンマをカット
                $rlc = $r -match ">([^<]+)<"
                $rlc = mpattern_b( $matches[1] )
                $ot01 = $ot01 + $rlc

                $tp_cnt = 0
                $tp_b = ""

                $f_thrue = $true # パターンマッチ処理再開

                # 最終行の読み取り完了フラグをキャッチ
                if( $tp_f -eq $true ){
                    write-output "$ot00$ot01"
                    $ot01 = ""
                    $tp_f = $false
                }
            } else {
                $tp_cnt = $tp_cnt + 1
            }
            continue
        }

        #　　例外処理：　「決算年月」を分解した後に、通常出力
        "C" {
             if( $tp_cnt -eq 2 ){
                $bk = $r -match ">([^<]+)<"
                $rla = $matches[1]         # 通常の取り出し内容

                if( $rla -eq "---" ){
                    # 決算年月が、"---" の場合の処置
                    $ot01 = $01 + ",,---"
                } else {
                    # 決算年月に内容が存在する場合の処置
                    $rg_all = [regex]"([0-9]+)年([0-9]+)"
                    $bk = $rg_all.matches( $rla )
                    if ( $bk.count -eq 0 ){
                        $ot01 = $ot01 + ",,$rla"
                    } else {
                        $rlb = $bk.groups[1].value
                        $rlc = $bk.groups[2].value                               
                        $ot01 = $ot01 + ",$rlb" + "-" + "$rlc,$rla"
                    }
                }
               $tp_cnt = 0
               $tp_b = ""

               $f_thrue = $true # パターンマッチ再開

                # 最終行の読み取り完了フラグ をキャッチ
                if( $tp_f -eq $true ){
                    write-output "$ot00$ot01"
                    $ot01 = ""
                    $tp_f = $false
                }
            } else {
                $tp_cnt = $tp_cnt + 1
            }
            continue
         
        }

    }


    # 読み取り行のパターンマッチ

    # フラグが立っている時のみ処置実行
    if( $f_thrue ){

        switch -regex ( $r ) {

            # 社名
            "</a></h2>" {
                $bk = $r -match ">([^>]+)</a></h2>"
                $b01_syamei = $matches[1]
                continue
            }

            # cd, 市場
            ">[0-9]{4}（.+）</p>" {
                $bk = $r -match ">([0-9]{4}).+</p>"
                $rla = $matches[1]
                $bk = $r -match ">[0-9]{4}(.+)</p>"
                $rlb = $matches[1]

                $ot00 = "$rla,$rlb,$b01_syamei"
                continue    
            }

            # 決算期
            ">決算期</h3>"{
                $tp_b = "C" # 決算期を出力する前に、「年月」を出力
                $tp_cnt = 0
                $f_thrue = $false #パターンマッチの停止フラグ
                continue
            }

            # 決算発表日
            "決算発表日</h3>" {
                $tp_b = "A"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチの停止フラグ
                continue
            }

            # 決算月数
            "決算月数</h3>" {
                $tp_b = "A"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチの停止
                continue
            }

            #  売上高
            ">売上高</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチの停止
                continue
            }

            # 営業利益
            ">営業利益</h3>"{
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチの停止
                continue
            }

            # 経常利益
            ">経常利益</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false #パターンマッチ停止
                continue
            }
            # 当期利益
            ">当期利益</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチ停止
                continue
            }

            # EPS（一株あたり利益）
            ">EPS（一株あたり利益）</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチ停止
                continue
            }

            # 調整一株あたり利益
            ">調整一株あたり利益</h3>" {
                $tp_b = "A"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチ停止
                continue
            }

            # BPS（一株あたり純資産）
            ">BPS（一株あたり純資産）</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチ停止
                continue
            }
            #  総資産
            ">総資産</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチ停止
                continue
            }
        
            # 自己資本
            ">自己資本</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチ停止
                continue
            }

            # 資本金
            ">資本金</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチ停止
                continue
            }

            # 有利子負債
            ">有利子負債</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチ停止
                continue
            }

            # 自己資本比率
            ">自己資本比率</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチ停止
                continue
            }

            # 含み損益
            ">含み損益</h3>" {
                $tp_b = "A"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチ停止
                continue
            }

            # >ROA（総資産利益率）
            ">ROA（総資産利益率）</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチ停止
                continue
            }

            # ROE（自己資本利益率）
            ">ROE（自己資本利益率）</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false #　パターンマッチ停止
                continue
            }

            # 総資産経常利益率
            ">総資産経常利益率</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # パターンマッチ停止
                $tp_f = $true   # 最終行の読み取り完了フラグ
                continue
            }
        }　

    }

} catch [Exception] {

    write-output "エラーキャッチ：$ot01"

}

}

# 処理ループはここまで


