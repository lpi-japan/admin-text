#ネットワークの管理

## ネットワークインターフェイスの設定
ネットワークインターフェースには、IPアドレスなどネットワーク通信のための各種設定が必要となります。ネットワーク環境に合わせて設定を変更します。

### ipコマンドを使ったネットワークインターフェースの設定
ipコマンドは、ネットワークインターフェースの状態の確認や設定、ルーティングテーブルの表示や追加、削除、ARPテーブルの確認や削除など、ネットワークにおける操作全般を行うことができます。

### ネットワーク設定の確認
IPアドレスやMACアドレスの確認にはip address showコマンドを実行します。

```shell-session
# ip address show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:1c:42:dc:25:92 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.10/24 brd 192.168.0.255 scope global eth0
    inet6 fe80::21c:42ff:fedc:2592/64 scope link 
       valid_lft forever preferred_lft forever
```

### ルーティングテーブル、デフォルトゲートウェイの確認
ルーティングテーブルの確認を行うにはip route showコマンドを実行します。これは従来のrouteコマンドに相当します。

```shell-session
# ip route show
192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.10  metric 1 
default via 192.168.0.1 dev eth0  proto static 
```

defaultになっている行がデフォルトゲートウェイの設定です。この例では、192.168.0.1がネットワークインターフェースeth0から通信する場合のデフォルトゲートウェイとして設定されています。


### ARPテーブルの確認
ARPテーブルの確認を行うにはip neighbor showコマンドを実行します。neighborはneighに省略できます。

```shell-session
#  ip neigh show
192.168.0.1 dev eth0 lladdr 00:1c:42:00:00:18 STALE
192.168.0.2 dev eth0 lladdr 00:1c:42:00:00:08 REACHABLE
```

## netstatコマンドを使った設定確認
※ssコマンドに置き換え
netstatコマンドはネットワークの各種状態を確認することができます。よく使用するオプションは以下の通りです。

|オプション|説明|
|-------|-------|
|-i|ネットワークインターフェースの統計情報を表示|
|-n|コンピューター名の名前解決をせずにIPアドレスで表示|
|-a|すべての接続を表示|
|-l|リッスンしているポートの統計情報を表示|
|-t|TCPの統計情報を表示|
|-u|UDPの統計情報を表示|


### ネットワークインターフェースの統計情報の表示
netstat -iコマンドは、各ネットワークインターフェースのパケット転送量を分かりやすく表示します。

```shell-session
# netstat -i
Kernel Interface table
Iface       MTU Met    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
eth0       1500   0    47780      0      0      0    16784      0      0      0 BMRU
lo        65536   0     2366      0      0      0     2366      0      0      0 LRU
```

### TCP通信の状態の表示
すべてのTCP通信の状態を表示したい場合には、netstat -natコマンドを実行します。

```shell-session
# netstat -nat
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address               Foreign Address             State
tcp        0      0 0.0.0.0:22                  0.0.0.0:*                   LISTEN      
tcp        0      0 127.0.0.1:631               0.0.0.0:*                   LISTEN      
tcp        0      0 127.0.0.1:25                0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:37729               0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:111                 0.0.0.0:*                   LISTEN      
tcp        0      0 :::22                       :::*                        LISTEN      
tcp        0      0 ::1:631                     :::*                        LISTEN      
tcp        0      0 ::1:25                      :::*                        LISTEN      
tcp        0      0 :::37114                    :::*                        LISTEN      
tcp        0      0 :::111                      :::*                        LISTEN      
```

### 待ち受けTCPポートの表示
待ち受けているすべてのTCPのポートを表示したい場合には、netstat -nltコマンドを実行します。

```shell-session
# netstat -nlt
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State
tcp        0      0 0.0.0.0:22                  0.0.0.0:*                   LISTEN      
tcp        0      0 127.0.0.1:631               0.0.0.0:*                   LISTEN      
tcp        0      0 127.0.0.1:25                0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:37729               0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:111                 0.0.0.0:*                   LISTEN      
tcp        0      0 :::22                       :::*                        LISTEN      
tcp        0      0 ::1:631                     :::*                        LISTEN      
tcp        0      0 ::1:25                      :::*                        LISTEN      
tcp        0      0 :::37114                    :::*                        LISTEN      
tcp        0      0 :::111                      :::*                        LISTEN      
```

### 待ち受けUDPポートの表示
待ち受けているすべてのUDPのポートを表示したい場合には、netstat -nluコマンドを実行します。

