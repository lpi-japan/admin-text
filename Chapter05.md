# システムのメンテナンス

## パッケージ管理
Linuxの各ディストリビューションでは、Linuxカーネルやアプリケーションなどシステムに必要なソフトウェアをパッケージ形式でインストール、管理する仕組みを持っています。
パッケージは、たとえばLinuxカーネルであればカーネル本体およびカーネルモジュールを1つのパッケージファイルにまとめたものです。

Red Hat Enterprise LinuxやAlmaLinux、Rocky Linux、SUSE Linuxなどでは、パッケージ管理にRPM(Red Hat Package Manager)が採用されています。また、アップデート時のバージョン管理等を行う為に開発されたYum（Yellowdog Updater Modified）が、システムの更新等で広く使われるようになり、現在ではYumの後継であるDNF（Dandified Yum）が使われるようになっています。

Debian GNU/LinuxやUbuntuなどのディストリビューションでは、パッケージ管理にDebianパッケージ（deb形式）が採用されています。パッケージ管理ツールとしてAPT（Advanced Package Tool）が使われています。 

本教科書では、AlmaLinuxのパッケージ管理ツールであるDNFの使用方法について解説します。

### DNFとは
以前はRPMパッケージの管理にはrpmコマンドが使用されていましたが、パッケージ間の依存関係を自動的に解決できなかったため、パッケージのインストールを行う際に管理者が自分で依存関係を確認しながら、手動で必要なパッケージを指定する必要がありました。そのため、依存関係で必要となるパッケージが多数あった場合、インストール作業が大変でした。

DNFでは、dnfコマンドを使ったパッケージのインストール時に依存関係の解決を自動的に行い、必要となるパッケージも同時にインストールするため、パッケージ管理が簡単になっています。

DNFやその前に使われていたYumの後継のため、現在でも設定ファイルなどはYumの頃と同じものが使われています。また、dnfコマンドとyumコマンドの間で基本的なサブコマンドには互換性があります。

### DNFの設定
DNFでは、RPMパッケージをまとめて置いておく場所を「リポジトリ」と呼びます。パッケージのインストールの際には、リポジトリから必要なRPMパッケージを取得します。

リポジトリの設定ファイルは/etc/yum.repos.dディレクトリにあります。

```
$ ls /etc/yum.repos.d
almalinux-appstream.repo  almalinux-extras.repo            almalinux-plus.repo              almalinux-sap.repo
almalinux-baseos.repo     almalinux-highavailability.repo  almalinux-resilientstorage.repo  almalinux-saphana.repo
almalinux-crb.repo        almalinux-nfv.repo               almalinux-rt.repo
```

それぞれのリポジトリ設定ファイルに、リポジトリの参照先などが記述されています。

デフォルトで利用されるalmalinux-baseos.repoの中身は以下の通りです。

```
$ cat /etc/yum.repos.d/almalinux-baseos.repo
[baseos]
name=AlmaLinux $releasever - BaseOS
mirrorlist=https://mirrors.almalinux.org/mirrorlist/$releasever/baseos
# baseurl=https://repo.almalinux.org/almalinux/$releasever/BaseOS/$basearch/os/
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-9
metadata_expire=86400
enabled_metadata=1
（略）
```

設定項目mirrorlistで指定したmirrors.almalinux.orgは、リポジトリのミラーリストから返される、ネットワークで接続しやすいリポジトリのアドレスに置き換えられます。

設定項目enabledの値が0に設定されていると、そのリポジトリはdnfコマンドの--enablerepoオプションで指定されなければ参照しません。

dnfコマンドは、インターネットに接続し、HTTPでインストールするパッケージをダウンロードすることができる必要があります。もし、PROXYサーバを経由する必要がある場合には、dnfコマンドの設定ファイル/etc/dnf/dnf.confにPROXYサーバに関する設定を記述する必要があります。設定項目は以下の通りです。

|項目|設定する値|
|-------|-------|
|proxy|PROXYサーバのURL|
|proxy_username|PROXYサーバの認証ユーザ名|
|proxy_password|PROXYサーバの認証パスワード|

また、インターネットに接続できない場合には、インストール用のDVDメディアをリポジトリとして参照する方法が利用できます。具体的な手順は後述します。

