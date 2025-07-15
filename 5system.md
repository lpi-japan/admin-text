# システムのメンテナンス

## パッケージ管理

Linuxの各ディストリビューションでは、Linuxカーネルやアプリケーションなどシステムに必要なソフトウェアをパッケージ形式でインストール、管理する仕組みを持っています。
パッケージは、たとえばLinuxカーネルであればカーネル本体およびカーネルモジュールを1つのパッケージファイルにまとめたものです。

Red Hat Enterprise LinuxやCentOS、SUSE Linuxなどでは、パッケージ管理にRPM(Red Hat Package Manager)が採用されています。また、アップデート時のバージョン管理等を行う為に開発されたYum（Yellowdog Updater Modified）が、システムの更新等で広く使われています。

Debian GNU/LinuxやUbuntuなどのディストリビューションでは、パッケージ管理にDebianパッケージ（deb形式）が採用されています。パッケージ管理ツールとしてAPT（Advanced Package Tool）が使われています。

本教科書では、CentOS 6のパッケージ管理ツールであるyumの使用方法について解説します。

### Yumとは

以前はRPMパッケージの管理にはrpmコマンドが使用されていましたが、パッケージ間の依存関係を自動的に解決できなかったため、パッケージのインストールを行う際に管理者が自分で依存関係を確認しながら、手動で必要なパッケージを指定する必要がありました。そのため、依存関係で必要となるパッケージが多数あった場合、インストール作業が大変でした。

Yumでは、yumコマンドを使ったパッケージのインストール時に依存関係の解決を自動的に行い、必要となるパッケージも同時にインストールするため、パッケージ管理が簡単になっています。

### Yumの設定

Yumでは、RPMパッケージをまとめて置いておく場所を「リポジトリ」と呼びます。パッケージのインストールの際には、リポジトリから必要なRPMパッケージを取得します。

リポジトリの設定ファイルは/etc/yum.repos.dディレクトリにあります。

```shell-session
# ls /etc/yum.repos.d
CentOS-Base.repo       CentOS-Media.repo  CentOS-fasttrack.repo
CentOS-Debuginfo.repo  CentOS-Vault.repo
```

それぞれのリポジトリ設定ファイルに、リポジトリの参照先などが記述されています。

デフォルトで利用されるCentOS-Base.repoの中身は以下の通りです。

```shell-session
# cat /etc/yum.repos.d/CentOS-Base.repo
（略）
[base]
name=CentOS-$releasever - Base
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
（略）

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
（略）
```

設定項目mirrorlistで指定したmirror.centos.orgは、リポジトリのミラーリストから返される、ネットワークで接続しやすいリポジトリのアドレスに置き換えられます。

設定項目enabledの値が0に設定されていると、そのリポジトリはyumコマンドの--enablerepoオプションで指定されなければ参照しません。

yumコマンドは、インターネットに接続し、HTTPでインストールするパッケージをダウンロードすることができる必要があります。もし、PROXYサーバを経由する必要がある場合には、yumコマンドの設定ファイル/etc/yum.confにPROXYサーバに関する設定を記述する必要があります。設定項目は以下の通りです。

| 項目           | 設定する値                  |
| -------------- | --------------------------- |
| proxy          | PROXYサーバのURL            |
| proxy_username | PROXYサーバの認証ユーザ名   |
| proxy_password | PROXYサーバの認証パスワード |

また、インターネットに接続できない場合には、インストール用のDVDメディアをリポジトリとして参照する方法が利用できます。具体的な手順は後述します。

### yumコマンドの基本的な使い方

yumコマンドは、引数として様々なサブコマンドを指定して使用します。主なサブコマンドは以下の通りです。

#### パッケージのインストール

指定されたパッケージをインストールします。

```
yum install パッケージ名
```

#### パッケージのアンインストール（削除）

指定されたパッケージをアンインストール（削除）します。

```
yum remove パッケージ名
```

#### パッケージの更新の確認

インストールされているパッケージの更新があるかを確認します。

```
yum check-update
```

#### パッケージの更新

インストールされているパッケージを更新します。パッケージ名を指定しなかった場合には、すべての更新可能なパッケージが対象となります。

```
yum update [パッケージ名]
```

#### パッケージグループの一覧表示

利用可能なパッケージグループを表示します。

```
yum grouplist
```

#### パッケージグループのインストール

指定されたパッケージグループに含まれるすべてのパッケージをまとめてインストールします。

```
yum groupinstall パッケージグループ名
```

#### パッケージグループのアンインストール（削除）

指定されたパッケージグループに含まれるすべてのパッケージをまとめてアンインストール（削除）します。

```
yum groupremove パッケージグループ名
```

### パッケージグループを指定したインストール

yumコマンドを使ったパッケージのインストールはdumpコマンドのインストールなどで既に行っているので、パッケージグループを指定したインストールを行います。