```shell-session
# netstat -nlu
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State
udp        0      0 0.0.0.0:68                  0.0.0.0:*                               
udp        0      0 127.0.0.1:708               0.0.0.0:*                               
udp        0      0 0.0.0.0:111                 0.0.0.0:*                               
udp        0      0 0.0.0.0:631                 0.0.0.0:*                               
udp        0      0 192.168.0.10:123            0.0.0.0:*                               
udp        0      0 127.0.0.1:123               0.0.0.0:*                               
udp        0      0 0.0.0.0:123                 0.0.0.0:*                               
udp        0      0 0.0.0.0:44415               0.0.0.0:*                               
udp        0      0 0.0.0.0:655                 0.0.0.0:*                               
udp        0      0 :::111                      :::*                                    
udp        0      0 fe80::21c:42ff:fedc:2592:123 :::*                                    
udp        0      0 ::1:123                     :::*                                    
udp        0      0 :::123                      :::*                                    
udp        0      0 :::39182                    :::*                                    
udp        0      0 :::655                      :::*                                    
```

## ping コマンドを使用した疎通の確認
リモートのホストにIPのパケットが到達できるか確認するためにはpingコマンドを実行します。Ctrl+Cを実行するまで無制限に実行されます。

```shell-session
# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=128 time=6.26 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=128 time=3.28 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=128 time=2.85 ms
※^C Ctrl+Cキーを入力する
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 62.780/64.980/66.416/1.579 ms
```

-c オプションで実行回数を指定できます。以下の例では、5回だけ疎通確認を行っています。

```shell-session
# ping -c 5 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=128 time=3.39 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=128 time=3.12 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=128 time=3.44 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=128 time=2.85 ms
64 bytes from 8.8.8.8: icmp_seq=5 ttl=128 time=3.10 ms

--- 8.8.8.8 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4012ms
rtt min/avg/max/mdev = 2.856/3.185/3.440/0.225 ms
```

pingコマンドはICMPプロトコルを使いますので、経路の途中にあるルーターやファイアーウォールなどでICMPプロトコルがブロックされていると、pingコマンドを実行してもうまく結果が返ってこない場合があります。また、対象となるリモートのホストがpingコマンドに反応を返さない場合もあります。

レスポンス結果(RTT)の目安としては、同じネットワークセグメント上のホストの場合は1ms(ミリ秒)以内、国内のインターネット上の他のホストの場合、10ms〜30ms、地球の裏側で500ms程度かかかります。

### ethtoolコマンドを使ったネットワークインターフェース情報の確認
ethtoolコマンドは、ネットワークインターフェースに対するハードウェアスペックやファームウェア、リンク状態、リンクスピードなどの確認、およびアクセラレーション機能の有効化・無効化を制御することができます。

ネットワークインターフェースに対するハードウェアスペックやファームウェア、リンク状態、リンクスピードなどの確認をするにはethtoolコマンドを実行します。

```shell-session
# ethtool eth0
Settings for eth0:
   Supported ports: [ TP ]
   Supported link modes:   10baseT/Half 10baseT/Full
                       	100baseT/Half 100baseT/Full
                       	1000baseT/Full
   Supported pause frame use: No
   Supports auto-negotiation: Yes
   Advertised link modes:  10baseT/Half 10baseT/Full
                       	100baseT/Half 100baseT/Full
                       	1000baseT/Full
   Advertised pause frame use: No
   Advertised auto-negotiation: Yes
   Speed: 1000Mb/s
   Duplex: Full
   Port: Twisted Pair
   PHYAD: 1
   Transceiver: internal
   Auto-negotiation: on
   MDI-X: Unknown
   Supports Wake-on: g
   Wake-on: g
   Link detected: yes
```

ファームウェアのバージョンなどを確認するにはethtool -iコマンドを実行します。

```shell-session
# ethtool -i eth0
driver: bnx2
version: 2.2.3
firmware-version: bc 4.6.4 NCSI 1.0.3
bus-info: 0000:02:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no
```

仮想マシンが利用している仮想ネットワークインターフェースの場合、多くの情報が取得できない場合があります。

```shell-session
# ethtool eth0
Settings for eth0:
	Link detected: yes
```

```shell-session
# ethtool -i eth0
driver: virtio_net
version: 
firmware-version: 
bus-info: virtio0
supports-statistics: no
supports-test: no
supports-eeprom-access: no
supports-register-dump: no
supports-priv-flags: no
```

