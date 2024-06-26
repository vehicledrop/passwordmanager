#!/bin/bash

#ユーザーが入力するコマンドを変数に代入
add="Add Password"
get="Get Password"
exit="Exit"
passfile="password.asc" #パスワードが保存されるファイル名

echo "パスワードマネージャへようこそ！"
echo "次の選択肢から入力してください("$add"/"$get"/"$exit")"

while true #正しいコマンドを入力しない場合には正しいコマンドを入力するまで入力を促し続ける
do
    read answer

    if [ "$answer" = "$add" ]; then #Add Passwordの場合の処理
        echo "サービス名を入力してください"
        read service
        echo "ユーザー名を入力してください"
        read username
        echo "パスワードを入力してください"
        read password
        if test -z $gpgname; then #gpgname(gnupgのユーザー名)が入力済みの場合はFalse。入力がまだの場合のみ入力を促す
            echo "GnuPGのユーザー名を入力してください"
            read gpgname
        fi
        if test -f "$passfile"; then #パスワードを保存した暗号化ファイルがあるときの処理(新規作成じゃない時)
            gpgfile=$(gpg -r "$gpgname" -d "$passfile") #暗号化したパスワードファイルを取得し変数に代入する
            gpgfile="$gpgfile\n$service:$username:$password" #ユーザーが入力した値をパスワードの入った変数に追加する
        else #パスワードを保存した暗号化ファイルがない時（新規作成の時)
            touch "$passfile" #空のpassword.ascファイルを作成(password.ascがない場合のエラー回避)
            gpgfile="$service:$username:$password" #ユーザーの入力したサービス名、ユーザー名、パスワードを保存
        fi
        echo -e "$gpgfile" | gpg -r "$gpgname" -ea > "$passfile" #復号化したパスワードとユーザーが入力したパスワードを上書き保存
        echo "パスワードの追加は成功しました"
        echo "次の選択肢から入力してください("$add"/"$get"/"$exit")"
    elif [ "$answer" = "$get" ]; then #Get Passwordの場合の処理
        echo "サービス名を入力してください"
        read service
        if test -z $gpgname; then #パスワードを保存した暗号化ファイルがあるときの処理(新規作成じゃない時)
            echo "GnuPGのユーザー名を入力してください"
            read gpgname
        fi
        flag=0 #フラグ用変数を初期化(サービスが見つからなかった場合の処理に使用)
        if test -f "$passfile"; then #パスワードファイルがあるか確認(エラー回避)
            #gpg -r "$gpgname" -d "$passfile" | 
            while read line #復号化した内容を1行ずつ読み取り、変数lineに代入
            do
                if echo "$line" | grep -q "^$service:" #行の最初から、最初の : までの部分がユーザー名が入力した値と一致する場合
                then
                    echo "$line" #取得した行全体を出力する
                    flag=1
                fi
            done < <(gpg -r "$gpgname" -d "$passfile" | grep "^$service:")
            if [ $flag -eq 0 ]; then #ユーザーが入力したサービス名が見つかったかどうかの判定
                echo "そのサービスは登録されていません。"
            fi
        else #パスワードファイルがない場合、ユーザーにわかるように通知する
            echo "パスワードが保存されていないため、パスワードを取得できませんでした。"
        fi
        echo "次の選択肢から入力してください("$add"/"$get"/"$exit")"
    elif [ "$answer" = "$exit" ]; then #Exitの場合の処理
        echo "Thank you!"
        break
    else
        echo "入力が間違えています。"$add"/"$get"/"$exit" から入力してください。"
    fi
done