以下の例では、高機能なエディタである「Emacs」パッケージグループをインストールします。

利用可能なパッケージグループを表示します。

```shell-session
# yum grouplist
読み込んだプラグイン:fastestmirror, refresh-packagekit, security
グループ処理の設定をしています
Loading mirror speeds from cached hostfile
 * base: ftp.nara.wide.ad.jp
 * extras: ftp.nara.wide.ad.jp
 * updates: ftp.nara.wide.ad.jp
インストール済みグループ:
   CIFS ファイルサーバー
   Java プラットフォーム
（略）
利用可能なグループ
   Eclipse
   ※Emacs
（略）
```

「Emacs」パッケージグループをインストールします。

```shell-session
# yum groupinstall Emacs
読み込んだプラグイン:fastestmirror, refresh-packagekit, security
グループ処理の設定をしています
Loading mirror speeds from cached hostfile
 * base: ftp.riken.jp
 * extras: ftp.riken.jp
 * updates: ftp.riken.jp
依存性の解決をしています
--> トランザクションの確認を実行しています。
---> Package emacs.x86_64 1:23.1-25.el6 will be インストール
--> 依存性の処理をしています: emacs-common = 1:23.1-25.el6 のパッケージ: 1:emacs-23.1-25.el6.x86_64
（略）

依存性を解決しました

================================================================================
 パッケージ               アーキテクチャ
                                        バージョン            リポジトリー
                                                                           容量
================================================================================
インストールしています:
 emacs                    x86_64        1:23.1-25.el6         base        2.2 M
依存性関連でのインストールをします。:
 emacs-common             x86_64        1:23.1-25.el6         base         18 M
 libXaw                   x86_64        1.0.11-2.el6          base        178 k
 libXpm                   x86_64        3.5.10-2.el6          base         51 k
 libotf                   x86_64        0.9.9-3.1.el6         base         80 k
 m17n-db-datafiles        noarch        1.5.5-1.1.el6         base        717 k

トランザクションの要約
================================================================================
インストール         6 パッケージ

総ダウンロード容量: 21 M
インストール済み容量: 73 M
これでいいですか? [y/N]※y ←yを入力
パッケージをダウンロードしています:
(1/6): emacs-23.1-25.el6.x86_64.rpm                      | 2.2 MB     00:00
（略）

インストール:
  emacs.x86_64 1:23.1-25.el6

依存性関連をインストールしました:
  emacs-common.x86_64 1:23.1-25.el6            libXaw.x86_64 0:1.0.11-2.el6
  libXpm.x86_64 0:3.5.10-2.el6                 libotf.x86_64 0:0.9.9-3.1.el6
  m17n-db-datafiles.noarch 0:1.5.5-1.1.el6

完了しました!
```

Emacsを起動します

```shell-session
# emacs
```

Emacsを終了します。Ctrl+Xキーを押した後、Ctrl+Cキーを押します。

### パッケージグループ名を英語表記で表示する

yumコマンドはロケール（Locale）に対応しているため、環境変数LANGの値が日本語に設定されているとパッケージグループ名が日本語で表示されます。このため、yum groupinstallコマンドを実行する際に日本語でパッケージグループ名を指定しなければなりません。

日本語がうまく表示できない、あるいは日本語が入力できない環境の場合、yumコマンドの前に「LANG=C」と入力することでパッケージグループ名を英語表記で表示できます。この方法は環境変数LANGの値を一時的に変更した状態で、yumコマンドを実行したことになります。

```shell-session
# LANG=C yum grouplist
（略）
Installed Groups:
   Additional Development
   Base
   CIFS file server
（略）
```

インストール時には、ローケルを指定しないでも英語表記のままパッケージグループ名を指定できます。パッケージグループ名に空白が含まれている場合には「"」（ダブルクォート）でパッケージグループ名を括って下さい。

以下の例では、開発ツール（Development tools）パッケージグループを指定して、コンパイラなどをインストールしています。

```shell-session
# yum groupinstall "Development tools"
```

### インストールDVDメディアをリポジトリにする方法

インターネットに接続できない環境でyumコマンドを利用する方法として、インストールDVDメディアをリポジトリとして参照させる方法があります。

設定ファイル/etc/yum.repos.d/CentOS-Media.repoが用意されており、以下のように設定が記述されています。

```shell-session
# cat /etc/yum.repos.d/CentOS-Media.repo
# CentOS-Media.repo
#
#  This repo can be used with mounted DVD media, verify the mount point for
#  CentOS-6.  You can use this repo and yum to install items directly off the
#  DVD ISO that we release.
#
# To use this repo, put in your DVD and use it with the other repos too:
#  yum --enablerepo=c6-media [command]
#
# or for ONLY the media repo, do this:
#
#  yum --disablerepo=\* --enablerepo=c6-media [command]

[c6-media]
name=CentOS-$releasever - Media
baseurl=file:///media/CentOS/
        file:///media/cdrom/
        file:///media/cdrecorder/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
```

