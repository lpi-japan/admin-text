# サービスの管理

## OSが起動するまでのプロセス

マシンに電源を入れた後、以下のような順番でシステムの初期化が行われ、OSが起動します。

1. 電源オン
1. BIOS起動とハードウェアの初期化
1. ブートローダー（GRUB）の起動
1. Linuxカーネルイメージの読み込み
1. initプロセスの起動
1. 各種サービスの起動
1. OS起動

### ブートローダーGRUBの起動

マシンの電源をオンにすると、BIOSが起動してハードウェアの初期化が行われ、起動に使用するブートデバイス（ハードディスクなど）が決定します。ブートデバイスからブートローダーであるGRUBが読み込まれ、起動処理が引き継がれます。
GRUBは、Linuxカーネルのイメージをメモリ上にロードする役割を持っています。

![GRUB選択画面](grubmenu.png)

Linuxカーネルイメージが複数ある場合は、GRUBの初期画面が表示されている時に何かキーを入力すると、GRUBのメニュー画面が表示されます。ロードしたいイメージを選択して、Enterキーを押します。

GRUBの設定確認
grubby --info=ALL

GRUBのデフォルト起動カーネルの確認
grubby --default-kernel

GRUBのデフォルト起動カーネルのインデックス確認
grubby --default-index

GRUBのデフォルト起動カーネルの変更
grubby --set-default /boot/vmlinuz-5.14.0-503.11.1.el9_5.x86_64

GRUBのデフォルト起動カーネルのインデックスによる変更
grubby --set-default 1

### GRUB設定

$ sudo grubby --info=ALL
[sudo] linuc のパスワード:
index=0
kernel="/boot/vmlinuz-5.14.0-570.25.1.el9_6.aarch64"
args="ro crashkernel=1G-4G:256M,4G-64G:320M,64G-:576M rd.lvm.lv=almalinux_vbox/root rd.lvm.lv=almalinux_vbox/swap rhgb quiet $tuned_params"
root="/dev/mapper/almalinux_vbox-root"
initrd="/boot/initramfs-5.14.0-570.25.1.el9_6.aarch64.img $tuned_initrd"
title="AlmaLinux (5.14.0-570.25.1.el9_6.aarch64) 9.6 (Sage Margay)"
id="9e034831eddf4bbb9525d8a0f6676c28-5.14.0-570.25.1.el9_6.aarch64"
index=1
kernel="/boot/vmlinuz-5.14.0-570.12.1.el9_6.aarch64"
args="ro crashkernel=1G-4G:256M,4G-64G:320M,64G-:576M rd.lvm.lv=almalinux_vbox/root rd.lvm.lv=almalinux_vbox/swap rhgb quiet $tuned_params"
root="/dev/mapper/almalinux_vbox-root"
initrd="/boot/initramfs-5.14.0-570.12.1.el9_6.aarch64.img $tuned_initrd"
title="AlmaLinux (5.14.0-570.12.1.el9_6.aarch64) 9.6 (Sage Margay)"
id="9e034831eddf4bbb9525d8a0f6676c28-5.14.0-570.12.1.el9_6.aarch64"
index=2
kernel="/boot/vmlinuz-0-rescue-9e034831eddf4bbb9525d8a0f6676c28"
args="ro crashkernel=1G-4G:256M,4G-64G:320M,64G-:576M rd.lvm.lv=almalinux_vbox/root rd.lvm.lv=almalinux_vbox/swap rhgb quiet"
root="/dev/mapper/almalinux_vbox-root"
initrd="/boot/initramfs-0-rescue-9e034831eddf4bbb9525d8a0f6676c28.img"
title="AlmaLinux (0-rescue-9e034831eddf4bbb9525d8a0f6676c28) 9.6 (Sage Margay)"
id="9e034831eddf4bbb9525d8a0f6676c28-0-rescue"

設定の意味は以下の通りです。

index
ブートメニューの選択肢のインデックス番号です。

kernel
起動に使用するカーネルです。

args
カーネル起動時に引き渡される値です。

root
起動時に参照されるルートデバイスです。

initrd
起動時に使用される起動RAMディスクです。

title
ブートメニューの選択肢に表示される文字列です。

id
マシンのユニークIDとカーネルバージョンを組み合わせた値です。

### カーネルの起動

GRUBで指定されたLinuxカーネルイメージがメモリに読み込まれて、カーネルが起動します。カーネルはハードウェアを初期化し、カーネルの各種機能を有効にしていきます。