## 各種ネットワーク設定ファイル
Linuxのネットワーク関連の設定は、いくつかの設定ファイルに分散して設定されています。

### ネットワーク設定に関する情報を指定 /etc/sysconfig/network
設定ファイル/etc/sysconfig/networkには、ネットワークの有効化やホスト名などの情報が含まれています。

```shell-session
# cat /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=server.example.com
NTPSERVERARGS=iburst
```

ホスト名を変更したい場合には、HOSTNAMEの値を変更して、システムを再起動します。

### 静的な名前解決 /etc/hosts
設定ファイル/etc/hostsには、静的な名前解決のためにIPアドレスとホスト名が対になって列挙された情報が記述されています。

```shell-session
# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.0.10	server.example.com server
192.168.0.101	client.example.com client
```

### 参照DNS設定ファイル /etc/resolv.conf
設定ファイル/etc/resolv.confには、DNSを使って名前解決を行う場合に参照するDNSサーバの情報が記述されています。先に記述されてあるDNSサーバを優先DNSサーバとして最初に参照します。その優先DNSサーバが応答しない場合には、次に記述されている代替DNSサーバを参照します。

```shell-session
# cat /etc/resolv.conf 
# Generated by NetworkManager
search example.com
nameserver 192.168.0.1
```

#### /etc/resolv.confは直接編集しない
/etc/resolv.confファイルを直接編集して、参照するDNSの設定を変更することは推奨されていません。なぜなら、NetworkManagerやnetworkサービス、DHCPクライアントの設定ファイルなどにより、/etc/resolv.confの設定情報は自動的に変更されます。そのため、/etc/resolv.confを手動で変更後にシステムや各サービスを再起動すると、/etc/resolv.confの設定が古い設定で上書きされてしまい、名前解決ができなくなるなど予期せぬトラブルが発生してしまいます。

DNSサーバの設定は、インターフェース設定ファイルに記述しておきます。ネットワークインターフェースが有効になる際に、記述しておいた値に基づいて/etc/resolv.confファイルが設定されます。

/etc/sysconfig/network-scripts/ifcfg-eth0に以下を追記します。DNS1で優先DNSサーバ、DNS2で代替DNSサーバを指定します。

```shell-session
DNS1=192.168.0.1
DNS2=192.168.0.2
```

この設定は、システム再起動時、またはNetworkManagerサービス、あるいはnetworkサービスの再起動を行うと/etc/resolv.confに反映されます。

### 名前解決設定ファイル /etc/nsswitch.conf
設定ファイル/etc/nsswitch.confには、名前解決などを行う場合に参照する仕組みのリストと優先順位が記述されています。/etc/hostsを参照するのか、DNSやNISを参照させるのかなどが細かく設定できます。

```shell-session
# cat /etc/nsswitch.conf
（略）
#hosts:     db files nisplus nis dns
hosts:      files dns
（略）
```

ホストの名前解決は、左から順に「files」、「dns」で優先度が記述されています。まず設定ファイル/etc/hostsを参照し、次にDNSを参照して名前解決を行います。
この設定ファイルには他に、ユーザ認証を行う際の参照先の指定なども記述されます。

### ポート番号とサービスの対応リスト /etc/services
設定ファイル/etc/servicesには、各種TCP/UDPのポート番号と対応するサービスの名前が記述されています。

たとえば、HTTPプロトコルは以下のように記述されています。

```shell-session
http        	80/tcp      	www www-http	# WorldWideWeb HTTP
```

各種コマンドがポート番号を表示する際、TCPのポート番号80番を表示する時にはプロトコル名に置き換えてhttpと表示します。
netstatの-nオプションは表示を数値で表示し、-nオプションが指定されないとプロトコル名などを名前で表示します。

この設定ファイルは、あくまで各種コマンドがポート番号をプロトコル名に置き換えて表示するために参照されます。実際には他のプロトコルがポートを使用している場合もあります。

```shell-session
# netstat -nat | grep 80
tcp        0      0 :::80                       :::*                        LISTEN      
# netstat -at | grep http
tcp        0      0 *:http                      *:*                         LISTEN      
```

ポート番号80がhttpに置き換えられているのが分かります。ポート番号が数字のまま表示される場合があるのは、/etc/servicesに記述が無いためです。
また、1つ目の例は表示がIPv6での表示になっていますが、これはIPv6が有効な場合のApache Webサーバの動作によるものです。この状態でもIPv4で接続できます。