この設定を利用するには、インストールDVDメディアを/media/CentOSディレクトリにマウントし、yumコマンドにリポジトリ指定のオプションをつけて実行する必要があります。

以下の手順で、インストールDVDメディアをリポジトリとして参照できるようにします。

1. CentOSにユーザrootとしてグラフィカルログインします。
1. インストールDVDメディアをDVDドライブに挿入します。仮想マシンの場合には、インストールISOイメージファイルを仮想DVDドライブで参照します。
1. 自動マウントされることを確認します。
1. mountコマンドで確認します。インストールDVDメディアは/media/CentOS_6.6_Finalにマウントされています。

```shell-session
# mount
（略）
/dev/sr0 on /media/CentOS_6.6_Final type iso9660 (ro,nosuid,nodev,uhelper=udisks,uid=0,gid=0,iocharset=utf8,mode=0400,dmode=0500)
```

＃5

1. シンボリックリンク/media/CentOSを作成します。

```shell-session
# ln -s /media/CentOS_6.6_Final/ /media/CentOS
# ls -l /media
合計 4
lrwxrwxrwx. 1 root root   24  1月 15 02:47 2015 CentOS -> /media/CentOS_6.6_Final/
dr-xr-xr-x. 7 root root 4096 10月 24 23:17 2014 CentOS_6.6_Final
```

＃６

1. yumコマンドを実行します。--disablerepoオプションですべてのリポジトリを参照不要とし、--enablerepoオプションでc6-mediaリポジトリのみ参照するように指定します。以下の例では、グループリストを取得しています。

```shell-session
# yum --disablerepo=\* --enablerepo=c6-media grouplist
```

## システム監視

システムを適切に運用していく上で、システム上のリソースが常に有効に使われているか、極端にリソースを占有しているプロセスは無いかを監視することは重要な事です。

システム上のリソースを様々な角度で監視する方法を解説します。

### stressコマンドのインストール

システムに負荷をかけるために、stressコマンドを使用します。stressコマンドは、CentOS 6の標準パッケージでは提供されておらず、RPMforgeのリポジトリで提供されています。リポジトリを追加してyumコマンドでインストールします。

RPMforgeのリポジトリを追加するには、下記のサイトから、ディストリビューションに対応した最新のrpmforge-releaseパッケージをダウンロードします。

```
http://pkgs.repoforge.org/rpmforge-release/
```

64ビット版CentOS 6の場合、以下のパッケージとなります。パッケージがバージョンアップするとファイル名が変わるので注意が必要です。

```
http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
```

コマンドラインでの作業を行っている場合、wgetコマンドを使ってダウンロードします。

```shell-session
# wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
（略）

2014-12-24 11:19:30 (19.2 KB/s) - `rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm' へ保存完了 [12640/12640]
```

rpmコマンドでrpmforge-releaseパッケージをインストールします。

```shell-session
# ls -l rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
-rw-r--r--. 1 root root 12640  3月 21 00:59 2013 rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
# rpm -ivh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
```

yumコマンドでstressパッケージをインストールします。

```shell-session
# yum install stress
```

#### RPMパッケージの直接取得

インターネットに接続できない場合には、インターネットに接続できる端末で以下のURLからRPMパッケージをダウンロードしてコピーして下さい。

```
http://pkgs.repoforge.org/stress/
http://pkgs.repoforge.org/stress/stress-1.0.2-1.el6.rf.x86_64.rpm
```

### topコマンドによるシステムリソース監視

topコマンドは、システムのどのプロセスがどの程度のCPUやメモリなどのリソースを消費しているかを簡単に示してくれる対話型のコマンドです。

topコマンドを実行すると、デフォルトでは先頭五行（サマリーエリア）にシステム全体の情報が表示されます。次の行が対話的にコマンドを入力するエリアです。その次の行から、プロセス毎の情報が表示されます。

```shell-session
top - 03:11:49 up 16:28,  4 users,  load average: 0.08, 0.03, 0.01
Tasks: 188 total,   1 running, 187 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.0%us,  0.0%sy,  0.0%ni, 99.8%id,  0.2%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   1016372k total,   811796k used,   204576k free,    24736k buffers
Swap:  2064380k total,    41640k used,  2022740k free,   295652k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
    1 root      20   0 19364 1304 1036 S  0.0  0.1   0:01.24 init
    2 root      20   0     0    0    0 S  0.0  0.0   0:00.03 kthreadd
    3 root      RT   0     0    0    0 S  0.0  0.0   0:00.03 migration/0
    4 root      20   0     0    0    0 S  0.0  0.0   0:00.09 ksoftirqd/0
    5 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 stopper/0
    6 root      RT   0     0    0    0 S  0.0  0.0   0:00.08 watchdog/0
    7 root      RT   0     0    0    0 S  0.0  0.0   0:00.04 migration/1
    8 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 stopper/1
    9 root      20   0     0    0    0 S  0.0  0.0   0:00.07 ksoftirqd/1
   10 root      RT   0     0    0    0 S  0.0  0.0   0:00.06 watchdog/1
   11 root      20   0     0    0    0 S  0.0  0.0   0:03.16 events/0
   12 root      20   0     0    0    0 S  0.0  0.0   0:02.79 events/1
   13 root      20   0     0    0    0 S  0.0  0.0   0:00.00 cgroup
   14 root      20   0     0    0    0 S  0.0  0.0   0:00.01 khelper
   15 root      20   0     0    0    0 S  0.0  0.0   0:00.00 netns
   16 root      20   0     0    0    0 S  0.0  0.0   0:00.00 async/mgr
   17 root      20   0     0    0    0 S  0.0  0.0   0:00.00 pm
