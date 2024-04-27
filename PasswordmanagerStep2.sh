#!/bin/sh

#ユーザーが入力するコマンドを変数に代入
add="Add Password"
get="Get Password"
exit="Exit"
pass="password.log"

echo "パスワードマネージャへようこそ！"
echo "次の選択肢から入力してください("$add"/"$get"/"$exit")"

while true #breakが実行される(Exitが入力されたときの条件)まで処理を繰り返す
do
    read answer

    if [ "$answer" = "$add" ]; then #ユーザーの入力したコマンドがAdd Passwordの場合の処理
        echo "サービス名を入力してください"
        read service
        echo "ユーザー名を入力してください"
        read username
        echo "パスワードを入力してください"
        read password
        echo $service:$username:$password >> $pass #ファイルにサービス名:ユーザー名:パスワード　の形で1行ずつ保存
        echo "パスワードの追加は成功しました"
        echo "次の選択肢から入力してください("$add"/"$get"/"$exit")"
    elif [ "$answer" = "$get" ]; then #ユーザーの入力したコマンドがGet Passwordの場合の処理
        echo "サービス名を入力してください"
        read service
        flag=0
        if test -f $pass; then #password.logがある場合の処理
            while read line #ファイルpassword.logを1行ずつ読み取り、変数lineに代入
            do
                if echo "$line" | grep -q "^$service:"; then #行の最初から、最初の : までの部分がユーザー名が入力した値と一致する場合
                    echo "$line"
                    flag=1
                fi
            done < $pass #while readlineに標準出力する
            if [ $flag -eq 0 ]; then
                echo "そのサービスは登録されていません。：２"
            fi            
        else #password.logがない場合の処理
            echo "そのサービスは登録されていません。：３" 
        fi
        echo "次の選択肢から入力してください("$add"/"$get"/"$exit")"
    elif [ "$answer" = "$exit" ]; then #ユーザーの入力したコマンドがExitの場合の処理
        echo "Thank you!"
        break #whileを修了させる(プログラムの終了)
    else
        echo "入力が間違えています。"$add"/"$get"/"$exit" から入力してください。"
    fi
done