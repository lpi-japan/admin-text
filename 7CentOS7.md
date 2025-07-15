# CentOS 7への移行

## CentOS 7への移行

本教科書ではCentOS 6を使って解説をしてきましたが、現在では新しいバージョンであるCentOS 7もリリースされています。

CentOS 7へのバージョンアップ後も基本的な運用管理の知識は大きくは変わりませんが、CentOS 7で大きく変更になった以下の点について解説します。

- SysV initからsystemdへの移行
- journaldによるログ記録
- firewalldによるパケットフィルタリング

また、変更されたわけではありませんが、ネットワークはNetworkManagerがCentOS 6と変わらず標準なので、CUIのNetworkManager用のツールであるnmtuiを紹介します。

## SysV initからsystemdへの移行

CentOS 7から、これまでのサービス管理であるSysV init、またはUpstartからLinux向けの新しいサービス管理マネージャーである「systemd」に置き換えられました。/etc/rc.dディレクトリ以下のサービス起動スクリプトを使う方式から改められました。

簡単にsystemdでのサービス管理について解説します。

### ユニットでの管理

従来ランレベルやサービスと呼ばれていた仕組みは、systemdでは「ユニット」として再定義されました。ユニットには、「ターゲット」（ランレベルに相当）ユニットや「サービス」ユニットがあり、それぞれのユニットは依存関係の定義ができるようになっています。

依存関係とは、たとえば「このサービスを実行するにはあらかじめこのサービスが実行されていなければならない」という関係です。従来のSysV initではサービスには依存関係が無かったため、サービスを順番に実行するという方法で依存関係を解消していました。しかし、実行の順番を保証するために1つずつ実行する「順列処理」となるため、システム起動が遅くなるという難点がありました。

systemdでは依存関係にないサービスを「並列処理」で実行するため、高速にシステムを起動できるという利点があります。

主なユニットの種類は以下の通りです。

| ユニット | 役割                                 |
| -------- | ------------------------------------ |
| service  | 従来のサービスと同様                 |
| target   | サービスを取りまとめるためのユニット |
| mount    | マウントポイント                     |
| swap     | スワップ領域                         |
| device   | デバイス                             |

### サービスの操作

systemdでは、サービスの起動や停止を行うのにsystemctlコマンドを使用します。これは従来のserviceコマンドに相当します。

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

たとえば、serviceユニットだけを表示するには以下のsystemctlコマンドを実行します。これは従来のchkconfig --listコマンドに相当します。

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
dev-dm\x2d0.swap loaded active active /dev/dm-0
（略）
```

### サービスの自動起動の設定

システム起動時にサービスを自動起動するには、systemctl enableコマンドを実行します。これは従来のchkconfigコマンドに相当します。

例として、Webサービスをシステム起動時に自動起動するように設定します。/usr/lib/systemd/system/httpd.serviceがWebサービスの起動スクリプトです。systemctl enableコマンドを実行すると、/etc/systemd/system/multi-user.target.wantsディレクトリにシンボリックリンクが作成されます。

この動作は、multi-user.targetターゲットユニットが呼び出された時に、シンボリックリンクの起動スクリプトが実行されるように設定しています。SysV initにおける/etc/init.dディレクトリ内のサービス起動スクリプトと/etc/rc.dディレクトリ内にランレベル毎に作成されるシンボリックリンクの関係に相当します。

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

SysV initではランレベル3とランレベル5は別々の扱いでしたが、systemdではmulti-user.targetを実行後にgraphical.targetが実行されるようになっています。

どこまで実行するかは、次に説明するデフォルトターゲットの設定によって決められています。

### デフォルトターゲットの変更

systemdではランレベルではなく、サービス起動スクリプトを順番に実行していき、デフォルトターゲットで指定されたターゲットまで実行します。デフォルトターゲットを変更することで、CUI起動をするか、GUI起動にするかを選択できます。

デフォルトターゲットの変更は、systemctl set-defaultコマンドを実行します。これは、SysV initの設定ファイル/etc/inittabで指定している起動時ランレベル（initdefault）の変更に相当します。

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

systemdでの現在のターゲットを一時的に変更するには、systemctl isolateコマンドを実行します。これは、SysV initのランレベル変更（telinitコマンド）に相当します。

GUIからCUIに変更します。GUIログインしている場合、ログアウトします。

```shell-session
# systemctl isolate multi-user.target
```

CUIからGUIに変更します。

```shell-session
# systemctl isolate graphical.target
```

## journaldによるログ記録

systemdにはサービスなどからのログを記録するjournaldが用意されており、syslogとは別にログが記録されています。

### journaldのログの確認

journaldのログを確認するには、journalctlコマンドを実行します。オプションを付与しないで実行すると、すべてのログが表示されます。

以下の例では、dmesgコマンドで確認できるLinuxカーネル起動時のログが記録されているのが分かります。

```shell-session
# journalctl
-- Logs begin at 水 2015-01-28 17:29:04 JST, end at 水 2015-01-28 17:29:38 JST.
 1月 28 17:29:04 centos7.example.com systemd-journal[149]: Runtime journal is us
 1月 28 17:29:04 centos7.example.com systemd-journal[149]: Runtime journal is us
（略）
```

特定のサービスのログに絞るには、-uオプションを付与して実行します。

以下の例では、httpdサービス起動時のログが確認できます。

```shell-session
# journalctl -u httpd
-- Logs begin at 水 2015-01-28 17:29:04 JST, end at 水 2015-01-28 17:31:34 JST.
 1月 28 17:31:28 centos7.example.com systemd[1]: Starting The Apache HTTP Server
 1月 28 17:31:34 centos7.example.com httpd[2232]: AH00557: httpd: apr_sockaddr_i
 1月 28 17:31:34 centos7.example.com httpd[2232]: AH00558: httpd: Could not reli
 1月 28 17:31:34 centos7.example.com systemd[1]: Started The Apache HTTP Server.
