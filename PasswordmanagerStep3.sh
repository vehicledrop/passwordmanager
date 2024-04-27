#!/bin/bash

#ユーザーが入力するコマンドを変数に代入
add="Add Password"
get="Get Password"
exit="Exit"
gpgname="vehicledrop@gmail.com" #gpgの暗号化に使用するアカウント名
passfile="password.asc" #gpgファイルのパス名

echo "パスワードマネージャへようこそ！"
echo "次の選択肢から入力してください("$add"/"$get"/"$exit")"

while true #正しいコマンドを入力しない場合には正しいコマンドを入力するまで入力を促し続ける
do
    read answer

    if [ "$answer" = "$add" ]; then #ユーザーの入力したコマンドがAdd Passwordの場合の処理
        echo "サービス名を入力してください"
        read service
        echo "ユーザー名を入力してください"
        read username
        echo "パスワードを入力してください"
        read password
        if test -f "$passfile"; then #パスワードを保存した暗号化ファイルがあるときの処理(新規作成じゃない時)
            gpgfile=$(gpg -r "$gpgname" -d "$passfile") #暗号化したパスワードファイルを復号化し変数に代入する
            gpgfile="$gpgfile\n$service:$username:$password" #ユーザーが入力した値をパスワードの入った変数に追加する
            echo "パスワードファイルがある場合の処理：１"
        else #パスワードを保存した暗号化ファイルがない時（新規作成の時)
            touch "$passfile" #空のpassword.ascファイルを作成(password.ascがない場合、下の処理にエラーが出るためエラー回避)
            gpgfile="$service:$username:$password" #ユーザーの入力したサービス名、ユーザー名、パスワードを保存
            echo "パスワードファイルがない場合の処理：２"
        fi
        echo "$gpgfile" | gpg -r "$gpgname" -ea >> "$passfile" #変数gpgfile(ユーザーが入力した新規の値を含む)の中身を追記して保存
        echo "パスワードの追加は成功しました"
        echo "次の選択肢から入力してください("$add"/"$get"/"$exit")"
    elif [ "$answer" = "$get" ]; then #ユーザーの入力したコマンドがGet Passwordの場合の処理
        echo "サービス名を入力してください"
        read service
        flag=0
        if test -f "$passfile"; then #パスワードファイルがあるか確認(エラー回避目的)
            #gpg -r "$gpgname" -d "$passfile" | 
            while read line #復号化した内容を1行ずつ読み取り、変数lineに代入
            do
                if echo "$line" | grep -q "^$service:" #行の最初から、最初の : までの部分がユーザー名が入力した値と一致する場合
                then
                    echo "$line" #取得した行全体を出力する
                    flag=1
                fi
            done < <(gpg -r "$gpgname" -d "$passfile")
            if [ $flag -eq 0 ]; then
                echo "そのサービスは登録されていません。：２"
            fi
        else #パスワードファイルがない場合、ユーザーにわかるように通知する
            echo "パスワードが保存されていないため、パスワードを取得できませんでした。"
        fi
        echo "次の選択肢から入力してください("$add"/"$get"/"$exit")"
    elif [ "$answer" = "$exit" ]; then #ユーザーの入力したコマンドがExitの場合の処理
        echo "Thank you!"
        break
    else
        echo "入力が間違えています。"$add"/"$get"/"$exit" から入力してください。"
    fi
done