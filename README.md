# gitea_docker

## 概要
作成中

https://hub.docker.com/r/gitea/gitea/tags  
https://hub.docker.com/r/gitea/act_runner/tags  

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
