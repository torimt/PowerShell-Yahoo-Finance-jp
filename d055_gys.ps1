$mp = [regex]"([0-9-�]`.]*)(.+)"

function mpattern_b ( [string]$st ){

    if( $st -match "---" -eq $true ){
        return ",,"
    } else {
        $rts = $mp.matches( $st )
        $rla = $rts.groups[1].value
        $rlb = $rts.groups[2].value
        if( $rla -eq "�]" ){
            return ",,$rlb"
        } else {
            return ",$rla,$rlb"
        }
    }

}

$ot00 = ""
$ot01 = ""
$b01_syamei

$tp_b = ""   # ���ڎ擾�X�C�b�`
$tp_cnt = 0  # �s�J�E���^

[boolean]$f_thrue = $true # �p�^�[���}�b�`�̃X���[�t���O
    # true �}�b�`���O�������s
    # false �}�b�`���O�s�v

[boolean]$tp_f = $false  # �ŏI�s�t���O�@�i�@�o�̓t���O�@�j

foreach ( $r in $input ){

try{

    switch ( $tp_b ){

        # �P���ڂ��̂܂܎��o���p�^�[��
        "A" {
            if( $tp_cnt -eq 2 ){
                $r = $r -replace ",",""     # �܂��́A�J���}�J�b�g
                $bk = $r -match ">([^>]+)<"
                $rla = $matches[1]
                $ot01 = $ot01 + ",$rla"
                $tp_cnt = 0
                $tp_b = ""
                # �ŏI�s�̓ǂݎ�芮���t���O ���L���b�`
                if( $tp_f -eq $true ){
                    write-output "$ot00$ot01"
                    $ot01 = ""
                    $tp_f = $false
                }
                $f_thrue = $true # �p�^�[���}�b�`�������J�n����
            } else {
                $tp_cnt = $tp_cnt + 1
            }
            continue
        }

        # �P���ڂ����o���āA���l�Ƃ��̌�𕪗�
        "B" {
            if( $tp_cnt -eq 2 ){
                $r = $r -replace ",",""      # ��ɃJ���}���J�b�g
                $rlc = $r -match ">([^<]+)<"
                $rlc = mpattern_b( $matches[1] )
                $ot01 = $ot01 + $rlc

                $tp_cnt = 0
                $tp_b = ""

                $f_thrue = $true # �p�^�[���}�b�`�����ĊJ

                # �ŏI�s�̓ǂݎ�芮���t���O���L���b�`
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

        #�@�@��O�����F�@�u���Z�N���v�𕪉�������ɁA�ʏ�o��
        "C" {
             if( $tp_cnt -eq 2 ){
                $bk = $r -match ">([^<]+)<"
                $rla = $matches[1]         # �ʏ�̎��o�����e

                if( $rla -eq "---" ){
                    # ���Z�N�����A"---" �̏ꍇ�̏��u
                    $ot01 = $01 + ",,---"
                } else {
                    # ���Z�N���ɓ��e�����݂���ꍇ�̏��u
                    $rg_all = [regex]"([0-9]+)�N([0-9]+)"
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

               $f_thrue = $true # �p�^�[���}�b�`�ĊJ

                # �ŏI�s�̓ǂݎ�芮���t���O ���L���b�`
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


    # �ǂݎ��s�̃p�^�[���}�b�`

    # �t���O�������Ă��鎞�̂ݏ��u���s
    if( $f_thrue ){

        switch -regex ( $r ) {

            # �Ж�
            "</a></h2>" {
                $bk = $r -match ">([^>]+)</a></h2>"
                $b01_syamei = $matches[1]
                continue
            }

            # cd, �s��
            ">[0-9]{4}�i.+�j</p>" {
                $bk = $r -match ">([0-9]{4}).+</p>"
                $rla = $matches[1]
                $bk = $r -match ">[0-9]{4}(.+)</p>"
                $rlb = $matches[1]

                $ot00 = "$rla,$rlb,$b01_syamei"
                continue    
            }

            # ���Z��
            ">���Z��</h3>"{
                $tp_b = "C" # ���Z�����o�͂���O�ɁA�u�N���v���o��
                $tp_cnt = 0
                $f_thrue = $false #�p�^�[���}�b�`�̒�~�t���O
                continue
            }

            # ���Z���\��
            "���Z���\��</h3>" {
                $tp_b = "A"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`�̒�~�t���O
                continue
            }

            # ���Z����
            "���Z����</h3>" {
                $tp_b = "A"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`�̒�~
                continue
            }

            #  ���㍂
            ">���㍂</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`�̒�~
                continue
            }

            # �c�Ɨ��v
            ">�c�Ɨ��v</h3>"{
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`�̒�~
                continue
            }

            # �o�험�v
            ">�o�험�v</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false #�p�^�[���}�b�`��~
                continue
            }
            # �������v
            ">�������v</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`��~
                continue
            }

            # EPS�i�ꊔ�����藘�v�j
            ">EPS�i�ꊔ�����藘�v�j</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`��~
                continue
            }

            # �����ꊔ�����藘�v
            ">�����ꊔ�����藘�v</h3>" {
                $tp_b = "A"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`��~
                continue
            }

            # BPS�i�ꊔ�����菃���Y�j
            ">BPS�i�ꊔ�����菃���Y�j</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`��~
                continue
            }
            #  �����Y
            ">�����Y</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`��~
                continue
            }
        
            # ���Ȏ��{
            ">���Ȏ��{</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`��~
                continue
            }

            # ���{��
            ">���{��</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`��~
                continue
            }

            # �L���q����
            ">�L���q����</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`��~
                continue
            }

            # ���Ȏ��{�䗦
            ">���Ȏ��{�䗦</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`��~
                continue
            }

            # �܂ݑ��v
            ">�܂ݑ��v</h3>" {
                $tp_b = "A"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`��~
                continue
            }

            # >ROA�i�����Y���v���j
            ">ROA�i�����Y���v���j</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`��~
                continue
            }

            # ROE�i���Ȏ��{���v���j
            ">ROE�i���Ȏ��{���v���j</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false #�@�p�^�[���}�b�`��~
                continue
            }

            # �����Y�o�험�v��
            ">�����Y�o�험�v��</h3>" {
                $tp_b = "B"
                $tp_cnt = 0
                $f_thrue = $false # �p�^�[���}�b�`��~
                $tp_f = $true   # �ŏI�s�̓ǂݎ�芮���t���O
                continue
            }
        }�@

    }

} catch [Exception] {

    write-output "�G���[�L���b�`�F$ot01"

}

}

# �������[�v�͂����܂�


