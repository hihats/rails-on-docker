# Rails on Docker

# Setup Dockerized development environment
- Docker環境をローカルマシンに作成
- bundlerでFWなどのパッケージを導入して使用する想定
- RDBMSはMySQLとする

## Installation

**Docker for Mac は未動作確認かつ動作が遅いという伝聞のため割愛**


[Docker Toolbox](https://www.docker.com/products/docker-toolbox)

dockerコマンド、docker-machineコマンド、docker-composeコマンド全部入り

Macであれば
```bash
$ brew cask install dockertoolbox
```
でも可

## Initial Setting

### Gemfile確認
必要なものを記載します。（リポジトリ上のGemfileは適当なサンプル）

### Launch Docker Host OS
docker-machineコマンドを使用
```bash
$ docker-machine create --driver virtualbox myrailsapp
$ docker-machine start myrailsapp
```
### 起動を確認
```bash
$ docker-machine ls
```
### 接続
```bash
$ docker-machine env myrailsapp
```
`# Run this command to configure your shell:`と出力されるので従う

    別のDocker machineを使う場合はその都度設定する必要あり

## コンテナレジストリにログイン認証を通す
e.g. [Dockerhub](https://hub.docker.com/)を使った例
     アカウントを取得しておく
```bash
$ docker login
```
`Login Succeeded`

これでSetup準備完了


### Docker Container Setup
docker-composeコマンドを使い、複数コンテナを起動する
(設定は`docker-compose.yml`)
```
$ docker-compose build
Successfully built.

$ docker-compose up -d
```
Bundle installが走る

コンテナの起動確認
```
$ docker ps
```

## Setting environment valuables
コンテナ間の接続の設定
```bash
$ docker exec **(appコンテナ名) env
```

出力された値を`.env`に設定  
e.g.
```
DB_HOST       = 172.17.**.**
DB_PORT       = 3306
DB_DATABASE   = MYSQL_DATABASE
DB_USERNAME   = myrailsapp
DB_PASSWORD   = secret
```

$DOCKER_HOSTの値を、ローカルの`/etc/hosts`に追記  
```
192.168.***.**  dev.myrailsapp.jp
```

`dev.myrailsapp.jp` ブラウザアクセスしてRailsの確認

## Gemfileに変更があった場合
変更をローカルにマージ後

```
$ docker-composer build
```
buildし直すことで、DockerfileのAddがGemfile&Gemfile.lockのキャッシュから更新があったときのみ検知してbundle install が走る


## 既存問題点

###  Docker machine のホスト時刻がずれて、Railsの更新が反映されない問題

http://qiita.com/pocari/items/456052a291381895f8b3

Dockerマシンの中に入って
```bash
$ docker-machine ssh ****
```

VirualBoxの設定変更
```bash
$ sudo VBoxControl guestproperty set "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold" 5000
```



###  Docker inorify issue

 `reach limit of inotify count in rails console` Error Message

[Increasing the amount of inotify watchers](https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers)

```bash
$ echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p
$ cat /proc/sys/fs/inotify/max_user_watches
```
Dockerfileに組み込みたいが、Privilegedで起動扠せねばならぬ問題があるため、起動時に叩くシェルを作るか