カーネルは必要に応じてモジュールを読み込みますが、モジュールは初期化RAMディスク（initramfs）に含まれています。カーネルは初期化RAMディスクをメモリに読み込み、仮のルートファイルシステムとして利用可能にすることで、必要となるモジュールのファイルが読み込めるようになります。

#### dmesgによるカーネル起動時の動作の確認

カーネルが起動する際の動作の様子は、dmesgコマンドで確認できます。

```shell-session
# dmesg
Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 2.6.32-504.el6.x86_64 (mockbuild@c6b9.bsys.dev.centos.org) (gcc version 4.4.7 20120313 (Red Hat 4.4.7-11) (GCC) ) #1 SMP Wed Oct 15 04:27:16 UTC 2014
Command line: ro root=/dev/mapper/vg_server-lv_root rd_LVM_LV=vg_server/lv_swap rd_NO_LUKS rd_LVM_LV=vg_server/lv_root rd_NO_MD crashkernel=auto  KEYBOARDTYPE=pc KEYTABLE=jp106 LANG=ja_JP.UTF-8 rd_NO_DM rhgb quiet
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
Disabled fast string operations
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009ec00 (usable)
（略）
```

## systemdについて

### ユニットでの管理

systemdでは「ユニット」という単位でシステムを管理します。ユニットには、「ターゲット」（ランレベルに相当）ユニットや「サービス」ユニットがあり、それぞれのユニットは依存関係の定義ができるようになっています。

依存関係とは、たとえば「このサービスを実行するにはあらかじめこのサービスが実行されていなければならない」という関係です。systemdでは依存関係にないサービスを「並列処理」で実行するため、高速にシステムを起動できるという利点があります。

主なユニットの種類は以下の通りです。

| ユニット | 役割                                 |
| -------- | ------------------------------------ |
| service  | 従来のサービスと同様                 |
| target   | サービスを取りまとめるためのユニット |
| mount    | マウントポイント                     |
| swap     | スワップ領域                         |
| device   | デバイス                             |

### サービスの操作

systemdでは、サービスの起動や停止を行うのにsystemctlコマンドを使用します。

Webサービスの起動や停止、再起動、そして状態の確認を行うには、以下のsystemctlコマンドを使用します。

#### サービスの起動

systemctl startコマンドで、サービスを起動します。

```shell-session
# systemctl start httpd
```

#### サービスのステータス確認

systemctl statusコマンドで、サービスのステータスを確認できます。

systemdでは、サービスのプロセスを「コントロールグループ」（cgroup）というLinuxカーネルの仕組みで実行するように変わりました。cgroupを使うことで、CPUやメモリなどのリソースを柔軟に割り当てることができる利点があります。

```shell-session
# systemctl status httpd
httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled)
   Active: active (running) since 水 2015-01-28 15:23:50 JST; 33s ago
 Main PID: 2926 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/httpd.service
           ├─2926 /usr/sbin/httpd -DFOREGROUND
           ├─2927 /usr/sbin/httpd -DFOREGROUND
           ├─2928 /usr/sbin/httpd -DFOREGROUND
           ├─2929 /usr/sbin/httpd -DFOREGROUND
           ├─2930 /usr/sbin/httpd -DFOREGROUND
           └─2931 /usr/sbin/httpd -DFOREGROUND

 1月 28 15:23:50 centos7.example.com httpd[2926]: AH00557: httpd: apr_sockad...
 1月 28 15:23:50 centos7.example.com httpd[2926]: AH00558: httpd: Could not ...
 1月 28 15:23:50 centos7.example.com systemd[1]: Started The Apache HTTP Ser...
Hint: Some lines were ellipsized, use -l to show in full.
```

#### サービスの再起動

systemctl restartコマンドで、サービスを再起動します。

```shell-session
# systemctl restart httpd
# systemctl status httpd
httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled)
   Active: active (running) since 水 2015-01-28 15:24:40 JST; 2s ago
  Process: 2945 ExecStop=/bin/kill -WINCH ${MAINPID} (code=exited, status=0/SUCCESS)
 Main PID: 2950 (httpd)
（略）
```

#### サービスの停止

systemctl stopコマンドで、サービスを停止します。

```shell-session
# systemctl stop httpd
# systemctl status httpd
httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled)
   Active: inactive (dead)
```

### ユニット一覧の取得

systemdで管理されているユニットの一覧を取得するには、systemctl list-unit-filesコマンドを実行します。

```shell-session
# systemctl list-unit-files
```