### dnfコマンドの基本的な使い方
dnfコマンドは、引数として様々なサブコマンドを指定して使用します。主なサブコマンドは以下の通りです。

#### パッケージのインストール
指定されたパッケージをインストールします。

```
dnf install パッケージ名
```

#### パッケージのアンインストール（削除）
指定されたパッケージをアンインストール（削除）します。

```
dnf remove パッケージ名
```

#### パッケージの更新の確認
インストールされているパッケージの更新があるかを確認します。

```
dnf check-update
```

#### パッケージの更新
インストールされているパッケージを更新します。パッケージ名を指定しなかった場合には、すべての更新可能なパッケージが対象となります。

```
dnf update [パッケージ名]
```

#### パッケージグループの一覧表示
利用可能なパッケージグループを表示します。

```
dnf grouplist
```

#### パッケージグループのインストール
指定されたパッケージグループに含まれるすべてのパッケージをまとめてインストールします。

```
dnf groupinstall パッケージグループ名
```

#### パッケージグループのアンインストール（削除）
指定されたパッケージグループに含まれるすべてのパッケージをまとめてアンインストール（削除）します。

```
dnf groupremove パッケージグループ名
```

### パッケージグループを指定したインストール
dnfコマンドを使ってパッケージグループを指定したインストールを行います。

以下の例では、コンパイラーなどが含まれている「開発ツール」パッケージグループをインストールします。

利用可能なパッケージグループを表示します。

```
$ dnf grouplist
AlmaLinux 9 - AppStream                                                                                                    3.6 kB/s | 4.2 kB     00:01
AlmaLinux 9 - AppStream                                                                                                    6.9 MB/s |  14 MB     00:02
AlmaLinux 9 - BaseOS                                                                                                       5.6 kB/s | 3.8 kB     00:00
AlmaLinux 9 - BaseOS                                                                                                       7.1 MB/s |  15 MB     00:02
AlmaLinux 9 - Extras                                                                                                       5.4 kB/s | 3.8 kB     00:00
AlmaLinux 9 - Extras                                                                                                        27 kB/s |  20 kB     00:00
利用可能な環境グループ:
   サーバー
   最小限のインストール
（略）
インストール済みの環境グループ:
   サーバー (GUI 使用)
インストール済みのグループ:
   コンテナー管理
   ヘッドレス管理
利用可能なグループ:
   コンソールインターネットツール
   .NET Development
   RPM 開発ツール
   開発ツール
（略）
```

「開発ツール」パッケージグループをインストールします。

```
$ sudo dnf groupinstall "開発ツール" -y
メタデータの期限切れの最終確認: 2:33:22 前の 2025年07月27日 11時15分35秒 に実施しました。
依存関係が解決しました。
===========================================================================================================================================================
 パッケージ                                         アーキテクチャー          バージョン                                リポジトリー                 サイズ
===========================================================================================================================================================
group/moduleパッケージをインストール:
 asciidoc                                           noarch                    9.1.0-3.el9                               appstream                    237 k
 autoconf                                           noarch                    2.69-39.el9                               appstream                    665 k
 automake                                           noarch                    1.16.2-8.el9                              appstream                    662 k
（略）
  valgrind-1:3.24.0-3.el9.x86_64                                           valgrind-devel-1:3.24.0-3.el9.x86_64
  xorg-x11-fonts-ISO8859-1-100dpi-7.5-33.el9.noarch                        xz-devel-5.2.5-8.el9_0.x86_64
  zlib-devel-1.2.11-40.el9.x86_64                                          zstd-1.5.5-1.el9.x86_64

完了しました!
```

### パッケージグループ名を英語表記で表示する
dnfコマンドはロケール（Locale）に対応しているため、環境変数LANGの値が日本語に設定されているとパッケージグループ名が日本語で表示されます。このため、dnf groupinstallコマンドを実行する際に日本語でパッケージグループ名を指定しなければなりません。

日本語がうまく表示できない、あるいは日本語が入力できない環境の場合、dnfコマンドの前に「LANG=C」と入力することでパッケージグループ名を英語表記で表示できます。この方法は環境変数LANGの値を一時的に変更した状態で、dnfコマンドを実行したことになります。

