# gitea_docker

## 概要
作成中

https://hub.docker.com/r/gitea/gitea/tags  
https://hub.docker.com/r/gitea/act_runner/tags  

https://gitea.com/gitea/act_runner

## 詳細

```sh
docker compose up -d gitea gitea_db
```

```sh
export GITEA_RUNNER_REGISTRATION_TOKEN=$(docker compose exec --user git gitea bash -c 'gitea actions generate-runner-token')
```

```sh
echo ${GITEA_RUNNER_REGISTRATION_TOKEN}
```

```sh
docker compose up -d gitea_act_runner
```

初期管理者ユーザーの登録
```sh
docker compose exec --user git gitea bash -c 'gitea admin user create --username gitea --password gitea --email gitea@example.com --admin'
```

http://localhost:3000
docker network create gitea_network

docker compose down
docker compose down -v
docker network rm gitea_network

https://docs.gitea.com/usage/actions/quickstart

.gitea/workflows/demo.yaml
```
name: Gitea Actions Demo
run-name: ${{ gitea.actor }} is testing out Gitea Actions 🚀
on: [push]

jobs:
  Explore-Gitea-Actions:
    runs-on: ubuntu-latest
    steps:
      - run: echo "🎉 The job was automatically triggered by a ${{ gitea.event_name }} event."
      - run: echo "🐧 This job is now running on a ${{ runner.os }} server hosted by Gitea!"
      - run: echo "🔎 The name of your branch is ${{ gitea.ref }} and your repository is ${{ gitea.repository }}."
      - name: Check out repository code
        uses: actions/checkout@v4
      - run: echo "💡 The ${{ gitea.repository }} repository has been cloned to the runner."
      - run: echo "🖥️ The workflow is now ready to test your code on the runner."
      - name: List files in the repository
        run: |
          ls ${{ gitea.workspace }}
      - run: echo "🍏 This job's status is ${{ job.status }}."
```

ワークフローの手動実行(workflow_dispatch)のサポート  
→ v1.23 で実装予定 ※ v1.23.0-rc0 に実装されていることを確認 

Actions support workflow dispatch event  
https://github.com/go-gitea/gitea/pull/28163  

```yaml
name: Gitea Actions workflow_dispatch Example

on:
  workflow_dispatch:
    inputs:
      environment_1:
        description: 'テキスト入力のテスト'
        type: environment
        required: true
        default: 'これはデフォルト値です'
      number_1:
        description: '数値入力のテスト'
        type: number
        required: true
        default: '100'
      boolean_1:
        description: 'チェックボックスのテスト'
        type: boolean
        required: false
      choice_1:
        description: 'コンボボックスのテスト'
        type: choice
        required: true
        options:
          - アイテム1
          - アイテム2
          - アイテム3
        default: 'アイテム2'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo テキスト入力のテスト = ${{ inputs.environment_1 }}
      - run: echo 数値入力のテスト = ${{ inputs.number_1 }}
      - run: echo チェックボックスのテスト = ${{ inputs.boolean_1 }}
      - run: echo コンボボックスのテスト = ${{ inputs.choice_1 }}
```

actions/upload-artifact@v4 を使ってみようとしたがエラーになる  
https://gitea.com/actions/upload-artifact  
```
With the provided path, there will be 1 file uploaded
::warning::Artifact upload failed with error: GHESNotSupportedError: @actions/artifact v2.0.0+, upload-artifact@v4+ and download-artifact@v4+ are not currently supported on GHES..%0A%0AErrors can be temporary, so please try again and optionally run the action with debug mode enabled for more information.%0A%0AIf the error persists, please check whether Actions is operating normally at [https://githubstatus.com](https://www.githubstatus.com).
::error::@actions/artifact v2.0.0+, upload-artifact@v4+ and download-artifact@v4+ are not currently supported on GHES.
```

```yaml
name: Gitea Actions workflow_dispatch Example

on:
  workflow_dispatch:
    inputs:
      environment_1:
        description: 'テキスト入力のテスト'
        type: environment
        required: true
        default: 'これはデフォルト値です'
      number_1:
        description: '数値入力のテスト'
        type: number
        required: true
        default: '100'
      boolean_1:
        description: 'チェックボックスのテスト'
        type: boolean
        required: false
      choice_1:
        description: 'コンボボックスのテスト'
        type: choice
        required: true
        options:
          - アイテム1
          - アイテム2
          - アイテム3
        default: 'アイテム2'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo テキスト入力のテスト = ${{ inputs.environment_1 }} > output.txt
      - run: echo 数値入力のテスト = ${{ inputs.number_1 }} > output.txt
      - run: echo チェックボックスのテスト = ${{ inputs.boolean_1 }} > output.txt
      - run: echo コンボボックスのテスト = ${{ inputs.choice_1 }} > output.txt
      - uses: actions/upload-artifact@v4
        with:
          name: my-artifact
          path: output.txt
```

TODO
* 2回目以降の up.sh の実行でランナーの登録やユーザーの登録をスキップする