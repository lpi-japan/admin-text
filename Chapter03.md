# サービスの管理

## OSが起動するまでのプロセス
マシンに電源を入れた後、以下のような順番でシステムの初期化が行われ、OSが起動します。

1. 電源オン
1. UEFI/BIOS起動とハードウェアの初期化
1. ブートローダー（GRUB）の起動
1. Linuxカーネルイメージの読み込み
1. systemdプロセスの起動
1. 各種サービスの起動
1. OS起動完了

## ブートローダーGRUBの起動
マシンの電源をオンにすると、UEFI/BIOSが起動してハードウェアの初期化が行われ、起動に使用するブートデバイス（ハードディスクなど）が決定します。ブートデバイスからブートローダーであるGRUBが読み込まれ、起動処理が引き継がれます。
GRUBは、Linuxカーネルのイメージをメモリ上にロードする役割を持っています。

![GRUB選択画面](grubmenu.png)

Linuxカーネルイメージが複数ある場合は、GRUBのメニュー画面でロードしたいイメージを選択して、Enterキーを押します。

### GRUBの設定確認
GRUBの設定を確認したい場合には、grubbyコマンドに--info=ALLオプションをつけて実行します。

```
$ sudo grubby --info=ALL
index=0
kernel="/boot/vmlinuz-5.14.0-570.26.1.el9_6.x86_64"
args="ro crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M resume=/dev/mapper/almalinux_vbox-swap rd.lvm.lv=almalinux_vbox/root rd.lvm.lv=almalinux_vbox/swap rhgb quiet $tuned_params"
root="/dev/mapper/almalinux_vbox-root"
initrd="/boot/initramfs-5.14.0-570.26.1.el9_6.x86_64.img $tuned_initrd"
title="AlmaLinux (5.14.0-570.26.1.el9_6.x86_64) 9.6 (Sage Margay)"
id="65dd8a0b080e4373a5633404cabaac84-5.14.0-570.26.1.el9_6.x86_64"
index=1
kernel="/boot/vmlinuz-5.14.0-570.12.1.el9_6.x86_64"
args="ro crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M resume=/dev/mapper/almalinux_vbox-swap rd.lvm.lv=almalinux_vbox/root rd.lvm.lv=almalinux_vbox/swap rhgb quiet $tuned_params"
root="/dev/mapper/almalinux_vbox-root"
initrd="/boot/initramfs-5.14.0-570.12.1.el9_6.x86_64.img $tuned_initrd"
title="AlmaLinux (5.14.0-570.12.1.el9_6.x86_64) 9.6 (Sage Margay)"
id="65dd8a0b080e4373a5633404cabaac84-5.14.0-570.12.1.el9_6.x86_64"
index=2
kernel="/boot/vmlinuz-0-rescue-65dd8a0b080e4373a5633404cabaac84"
args="ro crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M resume=/dev/mapper/almalinux_vbox-swap rd.lvm.lv=almalinux_vbox/root rd.lvm.lv=almalinux_vbox/swap rhgb quiet"
root="/dev/mapper/almalinux_vbox-root"
initrd="/boot/initramfs-0-rescue-65dd8a0b080e4373a5633404cabaac84.img"
title="AlmaLinux (0-rescue-65dd8a0b080e4373a5633404cabaac84) 9.6 (Sage Margay)"
id="65dd8a0b080e4373a5633404cabaac84-0-rescue"
```

3つの設定が存在しているのがわかります。各設定項目の意味は以下の通りです。

| 項目 | 意味
| - | -
| index | ブートメニューの選択肢のインデックス番号です。
| kernel | 起動に使用するカーネルです。
| args | カーネル起動時に引き渡される値です。
| root | 起動時に参照されるルートデバイスです。
| initrd | 起動時に使用される起動RAMディスクです。
| title | ブートメニューの選択肢に表示される文字列です。
| id | マシンのユニークIDとカーネルバージョンを組み合わせた値です。

### GRUBのデフォルト起動の確認
GRUBがデフォルトで起動するカーネルの確認は、grubbyコマンドに--default-kernelオプション、または--default-indexオプションをつけて実行すると確認できます。