```
$ LANG=C dnf grouplist
Last metadata expiration check: 0:04:17 ago on Sun Jul 27 13:46:51 2025.
Available Environment Groups:
   Server
   Minimal Install
   Workstation
（略）
```

インストール時には、ローケルを指定しないでも英語表記のままパッケージグループ名を指定できます。パッケージグループ名に空白が含まれている場合には「"」（ダブルクォート）でパッケージグループ名を括って下さい。

以下の例では、開発ツール（Development Tools）パッケージグループを指定して、コンパイラなどをインストールしています。

```
$ sudo dnf groupinstall "Development Tools"
```

### インストールDVDメディアをリポジトリにする方法
インターネットに接続できない環境でdnfコマンドを利用する方法として、ISOイメージやDVDなどのインストールメディアをリポジトリとして参照させる方法があります。

インストールメディアを/run/media/linucディレクトリにマウントし、リポジトリ設定ファイルを作成して、dnfコマンドにリポジトリ指定のオプションをつけて実行する必要があります。

以下の手順で、インストールDVDメディアをリポジトリとして参照できるようにします。

1. AlmaLinuxにlinucユーザーとしてグラフィカルログインします。
1. インストールメディアをDVDドライブに挿入します。仮想マシンの場合には、ISOイメージファイルを仮想DVDドライブで参照します。VirtualBoxの場合、「デバイス」メニューから「光学ドライブ」を選択し、ISOイメージファイルを選択します。
1. 自動マウントされることを確認します。
1. mountコマンドで確認します。インストールメディアは/run/media/linucディレクトリ内にマウントされています。
1. マウントされたディレクトリを参照するリポジトリ設定ファイルを作成します。

自動マウントされたディレクトリを確認します。

```
# mount
（略）
/dev/sr0 on /run/media/linuc/AlmaLinux-9-6-x86_64-dvd type iso9660 (ro,nosuid,nodev,relatime,nojoliet,check=s,map=n,blocksize=2048,uid=1000,gid=1000,dmode=500,fmode=400,uhelper=udisks2)
```

インストールメディアをマウントした後、リポジトリの設定ファイル/etc/yum.repos.d/almalinux-media.repoを作成します。内容は以下の通りです。


```
$ sudo vi /etc/yum.repos.d/almalinux-media.repo
```

```
[media_BaseOS]
name=AlmaLinux 9 Media - BaseOS
baseurl=file:///run/media/linuc/AlmaLinux-9-6-x86_64-dvd/BaseOS/
enabled=0
gpgcheck=0
gpgkey=file:///run/media/linuc/AlmaLinux-9-6-x86_64-dvd/RPM-GPG-KEY-AlmaLinux-9

[media_AppStream]
name=AlmaLinux 9 Media - AppStream
baseurl=file:///run/media/linuc/AlmaLinux-9-6-x86_64-dvd/AppStream/
enabled=0
gpgcheck=0
gpgkey=file:///run/media/linuc/AlmaLinux-9-6-x86_64-dvd/RPM-GPG-KEY-AlmaLinux-9
```


dnfコマンドを実行します。--disablerepoオプションですべてのリポジトリを参照不要とし、--enablerepoオプションでmediaリポジトリのみ参照するように指定します。以下の例では、グループリストを取得しています。

```
$ sudo dnf --disablerepo=\* --enablerepo=media* grouplist
AlmaLinux 9 Media - BaseOS                                                                                                 157 MB/s | 2.3 MB     00:00
AlmaLinux 9 Media - AppStream                                                                                              217 MB/s | 8.1 MB     00:00
メタデータの期限切れの最終確認: 0:00:01 前の 2025年07月27日 13時57分30秒 に実施しました。
利用可能な環境グループ:
   サーバー
   最小限のインストール
（略）
```

## システム監視
システムを適切に運用していく上で、システム上のリソースが常に有効に使われているか、極端にリソースを占有しているプロセスは無いかを監視することは重要な事です。

システム上のリソースを様々な角度で監視する方法を解説します。

### topコマンドによるシステムリソース監視
topコマンドは、システムのどのプロセスがどの程度のCPUやメモリなどのリソースを消費しているかを簡単に示してくれる対話型のコマンドです。

