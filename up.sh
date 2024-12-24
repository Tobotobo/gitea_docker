#!/usr/bin/env bash

# set -x # 実行したコマンドと引数も出力する
set -e # スクリプト内のコマンドが失敗したとき（終了ステータスが0以外）にスクリプトを直ちに終了する
set -E # '-e'オプションと組み合わせて使用し、サブシェルや関数内でエラーが発生した場合もスクリプトの実行を終了する
set -u # 未定義の変数を参照しようとしたときにエラーメッセージを表示してスクリプトを終了する
set -o pipefail # パイプラインの左辺のコマンドが失敗したときに右辺を実行せずスクリプトを終了する

# Bash バージョン 4.4 以上の場合のみ実行
if [[ ${BASH_VERSINFO[0]} -ge 4 && ${BASH_VERSINFO[1]} -ge 4 ]]; then
    shopt -s inherit_errexit # '-e'オプションをサブシェルや関数内にも適用する
fi

# 初期のカレントディレクトリを保存
initial_dir_path=$(pwd)

# スクリプト終了時に初期のカレントディレクトリに戻るよう設定
trap 'cd "${initial_dir_path}"' EXIT

# このスクリプトがあるフォルダへのパス
script_dir_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# このスクリプトがあるフォルダにカレントディレクトリを設定
cd "${script_dir_path}"

# Gitea を先に起動
docker compose up -d gitea gitea_db

# 起動するまで最大 30 秒待機
docker compose exec --user git gitea bash -c '
timeout=30
elapsed=0
while ! curl -f 127.0.0.1:3000/api/healthz >/dev/null 2>&1; do
  if [ $elapsed -ge $timeout ]; then
    echo "Service did not become available within $timeout seconds."
    exit 1
  fi
  echo "Waiting for service to be available... ($elapsed/$timeout seconds)"
  sleep 2
  elapsed=$((elapsed + 2))
done
echo "Service is now available."
'

# Gitea Actions ランナーのトークンを取得
export GITEA_RUNNER_REGISTRATION_TOKEN=$(docker compose exec --user git gitea bash -c 'gitea actions generate-runner-token')

# Gitea Actions のランナーを起動 & 登録
docker compose up -d gitea_act_runner

# 初期管理者ユーザーの登録
docker compose exec --user git gitea bash -c '
gitea admin user create --username gitea --password gitea --email gitea@example.com --admin
'