```
$ sudo grubby --default-kernel
/boot/vmlinuz-5.14.0-570.26.1.el9_6.x86_64
$ sudo grubby --default-index
0
```

### GRUBのデフォルト起動カーネルの変更
GRUBのデフォルト起動カーネルを変更したい場合には、grubbyコマンドに--set-defaultオプションでカーネル、またはindexの番号を指定することで変更できます。

```
$ sudo grubby --set-default /boot/vmlinuz-5.14.0-570.12.1.el9_6.x86_64
The default is /boot/loader/entries/65dd8a0b080e4373a5633404cabaac84-5.14.0-570.12.1.el9_6
.x86_64.conf with index 1 and kernel /boot/vmlinuz-5.14.0-570.12.1.el9_6.x86_64
$ sudo grubby --set-default 0
The default is /boot/loader/entries/65dd8a0b080e4373a5633404cabaac84-5.14.0-570.26.1.el9_6
.x86_64.conf with index 0 and kernel /boot/vmlinuz-5.14.0-570.26.1.el9_6.x86_64
```

## カーネルの起動
GRUBで指定されたLinuxカーネルイメージがメモリに読み込まれて、カーネルが起動します。カーネルはハードウェアを初期化し、カーネルの各種機能を有効にしていきます。

カーネルは必要に応じてモジュールを読み込みますが、モジュールは初期化RAMディスク（initramfs）に含まれています。カーネルは初期化RAMディスクをメモリに読み込み、仮のルートファイルシステムとして利用可能にすることで、必要となるモジュールのファイルが読み込めるようになります。

### dmesgによるカーネル起動時の動作の確認
カーネルが起動する際の動作の様子は、dmesgコマンドで確認できます。

```
# dmesg
I[    0.000000] Linux version 5.14.0-570.26.1.el9_6.x86_64 (mockbuild@x64-builder03.almalinux.org) (gcc (GCC) 11.5.0 20240719 (Red Hat 11.5.0-5), GNU ld version 2.35.2-63.el9) #1 SMP PREEMPT_DYNAMIC Wed Jul 16 09:12:04 EDT 2025
[    0.000000] The list of certified hardware and cloud instances for Red Hat Enterprise Linux 9 can be viewed at the Red Hat Ecosystem Catalog, https://catalog.redhat.com.
[    0.000000] Command line: BOOT_IMAGE=(hd0,gpt2)/vmlinuz-5.14.0-570.26.1.el9_6.x86_64 root=/dev/mapper/almalinux_vbox-root ro crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M resume=/dev/mapper/almalinux_vbox-swap rd.lvm.lv=almalinux_vbox/root rd.lvm.lv=almalinux_vbox/swap rhgb quiet
[    0.000000] [Firmware Bug]: TSC doesn't count with P0 frequency!
[    0.000000] BIOS-provided physical RAM map:
（略）
```

特定のデバイスが動作しないなどのトラブルは、カーネル起動時のメッセージで発生している問題を特定できることがあります。デバイス名等で検索してみるとよいでしょう。

## systemdについて
systemdは、カーネル起動後、最初に起動されるプロセスです。Linuxのシステムを構成する各種サービスの起動などを行う役目を担っています。

### ユニットでの管理
systemdでは「ユニット」という単位でシステムを管理します。ユニットには、「ターゲット」（ランレベルに相当）ユニットや「サービス」ユニットがあり、それぞれのユニットは依存関係の定義ができるようになっています。

依存関係とは、たとえば「このサービスを実行するにはあらかじめこのサービスが実行されていなければならない」という関係です。systemdでは依存関係にないサービスを並列処理で実行するため、高速にシステムを起動できるという利点があります。

主なユニットの種類は以下の通りです。

|ユニット|役割|
|-------|-------|
|service|従来のサービスと同様|
|target|サービスを取りまとめるためのユニット|
|mount|マウントポイント|
|swap|スワップ領域|
|device|デバイス|