すべての種類のユニットが表示されてしまうので、ユニットの種類を絞り込むには-tオプションを付与して実行します。

たとえば、serviceユニットだけを表示するには以下のsystemctlコマンドを実行します。

```shell-session
# systemctl list-unit-files -t service
```

表示されるステータス（STATE）の意味は以下の通りです。

| ステータス | 意味                                     |
| ---------- | ---------------------------------------- |
| enabled    | システム起動時に実行される               |
| disabled   | システム起動時に実行されない             |
| static     | システム起動時の実行の有無は設定できない |

### 現在のユニットの状況を確認

現在のユニットの状況を確認するには、systemctl list-unitsコマンドを実行します。systemctlコマンドのデフォルトはこのサブコマンドの指定になっています。

以下の例は同じ結果を返します。

```shell-session
# systemctl list-units
# systemctl
```

-tオプションを使って、serviceユニットだけに絞り込むこともできます。

```shell-session
# systemctl -t service
UNIT                         LOAD   ACTIVE SUB     DESCRIPTION
abrt-ccpp.service            loaded active exited  Install ABRT coredump hook
abrt-oops.service            loaded active running ABRT kernel log watcher
abrt-xorg.service            loaded active running ABRT Xorg log watcher
abrtd.service                loaded active running ABRT Automated Bug Reporting
alsa-state.service           loaded active running Manage Sound Card State (rest
atd.service                  loaded active running Job spooling tools
（略）
kdump.service                loaded failed failed  Crash recovery kernel arming
（略）
```

表示の意味は以下の通りです。

| 項目        | 意味                                                                            |
| ----------- | ------------------------------------------------------------------------------- |
| UNIT        | ユニット名                                                                      |
| LOAD        | systemdへの設定の読み込み状況                                                   |
| ACTIVE      | 実行状態の概要。activeかinactiveで表される                                      |
| SUB         | 実行状態の詳細。running（実行中）やexited（実行したが終了した）などで表される。 |
| DESCRIPTION | ユニットの説明                                                                  |

デフォルトでは、項目ACTIVEの実行状態がactiveになっているもののみが表示されています。inactiveのユニットも表示するには--allオプションを付与して実行します。

項目LOADは、systemctl maskコマンドで無効化されるとmaskedに変わります。詳細は後述します。

項目ACTIVEがfailedになっていると、何らかの原因で起動失敗しているということになります。上記の例では、kdump（カーネルダンプ）サービスの起動に失敗しています。

### デバイス一覧の確認

-t deviceオプションを付与して、デバイス一覧を表示します。

```shell-session
# systemctl list-units -t device
UNIT                                                                                     LOAD   ACTIVE SUB     DESCRIPTION
sys-devices-pci0000:00-0000:00:05.0-virtio0-net-eth0.device                              loaded active plugged Virtio network device
sys-devices-pci0000:00-0000:00:1f.2-ata3-host2-target2:0:0-2:0:0:0-block-sda-sda1.device loaded active plugged CentOS_7-0_SSD
（略）
```

### マウント状況の確認

-t mountオプションを付与して、マウントの状況一覧を表示します。

```shell-session
# systemctl list-units -t mount
UNIT                         LOAD   ACTIVE SUB     DESCRIPTION
-.mount                      loaded active mounted /
boot.mount                   loaded active mounted /boot
dev-hugepages.mount          loaded active mounted Huge Pages File System
dev-mqueue.mount             loaded active mounted POSIX Message Queue File Syst
home.mount                   loaded active mounted /home
（略）
```

### スワップ状況の確認

-t swapオプションを付与して、スワップの状況一覧を表示します。

```shell-session
# systemctl list-units -t swap
UNIT             LOAD   ACTIVE SUB    DESCRIPTION
dev-dm¥x2d0.swap loaded active active /dev/dm-0
（略）
```

### サービスの自動起動の設定

システム起動時にサービスを自動起動するには、systemctl enableコマンドを実行します。

例として、Webサービスをシステム起動時に自動起動するように設定します。/usr/lib/systemd/system/httpd.serviceがWebサービスの起動スクリプトです。systemctl enableコマンドを実行すると、/etc/systemd/system/multi-user.target.wantsディレクトリにシンボリックリンクが作成されます。

この動作は、multi-user.targetターゲットユニットが呼び出された時に、シンボリックリンクの起動スクリプトが実行されるように設定しています。

```shell-session
# systemctl enable httpd
ln -s '/usr/lib/systemd/system/httpd.service' '/etc/systemd/system/multi-user.target.wants/httpd.service'
```

