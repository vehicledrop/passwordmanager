#!/bin/sh

echo "パスワードマネージャへようこそ！"
echo "サービス名を入力してください"
read service
echo "ユーザー名を入力してください"
read username
echo "パスワードを入力してください"
read password
echo "Thank you!"
echo $service:$username:$password >> password.log #ファイルにサービス名:ユーザー名:パスワード　の形で1行ずつ保存