mountユニット、swapユニット、deviceユニットは直接操作することはありません。主にserviceユニットを操作することになります。targetユニットは、システムをGUIで起動するかCUIで起動するかなどで操作する程度にしか使用しません。

### サービスの操作
systemdでは、サービスの起動や停止を行うのにsystemctlコマンドを使用します。

Webサービスの起動や停止、再起動、そして状態の確認を行うには、以下のsystemctlコマンドを使用します。

#### サービスの起動と停止、再起動
systemctl startコマンドで、サービスを起動します。systemctl stopコマンドでサービスを停止します。systemctl restartコマンドで、サービスを再起動します。


```
$ sudo systemctl start firewalld
$ sudo systemctl stop firewalld
$ sudo systemctl restart firewalld
```

#### サービスのステータス確認
systemctl statusコマンドで、サービスのステータスを確認できます。

```
$ sudo systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
     Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; preset: enabled)
     Active: active (running) since Sat 2025-07-26 15:13:03 JST; 2s ago
       Docs: man:firewalld(1)
   Main PID: 3400 (firewalld)
      Tasks: 2 (limit: 10816)
     Memory: 23.1M
        CPU: 367ms
     CGroup: /system.slice/firewalld.service
             └─3400 /usr/bin/python3 -s /usr/sbin/firewalld --nofork --nopid

 7月 26 15:13:03 vbox systemd[1]: Starting firewalld - dynamic firewall daemon...
 7月 26 15:13:03 vbox systemd[1]: Started firewalld - dynamic firewall daemon.
```

### ユニット一覧の取得
systemdで管理されているユニットの一覧を取得するには、systemctl list-unit-filesコマンドを実行します。

```
$ systemctl list-unit-files
UNIT FILE                                  STATE           PRESET
proc-sys-fs-binfmt_misc.automount          static          -
-.mount                                    generated       -
boot-efi.mount                             generated       -
boot.mount                                 generated       -
dev-hugepages.mount                        static          -
dev-mqueue.mount                           static          -
proc-sys-fs-binfmt_misc.mount              disabled        disabled
（略）
systemd-sysupdate-reboot.timer             disabled        disabled
systemd-sysupdate.timer                    disabled        disabled
systemd-tmpfiles-clean.timer               static          -

427 unit files listed.
```

すべての種類のユニットが表示されてしまうので、ユニットの種類を絞り込むには-tオプションを付与して実行します。

たとえば、serviceユニットだけを表示するには以下のsystemctlコマンドを実行します。

```
$ systemctl list-unit-files -t service
UNIT FILE                                  STATE           PRESET
accounts-daemon.service                    enabled         enabled
alsa-restore.service                       static          -
alsa-state.service                         static          -
（略）
```

表示されるステータス（STATE）の意味は以下の通りです。

|ステータス|意味|
|-------|-------|
|enabled|システム起動時に実行される|
|disabled|システム起動時に実行されない|
|static|システム起動時の実行の有無は設定できない|
|generated|systemdが生成したユニット|

### 現在のユニットの状況を確認
現在のユニットの状況を確認するには、systemctl list-unitsコマンドを実行します。systemctlコマンドのデフォルトはこのサブコマンドの指定になっています。

以下の例は同じ結果を返します。

```
$ systemctl list-units
$ systemctl
```

-tオプションを使って、serviceユニットだけに絞り込むこともできます。

```
$ systemctl -t service
  UNIT                    LOAD   ACTIVE SUB     DESCRIPTION
  accounts-daemon.service loaded active running Accounts Service
  alsa-state.service      loaded active running Manage Sound Card State (restore and store)
  atd.service             loaded active running Deferred execution scheduler
  auditd.service          loaded active running Security Auditing Service
（略）
● mcelog.service         loaded failed failed  Machine Check Exception Logging Daemon
（略）

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.
58 loaded units listed. Pass --all to see loaded but inactive units, too.
To show all installed unit files use 'systemctl list-unit-files'.
```

表示の意味は以下の通りです。