### プロトコル定義ファイル /etc/protocols
設定ファイル/etc/protocolsには各種プロトコルの名前とプロトコル番号が記述されています。
たとえば、よく使用しているプロトコル番号は以下の通りです。

```shell-session
ip	0	IP		# internet protocol, pseudo protocol number
icmp	1	ICMP		# internet control message protocol
tcp	6	TCP		# transmission control protocol
udp	17	UDP		# user datagram protocol
```

## iptablesによるパケットフィルタリング
iptablesはLinuxカーネルに実装されたパケットフィルタリングの仕組みです。
パケットフィルタリングとは、ネットワークに対してどのようなパケットの通過を許可および拒否するか判定する機能のことです。ファイアーウォールの基本的な機能であるため、ファイアーウォール機能と説明される場合もあります。
iptablesは、カーネル内のNF(netfilter)によって実装されており、ユーザーランドのパケットフィルタリングのルール定義を行うコマンドとしてiptablesコマンドが用意されています。

### iptablesのNAT機能
iptablesにはパケットフィルタリング機能の他に、NAT(Network Address Translation)というパケットの送信元または宛先のIPアドレスを変換する機能があります。
NATには以下の種類があります。ここでは内部ネットワークをプライベートIPアドレスが割り振られたLAN、外部ネットワークをグローバルIPアドレスが割り振られたインターネットを想定して説明します。

#### スタティックNAT
内部ホストのIPアドレスと外部向けIPアドレスを1対1で結びつけます。内部から外部へアクセスするパケットの送信元IPアドレスを、内部ホストのIPアドレスから結びつけられている外部向けIPアドレスに書き換えて通信を行います。
外部と通信できるホストは用意された外部向けIPアドレスの数とあらかじめ決まっています。外部から内部への通信を許可して、外部から内部のホストへアクセスさせることもできます。

#### ダイナミックNAT
複数の内部ホストのIPアドレスと複数の外部向けIPアドレスをN対Nで結びつけます。内部から外部へアクセスするパケットの送信元IPアドレスを、内部ホストのIPアドレスから外部向けIPアドレスのプールから選択されたIPアドレスに書き換えて通信を行います。
IPアドレスの対応付けは通信開始時に行われるので、外部向けIPアドレスが余っていないと通信が行えませんが、他のホストが通信を終了して外部向けIPアドレスが解放されると通信が行えるようになります。内部のホストの数が多い場合には、外部向けIPアドレスが不足することになるので、次のNAPTを使用した方が外部との通信が行いやすいでしょう。

#### NAPT(IPマスカレード)
複数の内部ホストのIPアドレスと1つの外部向けIPアドレスを結びつけます。内部向けIPアドレスは外部に出る際に外部向けIPアドレスに書き換えられて通信を行います。その際にNAPTではポート番号の変換も行います。ポート番号は最大65535番まであるので、1つの外部IPアドレスで沢山の内部ホストを外部と通信させることができます。

### iptablesの起動と停止
serviceコマンドでiptablesの起動と停止が行えます。

```shell-session
# service iptables start
iptables: チェインをポリシー ACCEPT へ設定中filter         [  OK  ]
iptables: ファイアウォールルールを消去中:                  [  OK  ]
iptables: モジュールを取り外し中:                          [  OK  ]
iptables: ファイアウォールルールを適用中:                  [  OK  ]
```

serviceコマンドでiptablesを停止します。

```shell-session
# service iptables stop
iptables: チェインをポリシー ACCEPT へ設定中filter         [  OK  ]
iptables: ファイアウォールルールを消去中:                  [  OK  ]
iptables: モジュールを取り外し中:                          [  OK  ]
```

### iptablesのステータス確認
serviceコマンドでiptablesのステータスを確認します。

```shell-session
# service iptables start
iptables: ファイアウォールルールを適用中:                  [  OK  ]
# service iptables status
テーブル: filter
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination         
1    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED 
2    ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           
3    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           
4    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:22 
5    REJECT     all  --  0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited 

Chain FORWARD (policy ACCEPT)
num  target     prot opt source               destination         
1    REJECT     all  --  0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited 

Chain OUTPUT (policy ACCEPT)
num  target     prot opt source               destination         
```

iptables -Lコマンドでもiptablesのステータスの確認ができます。

```shell-session
# iptables -L
```

iptables-saveコマンドは、iptablesの設定をiptablesコマンドの設定オプションの形式で出力します。

