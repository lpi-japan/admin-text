# ネットワークの管理

## ネットワークインターフェイスの設定
ネットワークインターフェースには、IPアドレスなどネットワーク通信のための各種設定が必要となります。ネットワーク環境に合わせて設定を変更します。

### ipコマンドを使ったネットワークインターフェースの設定
ipコマンドは、ネットワークインターフェースの状態の確認や設定、ルーティングテーブルの表示や追加、削除、ARPテーブルの確認や削除など、ネットワークにおける操作全般を行うことができます。

### ネットワーク設定の確認
IPアドレスやMACアドレスの確認にはip address showコマンドを実行します。ip aコマンドに省略可能です。

```
$ ip address show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:e6:fe:4c brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 73888sec preferred_lft 73888sec
    inet6 fd17:625c:f037:2:a00:27ff:fee6:fe4c/64 scope global dynamic noprefixroute
       valid_lft 86313sec preferred_lft 14313sec
    inet6 fe80::a00:27ff:fee6:fe4c/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:40:b7:96 brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.101/24 brd 192.168.56.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe40:b796/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

enp0s3がVirtualBoxのNATに設定されたアダプター、enp0s8がホストオンリーに設定されたアダプターです。

### ルーティングテーブル、デフォルトゲートウェイの確認
ルーティングテーブルの確認を行うにはip route showコマンドを実行します。ip rコマンドに省略可能です。これは従来のrouteコマンドに相当します。

```
$ ip route show
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 metric 100
192.168.56.0/24 dev enp0s8 proto kernel scope link src 192.168.56.101 metric 101
```

defaultになっている行がデフォルトゲートウェイの設定です。この例では、10.0.2.2がネットワークインターフェースenp0s3から通信する場合のデフォルトゲートウェイとして設定されています。192.168.56.0/24は、ホストオンリーで外部とは通信できないネットワークなのでゲートウェイが設定されていません。

### ARPテーブルの確認
ARPテーブルの確認を行うにはip neighbor showコマンドを実行します。neighborはneighに省略できます。

```
$  ip neigh show
10.0.2.3 dev enp0s3 lladdr 52:55:0a:00:02:03 STALE
10.0.2.2 dev enp0s3 lladdr 52:55:0a:00:02:02 REACHABLE
fe80::2 dev enp0s3 lladdr 52:56:00:00:00:02 router STALE
```

## ssコマンドを使った設定確認
ssコマンドはLinuxの通信ソケットの状態を確認するコマンドです。確認する対象をネットワークインターフェースに指定することで、ネットワークの各種状態を確認できます。よく使用するオプションは以下の通りです。

|オプション|説明|
|-------|-------|
|-t|TCPの情報を表示|
|-u|UDPの情報を表示|
|-l|LISTENしているポートの情報を表示|
|-a|すべての接続を表示|
|-n|コンピューター名の名前解決をせずにIPアドレスで表示|
|-i|ネットワークインターフェースの統計情報を表示|
|-4|IPv4だけを表示|
|-6|IPv6だけを表示|

### TCP通信の状態の表示
すべてのTCP通信の状態を表示したい場合には、ss -tanコマンドを実行します。TCP、すべて、名前解決をしない、を指定するオプションです。

```
$ ss -tan
State                      Recv-Q                     Send-Q                                           Local Address:Port                                             Peer Address:Port
LISTEN                     0                          128                                                    0.0.0.0:22                                                    0.0.0.0:*
LISTEN                     0                          4096                                                 127.0.0.1:631                                                   0.0.0.0:*
LISTEN                     0                          25                                                     0.0.0.0:514                                                   0.0.0.0:*
ESTAB                      0                          0                                               192.168.56.101:22                                               192.168.56.1:50396
LISTEN                     0                          128                                                       [::]:22                                                       [::]:*
LISTEN                     0                          4096                                                     [::1]:631                                                      [::]:*
LISTEN                     0                          25                                                        [::]:514                                                      [::]:*
```

いくつかの待ち受けポートの他、SSHで接続しているのが分かります。

### 待ち受けTCPポートの表示
待ち受けているすべてのTCPのポートを表示したい場合には、ss -tlコマンドを実行します。TCP、待ち受けです。ポート番号は/setc/servicesを参照して書き換えられています。

```
$ ss -tl
State                       Recv-Q                      Send-Q                                           Local Address:Port                                            Peer Address:Port
LISTEN                      0                           128                                                    0.0.0.0:ssh                                                  0.0.0.0:*
LISTEN                      0                           4096                                                 127.0.0.1:ipp                                                  0.0.0.0:*
LISTEN                      0                           25                                                     0.0.0.0:shell                                                0.0.0.0:*
LISTEN                      0                           128                                                       [::]:ssh                                                     [::]:*
LISTEN                      0                           4096                                                     [::1]:ipp                                                     [::]:*
LISTEN                      0                           25                                                        [::]:shell                                                   [::]:*
```

### 待ち受けUDPポートの表示
待ち受けているすべてのUDPのポートを表示したい場合には、ss -ulコマンドを実行します。

```
$ ss -ul
State                  Recv-Q                  Send-Q                                                        Local Address:Port                                            Peer Address:Port
UNCONN                 0                       0                                                                   0.0.0.0:43085                                                0.0.0.0:*
UNCONN                 0                       0                                                                   0.0.0.0:mdns                                                 0.0.0.0:*
UNCONN                 0                       0                                                                 127.0.0.1:323                                                  0.0.0.0:*
UNCONN                 0                       0                                                                   0.0.0.0:syslog                                               0.0.0.0:*
UNCONN                 0                       0                                                                      [::]:mdns                                                    [::]:*
UNCONN                 0                       0                                                                     [::1]:323                                                     [::]:*
UNCONN                 0                       0                                                                      [::]:syslog                                                  [::]:*
UNCONN                 0                       0                                        [fe80::6704:7f74:b962:8c5e]%enp0s9:dhcpv6-client                                           [::]:*
UNCONN                 0                       0                                                                      [::]:57956                                                   [::]:*
```

## ping コマンドを使用した疎通の確認
リモートのホストにIPのパケットが到達できるか確認するためにはpingコマンドを実行します。Ctrl+Cを実行するまで無制限に実行されます。

```
$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 バイト応答 送信元 8.8.8.8: icmp_seq=1 ttl=255 時間=8.47ミリ秒
64 バイト応答 送信元 8.8.8.8: icmp_seq=2 ttl=255 時間=8.29ミリ秒
64 バイト応答 送信元 8.8.8.8: icmp_seq=3 ttl=255 時間=8.95ミリ秒
^C
--- 8.8.8.8 ping 統計 ---
送信パケット数 3, 受信パケット数 3, 0% packet loss, time 1998ms
rtt min/avg/max/mdev = 8.294/8.572/8.954/0.279 ms
```

-c オプションで実行回数を指定できます。以下の例では、5回だけ疎通確認を行っています。

```
$ ping -c 5 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 バイト応答 送信元 8.8.8.8: icmp_seq=1 ttl=255 時間=8.80ミリ秒
64 バイト応答 送信元 8.8.8.8: icmp_seq=2 ttl=255 時間=8.71ミリ秒
64 バイト応答 送信元 8.8.8.8: icmp_seq=3 ttl=255 時間=8.35ミリ秒
64 バイト応答 送信元 8.8.8.8: icmp_seq=4 ttl=255 時間=8.47ミリ秒
64 バイト応答 送信元 8.8.8.8: icmp_seq=5 ttl=255 時間=8.61ミリ秒