|項目|意味|
|-------|-------|
|UNIT|ユニット名|
|LOAD|systemdへの設定の読み込み状況|
|ACTIVE|実行状態の概要。activeかinactiveで表される|
|SUB|実行状態の詳細。running（実行中）やexited（実行したが終了した）などで表される。|
|DESCRIPTION|ユニットの説明|

デフォルトでは、項目ACTIVEの実行状態がactiveになっているもののみが表示されています。inactiveのユニットも表示するには--allオプションをつけて実行します。

項目LOADは、systemctl maskコマンドで無効化されるとmaskedに変わります。詳細は後述します。

項目ACTIVEがfailedになっていると、何らかの原因で起動失敗しているということになります。上記の例では、mcelogサービスの起動に失敗しています。

### デバイス一覧の確認
-t deviceオプションを付与して、デバイス一覧を表示します。

```
$ systemctl list-units -t device
  UNIT                                                                                     LOAD   ACTIVE SUB     DESCRIPTION                              >
  sys-devices-pci0000:00-0000:00:01.1-ata2-host2-target2:0:0-2:0:0:0-block-sr0
.device      loaded active plugged VBOX_CD-ROM
  sys-devices-pci0000:00-0000:00:03.0-net-enp0s3.device                                    loaded active plugged 82540EM Gigabit Ethernet Controller (PRO/>
  sys-devices-pci0000:00-0000:00:05.0-sound-card0-controlC0.device                         loaded active plugged /sys/devices/pci0000:00/0000:00:05.0/soun>
  sys-devices-pci0000:00-0000:00:08.0-net-enp0s8.device                                    loaded active plugged 82540EM Gigabit Ethernet Controller (PRO/>
（略）
```

### マウント状況の確認
-t mountオプションを付与して、マウントの状況一覧を表示します。

```
$ systemctl list-units -t mount
  UNIT                    LOAD   ACTIVE SUB     DESCRIPTION
  -.mount                 loaded active mounted Root Mount
  boot-efi.mount          loaded active mounted /boot/efi
  boot.mount              loaded active mounted /boot
  dev-hugepages.mount     loaded active mounted Huge Pages File System
（略）
```

### スワップ状況の確認
-t swapオプションを付与して、スワップの状況一覧を表示します。

```
$ systemctl list-units -t swap
  UNIT                                   LOAD   ACTIVE SUB    DESCRIPTION
  dev-mapper-almalinux_vbox\x2dswap.swap loaded active active /dev/mapper/almalinux_vbox-swap
（略）
```

### サービスの自動起動の設定
システム起動時にサービスを自動起動するには、systemctl enableコマンドを実行します。自動起動しないようにするにはsystemctl disableコマンドを実行します。

例として、firewalldをシステム起動時に自動起動するように設定します。すでにデフォルトで自動起動する設定のため、一度systemctl disableコマンドを実行した後、systemctl enableコマンドを実行します。

```
$ sudo systemctl disable firewalld
Removed "/etc/systemd/system/multi-user.target.wants/firewalld.service".
Removed "/etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service".
$ sudo systemctl enable firewalld
Created symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service → /usr/lib/systemd/system/firewalld.service.
Created symlink /etc/systemd/system/multi-user.target.wants/firewalld.service → /usr/lib/systemd/system/firewalld.service.
```

/usr/lib/systemd/system/firewalld.serviceがWebサービスの起動スクリプトです。systemctl enableコマンドを実行すると、/etc/systemd/system/multi-user.target.wantsディレクトリにシンボリックリンクが作成されます。

この動作は、multi-user.targetターゲットユニットが呼び出された時に、シンボリックリンクの起動スクリプトが実行されるように設定しています。

systemctl disableコマンドを実行すると、作成されたシンボリックリンクが削除され、起動スクリプトは呼び出されなくなります。

### サービスのsystemdからの除外
systemctl maskコマンドを実行すると、指定したサービスがsystemdの管理から除外され、手動での起動も行えなくなります。

動作としては、/etc/systemd/system/httpd.serviceが/dev/nullへのシンボリックリンクとして作成され、この起動スクリプトが呼び出されても何も行われなくなります。

Webサービスをsystemdから除外します。

