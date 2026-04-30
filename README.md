# gitea_docker

## 概要
* Git サーバーの Gitea を Docker Compose で簡単に構築する
* ランナーもセットで Gitea Actions をすぐに試せる
* 本番運用ではなく、Gitea を気軽に試すことが目的

![alt text](docs/images/image-35.png)  

## 詳細

### 目次
* [ランナー用のトークンを生成](#ランナー用のトークンを生成)
* [ネットワークを作成](#ネットワークを作成)
* [起動](#起動)
* [管理者ユーザー作成](#管理者ユーザー作成)
* [サインイン](#サインイン)
* [リポジトリの作成](#リポジトリの作成)
* [はじめての Actions](#はじめての-actions)
* [実行結果をダウンロードできるアクション](#実行結果をダウンロードできるアクション)

### ランナー用のトークンを生成
```
openssl rand -hex 24 > runner-token
```

### ネットワークを作成
```
docker network create gitea_network
```

### 起動
```
docker compose up -d
```

### 管理者ユーザー作成
```
docker compose exec --user git gitea bash -c 'gitea admin user create --username gitea --password gitea --email gitea@example.com --admin'
```

### サインイン

http://localhost:3000  
ID: `gitea`  
PW: `gitea`  

![alt text](docs/images/image.png)

### リポジトリの作成

* 右上の + > 新しいリポジトリ  
  ![alt text](docs/images/image-1.png)

* リポジトリ名を入力  
  ![alt text](docs/images/image-2.png)

* `リポジトリを作成` をクリック    
  ![alt text](docs/images/image-3.png)  

* 右中央の `URL をコピー` をクリック  
  ![alt text](docs/images/image-4.png)

* 適当なフォルダでターミナルから以下を実行  
    ```
    git clone ※コピーした URL
    ```
    ![alt text](docs/images/image-5.png)  
    ![alt text](docs/images/image-6.png)

* フォルダ内にリポジトリ名のフォルダが出来てるので VSCode で開く  
  ※.git フォルダを右クリックしないよう注意！  
  ※さっきのターミナルで `code ※リポジトリ名` でも可
  ![alt text](docs/images/image-7.png)  
  ![alt text](docs/images/image-8.png)

* 試しに README.md を作ってコミットしてみる
  * README.md を作る  
    ![alt text](docs/images/image-9.png)
  * ソース管理  
    ![alt text](docs/images/image-10.png)
  * 適当にメッセージ入力してコミット  
    ![alt text](docs/images/image-11.png)  
  * Branch の発行  
    ![alt text](docs/images/image-12.png)  
  * エラーになるはず  
    ![alt text](docs/images/image-13.png)  
  * エラーはキャンセルで閉じる
  * 表示 > ターミナル
    ![alt text](docs/images/image-14.png)
  * ターミナルで以下を実行し、ユーザー名とメールアドレスを設定  
    ```
    git config --local user.name "gitea"; git config --local user.email "gitea@example.com"
    ```
    ![alt text](docs/images/image-15.png)
  * 再度 Branch の発行  
  * アプリケーションを許可  
    ![alt text](docs/images/image-16.png)  
    ![alt text](docs/images/image-17.png)  
    ![alt text](docs/images/image-18.png)
  * 更新すると README.md がアップされている  
    ![alt text](docs/images/image-19.png)

### はじめての Actions

※前項の リポジトリの作成 で作成したリポジトリを想定してます。

* .gitea/workflows/demo.yaml を作成  
  ※.github/workflows/demo.yaml でも OK  
  ```yaml
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
  ![alt text](docs/images/image-20.png)

* 適当にコミットして変更の同期  
  ![alt text](docs/images/image-21.png)  
  ![alt text](docs/images/image-22.png)  

* 更新して Actions  
  ![alt text](docs/images/image-23.png)  
  ![alt text](docs/images/image-24.png)  
  ![alt text](docs/images/image-25.png)  

* 初回は実行が始まるまでに少し時間がかかる
  ![alt text](docs/images/image-26.png)

* Complete job と表示されれば完了
  ![alt text](docs/images/image-27.png)

### 実行結果をダウンロードできるアクション

※ついでに手動実行のサンプル

* .gitea/workflows/demo2.yaml
  ```yaml
  name: Gitea Actions upload-artifact Example

  on:
    workflow_dispatch:
      
  jobs:
    build:
      runs-on: ubuntu-latest
      steps:
        - run: echo あいうえお > output.txt
        - uses: actions/upload-artifact@v3
          with:
            name: my-artifact
            path: output.txt
  ```
  ![alt text](docs/images/image-28.png)  

* 適当にコミットして変更の同期  

* Actions > demo2.yaml  
  ![alt text](docs/images/image-29.png)

* ワークフローを実行  
  ![alt text](docs/images/image-30.png)  
  ![alt text](docs/images/image-31.png)  
  ![alt text](docs/images/image-32.png)

* しばらく待ってると実行されて、左側の成果物に my-artifact ができる
  ![alt text](docs/images/image-33.png)  
  ![alt text](docs/images/image-34.png)  
  ![alt text](docs/images/image-35.png)

* my-artifact をクリックすると zip でダウンロードできる 
  ![alt text](docs/images/image-36.png)