--- 8.8.8.8 ping 統計 ---
送信パケット数 5, 受信パケット数 5, 0% packet loss, time 4009ms
rtt min/avg/max/mdev = 8.351/8.589/8.798/0.161 ms
```

pingコマンドはICMPプロトコルを使いますので、経路の途中にあるルーターやファイアーウォールなどでICMPプロトコルがブロックされていると、pingコマンドを実行してもうまく結果が返ってこない場合があります。また、対象となるリモートのホストがpingコマンドに反応を返さない場合もあります。

レスポンス結果(RTT)の目安としては、同じネットワークセグメント上のホストの場合は1ms(ミリ秒)以内、国内のインターネット上の他のホストの場合、10ms〜30ms、地球の裏側で500ms程度かかかります。

## ethtoolコマンドを使ったネットワークインターフェース情報の確認
ethtoolコマンドは、ネットワークインターフェースに対するハードウェアスペックやファームウェア、リンク状態、リンクスピードなどの確認、およびアクセラレーション機能の有効化・無効化を制御することができます。

ネットワークインターフェースに対するハードウェアスペックやファームウェア、リンク状態、リンクスピードなどの確認をするにはethtoolコマンドを実行します。

```
$ ethtool enp0s3
Settings for enp0s3:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Full
	Supported pause frame use: No
	Supports auto-negotiation: Yes
	Supported FEC modes: Not reported
	Advertised link modes:  10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Full
	Advertised pause frame use: No
	Advertised auto-negotiation: Yes
	Advertised FEC modes: Not reported
	Speed: 1000Mb/s
	Duplex: Full
	Auto-negotiation: on
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	MDI-X: Unknown
netlink error: Operation not permitted
        Current message level: 0x00000007 (7)
                               drv probe link
	Link detected: yes