```
$ sudo systemctl mask firewalld
Created symlink /etc/systemd/system/firewalld.service → /dev/null.
$ sudo systemctl start firewalld
Failed to start firewalld.service: Unit firewalld.service is masked.
```

systemctl is-enabledコマンドで、サービスの状態が確認できます。httpdサービスの状態はmaskedとなっています。

```
$ sudo systemctl is-enabled firewalld
masked
```

systemctl unmaskコマンドを実行すると、シンボリックリンクが削除されて、指定したサービスがsystemdで管理されるようになります。httpdサービスの状態はdisabledになります。

```
$ sudo systemctl unmask firewalld
Removed "/etc/systemd/system/firewalld.service".
$ sudo systemctl is-enabled firewalld
enabled
```

### systemdのサービスに関連するディレクトリとシステム起動の仕組み
systemdが内部的にどのような仕組みになっているのか、関連するディレクトリを解説します。

systemctl enableコマンドの動作を見ても分かる通り、systemdの仕組みにおいて、関連するディレクトリは以下の2つです。

* /usr/lib/systemd/systemディレクトリ
サービス起動スクリプトが格納されています。

* /etc/systemd/systemディレクトリ
サービス起動スクリプトに対するシンボリックリンクが配置されます。

システム起動時のsystemdの動作は、/etc/systemd/systemディレクトリ以下のサブディレクトリ内に作成されたサービス起動スクリプトへのシンボリックリンクが順次実行されてサービスが起動されます。シンボリックリンクの作成される場所は、役割別のターゲットユニット毎にディレクトリが分けられています。

ターゲット毎のディレクトリとその役割、実行の順番は以下の通りです。

1. /etc/systemd/system/sysinit.target.wants/
システムの初期に実行されるスクリプトです。rc.sysinitスクリプトに相当します。

2. /etc/systemd/system/basic.target.wants/
システム共通に実行されるスクリプトです。

3. /etc/systemd/system/multi-user.target.wants/
CUI起動の状態です。

4. /etc/systemd/system/graphical.target.wants/
GUI起動の状態です。

systemdではmulti-user.targetを実行後にgraphical.targetが実行されるようになっています。

どこまで実行するかは、次に説明するデフォルトターゲットの設定によって決められています。

### デフォルトターゲットの変更
systemdではランレベルではなく、サービス起動スクリプトを順番に実行していき、デフォルトターゲットで指定されたターゲットまで実行します。デフォルトターゲットを変更することで、CUI起動をするか、GUI起動にするかを選択できます。

デフォルトターゲットの変更は、systemctl set-defaultコマンドを実行します。

#### デフォルトターゲットの確認
systemctl get-defaultコマンドで、現在のデフォルトターゲットを確認します。

```
$ systemctl get-default
graphical.target
```

#### デフォルトターゲットをCUIに変更
デフォルトターゲットをmulti-user.targetに変更し、再起動します。CUIで起動してくることを確認します。

```
$ sudo systemctl set-default multi-user.target
Created symlink /etc/systemd/system/default.target → /usr/lib/systemd/system/multi-user.target.
$ sudo reboot
```

システムが再起動すると、CUIで起動し、ログインプロンプトが表示されます。

#### デフォルトターゲットをGUIに変更
GUIでの起動に戻すには、以下のsystemctl set-defaultコマンドを実行します。

```
$ sudo systemctl set-default graphical.target
Created symlink /etc/systemd/system/default.target → /usr/lib/systemd/system/graphical.target.
$ sudo reboot
```

システムが再起動すると、GUIで起動し、ユーザー選択画面が表示されます。

### 現在のターゲットの一時的な変更
systemdでの現在のターゲットを一時的に変更するには、systemctl isolateコマンドを実行します。

GUIからCUIに変更します。GUIログインしている場合、ログアウトします。

```
$ sudo systemctl isolate multi-user.target
```

CUIからGUIに変更します。

```
$ sudo systemctl isolate graphical.target
```

## systemdのタイマーによるジョブのスケジュール実行
システムのメンテナンスなどで定期的にプロセスを実行するには、systemdのタイマーを使います。

