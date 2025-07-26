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

```
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

|ユニット|役割|
|-------|-------|
|service|従来のサービスと同様|
|target|サービスを取りまとめるためのユニット|
|mount|マウントポイント|
|swap|スワップ領域|
|device|デバイス|

### サービスの操作
systemdでは、サービスの起動や停止を行うのにsystemctlコマンドを使用します。

Webサービスの起動や停止、再起動、そして状態の確認を行うには、以下のsystemctlコマンドを使用します。

#### サービスの起動
systemctl startコマンドで、サービスを起動します。

```
# systemctl start httpd
```

#### サービスのステータス確認
systemctl statusコマンドで、サービスのステータスを確認できます。

systemdでは、サービスのプロセスを「コントロールグループ」（cgroup）というLinuxカーネルの仕組みで実行するように変わりました。cgroupを使うことで、CPUやメモリなどのリソースを柔軟に割り当てることができる利点があります。

```
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

```
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

```
# systemctl stop httpd
# systemctl status httpd
httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled)
   Active: inactive (dead)
```

### ユニット一覧の取得
systemdで管理されているユニットの一覧を取得するには、systemctl list-unit-filesコマンドを実行します。

```
# systemctl list-unit-files
```

すべての種類のユニットが表示されてしまうので、ユニットの種類を絞り込むには-tオプションを付与して実行します。

たとえば、serviceユニットだけを表示するには以下のsystemctlコマンドを実行します。

```
# systemctl list-unit-files -t service
```

表示されるステータス（STATE）の意味は以下の通りです。


|ステータス|意味|
|-------|-------|
|enabled|システム起動時に実行される|
|disabled|システム起動時に実行されない|
|static|システム起動時の実行の有無は設定できない|

### 現在のユニットの状況を確認
現在のユニットの状況を確認するには、systemctl list-unitsコマンドを実行します。systemctlコマンドのデフォルトはこのサブコマンドの指定になっています。

以下の例は同じ結果を返します。

```
# systemctl list-units
# systemctl
```

-tオプションを使って、serviceユニットだけに絞り込むこともできます。

```
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

|項目|意味|
|-------|-------|
|UNIT|ユニット名|
|LOAD|systemdへの設定の読み込み状況|
|ACTIVE|実行状態の概要。activeかinactiveで表される|
|SUB|実行状態の詳細。running（実行中）やexited（実行したが終了した）などで表される。|
|DESCRIPTION|ユニットの説明|

デフォルトでは、項目ACTIVEの実行状態がactiveになっているもののみが表示されています。inactiveのユニットも表示するには--allオプションを付与して実行します。

項目LOADは、systemctl maskコマンドで無効化されるとmaskedに変わります。詳細は後述します。

項目ACTIVEがfailedになっていると、何らかの原因で起動失敗しているということになります。上記の例では、kdump（カーネルダンプ）サービスの起動に失敗しています。

### デバイス一覧の確認
-t deviceオプションを付与して、デバイス一覧を表示します。

```
# systemctl list-units -t device
UNIT                                                                                     LOAD   ACTIVE SUB     DESCRIPTION
sys-devices-pci0000:00-0000:00:05.0-virtio0-net-eth0.device                              loaded active plugged Virtio network device
sys-devices-pci0000:00-0000:00:1f.2-ata3-host2-target2:0:0-2:0:0:0-block-sda-sda1.device loaded active plugged CentOS_7-0_SSD
（略）
```

### マウント状況の確認
-t mountオプションを付与して、マウントの状況一覧を表示します。