```

ドライバーなどの情報を確認するにはethtool -iコマンドを実行します。

```
driver: e1000
version: 5.14.0-570.26.1.el9_6.x86_64
firmware-version:
expansion-rom-version:
bus-info: 0000:00:03.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no
```

## 各種ネットワーク設定ファイル
Linuxのネットワーク関連の設定は、いくつかの設定ファイルに分散して設定されています。IPアドレスなどは

### 静的な名前解決 /etc/hosts
設定ファイル/etc/hostsには、静的な名前解決のためにIPアドレスとホスト名が対になって列挙された情報が記述されています。

```
$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
```

### 参照DNS設定ファイル /etc/resolv.conf
設定ファイル/etc/resolv.confには、DNSを使って名前解決を行う場合に参照するDNSサーバの情報が記述されています。先に記述されてあるDNSサーバを優先DNSサーバとして最初に参照します。その優先DNSサーバが応答しない場合には、次に記述されている代替DNSサーバを参照します。

```
$ cat /etc/resolv.conf 
# Generated by NetworkManager
search localdomain
nameserver 10.0.2.3
nameserver fd17:625c:f037:2::3
```

#### /etc/resolv.confは直接編集しない
/etc/resolv.confファイルを直接編集して、参照するDNSの設定を変更することは推奨されていません。なぜなら、/etc/resolv.confの設定情報はNetworkManagerよって自動的に変更されます。そのため、/etc/resolv.confを手動で変更後にシステムやNetworkManagerを再起動すると、/etc/resolv.confの設定が古い設定で上書きされてしまい、名前解決ができなくなるなど予期せぬトラブルが発生してしまいます。

DNSサーバの設定は、NetworkManagerで変更します。ネットワークインターフェースが有効になる際に、記述しておいた値に基づいて/etc/resolv.confファイルが設定されます。

### 名前解決設定ファイル /etc/nsswitch.conf
設定ファイル/etc/nsswitch.confには、名前解決などを行う場合に参照する仕組みのリストと優先順位が記述されています。/etc/hostsを参照するのか、DNSやNISを参照させるのかなどが細かく設定できます。

```
$ cat /etc/nsswitch.conf
（略）
hosts:      files dns myhostname
（略）
```

ホストの名前解決は、左から順に「files」、「dns」で優先度が記述されています。まず設定ファイル/etc/hostsを参照し、次にDNSを参照して名前解決を行います。

この設定ファイルには他に、ユーザ認証を行う際の参照先の指定なども記述されます。

### ポート番号とサービスの対応リスト /etc/services
設定ファイル/etc/servicesには、各種TCP/UDPのポート番号と対応するサービスの名前が記述されています。

たとえば、HTTPプロトコルは以下のように記述されています。

```
$ cat /etc/services
（略）
http            80/tcp          www www-http    # WorldWideWeb HTTP
http            80/udp          www www-http    # HyperText Transfer Protocol
http            80/sctp                         # HyperText Transfer Protocol
（略）
```

HTTPは基本的にTCPを使っていますが、UDPやSCTPも定義されています。

各種コマンドがポート番号を表示する際、TCPのポート番号80番を表示する時にはプロトコル名に置き換えてhttpと表示します。
netstatの-nオプションは表示を数値で表示し、-nオプションが指定されないとプロトコル名などを名前で表示します。

この設定ファイルは、あくまで各種コマンドがポート番号をプロトコル名に置き換えて表示するために参照されます。実際には他のプロトコルがポートを使用している場合もあります。

```
$ ss -tln | grep 22
LISTEN 0      128          0.0.0.0:22        0.0.0.0:*
LISTEN 0      128             [::]:22           [::]:*
$ ss -tl | grep ssh
LISTEN 0      128          0.0.0.0:ssh        0.0.0.0:*
LISTEN 0      128             [::]:ssh           [::]:*
```

ポート番号22がsshに置き換えられているのが分かります。ポート番号が数字のまま表示される場合、/etc/servicesに記述が無いためです。
また、2つ目の例は表示がIPv6での表示になっていますが、これはIPv6が有効な場合のSSHサーバーの動作によるものです。IPv4でもIPv6でも、どちらでも接続可能になっています。

### プロトコル定義ファイル /etc/protocols
設定ファイル/etc/protocolsには各種プロトコルの名前とプロトコル番号が記述されています。
たとえば、よく使用しているプロトコル番号は以下の通りです。

```
ip	0	IP		# internet protocol, pseudo protocol number
icmp	1	ICMP		# internet control message protocol
tcp	6	TCP		# transmission control protocol
udp	17	UDP		# user datagram protocol
```

## firewalldによるパケットフィルタリング
firewalldはLinuxカーネルに実装されたパケットフィルタリングを使用する仕組みです。
パケットフィルタリングとは、ネットワークに対してどのようなパケットの通過を許可および拒否するか判定する機能のことです。ファイアーウォールの基本的な機能であるため、ファイアーウォール機能と説明される場合もあります。
firewalldは、カーネル内のnetfilter機能のフロントエンドとして実装されており、ユーザーランドのパケットフィルタリングのルール定義を行うコマンドとしてfirewalld-cmdコマンドが用意されています。

### firewalldのNAT機能
firewalldにはパケットフィルタリング機能の他に、NAT(Network Address Translation)というパケットの送信元または宛先のIPアドレスを変換する機能があります。
NATには以下の種類があります。ここでは内部ネットワークをプライベートIPアドレスが割り振られたLAN、外部ネットワークをグローバルIPアドレスが割り振られたインターネットを想定して説明します。

#### スタティックNAT
内部ホストのIPアドレスと外部向けIPアドレスを1対1で結びつけます。内部から外部へアクセスするパケットの送信元IPアドレスを、内部ホストのIPアドレスから結びつけられている外部向けIPアドレスに書き換えて通信を行います。
外部と通信できるホストは用意された外部向けIPアドレスの数とあらかじめ決まっています。外部から内部への通信を許可して、外部から内部のホストへアクセスさせることもできます。

#### ダイナミックNAT
複数の内部ホストのIPアドレスと複数の外部向けIPアドレスをN対Nで結びつけます。内部から外部へアクセスするパケットの送信元IPアドレスを、内部ホストのIPアドレスから外部向けIPアドレスのプールから選択されたIPアドレスに書き換えて通信を行います。
IPアドレスの対応付けは通信開始時に行われるので、外部向けIPアドレスが余っていないと通信が行えませんが、他のホストが通信を終了して外部向けIPアドレスが解放されると通信が行えるようになります。内部のホストの数が多い場合には、外部向けIPアドレスが不足することになるので、次のNAPTを使用した方が外部との通信が行いやすいでしょう。

#### NAPT(IPマスカレード)
複数の内部ホストのIPアドレスと1つの外部向けIPアドレスを結びつけます。内部向けIPアドレスは外部に出る際に外部向けIPアドレスに書き換えられて通信を行います。その際にNAPTではポート番号の変換も行います。ポート番号は最大65535番まであるので、1つの外部IPアドレスで沢山の内部ホストを外部と通信させることができます。

### firewalldのステータス確認
serviceコマンドでiptablesのステータスを確認します。

```
$ sudo firewall-cmd --list-all
public (default, active)
  target: default
  ingress-priority: 0
  egress-priority: 0
  icmp-block-inversion: no
  interfaces: ens160
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