```

先頭の5行には、以下の情報が表示されています。

| 行数  | 意味                                         |
| ----- | -------------------------------------------- |
| 1行目 | 起動時間、ログインユーザ数、ロードアベレージ |
| 2行目 | 各状態のタスク数                             |
| 3行目 | CPUの使用状況                                |
| 4行目 | 物理メモリの使用状況                         |
| 5行目 | スワップ領域の使用状況                       |

stressコマンドを実行して、システムに負荷をかけた状態をtopコマンドで確認します。

stressコマンドをバックグラウンドで実行します。バックグラウンド実行を行った関係上、コマンドプロンプトが表示された後にstressコマンドのメッセージが表示されます。Enterキーを押せば、再度コマンドプロンプトが表示されます。

```shell-session
# stress --cpu 3 --io 4 --vm 2 --vm-bytes 128M &
[1] 9747
# stress: info: [9747] dispatching hogs: 3 cpu, 4 io, 2 vm, 0 hdd
※Enterキーを入力
#
```

topコマンドでプロセスの状況を確認します。stressコマンドがCPU、メモリを使用している様子が確認できます。

```shell-session
# top

top - 03:28:09 up 16:44,  3 users,  load average: 16.85, 14.44, 7.86
Tasks: 208 total,  13 running, 195 sleeping,   0 stopped,   0 zombie
Cpu(s): 55.5%us, 44.5%sy,  0.0%ni,  0.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   1016372k total,   718440k used,   297932k free,     1528k buffers
Swap:  2064380k total,   116124k used,  1948256k free,    39532k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
 9692 sato      20   0  6516  176   92 R 17.0  0.0   2:02.20 stress
 9698 sato      20   0  6516  176   92 R 17.0  0.0   2:03.52 stress
 9748 root      20   0  6516  188  104 R 17.0  0.0   0:04.95 stress
 9750 root      20   0  134m 125m  184 R 17.0 12.6   0:05.11 stress
 9754 root      20   0  6516  188  104 R 17.0  0.0   0:05.11 stress
 9694 sato      20   0  134m  24m  168 R 16.6  2.4   2:00.22 stress
 9695 sato      20   0  6516  176   92 R 16.6  0.0   2:02.48 stress
 9751 root      20   0  6516  188  104 R 16.6  0.0   0:04.88 stress
 9697 sato      20   0  134m  59m  168 R 16.3  6.0   2:00.31 stress
 9753 root      20   0  134m  55m  184 R 16.3  5.6   0:04.87 stress
 9755 root      20   0  6516  184  100 D  4.7  0.0   0:01.50 stress
 9756 root      20   0  6516  184  100 D  4.7  0.0   0:01.49 stress
 9696 sato      20   0  6516  172   88 R  4.0  0.0   0:54.59 stress
 9699 sato      20   0  6516  172   88 D  4.0  0.0   0:59.14 stress
 9693 sato      20   0  6516  172   88 D  2.0  0.0   0:57.48 stress
 9700 sato      20   0  6516  172   88 D  2.0  0.0   0:59.43 stress
 9749 root      20   0  6516  184  100 D  2.0  0.0   0:01.60 stress