```shell-session
# iptables-save
# Generated by iptables-save v1.4.7 on Fri Jan  9 16:51:47 2015
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [33:4180]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
-A INPUT -p icmp -j ACCEPT 
-A INPUT -i lo -j ACCEPT 
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT 
-A INPUT -j REJECT --reject-with icmp-host-prohibited 
-A FORWARD -j REJECT --reject-with icmp-host-prohibited 
COMMIT
# Completed on Fri Jan  9 16:51:47 2015
```


### パケットフィルタリングの設定
パケットフィルタリングはiptables-Aコマンドで設定します。コマンドの書式は以下の通りです。

```
iptables -A チェーン 条件 -j ターゲット
```

条件は様々なオプションで設定しますが、基本的な設定は後述します。
チェーンとターゲットで設定できる値は以下の通りです。

|チェーンの種類|説明|
|-------|-------|
|INPUT|受信パケット|
|OUTPUT|送信パケット|
|FORWARD|フォワードするパケット|
|PREROUTING|受信時に変換するチェーン|
|POSTROUTING|送信時に変換するチェーン|

|ターゲットの種類|説明|
|-------|-------|
|ACCEPT|パケットの通過を許可|
|DROP|パケットを破棄|
|REJECT [--reject-with <type>]|パケットを拒否し、ICMPで通知|
|LOG|パケットの情報をsyslogに出力|

### パケットの通過を許可するiptables設定ルール
パケットの通過を許可するには、INPUTチェーンに対して許可したいプロトコルやポート番号を指定します。コマンドの書式は以下の通りです。

```
iptables -A INPUT -m tcp -p tcp --dport ポート番号 -j ACCEPT
```

以下の例ではTCPプロトコルの80番ポート(HTTP)の通信を許可する設定を行っています。ただし、iptablesのルールは設定された順番に適用されます。デフォルト設定ではすべてのパケットをREJECTするルールが設定されているため、このコマンドで一番最後に追加されたルールは実際には機能しません。

実際の運用では、後述する設定ファイル/etc/sysconfig/iptablesに設定を記述して、iptablesに読み込ませる方法で設定を行います。

```shell-session
# iptables -A INPUT -m tcp -p tcp --dport 80 -j ACCEPT
# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  anywhere             anywhere            state RELATED,ESTABLISHED 
ACCEPT     icmp --  anywhere             anywhere            
ACCEPT     all  --  anywhere             anywhere            
ACCEPT     tcp  --  anywhere             anywhere            state NEW tcp dpt:ssh 
REJECT     all  --  anywhere             anywhere            reject-with icmp-host-prohibited ※すべて拒否
ACCEPT     tcp  --  anywhere             anywhere            tcp dpt:http ※到達しません
（略）
```

### iptablesの設定を保存する
iptablesの設定をシステム起動時に再度設定したい場合には、変更内容を保存しておきます。

```shell-session
# service iptables save
iptables: Saving firewall rules to /etc/sysconfig/iptables: [  OK  ]
```

保存されたiptablesの設定ルールは/etc/sysconfig/iptablesに保存されます。iptablesサービスは起動時にこの設定ファイルを読み込んで設定を行います。

新しいiptablesのルールを設定したい場合には、この設定ファイルを変更してiptablesに読み込ませます。

### iptablesの設定ルールをリロードする
設定ファイル/etc/sysconfig/iptablesを直接変更した場合は、設定ルールをリロード(再読み込み)してルールを適用する必要があります。リロードするには、service iptables reloadコマンドを実行します。

iptablesサービスはservice iptables restartで再度設定を行うこともできますが、プロトコルによってはiptablesの追加モジュールを使用している場合があり、restartすると一度モジュールがアンロードされて接続が切れてしまうことがあります。reloadを指定すれば、接続を切らずに新しいルールを適用できます。

```shell-session
# service iptables reload
iptables: Trying to reload firewall rules:                 [  OK  ]
```

### system-config-firewall-tuiを使用したiptablesの設定
system-config-firewall-tuiは、iptableの設定をCUIで行えるツールです。

もしインストールされていなかったら、以下の通りインストールを実行します。

```shell-session
# yum install system-config-firewall-tui
```

1. system-config-firewall-tuiを実行します。

```shell-session
# system-config-firewall-tui
```

＃2

2. カスタマイズを選択します。

![「カスタマイズ」を選択します](firewall1.png)

system-config-firewall-tuiを実行すると、設定画面が表示されます。ファイアウォールの設定を変更したい場合、「カスタマイズ」を選択してEnterキーを押します。選択の変更はTABキー、またはカーソルキーで行えます。