### 有効なタイマーの一覧


```
$ systemctl list-timers
NEXT                        LEFT       LAST                        PASSED    UNIT                         ACTIVATES
Sat 2025-07-26 16:11:27 JST 13min left -                           -         systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
Sat 2025-07-26 16:48:06 JST 50min left -                           -         dnf-makecache.timer          dnf-makecache.service
Sun 2025-07-27 00:00:00 JST 8h left    Sat 2025-07-26 14:58:27 JST 59min ago logrotate.timer              logrotate.service
Sun 2025-07-27 00:00:00 JST 8h left    Sat 2025-07-26 14:58:27 JST 59min ago mlocate-updatedb.timer       mlocate-updatedb.service

4 timers listed.
Pass --all to see loaded but inactive timers, too.
```

タイマーの確認をするには、systemctl statusコマンドを使います。ログのローテーションを行うlogrotate.timerの状態を確認してみます。

```
$ systemctl status logrotate.timer
● logrotate.timer - Daily rotation of log files
     Loaded: loaded (/usr/lib/systemd/system/logrotate.timer; enabled; preset: enabled)
     Active: active (waiting) since Sat 2025-07-26 15:56:31 JST; 1min 50s ago
      Until: Sat 2025-07-26 15:56:31 JST; 1min 50s ago
    Trigger: Sun 2025-07-27 00:00:00 JST; 8h left
   Triggers: ● logrotate.service
       Docs: man:logrotate(8)
             man:logrotate.conf(5)

 7月 26 15:56:31 localhost systemd[1]: Started Daily rotation of log files.
```

設定ファイルの内容を確認するには、systemctl catコマンドを使います。

```
$ sudo systemctl cat logrotate.timer
# /usr/lib/systemd/system/logrotate.timer
[Unit]
Description=Daily rotation of log files
Documentation=man:logrotate(8) man:logrotate.conf(5)

[Timer]
OnCalendar=daily
AccuracySec=1h
Persistent=true

[Install]
WantedBy=timers.target
```

最初に、このタイマーで実行されるサービスの定義ファイルが/usr/lib/systemd/system/logrotate.timerであることが分かります。

[Timer]セクションがスケジュール実行を定義しています。OnCalendarが実行するタイミングを指定しています。dailyは毎日0時を意味しています。このようなキーワードでの指定の他、時間や実行間隔などを指定することもできます。

AccuracySecは、タイマーの精度を指定しています。精度を高くすると、頻繁にタイマーを制御するためCPU実行が必要となり消費電力が上がります。デフォルトは1m（1分）ですが、ここではあまり高い精度は必要ない設定を行っています。

Persistentは、このタイマーを実行するタイミングにシステムが停止していた時、再度システムが起動した際の挙動を定義しています。trueに設定されていると、再度のシステム起動時にこのタイマーを実行します。

## NTPによる時刻合わせ
NTP（Network Time Protocol）はマシンなどの時刻を合わせるためのプロトコルです。Linuxでは、Linuxが動作しているマシンの時刻を合わせるNTPクライアントとしての動作と、その他のマシンなどに時刻同期を提供するNTPサーバーとしての動作があります。クライアントの数が多い場合、外部のNTPサーバーに大きな負荷をかけないよう、ローカルのNTPサーバーを用意してこのサーバーのみ外部のNTPサーバーと時刻同期し、内部のクライアントはローカルNTPサーバーと時刻同期させるようにするとよいでしょう。

### Chronyの動作確認
AlmaLinuxでは、NTPサーバー/NTPクライアントとしてChronyが使われており、chronydというサービスとして扱われます。Chronyはデフォルトで起動しているので、動作している様子を確認します。