```
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

```
# systemctl list-units -t swap
UNIT             LOAD   ACTIVE SUB    DESCRIPTION
dev-dm¥x2d0.swap loaded active active /dev/dm-0
（略）
```

### サービスの自動起動の設定
システム起動時にサービスを自動起動するには、systemctl enableコマンドを実行します。

例として、Webサービスをシステム起動時に自動起動するように設定します。/usr/lib/systemd/system/httpd.serviceがWebサービスの起動スクリプトです。systemctl enableコマンドを実行すると、/etc/systemd/system/multi-user.target.wantsディレクトリにシンボリックリンクが作成されます。

この動作は、multi-user.targetターゲットユニットが呼び出された時に、シンボリックリンクの起動スクリプトが実行されるように設定しています。

```
# systemctl enable httpd
ln -s '/usr/lib/systemd/system/httpd.service' '/etc/systemd/system/multi-user.target.wants/httpd.service'
```

システム起動時の自動起動を行わないようにするには、systemctl disableコマンドを実行します。作成されたシンボリックリンクが削除され、起動スクリプトは呼び出されなくなります。

```
# systemctl disable httpd
rm '/etc/systemd/system/multi-user.target.wants/httpd.service'
```

### サービスのsystemdからの除外
systemctl maskコマンドを実行すると、指定したサービスがsystemdの管理から除外され、手動での起動も行えなくなります。

動作としては、/etc/systemd/system/httpd.serviceが/dev/nullへのシンボリックリンクとして作成され、この起動スクリプトが呼び出されても何も行われなくなります。

Webサービスをsystemdから除外します。

```
# systemctl mask httpd
ln -s '/dev/null' '/etc/systemd/system/httpd.service'
# systemctl start httpd
Failed to issue method call: Unit httpd.service is masked.
```

systemctl is-enabledコマンドで、サービスの状態が確認できます。httpdサービスの状態はmaskedとなっています。

```
# systemctl is-enabled httpd
masked
```

systemctl unmaskコマンドを実行すると、シンボリックリンクが削除されて、指定したサービスがsystemdで管理されるようになります。httpdサービスの状態はdisabledになります。

```
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

```
# systemctl get-default
graphical.target
```

#### デフォルトターゲットをCUIに変更
デフォルトターゲットをmulti-user.targetに変更し、再起動します。CUIで起動してくることを確認します。

```
# systemctl set-default multi-user.target
# reboot
```

#### デフォルトターゲットをGUIに変更
GUIでの起動に戻すには、以下のsystemctl set-defaultコマンドを実行します。

```
# systemctl set-default graphical.target
# reboot
```

### 現在のターゲットの一時的な変更
systemdでの現在のターゲットを一時的に変更するには、systemctl isolateコマンドを実行します。

GUIからCUIに変更します。GUIログインしている場合、ログアウトします。

```
# systemctl isolate multi-user.target
```

CUIからGUIに変更します。

```
# systemctl isolate graphical.target
```

## systemdのタイマーによるジョブのスケジュール実行
システムのメンテナンスなどで定期的にプロセスを実行するには、systemdのタイマーを使います。

## 有効なタイマーの一覧


linuc@localhost:/usr/lib/systemd/system$ systemctl list-timers
NEXT                            LEFT LAST                          PASSED UNIT                         ACTIVATES
Sat 2025-06-28 16:03:42 JST    31min Sat 2025-06-28 15:07:02 JST        - fwupd-refresh.timer          fwupd-refresh.service
Sat 2025-06-28 16:05:11 JST    32min -                                  - dnf-makecache.timer          dnf-makecache.service
Sun 2025-06-29 00:00:00 JST       8h -                                  - sysstat-rotate.timer         sysstat-rotate.service
Sun 2025-06-29 00:27:55 JST       8h Sat 2025-06-28 14:50:20 JST        - logrotate.timer              logrotate.service
Sun 2025-06-29 00:39:12 JST       9h Sat 2025-06-28 14:50:20 JST        - plocate-updatedb.timer       plocate-updatedb.service
Sun 2025-06-29 01:00:00 JST       9h Wed 2025-06-25 15:08:20 JST        - raid-check.timer             raid-check.service
Sun 2025-06-29 15:24:09 JST      23h Sat 2025-06-28 15:24:09 JST 8min ago systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
Mon 2025-06-30 00:50:21 JST 1 day 9h Wed 2025-06-25 16:09:18 JST        - fstrim.timer                 fstrim.service