topコマンドを実行すると、デフォルトでは先頭五行（サマリーエリア）にシステム全体の情報が表示されます。次の行が対話的にコマンドを入力するエリアです。その次の行から、プロセス毎の情報が表示されます。

```
top - 13:59:16 up  3:35,  3 users,  load average: 0.00, 0.05, 0.05
Tasks: 200 total,   1 running, 199 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :   1753.5 total,    169.9 free,   1168.5 used,    602.4 buff/cache
MiB Swap:   2048.0 total,   2040.7 free,      7.3 used.    585.0 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
   2295 linuc     20   0 1474764 108924  39448 S   0.3   6.1   0:04.40 gnome-s+   30177 linuc     20   0  225900   4224   3456 R   0.3   0.2   0:00.08 top
      1 root      20   0  109948  18356  10912 S   0.0   1.0   0:01.80 systemd        2 root      20   0       0      0      0 S   0.0   0.0   0:00.00 kthreadd
      3 root      20   0       0      0      0 S   0.0   0.0   0:00.00 pool_wo+       4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker+
      5 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker+       6 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker+
      7 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker+       9 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker+
     11 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker+      13 root      20   0       0      0      0 I   0.0   0.0   0:00.00 rcu_tas+
     14 root      20   0       0      0      0 I   0.0   0.0   0:00.00 rcu_tas+      15 root      20   0       0      0      0 I   0.0   0.0   0:00.00 rcu_tas+
     16 root      20   0       0      0      0 S   0.0   0.0   0:00.12 ksoftir+      17 root      20   0       0      0      0 I   0.0   0.0   0:00.22 rcu_pre+
     18 root      20   0       0      0      0 S   0.0   0.0   0:00.00 rcu_exp+
```

先頭の5行には、以下の情報が表示されています。

|行数|意味|
|-------|-------|
|1行目|起動時間、ログインユーザ数、ロードアベレージ|
|2行目|各状態のタスク数|
|3行目|CPUの使用状況|
|4行目|物理メモリの使用状況|
|5行目|スワップ領域の使用状況|

### vmstatコマンドによるシステムリソース監視
vmstatコマンドは、メモリの使用状況やCPUの負荷などを表示するコマンドです。

vmstatコマンドを引数無しで実行すると、コマンドを実行した時点のメモリやCPU、ディスクの使用状況が表示されます。

```
$ vmstat
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0   7472 173780   2332 614608    0    0    50    56   86   90  0  0 100  0  0
```

表示される内容は以下の表のとおりです。

|項目|意味|
|-------|-------|
|r|実行待ちプロセス数|
|b|割り込み不可のスリープ状態にあるプロセス数|
|swpd|スワップアウトされたメモリ量|
|free|空きメモリの容量|
|buff|バッファに使用されているメモリの容量|
|cache|キャッシュに使用されているメモリの容量|
|si|1秒あたりのディスクからスワップインされているメモリの容量|
|so|1秒あたりのディスクにスワップアウトされているメモリの容量|
|bi|1秒あたりのブロックデバイスに送られたブロック|
|bo|1秒あたりのブロックデバイスから受け取ったブロック|
|in|1秒あたりの割り込みの回数|
|cs|1秒あたりのコンテキストスイッチの回数|
|us|CPU総時間当たりのユーザー時間の割合|
|sy|CPU総時間当たりのシステム時間の割合|
|id|CPU総時間当たりのアイドル時間の割合|

vmstatコマンドに引数として数値を与えると、指定された数値の秒間隔でシステムのリソース情報を出力し続けます。終了するにはCtrl+Cキーを入力します。

```
$ vmstat 5
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0   7472 173780   2332 614656    0    0    50    56   85   90  0  0 100  0  0
 0  0   7472 173532   2332 614744    0    0    18     0  180  126  0  0 100  0  0
 0  0   7472 173532   2332 614748    0    0     1     0  135   95  0  0 100  0  0
 ^C
```

### sysstatによるシステムリソース監視
稼働中のLinuxのシステム情報を継続して集めるには、sysstatパッケージに含まれているiostatコマンドやsarコマンドなどを使うと便利です。