servicesで、通信を許可するサービスを確認できます。cockpitはポート番号の確認でwebsm（9090番）と表示されていたものです。そしてDHCP、SSHが許可されています。

### パケットの通過を許可する
パケットの通過を許可はfirewall-cmd --add-serviceコマンドで設定します。コマンドの書式は以下の通りです。

```
firewall-cmd --add-service=サービス名
```

たとえば、WebサーバーへのHTTP通信を許可するには、以下のように実行します。

```
sudo firewall-cmd --add-service=http
success
$ sudo firewall-cmd --list-service
cockpit dhcpv6-client http ssh
```

ただし、この方法だと、システムを再起動すると許可設定は消えてしまいます。永続的に設定をしたい場合には、--permanentオプションをつけて設定を変更し、--reloadオプションをつけて実行して設定を適用します。

```
sudo firewall-cmd --add-service=http --permanent
success
$ sudo firewall-cmd --list-service
cockpit dhcpv6-client ssh
```

この段階では適用されていませんので--reloadをつけて実行します。

```
$ sudo firewall-cmd --reload
success
$ sudo firewall-cmd --list-service
cockpit dhcpv6-client http ssh
```

設定が反映されました。

### 設定できるサービスを確認する
どのようなサービスが値として指定できるのか、一覧を確認するには--get-servicesオプションを使います。

```
$ sudo firewall-cmd --get-services
0-AD RH-Satellite-6 RH-Satellite-6-capsule afp alvr amanda-client amanda-k5-client amqp amqps anno-1602 anno-1800 apcupsd aseqnet audit ausweisapp2 bacula 
（略）
wsmans xdmcp xmpp-bosh xmpp-client xmpp-local xmpp-server zabbix-agent zabbix-java-gateway zabbix-server zabbix-trapper zabbix-web-service zero-k zerotier
```
非常に多くの設定が可能です。必要な設定は許可したいソフトウェア側のマニュアルなども参照してください。

### 許可サービスの取り消し
許可されているサービスを取り消しすることもできます。

```
$ sudo firewall-cmd --remove-service=cockpit
success
```

この設定も一時的なもので、システムの再起動時に許可したくない場合には、--permanentオプションをつけて設定を変更し、--reloadオプションをつけて実行して設定を適用します。

```
$ sudo firewall-cmd --remove-service=cockpit --permanent
success
$ sudo firewall-cmd --reload
success
```

\pagebreak

