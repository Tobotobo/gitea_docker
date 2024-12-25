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

# .env ファイルが存在する場合は読み込む
if [[ -f ".env" ]]; then
    set -a
    source .env
    set +a
fi

# コンテナをボリュームを含め破棄
docker compose down -v

# ネットワークが作成されている場合は削除
network_name="gitea_network"
if ! docker network ls --format '{{.Name}}' | grep -q "^${network_name}$"; then
  docker network rm "${network_name}"
fi