```

### journaldのログの保存

journaldのログは、再起動すると消えてしまう設定がデフォルトとなっています。journaldの設定ファイル/etc/systemd/journald.confのStorage設定の値がデフォルトではautoに設定されています。この設定は、以下のように動作します。

1. /var/log/journalディレクトリが存在すれば書き込む
1. /var/log/journalディレクトリが存在しないか、書き込めない場合には、/run/log/journalディレクトリに書き込む

デフォルトでは/var/log/journalディレクトリは存在しないため、/run/log/journalディレクトリにログが書き込まれます。/run/log/journalディレクトリはtmpfsでメモリ上に作られた一時領域なので、システム再起動時にログのファイルは消えてしまいます。

journaldのログをシステム再起動時に消えないようにするには、以下のように/var/log/journalディレクトリを作成して、システムを再起動します。

```shell-session
# mkdir /var/log/journal
# chmod 700 /var/log/journal
# reboot
```

ログファイルが作成されたことを確認します

```shell-session
# ls -l /var/log/journal/
合計 0
drwxr-sr-x. 2 root systemd-journal 49  1月 28 14:53 3b71b9857a284561a3450996bf78a306
# ls -l /var/log/journal/3b71b9857a284561a3450996bf78a306/
合計 16392
-rw-r-----. 1 root root            8388608  1月 28 14:56 system.journal
-rw-r-----+ 1 root systemd-journal 8388608  1月 28 14:55 user-42.journal
```

## firewalld によるパケットフィルタリング

CentOS 7では、Linuxカーネルのパケットフィルタリングの仕組みであるiptablesをfirewalldサービスが管理しています。firewalldを利用すると複雑なパケットフィルタリングを実現できますが、ここでは基本的な設定を解説します。

また、複雑な設定が不要な場合には従来のiptablesサービスによる管理に戻すこともできます。

### firewalld の設定確認

firewalldでは、パケットフィルタリングの設定を「ゾーン」という仕組みで管理しています。

ゾーンを指定しなかった場合に利用されるデフォルトゾーンを確認するには、firewall-cmdコマンドに--get-default-zoneオプションを付与して実行します。デフォルトではpublicというゾーンが利用されるのが分かります。

```shell-session
# firewall-cmd --get-default-zone
public
```

デフォルトゾーンpublicの設定を確認します。DHCPクライアントとSSHが許可されています。

```shell-session
# firewall-cmd --list-all
public (default, active)
  interfaces: eth0
  sources:
  services: dhcpv6-client ssh
  ports:
  masquerade: no
  forward-ports:
  icmp-blocks:
  rich rules:
```

デフォルトゾーンで許可されているサービスだけを確認するには、--list-servicesオプションを付与します。

```shell-session
# firewall-cmd --list-services
dhcpv6-client ssh
```

定義されているサービスを確認します。ここで確認できるサービスをゾーンに適用することで、受信パケットを許可できます。

```shell-session
# firewall-cmd --get-services
amanda-client bacula bacula-client dhcp dhcpv6 dhcpv6-client dns ftp high-availability http https imaps ipp ipp-client ipsec kerberos kpasswd ldap ldaps libvirt libvirt-tls mdns mountd ms-wbt mysql nfs ntp openvpn pmcd pmproxy pmwebapi pmwebapis pop3s postgresql proxy-dhcp radius rpc-bind samba samba-client smtp ssh telnet tftp tftp-client transmission-client vnc-server wbem-https
```

### firewalld でHTTPを許可する

firewalldの設定を変更して、HTTPの受信を許可します。

--add-serviceオプションで定義されているサービスをゾーンに適用します。

--permanentオプションを付与すると、ゾーンの設定ファイルである/etc/firewalld/zones/public.xmlが修正されて、システム再起動後でもHTTPの受信が許可されるようになります。

```shell-session
# firewall-cmd --add-service=http  --permanent
success
# firewall-cmd --list-services
dhcpv6-client http ssh
# cat /etc/firewalld/zones/public.xml
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name="dhcpv6-client"/>
  <service name="http"/>
  <service name="ssh"/>
</zone>
```

Webサービスを起動し、外部からWebサーバに接続できることを確認します。

```shell-session
# systemctl start httpd
```

### iptables を有効にする

firewalldサービスを停止し、iptablesサービスを有効にするには以下のコマンドを実行します。

```shell-session
# systemctl stop firewalld
# systemctl disable firewalld
# systemctl enable iptables
# systemctl start iptables
```

firewalld サービスを有効に戻すには、以下のコマンドを実行します。

```shell-session
# systemctl stop iptables
# systemctl disable iptables
# systemctl enable firewalld
# systemctl start firewalld
```

\*NetworkManager用管理ツール nmtui
CentOS 7でも引き続きNetworkManagerを使ってネットワークを管理します。

NetworkManagerでは、設定ファイルを直接編集することは推奨されていません。GUIとCUI用の管理ツールが提供されているので、ツールを使って設定を変更します。

![GUIのNetworkManager設定画面](nmtui1.png)

GUIでは「システムツール」メニューから「設定」を実行することでネットワークの設定も行えます。

![CUIのNetworkManager設定画面](nmtui2.png)

CUIではnmtuiを実行することで、簡単にネットワークが設定できます。ネットワークインターフェースのIPアドレス等の設定や、有効／無効の切り替えも行えるようになっています。