```
$ systemctl status chronyd
● chronyd.service - NTP client/server
     Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; preset: enabled)
     Active: active (running) since Sat 2025-07-26 16:20:42 JST; 8s ago
       Docs: man:chronyd(8)
             man:chrony.conf(5)
    Process: 750 ExecStart=/usr/sbin/chronyd $OPTIONS (code=exited, status=0/SUCCESS)
   Main PID: 785 (chronyd)
      Tasks: 1 (limit: 10816)
     Memory: 4.1M
        CPU: 47ms
     CGroup: /system.slice/chronyd.service
             └─785 /usr/sbin/chronyd -F 2

 7月 26 16:20:42 localhost chronyd[785]: chronyd version 4.6.1 starting (+CMDMON +NTP +REFCLOCK +RTC +PRIVDROP +SCFILTER +SIGND +ASYNCDNS +NTS +SECHASH +I>
 7月 26 16:20:42 localhost chronyd[785]: Loaded 0 symmetric keys
 7月 26 16:20:42 localhost chronyd[785]: Using right/UTC timezone to obtain leap second data
 7月 26 16:20:42 localhost chronyd[785]: Frequency -8.088 +/- 0.231 ppm read from /var/lib/chrony/drift
 7月 26 16:20:42 localhost chronyd[785]: Loaded seccomp filter (level 2)
 7月 26 16:20:42 localhost systemd[1]: Started NTP client/server.
 7月 26 16:20:48 vbox chronyd[785]: Selected source 139.162.81.45 (2.almalinux.pool.ntp.org)
 7月 26 16:20:48 vbox chronyd[785]: System clock wrong by -1.974025 seconds
 7月 26 16:20:46 vbox chronyd[785]: System clock was stepped by -1.974025 seconds
 7月 26 16:20:46 vbox chronyd[785]: System clock TAI offset set to 37 seconds
```

ログを見てみると、起動時の時間が約2秒ほどずれており、時間が2秒ほど巻き戻されているのがタイムスタンプでも分かります。

### 参照しているNTPサーバーの確認
次に時刻同期のために参照しているNTPサーバーを確認します。クライアントとしての動作はchronycコマンドを使って操作します。

```
$ chronyc sources
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* old-tok2.jp.ntp.li            3   6    77    45  -1598us[-1688us] +/-   26ms
^+ time.cloudflare.com           3   6    77    46    +24us[  -67us] +/-   63ms
^+ time.cloudflare.com           3   6    77    44  +1973us[+1973us] +/-   61ms
^+ pred-374.chl.la               3   6    77    44   +873us[ +873us] +/-   24ms
```

2桁目にある記号のうち、「*」となっているのが現在参照しているNTPサーバーです。NTPサーバーは様々な組織がサービスを提供しており、複数のサーバーが参照可能（記号「+」）になっているのがわかります。

ステータスの読み方は以下の通りです。1列目のM列はソースのモードを示します。

| 記号  | 意味   |
|-------|-------|
|  ^  | サーバー |
|  =  | ピア   |
|  #  | ローカル |

2列目のS列はソースの状態を示します。

| 記号  | 意味 |
|-------|-------|
|  *  | 同期しているソース |
|  +  | 同期候補のソース |
|  -  | 同期候補から外れたソース |
|  ?  | 切断されたソース、パケットが全てのテストをパスしないソース |
|  x  | 偽の時計と判断したもの |
|  ~  | 時刻の変動性が大きすぎるソース |

### 参照するNTPサーバーの設定を確認、変更する
Chronyの設定は「/etc/chrony.conf」に記述されています。参照するNTPサーバーをNICTが提供している「ntp.nict.jp」に変更してみます。

```
$ sudo vi /etc/chrony.conf
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (https://www.pool.ntp.org/join.html).
# pool 2.almalinux.pool.ntp.org iburst
pool ntp.nict.jp iburst
```
デフォルトではntp.orgが運営しているNTPサーバープールからランダムに参照するようになっています。この設定をコメントアウトして無効にし、NICTのNTPサーバーを参照するように設定を追加します。

#### 設定変更を適用する
変更を適用するには、chronydサービスを再起動してみます。

```
$ sudo systemctl restart chronyd
```

chronycコマンドで時刻同期の様子を確認します。