sysstatパッケージをインストールします。

```
$ sudo dnf install sysstat
```

sysstatサービスを起動します。

```
$ sudo systemctl start sysstat
$ sudo systemctl enable sysstat
```

sysstatパッケージをインストールすると、タイマーが設定されます。

```
$ systemctl list-timers | grep sysstat
Sun 2025-07-27 14:10:00 JST 4min 15s left -                           -            sysstat-collect.timer        sysstat-collect.service
Mon 2025-07-28 00:07:00 JST 10h left      -                           -            sysstat-summary.timer        sysstat-summary.service
```

デフォルトで10分間隔でシステムのリソース情報が取得されるようにタイマーが設定されます。

```
$ systemctl cat sysstat-collect.timer
# /usr/lib/systemd/system/sysstat-collect.timer
（略）
[Timer]
OnCalendar=*:00/10
（略）
```

また、1日に1回、取得した情報のサマリーを作成するようにタイマーが設定されます。

```
$ systemctl cat sysstat-summary.timer
# /usr/lib/systemd/system/sysstat-summary.timer
（略）
[Timer]
OnCalendar=00:07:00
（略）
```

まとめられた情報は、後述するsarコマンドで参照できます。

### iostatコマンドによるシステムリソース監視
sysstatパッケージに含まれるiostatコマンドは、CPUの使用率や各種I/Oの利用状況を確認するためのコマンドです。I/Oは、ハードディスクやテープドライブ、ネットワークマウントしたファイルシステム、端末入出力等の入出力性能を監視できます。

iostatコマンドを実行すると、システムが起動してからiostatコマンドを実行した時点までの間のCPUおよびI/Oの状況が表示されます。

```
$ iostat
Linux 5.14.0-570.26.1.el9_6.x86_64 (vbox) 	2025年07月27日 	_x86_64_	(2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.17    0.01    0.27    0.02    0.00   99.53

Device             tps    kB_read/s    kB_wrtn/s    kB_dscd/s    kB_read    kB_wrtn    kB_dscd
dm-0              8.56        86.31        97.31         0.00    1176403    1326269          0
dm-1              0.16         0.20         0.57         0.00       2712       7752          0
dm-2              0.06         0.41         4.99         0.00       5550      67953          0
sda               6.83        91.65        98.03         0.00    1249236    1336119          0
sdb               0.19         3.93        10.18         0.00      53629     138792          0
sr0               0.01         0.94         0.00         0.00      12758          0          0
```

表示される内容は以下の表のとおりです。