システム起動時の自動起動を行わないようにするには、systemctl disableコマンドを実行します。作成されたシンボリックリンクが削除され、起動スクリプトは呼び出されなくなります。

```shell-session
# systemctl disable httpd
rm '/etc/systemd/system/multi-user.target.wants/httpd.service'
```

### サービスのsystemdからの除外

systemctl maskコマンドを実行すると、指定したサービスがsystemdの管理から除外され、手動での起動も行えなくなります。

動作としては、/etc/systemd/system/httpd.serviceが/dev/nullへのシンボリックリンクとして作成され、この起動スクリプトが呼び出されても何も行われなくなります。

Webサービスをsystemdから除外します。

```shell-session
# systemctl mask httpd
ln -s '/dev/null' '/etc/systemd/system/httpd.service'
# systemctl start httpd
Failed to issue method call: Unit httpd.service is masked.
```

systemctl is-enabledコマンドで、サービスの状態が確認できます。httpdサービスの状態はmaskedとなっています。

```shell-session
# systemctl is-enabled httpd
masked
```

systemctl unmaskコマンドを実行すると、シンボリックリンクが削除されて、指定したサービスがsystemdで管理されるようになります。httpdサービスの状態はdisabledになります。

```shell-session
# systemctl unmask httpd
rm '/etc/systemd/system/httpd.service'
# systemctl is-enabled httpd
disabled
```

### systemdのサービスに関連するディレクトリとシステム起動の仕組み

systemdが内部的にどのような仕組みになっているのか、関連するディレクトリを解説します。

systemctl enableコマンドの動作を見ても分かる通り、systemdの仕組みにおいて、関連するディレクトリは以下の2つです。

#### /usr/lib/systemd/systemディレクトリ

サービス起動スクリプトが格納されています。/etc/rc.d/init.dディレクトリに相当します。

#### /etc/systemd/systemディレクトリ

サービス起動スクリプトに対するシンボリックリンクが配置されます。/etc/rc.dディレクトリに相当します。

システム起動時のsystemdの動作は、/etc/systemd/systemディレクトリ以下のサブディレクトリ内に作成されたサービス起動スクリプトへのシンボリックリンクが順次実行されてサービスが起動されます。シンボリックリンクの作成される場所は、役割別のターゲットユニット毎にディレクトリが分けられています。

ターゲット毎のディレクトリとその役割、実行の順番は以下の通りです。

#### 1. /etc/systemd/system/sysinit.target.wants/

システムの初期に実行されるスクリプトです。rc.sysinitスクリプトに相当します。

#### 2. /etc/systemd/system/basic.target.wants/

システム共通に実行されるスクリプトです。

#### 3. /etc/systemd/system/multi-user.target.wants/

従来のランレベル3（CUI）に相当します。

#### 4. /etc/systemd/system/graphical.target.wants/

従来のランレベル5（GUI）に相当します。

systemdではmulti-user.targetを実行後にgraphical.targetが実行されるようになっています。

どこまで実行するかは、次に説明するデフォルトターゲットの設定によって決められています。

### デフォルトターゲットの変更

systemdではランレベルではなく、サービス起動スクリプトを順番に実行していき、デフォルトターゲットで指定されたターゲットまで実行します。デフォルトターゲットを変更することで、CUI起動をするか、GUI起動にするかを選択できます。

デフォルトターゲットの変更は、systemctl set-defaultコマンドを実行します。

#### デフォルトターゲットの確認

systemctl get-defaultコマンドで、現在のデフォルトターゲットを確認します。

```shell-session
# systemctl get-default
graphical.target
```

#### デフォルトターゲットをCUIに変更

デフォルトターゲットをmulti-user.targetに変更し、再起動します。CUIで起動してくることを確認します。

```shell-session
# systemctl set-default multi-user.target
# reboot
```

#### デフォルトターゲットをGUIに変更

GUIでの起動に戻すには、以下のsystemctl set-defaultコマンドを実行します。

```shell-session
# systemctl set-default graphical.target
# reboot
```

### 現在のターゲットの一時的な変更

systemdでの現在のターゲットを一時的に変更するには、systemctl isolateコマンドを実行します。

GUIからCUIに変更します。GUIログインしている場合、ログアウトします。

```shell-session
# systemctl isolate multi-user.target
```

CUIからGUIに変更します。

```shell-session
# systemctl isolate graphical.target
```

### anacron によるジョブの実行