8 timers listed.
Pass --all to see loaded but inactive timers, too.

タイマーの確認をするには、systemctl statusコマンドを使います。ログのローテーションを行うlogrotate.timerの状態を確認してみます。

linuc@localhost:/usr/lib/systemd/system$ systemctl status logrotate.timer
Warning: The unit file, source configuration file or drop-ins of logrotate.timer changed on disk. Run 'systemctl daemon-reload' to reload units.
● logrotate.timer - Daily rotation of log files
     Loaded: loaded (/usr/lib/systemd/system/logrotate.timer; enabled; preset: enabled)
     Active: active (waiting) since Sat 2025-06-28 15:09:21 JST; 26min ago
 Invocation: 9e94ba61ce2847eda12b927a0f467346
    Trigger: Sun 2025-06-29 00:27:55 JST; 8h left
   Triggers: ● logrotate.service
       Docs: man:logrotate(8)
             man:logrotate.conf(5)

 6月 28 15:09:21 localhost systemd[1]: Started logrotate.timer - Daily rotation of log files.

設定ファイルの内容を確認するには、sysmctl catコマンドを使います。

llinuc@localhost:~$ sudo systemctl cat logrotate.timer
# /usr/lib/systemd/system/logrotate.timer
[Unit]
Description=Daily rotation of log files
Documentation=man:logrotate(8) man:logrotate.conf(5)

[Timer]
OnCalendar=daily
RandomizedDelaySec=1h
Persistent=true

[Install]
WantedBy=timers.target

[Timer]セクションがスケジュール実行を定義しています。OnCalendarが実行するタイミングを指定しています。dailyは毎日0時を意味しています。このようなキーワードでの指定の他、時間や実行間隔などを指定することもできます。RandomizedDelaySecは、複数のタイマーがdailyなど同じスケジュールを指定していて同時実行されるとシステムに大きな負荷がかかるのを避けるため、ランダムに指定された値を上限に遅延を入れて実行します。1hが指定されているので最大60分（1時間）の遅延を入れて実行することになります。先ほど確認したタイマーの状態のうちTriggerが実際に実行される予定の時刻を表していますが、00:27:55に実行される予定になっています。Persistentは、このタイマーを実行するタイミングにシステムが停止していた時、再度システムが起動した際の挙動を定義しています。trueに設定されていると、再度のシステム起動時にこのタイマーを実行します。

## タイマーで実行されるサービス
タイマーで実行されるサービスは同一の名前のサービスになります。実行内容はsystemctl catコマンドを使って確認できます。

linuc@localhost:~$ systemctl cat logrotate.service
# /usr/lib/systemd/system/logrotate.service
[Unit]
Description=Rotate log files
Documentation=man:logrotate(8) man:logrotate.conf(5)
RequiresMountsFor=/var/log
ConditionACPower=true

[Service]
Type=oneshot
ExecStart=/usr/sbin/logrotate /etc/logrotate.conf
（略）

サービスの定義ファイルは、タイマーの定義ファイル同様、/usr/lib/systemd/systemディレクトリに配置されているのがわかります。



## anacron によるジョブの実行 
cronを使って決められた時刻に一斉にcronジョブを実行すると、システムの負荷が集中してしまう欠点があります。特にクラウド環境において同じ時刻にcronジョブが実行されてしまうと、CPUやメモリ、I/Oなどの共有リソースを複数の仮想マシンが一斉に取り合うことになります。
そこでanacronを使ってジョブを実行すると、ジョブが実行されるタイミングがランダムに決められるので、ジョブ実行が同時発生しないようになります。

