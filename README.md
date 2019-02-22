# Rails on Docker

# Setup Dockerized development environment
- Docker環境をローカルマシンに作成
- bundlerでFWなどのパッケージを導入して使用する想定
- RDBMSはMySQLとする

## Installation

[Docker for Mac, Docker for Windows](https://www.docker.com/products/docker-desktop)

dockerコマンド、docker-machineコマンド、docker-composeコマンド全部入り

In case of Mac, You can also use Homebrew
```bash
$ brew install docker
$ brew cask install docker
```

## Initial Setting

### Launch Docker Host OS（docker-machineをつかう場合だけ必要）
```bash
$ docker-machine create --driver virtualbox myrailsapp
$ docker-machine start myrailsapp
```
#### 起動を確認
```bash
$ docker-machine ls
```
#### 接続
```bash
$ docker-machine env myrailsapp
```
`# Run this command to configure your shell:`と出力されるので従う


## Gemfile確認
必要なものを記載します。（リポジトリ上のGemfileは適当なサンプル）


## Docker Container Setup
docker-composeコマンドを使い、複数コンテナを起動する
(設定は`docker-compose.yml`)
```
$ docker-compose build
Successfully built.

$ docker-compose run --rm app rails new . --force -d mysql --skip-bundle --skip-turbolinks --skip-test

$ docker-compose up -d
```

コンテナの起動確認
```
$ docker ps
```


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