cronを使って決められた時刻に一斉にcronジョブを実行すると、システムの負荷が集中してしまう欠点があります。特にクラウド環境において同じ時刻にcronジョブが実行されてしまうと、CPUやメモリ、I/Oなどの共有リソースを複数の仮想マシンが一斉に取り合うことになります。
そこでanacronを使ってジョブを実行すると、ジョブが実行されるタイミングがランダムに決められるので、ジョブ実行が同時発生しないようになります。

anacronで実行させたいジョブはシェルスクリプトとして作成し、実行したい時間間隔に応じて以下の表のディレクトリ内に配置します。シェルスクリプトのファイルを配置するだけでジョブが定期実行されるようになるので、定期実行するジョブをパッケージのインストール時に簡単に登録できるというメリットもあります。

| 実行する時間間隔 | ディレクトリ      |
| ---------------- | ----------------- |
| 1日おき          | /etc/cron.daily   |
| 1週間おき        | /etc/cron.weekly  |
| 1ヶ月おき        | /etc/cron.monthly |

### anacronの設定

anacronは、1時間おきにcrondから起動されます。起動時に設定ファイルとして/etc/anacrontabを読み込み、実行が必要なジョブを実行します。

デフォルトの設定ファイルは以下の通りです。

```shell-session
# cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron

# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# the maximal random delay added to the base delay of the jobs
RANDOM_DELAY=45
# the jobs will be started during the following hours only
START_HOURS_RANGE=3-22

#period in days   delay in minutes   job-identifier   command
1       5       cron.daily              nice run-parts /etc/cron.daily
7       25      cron.weekly             nice run-parts /etc/cron.weekly
@monthly 45     cron.monthly            nice run-parts /etc/cron.monthly
```

ジョブの実行頻度は、ジョブ設定の最初の数字で実行間隔を日数で記述します。デフォルトでは1日おきと7日おきのジョブが設定されています。1ヶ月毎の設定のように、実行間隔の設定は数値以外にマクロが用意されています。

| マクロ   | 設定値       |
| -------- | ------------ |
| @daily   | 1（毎日1回） |
| @weekly  | 7（毎週1回） |
| @monthly | 毎月1回      |

各ジョブは、それぞれの基準遅延時間に最大45分のランダムに決められた遅延時間（RANDOM_DELAY）を足して実行されます。基準遅延時間は、ジョブ定義の2番目の数字です。デフォルトでは、1日おきのジョブが5分、1週間おきのジョブが25分、1ヶ月おきのジョブが45分です。仮想マシン間で同時にジョブが実行されないようにしたい場合には、基準遅延時間を大きくずらす必要があります。

anacronがジョブを実行するのは、START_HOURS_RANGEで設定されている3時から22時の間です。anacronはシステムが停止していた場合、実行していなかったジョブを再起動後に実行する仕組みがあります。そのため、このようにジョブ実行時間が広く指定されています。
ただし、この設定では日中でもジョブが実行される可能性があります。もし、夜間にだけジョブを実行したい場合には、/etc/anacrontabに以下のように指定するといいでしょう。ここでは夜間の23時から翌日の朝6時までを指定しています。

```
START_HOURS_RANGE=23-6
```

## NTPによる時刻管理

コンピューターの時刻は、意外と精度が低く1日ごとに数秒狂っていきます。しかも、電源OFFにした状態だとさらに狂いやすくなります。認証やデータベース、ログを集中管理するような環境の場合には、この時刻のずれが大きな問題になる場合があります。

システムの時刻を合わせる仕組みとして、NTP（Network Time Protocol）があります。NTPを利用することで、ネットワーク上のNTPサーバから時刻を取得し、システムの時刻を正確な時刻に合わせる事ができます。

### NTPサービスのインストール

NTPクライアントに対して時刻を提供するNTPサーバを実行するには、NTPサービスをインストールします。NTPサービスは、NTPサーバとしての機能と、自分自身の時刻をNTPサーバに同期させるNTPクライアントの機能の両方を備えています。

NTPサービスがインストールされていない場合には、yumコマンドでインストールします。

```shell-session
# yum install ntp
```

### NTPサービスの起動と自動起動の有効化

NTPサービス（ntpd）を起動します。

```shell-session
# service ntpd start
```

chkconfigコマンドで自動起動を有効化します。

```shell-session
# chkconfig ntpd on
# chkconfig --list ntpd
ntpd            0:off   1:off   2:off   3:on    4:off   5:off   6:off
```

NTPサーバを起動してから、しばらくすると上位のNTPサーバと時刻同期が始まります。時刻同期は徐々に行われるため、すぐには完了しません。