```
# chronyc sources
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^? ntp-a3.nict.go.jp             1   6     3     2   -441us[ -441us] +/- 4866us
^? 2001:ce8:78::2                1   6     3     1  +2926ns[+2926ns] +/- 9113us
^? ntp-b3.nict.go.jp             1   6     3     2    -33us[  -33us] +/- 4379us
^? ntp-a2.nict.go.jp             1   6     3     1   -285us[ -285us] +/- 4682us
```

記号「?」なので、まだ同期していない状態です。

```
# chronyc sources
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^- ntp-a3.nict.go.jp             1   6     7     1   +356us[  -68us] +/- 4295us
^- 2001:ce8:78::2                1   6     7     0   -827us[-1251us] +/-   10ms
^+ ntp-b3.nict.go.jp             1   6     7     1   +281us[ -143us] +/- 4552us
^* ntp-a2.nict.go.jp             1   6     7     0   -105us[ -529us] +/- 4624us
```

ntp-a2と同期し、ntp-b3も時刻同期可能な状態です。

```
# chronyc sources
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^+ ntp-a3.nict.go.jp             1   6    17    53   +369us[ +534us] +/- 4276us
^+ 2001:ce8:78::2                1   6    17    52  -1092us[ -927us] +/-   10ms
^+ ntp-b3.nict.go.jp             1   6    17    53   -238us[  -73us] +/- 4827us
^* ntp-a2.nict.go.jp             1   6    17    52   +268us[ +433us] +/- 4123us
```

4つすべてのNTPサーバーが時刻同期可能となりました。

Linuxが正しい時刻で動作していることは、ログの記録やファイルなどのデータの保存にとって重要なので、正しい時刻になっているようにNTPクライアントとしてきちんと動作していることを確認しておきましょう。

## NTPサーバーとして時刻を提供する
NTPサーバーは、他のクライアントに対して自身の時刻との同期をサービスとして提供します。

### NTPサーバー機能を有効にする
ChronyはデフォルトではNTPサーバー機能が無効になっています。設定を変更してNTPサーバーを有効にします。有効にするには、接続を許可するクライアントのIPアドレスを指定します。
```
$ sudo vi /etc/chrony.conf
（中略）
# Allow NTP client access from local network.
#allow 192.168.0.0/16
allow 192.168.56.0/24
```
allowディレクティブはデフォルトではコメントアウト状態ですが、接続を許可するIPアドレス、ここではネットワークアドレスで一括して許可するように設定しています。

設定を有効にするため、chronydサービスを再起動します。
```
# systemctl restart chronyd
```

### ファイアーウォールの設定を変更して接続を許可する
NTPはネットワークプロトコルのため、ファイアーウォールで接続の許可をする必要があります。

```
$ sudo firewall-cmd --add-service=ntp --permanent
success
$ sudo firewall-cmd --reload
success
$ sudo firewall-cmd --list-services
cockpit dhcpv6-client ntp ssh
```

### クライアントでNTPサーバーにアクセスする
次にクライアントからNTPサーバーにアクセスしてみます。

以下は別途クライアント用として用意したAlmalinuxでの操作です。NTPサーバーとして設定したサーバーのIPアドレスを指定します。

```
$ sudo vi /etc/chrony.conf
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (https://www.pool.ntp.org/join.html).
# pool 2.almalinux.pool.ntp.org iburst
server 192.168.56.101 iburst
```
NTPサーバーの参照はserverとpoolの2種類があります。serverは単一のサーバーを指定する場合、poolは名前解決で複数の結果が返る場合、最大4つまでを参照先NTPサーバーとする、という違いがあります。

設定を適用します。

```
$ sudo systemctl restart chronyd
```

動作を確認します。

```
$ chronyc sources
MMS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* 192.168.56.101                2   6    17     1  +1842ns[  +11us] +/- 4560us
```

時刻が同期しました。

NTPサーバーを1つだけ設定しましたが、NTPサーバーが停止するとクライアントは時刻同期ができなくなります。時刻設定がシビアな環境においては、NTPサーバーを複数用意する、用意したNTPサーバーが参照できない場合は一時的に外部NTPサーバーを参照させるなどいくつかの方法が考えられます。システム環境に合った設定を検討、実施するようにしてください。

\pagebreak