＃3

3. 許可するサービスを選択します。

![許可するサービスを選択します](firewall2.png)

カーソルキーの上下で許可したいサービスを選択し、スペースキーで有効にします。ここでは「WWW (HTTP)」を追加で有効にします。設定が終わったら「閉じる」を選択します。

4. 設定がすぐに反映されることを確認します。

![設定はすぐに反映されます](firewall3.png)

元の画面に戻るので、「OK」を選択します。現在のiptablesの設定を上書きするか確認されるので、「はい」を選択して終了します。

＃5

5. 設定を確認します。

system-config-firewall-tuiで設定を変更すると、/etc/sysconfig/iptablesの設定が上書きされ、現在設定されているiptablesのルールも変更されます。

たとえば、WWW(HTTP)の通信を許可した場合、下記のように80番ポートの通信許可設定が追加されます。

```shell-session
# cat /etc/sysconfig/iptables
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
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
```


## ファイアウォールの設定
ファイアウォールはネットワークにおいて様々なアクセス制限を行い、ネットワークからの攻撃や不正なアクセス等を防ぐ機能です。

AlmaLinuxのファイアウォール機能はfirewalldによって管理されています。firewalldでは、ネットワークインターフェースへのパケットの受信の許可、拒否のルールを管理しています。firewalldの設定は、firewall-cmdコマンドで行います。

### ファイアウォール設定の確認
まず、許可されているサービスを調べます。

```
$ sudo firewall-cmd --list-services
cockpit dhcpv6-client http ssh
```

ここでは、HTTPやSSHなどのプロトコルが使用するポートが受信を許可されています。

### 許可サービスの追加
サービスの許可を追加します。以下の例では、imapサービスを許可しています。

```
$ sudo firewall-cmd --add-service=imap
success
```

この設定は即座に有効になりますが、システムを再起動すると有効にはなりません。再起動後も有効にするには、これまでの実習で行った以下のような設定を行った後に再読み込みを行うか、後述する設定の保存を行います。

```
$ sudo firewall-cmd --add-service=imap --zone=public --permanent
$ sudo firewall-cmd --reload
```

### 設定可能なサービスの確認
設定可能なサービスはあらかじめ定義されているので、一覧を確認してみます。

```
$ sudo firewall-cmd --get-services
RH-Satellite-6 amanda-client amanda-k5-client bacula bacula-client bgp bitcoin bitcoin-rpc bitcoin-testnet bitcoin-testnet-rpc ceph ceph-mon cfengine condor-collector ctdb dhcp dhcpv6 dhcpv6-client dns docker-registry docker-swarm dropbox-lansync elasticsearch freeipa-ldap freeipa-ldaps freeipa-replication freeipa-trust ftp ganglia-client ganglia-master git gre high-availability http https imap imaps ipp ipp-client ipsec irc ircs iscsi-target jenkins kadmin kerberos kibana klogin kpasswd kprop kshell ldap ldaps libvirt libvirt-tls managesieve mdns minidlna mongodb mosh mountd ms-wbt mssql murmur mysql nfs nfs3 nmea-0183 nrpe ntp openvpn ovirt-imageio ovirt-storageconsole ovirt-vmconsole pmcd pmproxy pmwebapi pmwebapis pop3 pop3s postgresql privoxy proxy-dhcp ptp pulseaudio puppetmaster quassel radius redis rpc-bind rsh rsyncd samba samba-client sane sip sips smtp smtp-submission smtps snmp snmptrap spideroak-lansync squid ssh syncthing syncthing-gui synergy syslog syslog-tls telnet tftp tftp-client tinc tor-socks transmission-client upnp-client vdsm vnc-server wbem-https xmpp-bosh xmpp-client xmpp-local xmpp-server zabbix-agent zabbix-server
```

プロトコル名の場合もあれば、使用したいソフトウェアの名称で定義されている場合もあります。

### 許可サービスの取り消し
許可されているサービスを取り消しすることもできます。

```
$ sudo firewall-cmd --remove-service=imap
success
```

この設定も一時的なもので、システムの再起動時に許可したくない場合には、次の設定の保存が必要です。

### ファイアウォール設定の保存
上記の方法で行ったファイアウォールルールの変更は、一時的なものです。そのため、再起動をすると失われてしまいます。再起動後も設定を有効にするには、現在の設定を保存します。

```
$ sudo firewall-cmd --runtime-to-permanent
```