### 上位NTPサーバの設定

同期する時刻を提供してくれる上位NTPサーバの設定は/etc/ntp.confに記述します。サーバは複数指定できます。CentOSでは、デフォルトでpool.ntp.orgのNTPサーバに同期するように設定されています。pool.ntp.orgはインターネット上のNTPサーバのアドレスをランダムに返すようになっています。

```
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst
server 3.centos.pool.ntp.org iburst
```

ntpqコマンドを実行して、外部のNTPサーバとの時刻同期の状態を確認します。

```shell-session
# ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
*219x123x70x91.a 192.168.7.123    2 u  424 1024  377    2.296   -0.851   1.985
-balthasar.gimas 65.32.162.194    3 u  764 1024  377    4.574    3.282   1.737
+ntp-v6.chobi.pa 61.114.187.55    2 u  960 1024  337    1.012    0.546   1.170
+the.platformnin 22.42.17.250     3 u   46 1024  377    3.686    0.123   2.642
```

一番左に表示されているステータスの読み方は以下の通りです。

| 表示             | 意味                                             |
| ---------------- | ------------------------------------------------ |
| \*               | 同期している                                     |
| +                | いつでも同期可能                                 |
| x                | クロックが不正確なため無効                       |
| 空白（スペース） | 使用不可（通信不可、同期に時間が掛かっている等） |

### NTPクライアントからの時刻同期リクエストの制御

NTPサービスは、デフォルトではNTPクライアントからの時刻同期リクエストを受け付けないように設定されています。

以下の例では、NTPサーバの設定ファイル/etc/ntp.confに「192.168.0.0/255.255.255.0」のネットワークに属しているNTPクライアントからの時刻同期リクエストを許可するように設定しています。

```shell-session
# vi /etc/ntp.conf

# Hosts on local network are less restricted.
#restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap
※restrict 192.168.0.0 mask 255.255.255.0 nomodify notrap ←この行を追加
```

設定を変更したらntpサービスを再起動します。

```shell-session
# service ntpd restart
ntpd を停止中:                                             [  OK  ]
ntpd を起動中:                                             [  OK  ]
```

### ファイアーウォールの設定変更

NTPサーバはUDPのポート番号123番でNTPクライアントからの時刻同期リクエストを待ち受けています。iptablesでパケットフィルタリングを行っている場合、ルールを追加する必要があります。

/etc/sysconfig/iptablesを編集してルールを追加し、iptablesサービスをリロードします。

```shell-session
# vi /etc/sysconfig/iptables

# Firewall configuration written by system-config-firewall
# Manual customization of this file is not recommended.
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
※-A INPUT -m state --state NEW -m udp -p udp --dport 123 -j ACCEPT ←この行を追加※
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
```

serviceコマンドで、iptablesサービスをリロードします。

```shell-session
# service iptables reload
iptables: Trying to reload firewall rules:                 [  OK  ]
# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
（略）
ACCEPT     udp  --  anywhere             anywhere            state NEW udp dpt:ntp
REJECT     all  --  anywhere             anywhere            reject-with icmp-host-prohibited
（略）
```

### NTPクライアントのNTPサービスを使ってNTPサーバと時刻を同期する

クライアントのNTPサービスは、/etc/ntp.confにserver設定で指定されたNTPサーバと時刻同期を行います。

クライアントで、デフォルトで設定されているpool.ntp.orgのserver設定をコメントアウトし、構築したNTPサーバ（192.168.0.10）と時刻を同期するように設定します。

クライアントにNTPサービスがインストールされていない場合には、yumコマンドでインストールします。

```shell-session
[root@client ~]# yum install ntp
[root@client ~]# vi /etc/ntp.conf

※#※server 0.centos.pool.ntp.org iburst ※←行頭でコメントアウト
※#※server 1.centos.pool.ntp.org iburst ※←行頭でコメントアウト
※#※server 2.centos.pool.ntp.org iburst ※←行頭でコメントアウト
※#※server 3.centos.pool.ntp.org iburst ※←行頭でコメントアウト
※server 192.168.0.10 iburst ←この行を追加
```

クライアントのNTPサービスを再起動します。

```shell-session
# service ntpd restart
ntpd を停止中:                                             [  OK  ]
ntpd を起動中:                                             [  OK  ]
```

ntpqコマンドで、時刻同期の状態を確認します。

```shell-session
[root@client ~]# ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
*server          157.7.154.29     3 u    2   64    1    0.152    0.108   0.007
```