anacronで実行させたいジョブはシェルスクリプトとして作成し、実行したい時間間隔に応じて以下の表のディレクトリ内に配置します。シェルスクリプトのファイルを配置するだけでジョブが定期実行されるようになるので、定期実行するジョブをパッケージのインストール時に簡単に登録できるというメリットもあります。

|実行する時間間隔|ディレクトリ|
|-------|-------|
|1日おき|/etc/cron.daily|
|1週間おき|/etc/cron.weekly|
|1ヶ月おき|/etc/cron.monthly|

### anacronの設定
anacronは、1時間おきにcrondから起動されます。起動時に設定ファイルとして/etc/anacrontabを読み込み、実行が必要なジョブを実行します。

デフォルトの設定ファイルは以下の通りです。

```
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

|マクロ|設定値|
|-------|-------|
|@daily|1（毎日1回）|
|@weekly|7（毎週1回）|
|@monthly|毎月1回|

各ジョブは、それぞれの基準遅延時間に最大45分のランダムに決められた遅延時間（RANDOM_DELAY）を足して実行されます。基準遅延時間は、ジョブ定義の2番目の数字です。デフォルトでは、1日おきのジョブが5分、1週間おきのジョブが25分、1ヶ月おきのジョブが45分です。仮想マシン間で同時にジョブが実行されないようにしたい場合には、基準遅延時間を大きくずらす必要があります。

anacronがジョブを実行するのは、START_HOURS_RANGEで設定されている3時から22時の間です。anacronはシステムが停止していた場合、実行していなかったジョブを再起動後に実行する仕組みがあります。そのため、このようにジョブ実行時間が広く指定されています。
ただし、この設定では日中でもジョブが実行される可能性があります。もし、夜間にだけジョブを実行したい場合には、/etc/anacrontabに以下のように指定するといいでしょう。ここでは夜間の23時から翌日の朝6時までを指定しています。

```
START_HOURS_RANGE=23-6
```

## NTPによる時刻合わせ
NTP（Network Time Protocol）はマシンなどの時刻を合わせるためのプロトコルです。Linuxでは、Linuxが動作しているマシンの時刻を合わせるNTPクライアントとしての動作と、その他のマシンなどに時刻同期を提供するNTPサーバーとしての動作があります。クライアントの数が多い場合、外部のNTPサーバーに大きな負荷をかけないよう、ローカルのNTPサーバーを用意してこのサーバーのみ外部のNTPサーバーと時刻同期し、内部のクライアントはローカルNTPサーバーと時刻同期させるようにするとよいでしょう。

### Chronyの動作確認
AlmaLinuxでは、NTPサーバー/NTPクライアントとしてChronyが使われており、chronydというサービスとして扱われます。Chronyはデフォルトで起動しているので、動作している様子を確認します。
```
# systemctl status chronyd
● chronyd.service - NTP client/server
     Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; preset: enabled)
     Active: active (running) since Tue 2025-01-28 07:32:57 JST; 8h left
       Docs: man:chronyd(8)
             man:chrony.conf(5)
    Process: 821 ExecStart=/usr/sbin/chronyd $OPTIONS (code=exited, status=0/SUCCESS)
   Main PID: 867 (chronyd)
      Tasks: 1 (limit: 10118)
     Memory: 4.2M
        CPU: 40ms
     CGroup: /system.slice/chronyd.service
             └─867 /usr/sbin/chronyd -F 2
 1月 28 07:32:57 localhost chronyd[867]: chronyd version 4.5 starting (+CMDMON +NTP +REFCLOCK +RTC +PRIV>
 1月 28 07:32:57 localhost chronyd[867]: Loaded 0 symmetric keys
 1月 28 07:32:57 localhost chronyd[867]: Using right/UTC timezone to obtain leap second data
 1月 28 07:32:57 localhost chronyd[867]: Frequency -276.346 +/- 80.978 ppm read from /var/lib/chrony/dri>
 1月 28 07:32:57 localhost chronyd[867]: Loaded seccomp filter (level 2)
 1月 28 07:32:57 localhost systemd[1]: Started NTP client/server.
 1月 28 07:33:07 localhost.localdomain chronyd[867]: Selected source 45.76.218.37 (2.almalinux.pool.ntp.>
 1月 28 07:33:07 localhost.localdomain chronyd[867]: System clock wrong by -32400.283303 seconds
 1月 27 22:33:06 localhost.localdomain chronyd[867]: System clock was stepped by -32400.283303 seconds
 1月 27 22:33:06 localhost.localdomain chronyd[867]: System clock TAI offset set to 37 seconds
```
この環境は仮想マシンで動作させていますが、起動時のログを見てみると、最初は朝7時32分として起動していますが、NTPが外部のNTPサーバーと時刻同期し、9時間巻き戻って夜の22時33分に時刻を設定し直しているのがわかります。

### 参照しているNTPサーバーの確認
次に時刻同期のために参照しているNTPサーバーを確認します。クライアントとしての動作はchronycコマンドを使って操作します。

```
# chronyc sources
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* ipv4.ntp3.rbauman.com         2   6   167    51   +164us[+3006us] +/-   11ms
^- 122x215x240x51.ap122.ftt>     2   6   157    50   -958us[ -958us] +/-   49ms
^- ap-northeast-1.clearnet.>     2   6   147   113  +3598us[+5467us] +/-   30ms
^- 45.159.48.231                 3   6   147   113  +4552us[+6424us] +/-  139ms
```
2桁目にある記号のうち、「\*」となっているのが現在参照しているサーバーです。NTPサーバーは様々な組織がサービスを提供しており、複数のサーバーが参照可能（記号「-」）になっているのがわかります。

ステータスの読み方は以下の通りです。1列目のM列はソースのモードを示します。
| 記号  | 意味   |
|-------|-------|
|  ^  | サーバー |
|  =  | ピア   |
|  #  | ローカル |

2列目のS列はソースの状態を示します。
| 記号  | 意味                            |
|-------|-------|
|  *  | 同期しているソース                     |
|  +  | 同期候補のソース                      |
|  -  | 同期候補から外れたソース                  |
|  ?  | 切断されたソース、パケットが全てのテストをパスしないソース |
|  x  | 偽の時計と判断したもの                   |
|  ~  | 時刻の変動性が大きすぎるソース               |

### 参照するNTPサーバーの設定を確認、変更する
Chronyの設定は「/etc/chrony.conf」に記述されています。参照するNTPサーバーをNICTが提供している「ntp.nict.jp」に変更してみます。

```
# vi /etc/chrony.conf
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (https://www.pool.ntp.org/join.html).
# pool 2.almalinux.pool.ntp.org iburst
pool ntp.nict.jp iburst
```
デフォルトではntp.orgが運営しているNTPサーバープールからランダムに参照するようになっています。ここをNICTのNTPサーバーを参照するように変更します。

#### 設定変更を適用する
変更を適用するには、chronydサービスを再起動してみます。
```
# systemctl restart chronyd
```
chronycコマンドで時刻同期の様子を確認します。

```
# chronyc sources
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^? ntp-k1.nict.jp                1   6     3     0    -20ms[  -20ms] +/- 9780us
^? ntp-b2.nict.go.jp             1   6     3     0    -20ms[  -20ms] +/-   13ms
^? ntp-a3.nict.go.jp             1   6     1     2    -21ms[  -21ms] +/-   15ms
^? ntp-b3.nict.go.jp             1   6     1     2    -21ms[  -21ms] +/-   13ms
```
記号「?」なので、まだ同期していない状態です。

```
# chronyc sources
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^+ ntp-k1.nict.jp                1   6    77    58    +14ms[  +14ms] +/-   10ms
^* ntp-b2.nict.go.jp             1   6    77    58    +13ms[  -10ms] +/-   13ms
^- ntp-a3.nict.go.jp             1   6    77    57    +10ms[  +10ms] +/-   12ms
^+ ntp-b3.nict.go.jp             1   6    77    57    +13ms[  +13ms] +/-   11ms
```
ntp-a3のみ「-」なので、3つが時刻同期可能な状態です。

```
# chronyc sources
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^+ ntp-k1.nict.jp                1   6   177    12    +21ms[  +21ms] +/-   13ms
^* ntp-b2.nict.go.jp             1   6   177    12    +27ms[  +40ms] +/-   14ms
^+ ntp-a3.nict.go.jp             1   6   177    10    +12ms[  +12ms] +/-   27ms
^+ ntp-b3.nict.go.jp             1   6   177    11    +25ms[  +25ms] +/-   14ms
```
4つすべてのNTPサーバーが時刻同期可能となりました。

Linuxが正しい時刻で動作していることは、ログの記録やファイルなどのデータの保存にとって重要なので、正しい時刻になっているようにNTPクライアントとしてきちんと動作していることを確認しておきましょう。

## NTPサーバーとして時刻を提供する
NTPサーバーは、他のクライアントに対して自身の時刻との同期をサービスとして提供します。前節はNTPサーバー自身の時刻同期について設定・確認方法を解説しました。ここではNTPサーバーとして他のクライアントの時刻同期を許可する設定を行います。

### NTPサーバー機能を有効にする
ChronyはデフォルトではNTPサーバー機能が無効になっています。設定を変更してNTPサーバーを有効にします。有効にするには、接続を許可するクライアントのIPアドレスを指定します。
```
# vi /etc/chrony.conf
（中略）
# Allow NTP client access from local network.
#allow 192.168.0.0/16
allow 192.168.156.0/24
```
デフォルトではコメントアウト状態ですが、接続を許可するIPアドレス、ここではネットワークアドレスで一括して許可するように設定しています。

設定を有効にするため、chronydサービスを再起動します。
```
# systemctl restart chronyd
```

### ファイアーウォールの設定を変更して接続を許可する
NTPはネットワークプロトコルのため、ファイアーウォールで接続の許可をする必要があります。
```
# firewall-cmd --add-service=ntp --permanent
success
# firewall-cmd --reload
success
# firewall-cmd --list-services
cockpit dhcpv6-client ntp ssh
```
### クライアントでローカルNTPサーバーにアクセスする
次にクライアントからローカルNTPサーバーにアクセスしてみます。設定方法はNTPサーバーをNICTのNTPサーバーを参照するように設定するのと同じです。
以下はクライアントのAlmalinuxでの操作です。NTPサーバーとして設定したホストのIPアドレスを指定します。
```
# vi /etc/chrony.conf
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (https://www.pool.ntp.org/join.html).
# pool 2.almalinux.pool.ntp.org iburst
server 192.168.156.137 iburst
```
NTPサーバーの参照はserverとpoolの2種類があります。serverは単一のサーバーを指定する場合、poolは名前解決で複数の結果が返る場合、最大4つまでを参照先NTPサーバーとする、という違いがあります。

設定を適用します。
```
# systemctl restart chronyd
```

動作を確認します。
```
# chronyc sources
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^? 192.168.156.137               2   6     1     2    -20ms[  -20ms] +/-  103ms

# chronyc sources
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* 192.168.156.137               2   6     7     1   -617ns[  -19ms] +/-  101ms
```
時刻が同期しました。

上記ではローカルNTPサーバーを1つだけ設定しましたが、このローカルNTPサーバーが停止するとクライアントは時刻同期ができなくなります。時刻設定がシビアな環境においては、ローカルNTPサーバーを複数用意する、ローカルが参照できない場合は一時的に外部NTPサーバーを参照させるなどいくつかの方法が考えられます。システム環境に合った設定を検討、実施するようにしてください。