|項目|意味|
|-------|-------|
|%user|ユーザプロセスによるCPUの使用率|
|%nice|実行優先度（nice値）を変更したユーザプロセスによるCPUの使用率|
|%system|システムプロセスによるCPUの使用率|
|%iowait|I/O終了待ちとなったCPUの使用率|
|%steal|ハイパーバイザーによる他の仮想CPUの実行待ちとなったCPUの使用率|
|%idle|CPUが何も処理をせずに待機していた時間の割合(ディスクI/O以外）|
|tps|1秒間のI/O転送回数|
|kB_read/s|1秒間のディスクの読み込み量(ブロック数)|
|kB_wrtn/s|1秒間のディスクの書き込み量(ブロック数)|
|kB_dscd/s|1秒間のディスクの廃棄された量(ブロック数)|
|kB_read|ディスクの読み込み量(ブロック数)|
|kB_wrtn|ディスクの書き込み量(ブロック数)|
|kB_dscd|ディスクの廃棄された量(ブロック数)|

iostatコマンドに引数として数値を与えて実行すると、1回目の表示はシステム起動からiostatコマンド実行時までの間の情報ですが、その後指定された秒間隔で全てのデバイスのI/Oの利用状況が出力されます。終了するにはCtrl+Cを入力します。。

```
Linux 5.14.0-570.26.1.el9_6.x86_64 (vbox) 	2025年07月27日 	_x86_64_	(2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.17    0.01    0.26    0.02    0.00   99.55

Device             tps    kB_read/s    kB_wrtn/s    kB_dscd/s    kB_read    kB_wrtn    kB_dscd
dm-0              8.34        83.39        94.25         0.00    1177935    1331277          0
dm-1              0.15         0.19         0.55         0.00       2712       7752          0
dm-2              0.06         0.39         4.81         0.00       5550      67953          0
sda               6.66        88.55        94.94         0.00    1250768    1341127          0
sdb               0.18         3.80         9.83         0.00      53629     138792          0
sr0               0.01         0.90         0.00         0.00      12758          0          0


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.00    0.00    0.20    0.00    0.00   99.80

Device             tps    kB_read/s    kB_wrtn/s    kB_dscd/s    kB_read    kB_wrtn    kB_dscd
dm-0              0.00         0.00         0.00         0.00          0          0          0
dm-1              0.00         0.00         0.00         0.00          0          0          0
dm-2              0.00         0.00         0.00         0.00          0          0          0
sda               0.00         0.00         0.00         0.00          0          0          0
sdb               0.00         0.00         0.00         0.00          0          0          0
sr0               0.00         0.00         0.00         0.00          0          0          0


^C
```

iostatコマンドに-xオプションを付与して実行します。結果が拡張フォーマットで表示されます。

```
$ iostat -x
Linux 5.14.0-570.26.1.el9_6.x86_64 (vbox) 	2025年07月27日 	_x86_64_	(2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.17    0.01    0.26    0.02    0.00   99.55

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
dm-0             2.66     83.05     0.00   0.00    0.31    31.23    5.65     93.91     0.00   0.00    0.47    16.61    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   1.36
dm-1             0.02      0.19     0.00   0.00    0.25    12.27    0.14      0.55     0.00   0.00    4.15     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
dm-2             0.02      0.39     0.00   0.00    0.12    19.82    0.04      4.79     0.00   0.00    0.58   124.46    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
sda              2.73     88.19     0.09   3.31    0.21    32.35    3.92     94.61     1.90  32.69    0.39    24.14    0.00      0.00     0.00   0.00    0.00     0.00    0.41    0.41    0.00   0.10
sdb              0.14      3.78     0.00   0.00    0.09    26.10    0.04      9.79     0.07  65.54    0.66   272.68    0.00      0.00     0.00   0.00    0.00     0.00    0.01    0.48    0.00   0.00
sr0              0.01      0.90     0.00   0.00    0.20    75.94    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
```

表示される内容は以下の表のとおりです。

|項目|意味|
|-------|-------|
|r/s|1秒間の読み込みリクエスト数|
|rkB/s|1秒間の読み込みキロバイト（KB）数|
|rrqm/s|1秒間デバイスへマージされた読み込みリクエスト数|
|%rrqm|1秒間デバイスへマージされた読み込みリクエスト比率|
|r_await|デバイスへの読み込みリクエストの平均待ち時間|
|rareq-sz|デバイスへの読み込みリクエストの平均サイズ|
|w/s|1秒間の書き込みリクエスト数|
|wkB/s|1秒間の読み込みキロバイト（KB）数|
|wrqm/s|1秒間デバイスへマージされた書き込みリクエスト数|
|%wrqm|1秒間デバイスへマージされた書き込みリクエスト比率|
|w_await|デバイスへの書き込みリクエストの平均待ち時間|
|wareq-sz|デバイスへの書き込みリクエストの平均サイズ|
|d/s|1秒間の廃棄リクエスト数|
|dkB/s|1秒間の廃棄キロバイト（KB）数|
|drqm/s|1秒間デバイスへマージされた廃棄リクエスト数|
|%drqm|1秒間デバイスへマージされた廃棄リクエスト比率|
|d_await|デバイスへの廃棄リクエストの平均待ち時間|
|dareq-sz|デバイスへの廃棄リクエストの平均サイズ|
|f/s|1秒間のフラッシュリクエスト数|
|f_await|デバイスへのフラッシュリクエストの平均待ち時間|
|aqu-sz|デバイスへのキューの平均サイズ|
|%util|デバイスへのIOリクエスト期間CPUの使用率|

### 廃棄（discard）の意味
iostatの表示にある廃棄（discard）とは、SSDの寿命を長くするため、ファイルが削除されて未使用になったブロックを廃棄し、再利用可能にする処理のことです。fstrimコマンド、あるいはfstrimサービスを実行することで行われます。

\pagebreak