```

qキーを押して、topコマンドを終了します。バックグラウンドで動作しているstressコマンドもfgコマンドでフォアグラウンド実行に変更して、終了します。

```shell-session
# fg
stress --cpu 3 --io 4 --vm 2 --vm-bytes 128M
※^C ←Ctrl+Cキーを入力
```

### vmstatコマンドによるシステムリソース監視

vmstatコマンドは、メモリの使用状況やCPUの負荷などを表示するコマンドです。

vmstatコマンドを引数無しで実行すると、コマンドを実行した時点のメモリやCPU、ディスクの使用状況が表示されます。

```shell-session
# vmstat
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 8  0 116104 408536  58692  71292    0    1    10    11  251   66  2  2 97  0  0
```

表示される内容は以下の表のとおりです。

| 項目  | 意味                                                      |
| ----- | --------------------------------------------------------- |
| r     | 実行待ちプロセス数                                        |
| b     | 割り込み不可のスリープ状態にあるプロセス数                |
| swpd  | スワップアウトされたメモリ量                              |
| free  | 空きメモリの容量                                          |
| buff  | バッファに使用されているメモリの容量                      |
| cache | キャッシュに使用されているメモリの容量                    |
| si    | 1秒あたりのディスクからスワップインされているメモリの容量 |
| so    | 1秒あたりのディスクにスワップアウトされているメモリの容量 |
| bi    | 1秒あたりのブロックデバイスに送られたブロック             |
| bo    | 1秒あたりのブロックデバイスから受け取ったブロック         |
| in    | 1秒あたりの割り込みの回数                                 |
| cs    | 1秒あたりのコンテキストスイッチの回数                     |
| us    | CPU総時間当たりのユーザー時間の割合                       |
| sy    | CPU総時間当たりのシステム時間の割合                       |
| id    | CPU総時間当たりのアイドル時間の割合                       |

vmstatコマンドに引数として数値を与えると、秒間隔でシステムのリソース情報を出力し続けます。終了するにはCtrl+Cキーを入力します。

```shell-session
# vmstat 5
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
10  0 116104 261708  65040  79460    0    1    11    11  253   70  2  2 97  0  0
 9  0 116104 358068  65712  80356    0    0   189   242 5411 8564 42 58  0  0  0
 7  0 116104 301924  66184  81372    0    0   202   308 4610 7441 41 59  0  0  0
※^C Ctrl+Cキーを入力する
```

### sysstatによるシステムリソース監視

稼働中のLinuxのシステム情報を継続して集めるには、sysstatパッケージに含まれているiostatコマンドやsarコマンドなどを使うと便利です。

sysstatパッケージをインストールします。

```shell-session
# yum install sysstat
```

sysstatパッケージをインストールすると、デフォルトで10分間隔でシステムのリソース情報が取得されるようにcronが設定されます。

```shell-session
# cat /etc/cron.d/sysstat
# Run system activity accounting tool every 10 minutes
*/10 * * * * root /usr/lib64/sa/sa1 1 1
# 0 * * * * root /usr/lib64/sa/sa1 600 6 &
# Generate a daily summary of process accounting at 23:53
53 23 * * * root /usr/lib64/sa/sa2 -A
```

10分間隔で起動される/usr/lib64/sa/sa1スクリプトは、内部で/usr/lib64/sa/sadcを実行し、システムのリソース情報を取得して/var/log/sa/saDDファイル（DDは2桁の日付）に保存しています。
23:53に実行される/usr/lib64/sa/sa2スクリプトは、sa1スクリプトで取得した情報をまとめて/var/log/sa/sarDD（DDは2桁の日付）というファイルを生成し、古くなった情報を削除します。デフォルトでは28日分を保存しておきます。期間を変更したい場合には設定ファイル/etc/sysconfig/sysstatファイル内のHISTORY変数を変更します。

まとめられた情報は、後述するsarコマンドで参照できます。

### iostatコマンドによるシステムリソース監視

sysstatパッケージに含まれるiostatコマンドは、CPUの使用率や各種I/Oの利用状況を確認するためのコマンドです。I/Oは、ハードディスクやテープドライブ、ネットワークマウントしたファイルシステム、端末入出力等の入出力性能を監視できます。

iostatコマンドを実行すると、システムが起動してからiostatコマンドを実行した時点までの間のCPUおよびI/Oの状況が表示されます。

```shell-session
# iostat
Linux 2.6.32-504.el6.x86_64 (server.example.com)  2015年01月15日  _x86_64(2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.72    0.00    1.95    0.03    0.00   96.30

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
sda               1.89        44.06       117.04    2720068    7224884
scd0              0.01         0.18         0.00      11204          0
dm-0              6.51        41.98        42.57    2591466    2627904
dm-1              0.49         0.17        74.44      10552    4595040
dm-2              0.01         0.06         0.03       3522       1856
```

表示される内容は以下の表のとおりです。

| 項目       | 意味                                                           |
| ---------- | -------------------------------------------------------------- |
| %user      | ユーザプロセスによるCPUの使用率                                |
| %nice      | 実行優先度（nice値）を変更したユーザプロセスによるCPUの使用率  |
| %system    | システムプロセスによるCPUの使用率                              |
| %iowait    | I/O終了待ちとなったCPUの使用率                                 |
| %steal     | ハイパーバイザーによる他の仮想CPUの実行待ちとなったCPUの使用率 |
| %idle      | CPUが何も処理をせずに待機していた時間の割合(ディスクI/O以外）  |
| tps        | 1秒間のI/O転送回数                                             |
| Blk_read/s | 1秒間のディスクの読み込み量(ブロック数)                        |
| Blk_wrtn/s | 1秒間のディスクの書き込み量(ブロック数)                        |
| Blk_read   | ディスクの読み込み量(ブロック数)                               |
| Blk_wrtn   | ディスクの書き込み量(ブロック数)                               |

iostatコマンドに-xオプションを付与して実行すると、表示がKB単位に変わります。

| 項目      | 意味                                |
| --------- | ----------------------------------- |
| kB_read/s | 1秒間のディスクの読み込み量(KB単位) |
| kB_wrtn/s | 1秒間のディスクの書き込み量(KB単位) |
| kB_read   | ディスクの読み込み量(KB単位)        |
| kB_wrtn   | ディスクの書き込み量(KB単位)        |

iostatコマンドに引数として数値を与えて実行すると、1回目の表示はシステム起動からiostatコマンド実行時までの間の情報ですが、その後指定された秒間隔で全てのデバイスのI/Oの利用状況が出力されます。終了するにはCtrl+Cを入力します。。

```shell-session
# iostat 5
Linux 2.6.32-504.el6.x86_64 (server.example.com)  2015年01月15日  _x86_64(2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.76    0.00    2.01    0.03    0.00   96.20

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
sda               1.89        44.02       116.93    2720092    7225892
scd0              0.01         0.18         0.00      11204          0
dm-0              6.51        41.94        42.54    2591474    2628888
dm-1              0.49         0.17        74.36      10552    4595040
dm-2              0.01         0.06         0.03       3522       1856

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          44.30    0.00   55.70    0.00    0.00    0.00

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
sda               0.00         0.00         0.00          0          0
scd0              0.00         0.00         0.00          0          0
dm-0              0.00         0.00         0.00          0          0
dm-1              0.00         0.00         0.00          0          0
dm-2              0.00         0.00         0.00          0          0

※^C ←Ctrl+Cキーを入力する
```

iostatコマンドに-xオプションを付与して実行します。結果が拡張フォーマットで表示されます。

```shell-session
# iostat -x
Linux 2.6.32-504.el6.x86_64 (server.example.com)  2015年01月15日  _x86_64(2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.78    0.00    2.04    0.03    0.00   96.16

Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.83     4.90    0.83    1.06    44.00   116.88    85.16     0.00    0.57   0.30   0.06
scd0              0.04     0.00    0.01    0.00     0.18     0.00    27.00     0.00   14.24   9.61   0.01
dm-0              0.00     0.00    1.17    5.33    41.92    42.52    12.98     0.02    3.17   0.10   0.06
dm-1              0.00     0.00    0.02    0.47     0.17    74.33   150.83     0.00    1.80   0.03   0.00
dm-2              0.00     0.00    0.01    0.00     0.06     0.03     7.97     0.00    0.37   0.27   0.00
```

表示される内容は以下の表のとおりです。

| 項目     | 意味                                            |
| -------- | ----------------------------------------------- |
| rrqm/s   | 1秒間デバイスへマージされた読み込みリクエスト数 |
| wrqm/s   | 1秒間デバイスへマージされた書き込みリクエスト数 |
| r/s      | 1秒間の読み込みリクエスト数                     |
| w/s      | 1秒間の書き込みリクエスト数                     |
| rsec/s   | 1秒間の読み込みセクタ数                         |
| wsec/s   | 1秒間の書き込みセクタ数                         |
| rkB/s    | 1秒間の読み込みキロバイト（KB）数               |
| wkB/s    | 1秒間の読み込みキロバイト（KB）数               |
| avgrq-sz | デバイスへのIOリクエストの平均サイズ            |
| avgqu-sz | デバイスへのIOリクエストのキューの平均サイズ    |
| await    | デバイスへのIOリクエストの平均待ち時間          |
| svctm    | デバイスへのIOリクエストの平均処理時間          |
| %util    | デバイスへのIOリクエスト期間CPUの使用率         |

### sar（System Admin Reporter）によるシステムリソース監視

sarコマンドはCPUやネットワーク、メモリ、ディスクなどのシステム情報を確認・出力するためのコマンドです。sarコマンドで様々なシステム情報を取得、出力できるので、障害発生時の障害を特定するために利用されます。

また、オプションでファイルを指定することにより、過去に取得しているsarやsadcのバイナリ出力ファイルから利用状況を抜き出すことができます。sysstatパッケージをインストールした際に設定されたcronによる情報収集の結果も、sarコマンドで確認できます。

sarコマンドに引数を与えて実行します。例では1秒間隔で3回、CPUの情報を監視します。

```shell-session
# sar 1 3
Linux 2.6.32-504.el6.x86_64 (server.example.com)  2015年01月23日  _x86_64(2 CPU)

18時25分47秒     CPU     %user     %nice   %system   %iowait    %steal     %idle
18時25分48秒     all     38.00      0.00     62.00      0.00      0.00      0.00
18時25分49秒     all     38.50      0.00     61.50      0.00      0.00      0.00
18時25分50秒     all     39.80      0.00     60.20      0.00      0.00      0.00
平均値:      all     38.77      0.00     61.23      0.00      0.00      0.00
```

sarコマンドを-bオプションを付与して実行します。ディスクI/Oの利用状況を監視します。

```shell-session
# sar -b 1 3
Linux 2.6.32-504.el6.x86_64 (server.example.com)  2015年01月23日  _x86_64(2 CPU)

18時26分15秒       tps      rtps      wtps   bread/s   bwrtn/s
18時26分16秒      0.00      0.00      0.00      0.00      0.00
18時26分17秒      0.00      0.00      0.00      0.00      0.00
18時26分18秒    352.00    142.00    210.00   5648.00   1904.00
平均値:     117.73     47.49     70.23   1888.96    636.79
```

sarコマンドを-rオプションを付与して実行します。メモリやスワップの利用状況を監視します。

```shell-session
# sar -r 1 3
Linux 2.6.32-504.el6.x86_64 (server.example.com)  2015年01月23日  _x86_64(2 CPU)

18時26分32秒 kbmemfree kbmemused  %memused kbbuffers  kbcached  kbcommit   %commit
18時26分33秒    233684    782688     77.01     81008    152872   1562412     50.72
18時26分34秒    101404    914968     90.02     81008    152872   1562412     50.72
18時26分35秒    112552    903820     88.93     81008    152872   1562412     50.72
平均値:     149213    867159     85.32     81008    152872   1562412     50.72
```

sarコマンドを引数無しで実行すると、その日に実行されたsysstatの結果が表示されます。

```shell-session
# sar
Linux 2.6.32-504.el6.x86_64 (server.example.com)  2015年01月23日  _x86_64(2 CPU)

11時10分01秒     CPU     %user     %nice   %system   %iowait    %steal     %idle
11時20分01秒     all      0.39      0.00      0.36      0.01      0.00     99.24
11時30分02秒     all      9.34      0.00     12.22      0.04      0.00     78.39
11時40分01秒     all     43.10      0.00     56.90      0.00      0.00      0.00
（略）
```

sarコマンドに-fオプションを付与して実行します。オプションの値として/var/log/sa/saDDファイルを指定します。

```shell-session
# sar -f /var/log/sa/sa22
Linux 2.6.32-504.el6.x86_64 (server.example.com)  2015年01月22日  _x86_64(2 CPU)

12時10分02秒     CPU     %user     %nice   %system   %iowait    %steal     %idle
12時20分01秒     all      0.33      0.00      0.34      0.01      0.00     99.32
12時30分01秒     all      0.39      0.00      0.34      0.02      0.00     99.25
平均値:      all      0.36      0.00      0.34      0.01      0.00     99.29
（略）
```

/var/log/sa/sarDDファイルは1日の監視結果を集計したテキストファイルです。lessコマンドなどで参照できます。ただし、毎日23時53分にシステムが動作していないとsarDDファイルは作成されません。その場合には、rootユーザで以下のコマンドを実行するとその日のsarDDファイルが作成されます。

```shell-session
# /usr/lib64/sa/sa2 -A
# cat /var/log/sa/sar24
Linux 2.6.32-504.el6.x86_64 (server.example.com)  2015-01-23  _x86_64(2 CPU)

11時10分01秒     CPU      %usr     %nice      %sys   %iowait    %steal      %irq     %soft    %guest     %idle
11時20分01秒     all      0.39      0.00      0.35      0.01      0.00      0.00      0.01      0.00     99.24
11時20分01秒       0      0.44      0.00      0.36      0.02      0.00      0.00      0.02      0.00     99.17
（略）
```

### logwatchによるメール通知

サーバに出力されたログには、問題が発生した兆候がログとして出力されるものがあります。また、セキュリティ上、不正なアクセスなどもログに記録されます。

logwatchは、サーバのログを見やすいレポートにまとめて毎日メールで送信したり、特定のパターンが含まれるログが出た際にメールで通知を出すように設定できます。これにより、ログのチェックを簡略化することができます。

logwatchをインストールします。

```shell-session
# yum install logwatch
```

logwatchを設定します。logwatch.confのデフォルト設定は/usr/share/logwatch/default.conf/logwatch.confに記述されています。このデフォルト設定から値を変更したいものを/etc/logwatch/conf/logwatch.confに記述します。

設定できる値は以下の表のとおりです。

#### LogDir

チェックするログの格納先を指定

#### TmpDir

一時的なファイルの保存先

#### MailTo

結果レポートのメール送信先を指定

#### MailFrom

結果レポートのメール送信元を指定

#### Print

結果を標準出力（STDOUT）に出力（Yes）、あるいはMailTo宛にメール送信（No）

#### Save

結果レポートをファイルとして保存
標準では無効（コメントアウト）：保存しない

#### Archives

アーカイブされたファイルも調査（Yes）
標準では無効（コメントアウト）：調査しない

#### Range

チェック対象となるログファイルの日付範囲を指定
すべて（All）、当日（Today）、昨日（Yesterday）

#### Detail

結果レポートの詳細レベル
Low（0）、Med（5）、High（10）のいずれかを指定

#### Service

LogWatchでチェックの対象となるサービスを指定
/usr/share/logwatch/scripts/services以下のファイルが対象

#### LogFile

特定のログファイルのみをチェック
標準では無効（コメントアウト）：すべてチェック

#### mailer

メール送信で用いるメールプログラムを指定

#### HostLimit

特定のホスト名（hostnameコマンドの結果）に関するログエントリのみチェック
標準では無効（コメントアウト）：制限しない

一般的には、MailTo、Detailなどを変更します。デフォルトの設定ファイルをコピーして、必要な設定を変更するとよいでしょう。

```shell-session
# cp /usr/share/logwatch/default.conf/logwatch.conf /etc/logwatch/conf/logwatch.conf
cp: `/etc/logwatch/conf/logwatch.conf' を上書きしてもよろしいですか(yes/no)? ※y yを入力
```

以下はデフォルト値の抜粋です。

```
MailTo = root
Range = yesterday
Detail = Low
Service = All
```

デフォルト設定では、ローカルのユーザroot宛に昨日の結果を最小限でメール送信します。対象となるサービスは/usr/share/logwatch/scripts/servicesディレクトリ内に用意されているサービスです。

```shell-session
# ls /usr/share/logwatch/scripts/services
afpd            eximstats         pam_unix          sendmail-largeboxes
amavis          extreme-networks  php               shaperd
arpwatch        fail2ban          pix               slon
audit           ftpd-messages     pluto             smartd
automount       ftpd-xferlog      pop3              sonicwall
autorpm         http              portsentry        sshd
bfd             identd            postfix           sshd2
cisco           imapd             pound             stunnel
clam-update     in.qpopper        proftpd-messages  sudo
clamav          init              pureftpd          syslogd
clamav-milter   ipop3d            qmail             tac_acc
courier         iptables          qmail-pop3d       up2date
cron            kernel            qmail-pop3ds      vpopmail
denyhosts       mailscanner       qmail-send        vsftpd
dhcpd           modprobe          qmail-smtpd       windows
dnssec          mountd            raid              xntpd
dovecot         named             resolver          yum
dpkg            netopia           rt314             zz-disk_space
emerge          netscreen         samba             zz-fortune
evtapplication  oidentd           saslauthd         zz-network
evtsecurity     openvpn           scsi              zz-runtime
evtsystem       pam               secure            zz-sys
exim            pam_pwdb          sendmail
```

/etc/logwatch/conf/logwatch.confの設定を変更して、すべての期間のログファイルをチェックするように記述します。

```shell-session
# vi /etc/logwatch/conf/logwatch.conf

※#※Range = yesterday ※←行頭に#を追加
※Range = All ←新規に追加
```

logwatchの出力テストを行います。logwatchコマンドに--printオプションを付与して実行すると、結果が標準出力に表示されます。

````shell-session
# logwatch --print


 ################### Logwatch 7.3.6 (05/19/07) ####################
        Processing Initiated: Tue Jan 27 11:53:04 2015
        Date Range Processed: all
      Detail Level of Output: 0
              Type of Output: unformatted
           Logfiles for Host: server.example.com
  ##################################################################

 --------------------- Selinux Audit Begin ------------------------

  Number of audit daemon stops: 1

 ---------------------- Selinux Audit End -------------------------
（略）
 --------------------- Disk Space Begin ------------------------

 Filesystem            Size  Used Avail Use% Mounted on
 /dev/mapper/vg_server-lv_root
                        50G  3.8G   43G   9% /
 /dev/sda1             477M   28M  424M   7% /boot
 /dev/mapper/vg_server-lv_home
                        12G   31M   11G   1% /home


 ---------------------- Disk Space End -------------------------


 ###################### Logwatch End #########################

再度、/etc/logwatch/conf/logwatch.confを設定します。今日のログファイルをチェックするように記述します。

```shell-session
# vi /etc/logwatch/conf/logwatch.conf

Range = Today
````

再度logwatchコマンドに--printオプションを付与して実行します。結果が短くなったことを確認します。
