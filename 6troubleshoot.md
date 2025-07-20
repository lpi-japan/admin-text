# トラブルシューティング

## ログ管理
システム障害の問題解決をはかるトラブルシューティングを行う場合に、もっとも有益な情報源がログです。

ログには、OSが出力するログ、アプリケーションが出力するログなど多くの種類が存在します。

ここでは、代表的なログの種類と確認方法、設定方法などを解説します。

### ログの種類
AlmaLinuxでは、ログファイルは/var/logディレクトリ以下に格納されています。

以下は代表的なログファイルです。

|ファイル名|内容|
|-------|-------|
|messages|サービス起動時の出力など一般的なログ|
|secure|認証、セキュリティ関係のログ|
|maillog|メール間連のログ|
|dmesg|カーネルが出力したメッセージのログ|

また、systemdが記録するログが存在します。こちらは別途解説します。

### ログの確認
サーバのログにサービス起動時、または動作時のエラーログが記録されていないかを確認します。また、クライアント側にもエラーログが記録されていないかを確認します。

* 一般的なトラブルであれば、まずは/var/log/messagesを確認します。
* 認証関係やアクセス制限に関係するトラブルは/var/log/secureを確認します。
* メール関係であれば/var/log/maillogを確認します。
* Webサーバであれば/var/log/httpd/error_logなどを確認します。

### dmesgに記録されるログ
dmesgコマンドは「display message」の略で、Linuxカーネルがメッセージを出力するリングバッファ（循環バッファ）の内容を表示します。このリングバッファは一定のサイズ内で循環するようになっており、古いログは消えていきます。
dmesgコマンドを用いることにより、システム起動時に出力されるカーネルメッセージの確認ができます。カーネルが正しくハードウェアを認識しているかどうかを確認する場合などに参照します。

```
# dmesg
[    0.000000] Linux version 5.14.0-570.12.1.el9_6.x86_64 (mockbuild@x64-builder02.almalinux.org) (gcc (GCC) 11.5.0 20240719 (Red Hat 11.5.0-5), GNU ld version 2.35.2-63.el9) #1 SMP PREEMPT_DYNAMIC Tue May 13 06:11:55 EDT 2025
[    0.000000] The list of certified hardware and cloud instances for Red Hat Enterprise Linux 9 can be viewed at the Red Hat Ecosystem Catalog, https://catalog.redhat.com.
[    0.000000] Command line: BOOT_IMAGE=(hd0,gpt2)/vmlinuz-5.14.0-570.12.1.el9_6.x86_64 root=/dev/mapper/almalinux_vbox-root ro crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M resume=/dev/mapper/almalinux_vbox-swap rd.lvm.lv=almalinux_vbox/root rd.lvm.lv=almalinux_vbox/swap rhgb quiet
[    0.000000] [Firmware Bug]: TSC doesn't count with P0 frequency!
[    0.000000] BIOS-provided physical RAM map:
（略）
```

### syslogについて
syslogは、カーネルやプログラムなどから出力されるログをまとめて記録する仕組みです。syslogを使うことで、各プログラムは独自にログを記録する仕組みを開発する必要が無くなります。また、syslogサーバをネットワーク上で動作させることで、複数のホストからのログをまとめて記録することで、ログを一元管理することもできます。
AlmaLinuxでは、syslogサーバとしてrsyslogが使用できます。

rsyslogは、従来のsyslogデーモン（syslogd）に置き換わる、マルチスレッドのsyslogデーモンです。rsyslog（Reliable syslog）という名前からも分かる通り、高い信頼性を実現するように開発されています。そのため、ログの転送にTCPを使用したり、データベースへのログ保存、暗号化したログの転送なども行うことができます。基本的な設定については、従来のsyslogdと互換性があります。

### ファシリティとプライオリティ
カーネルやプログラムが出力するsyslogメッセージには、「ファシリティ」（facility）と「プライオリティ」（priority）と呼ばれる値が設定されています。

ファシリティは、何がそのログメッセージを生成したのかを指定します。たとえば、カーネルやメールといった値が指定されます。

また、プライオリティはメッセージの重要性を指定します。たとえば、単なる情報、非常に危険な状態などといった値が指定されます。

ファシリティには、以下の種類があります。

|ファシリティ|意味|
|-------|-------|
|auth|セキュリティ・認証関連（login、su など）|
|authpriv|セキュリティ・認証関連（プライベート）|
|cron|cronやatのログ|
|daemon|一般的なデーモン（サーバプログラム）関連|
|kern|カーネル関連|
|lpr|プリンタ関連|
|mail|メール関連|
|news|NetNews関連|
|security|authと同じ|
|syslog|syslogd自身のログ|
|user|ユーザアプリケーションのログ|
|uucp|uucp転送を行うプログラムのログ|
|local0からlocal7|独自のプログラムで利用可能なfacility|

プライオリティには、以下の種類があります。

|プライオリティ|意味|
|-------|-------|
|debug|デバッグ用メッセージ|
|info|一般的な情報メッセージ|
|notice|通知メッセージ|
|warning|警告メッセージ|
|warn|warningと同じ|
|err|一般的なエラーメッセージ|
|error|errと同じ|
|crit|ハード障害などの危険なエラーメッセージ|
|alert|システム破損などの緊急事態|
|emerg|非常に危険な状態|
|panic|emergと同じ|
|none|ファシリティを無効にする|

### syslogサーバの設定
syslogサーバの設定ファイルである/etc/rsyslog.confには、受け取ったログメッセージをファシリティとプライオリティの組み合わせでどのファイルに出力するかの設定が記述されています。

記述は以下の形式となります。

```
ファシリティ.プライオリティ	アクション
```

syslogサーバの設定ファイル中で、複数のファシリティを指定したい場合には、「,」（コンマ）で区切ります。たとえば、/var/log/messagesには様々なファシリティからのログが記録されるように設定されています。この設定は、すべてのファシリティのinfoプライオリティ以上のログをすべて/var/log/messagesに出力するようにしています。ただし、mail、authpriv、cronの3つのファシリティにはnoneプライオリティが指定されているため、対象からは除外されています。

```
*.info;mail.none;authpriv.none;cron.none                /var/log/messages
```

除外された各ファシリティの出力は、以下のように別途指定されています。

mailファシリティのログは、メモリ上にある程度バッファリングした上でログファイルに書き込むように「-（ハイフン）」を指定しています。メールサーバは一度に大量のログを書き込むことが多いからです。

```
authpriv.*						/var/log/secure
mail.*							-/var/log/maillog
cron.*							/var/log/cron
```

### プライオリティの動作
syslog設定ファイル中でプライオリティを指定すると、そのプライオリティ以上の重要度のプライオリティがすべて当てはまります。たとえば、以下のように設定したとします。

```
mail.warning
```

mailファシリティからのwarning以上（err、crit、alert、emerg）のすべてのプライオリティが当てはまります。

特定のプライオリティのみ指定したい場合には、「=プライオリティ」と指定します。

```
mail.=warning
```

この指定はmailファシリティのプライオリティがwarningのメッセージのみが当てはまります。

### アクションの設定
ファシリティとプライオリティを記述した右側に、該当するログをどうするかを指定するアクションを記述します。

主なアクションは、以下の表のとおりです。

#### ファイル名
ログをファイルに書き込む。

#### -ファイル名
ログをファイルに書き込む際にバッファリングする。書き込み性能が向上するが、書き込まれていないデータがある時にシステム障害が発生するとログが失われる。

#### \プログラム
ログメッセージをプログラムに引き渡す。

#### *
すべてのユーザのコンソールにメッセージを表示する。今後、使用できなくなる可能性があります。

#### :omusrmsg:*
*同様にすべてのユーザのコンソールにメッセージを表示する。今後はこちらを使用することが推奨されています。

#### @ホスト名（あるいはIPアドレス）
UDPでsyslogサーバにログメッセージを送信する。

#### @@ホスト名（あるいはIPアドレス）
TCPでsyslogサーバにログメッセージを送信する。

### カーネルログのsyslog出力設定
デフォルトの設定ではコメントアウトされて無効になっているカーネルからのログ出力の設定を有効にします。カーネルのログは、たとえばnftablesによるパケットフィルタリングのようなカーネルの機能がログを出力します。

firewalldの設定を変更して、拒否した通信をすべてログ出力するように変更します。

```
$ sudo firewall-cmd --get-log-denied
off
[linuc@vbox ~]$ sudo firewall-cmd --set-log-denied=all
success
[linuc@vbox ~]$ sudo firewall-cmd --get-log-denied
all
[linuc@vbox ~]$ sudo firewall-cmd --reload
success
```

この状態では、カーネルからのログ出力はすべて/var/log/messagesに記録されます。/etc/rsyslog.confを編集し、ファシリティがkern、プライオリティが全てのメッセージを/var/log/kern.logに出力する設定を追加します。

```
# vi /etc/rsyslog.conf

# Log all kernel messages to the console.
# Logging much else clutters up the screen.
#kern.*                                                 /dev/console
kern.*                                                 /var/log/kern.log
```

rsyslogサービスを再起動して、新しい設定を読み込ませます。

```
$ sudo systemctl restart rsyslog
```

外部のホストから設定を行ったホストに対して、nftablesで許可されていないポート番号80番と443番にWebブラウザ等でアクセスします。

/var/log/kern.logにポート番号80番に対する通信を拒否した旨のログが出力されます。DPTが宛先のポートです。

```
# sudo tail /var/log/kern.log 
Jul 19 19:21:07 vbox kernel: filter_IN_public_REJECT: IN=enp0s8 OUT= MAC=08:00:27:40:b7:96:d0:11:e5:1a:ce:3b:08:00 SRC=192.168.11.115 DST=192.168.11.108 LEN=64 TOS=0x00 PREC=0x00 TTL=64 ID=0 DF PROTO=TCP SPT=62290 DPT=80 WINDOW=65535 RES=0x00 CWR ECE SYN URGP=0
Jul 19 19:21:07 vbox kernel: filter_IN_public_REJECT: IN=enp0s8 OUT= MAC=08:00:27:40:b7:96:d0:11:e5:1a:ce:3b:08:00 SRC=192.168.11.115 DST=192.168.11.108 LEN=64 TOS=0x00 PREC=0x00 TTL=64 ID=0 DF PROTO=TCP SPT=62291 DPT=443 WINDOW=65535 RES=0x00 CWR ECE SYN URGP=0
```

### リモートホストのログをUDPで受け取る
syslogサーバとしてリモートホストのログを受け取るための設定を行います。syslogのメッセージの送受信は、通常UDPで行われます。

設定ファイル/etc/rsyslog.conf内にある以下の2行から、行頭のコメントアウトを削除して設定を有効にします。

module(load="imudp")は、UDP用のプロトコルモジュールのロードを設定しています。input(type="imudp" port="514")は、UDPでログメッセージを受け取るポート番号を514番として指定しています。

```
[root@server ~]## vi /etc/rsyslog.conf

（略）
# Provides UDP syslog reception
module(load="imudp") # needs to be done just once
input(type="imudp" port="514")
```

rsyslogサービスを再起動します。rsyslogdがUDPのポート番号514番で待ち受けるようになります。

```
$ sudo systemctl restart rsyslog
[linuc@vbox ~]$ ss -uln | grep 514
UNCONN 0      0                                0.0.0.0:514        0.0.0.0:*
UNCONN 0      0                                   [::]:514           [::]:*
```

設定後、firewalldの設定を変更し、外部からのUDPのポート番号514番へのパケットを許可するように設定を変更する必要があります。設定については後述します。

### リモートホストのログをTCPで受け取る
ログメッセージの送受信にTCPを使用することにより、UDPで発生していたログの取りこぼしを防ぐことができます。UDPはセッションレスなプロトコルのため、送受信に失敗した時に再送信する仕組みが無いためです。

ただし、TCPはプロトコルの性質上UDPよりも処理が重くなってしまうため、大量のログが送信されてくる環境では逆にボトルネックになってしまい、syslogサーバ側が高負荷で処理が滞ってしまう可能性があります。

そのため、TCPを使ったログメッセージの送受信は、ログの量がそれほど多くなくログ記録の信頼性が必要な場合に設定します。もし、大量のログが送信されてくる場合には、syslogサーバを複数用意するか、UDPを使う必要があります。

設定ファイル/etc/rsyslog.conf内にある以下の2行から、行頭のコメントアウトを削除して設定を有効にします。

module(load="imtcp")は、TCP用のプロトコルモジュールのロードを設定しています。input(type="imtcp" port="514")は、TCPでログメッセージを受け取るポート番号を514番として指定しています。

```
[root@server ~]# vi /etc/rsyslog.conf

（略）
# Provides TCP syslog reception
module(load="imtcp") # needs to be done just once
input(type="imtcp" port="514")
```

rsyslogサービスを再起動します。rsyslogdがTCPのポート番号514番で待ち受けるようになります。

```
$ sudo systemctl restart rsyslog
[linuc@vbox ~]$ ss -tln | grep 514
LISTEN 0      25           0.0.0.0:514       0.0.0.0:*
LISTEN 0      25              [::]:514          [::]:*
```

設定後、firewalldの設定を変更し、外部からのTCPのポート番号514番へのパケットを許可するように設定を変更する必要があります。

### syslogサーバーのためのfirewalldの設定
firewalldの設定を変更し、TCPおよびUDPのポート番号514番の接続を許可しておきます。


```
sudo firewall-cmd --add-port=514/udp --permanent
sudo firewall-cmd --add-port=514/tcp --permanent
sudo firewall-cmd --reload
```

### syslogクライアントの設定
ネットワークで接続されたsyslogサーバーに対してログメッセージを送信するsyslogクライアントを設定します。

syslogクライアント側のホストでもrsyslogを設定し、アクションの設定でネットワーク上のsyslog サーバーを指定します。

syslogクライアントの設定ファイル/etc/rsyslog.confを修正します。

authprivファシリティに関するすべてのログをsyslogサーバに送信するように設定を追加します。@送信先と指定することでUDPを使用した送信を指定できます。

また、mailファシリティに関するすべてのログをsyslogサーバに送信するように設定を追加します。@@送信先と指定することでTCPを使用した送信を指定できます。

```
# vi /etc/rsyslog.conf

# The authpriv file has restricted access.
authpriv.*                                              /var/log/secure
authpriv.*                                              @192.168.0.10

# Log all the mail messages in one place.
mail.*                                                  -/var/log/maillog
mail.*                                                  @@192.168.0.10
```

syslogクライアントのrsyslogサービスを再起動します。

```
$ sudo systemctl restart rsyslog
```

#### UDPでログを送信
syslogクライアントでloggerコマンドを実行して、authpriv.debugプライオリティでログを出力します。

```
[root@client ~]# logger -p authpriv.debug "This is auth log over UDP"
```

syslogサーバ上の/var/log/secureにログが出力されることを確認します。

```
[root@server ~]# tail -f /var/log/secure 
（略）
Dec 25 17:16:50 client root: This is auth log over UDP
```

#### TCPでログを送信
syslogクライアントでloggerコマンドを実行して、mail.debugプライオリティでログを出力します。

```
[root@client ~]# logger -p mail.debug "This is mail log over TCP"
```

syslogサーバ上の/var/log/maillogにログが出力されることを確認します。

```
[root@server ~]# tail /var/log/secure
（略）
Dec 25 17:18:03 client root: This is mail log over TCP
```

### logrotateによるログローテーション
ログファイルは常に追記されていくため、ファイルサイズが次第に肥大化してディスク容量を圧迫し、後でログを確認する際に必要なログを見つけにくくなります。これらの問題を回避するため、ログを一定期間でローテーションするlogrotateが使われています。

logrotateは、cronから1日1回、/etc/cron.daily/logrotateスクリプトによって起動されます。/etc/logrotate.confがlogrotateの設定ファイルとなっており、ログファイルをローテーションするタイミングや、ログファイルを何世代まで残すかなどの設定が記述されています。サービス毎の詳細な設定は、/etc/logrotate.dディレクトリに格納されています。

logrotateの設定で使用できるディレクティブは以下のとおりです。

#### create [モード] [所有ユーザ] [所有グループ]
ローテーションを行った後、代わりに空の新規ログファイルを作成します。属性も指定できます。モードは0755のような数値書式。指定しない属性については元のファイルの属性が引き継がれます。

#### nocreate
createをグローバルに設定した場合に、個別にcreateを無効にしたい際に使用します。

#### copy/nocopy
元のログファイルはそのままにして、コピーを保存します。

#### copytruncate/nocopytruncate
copyの動作を行った後、元のログファイルの内容を消去します。見かけ的にはcreateと同じ結果となります。これはログファイルをリロードする方法が無いプログラムへの対処法のひとつです。たとえばOracle 10g R1/R2のalertログに対しては、この方法を行わないと以前のログファイル（例えばalert_xx.log.1）にログが書き込み続けられます。

#### rotate 世代数
世代ローテーションの世代数を指定します。たとえば元のログファイルがa.logの場合、numに2を指定すると、a.log→a.log.1→a.log.2→廃棄となります。0の場合、a.log→廃棄となります。

#### start 数値
最初のローテーションファイルの末尾に付加する値を指定します。デフォルトは1です。たとえばnumに5を指定すると、a.log→a.log.5→a.log.6となります。

#### extension 拡張子
ローテーションした旧ログファイルに付ける拡張子を指定します。指定には区切りのドットも必要です。たとえば拡張子に「.bak」と指定すると、some.logの初代ローテーションログはsome.log.1.bakとなります。圧縮も行う場合、圧縮による拡張子はさらにその後ろに付きます。

#### compress/nocompress
ローテーションした後の旧ファイルに圧縮を掛けます。デフォルトはnocompress（非圧縮）です。

#### compresscmd コマンド
ログファイルの圧縮に使用するプログラムを指定します。デフォルトはgzipです。

#### uncompresscmd コマンド
ログファイルの解凍に使用するプログラムを指定します。デフォルトはgunzipです。

#### compressoptions オプション
圧縮プログラムへ渡すオプションを指定します。デフォルトはgzipに渡す「-9」（圧縮率最大）です。「-9 -s」のようにスペース入りで複数のオプションを指定することはできません。

#### compressext 拡張子
圧縮後のファイルに付ける拡張子（ドットも必要）を指定します。デフォルトでは、使用する圧縮コマンドに応じたものが付けられます。

#### delaycompress/nodelaycompress
圧縮処理を次のローテーションまで遅らせる、あるいは遅らせません。

#### olddir ディレクトリ/noolddir
ローテーションした旧ログをディレクトリに移動します。移動先は元と同じデバイス上で指定します。元のログに対する相対指定も有効です。

#### mail address/nomail
旧ログファイルをaddressに送信します。どの段階のログを送るかはmaillastなどのオプションで決まります。

#### maillast
世代が終わって破棄されるログをメールします。

#### mailfirst
初代ローテーションログをメールします。

#### daily/weekly/monthly
ログローテーションを日毎/週毎/月毎に行います。デフォルトはdaily。たとえばweeklyなら、毎日実行したとしても、週に1回だけローテーションが行われます。

#### size サイズ[K/M]
ログのサイズがサイズバイトを超えていればローテーションを行います。この条件はdaily,weeklyなどの条件より優先されます。キロバイト（K）、メガバイト（M）での指定もできます。

#### ifempty/notifempty
元のログファイルが空でもローテーションを行う、あるいは行いません。

#### missingok/nomissingok
指定のログファイルが存在しなかったとしてもエラーを出さずに処理を続行する、あるいはエラーを出力します。

#### firstaction
ローテーションを行う前にスクリプトを実行します。preroteteよりも前に実行される個別定義内でのみ指定可能です。

#### prerotate
ローテーションを行う前にスクリプトを実行します。firstactionの後に実行されます。個別定義内でのみ指定できます。

#### postrotate
ローテーションが行われた後にスクリプトを実行します。lastactionより前に実行されます。個別定義内でのみ指定できます。

#### lastaction
ローテーションが行われた後（よりも後）にスクリプトを実行します。postrotateの後に実行されます。個別定義内でのみ指定できます。

#### sharedscripts
ローテーションするログが複数あった場合に、prerotate、postrotateのスクリプトを一度だけ実行します。

#### nosharedscripts
ローテーションするログが複数あった場合に、prerotate、postrotateのスクリプトを各ログファイル毎に実行します。

#### include ファイル（ディレクトリ）
includeの記述のある位置に別の設定ファイルを読み込みます。ディレクトリを指定した場合、そのディレクトリ内から、ディレクトリおよび名前付きパイプ以外の通常ファイルがアルファベット順に読み込まれます。

#### tabooext [+] 拡張子[,拡張子,...]
includeでディレクトリを指定した場合に読み込むファイルから除外するファイルの拡張子を指定します。デフォルトで「.rpmorig」「.rpmsave」「,v」「.swp」「.rpmnew」「~」「.cfsaved」「.rhn-cfg-tmp-*」が指定されています。+を指定するとデフォルト指定に対して追加で拡張子を指定できます。+を指定しないとデフォルト指定を破棄して新規に拡張子を指定します。

### ログローテート設定ファイルの確認
/etc/logrotate.d/httpdを参考に、ローテートの設定を確認します。

```
# cat /etc/logrotate.d/httpd 
/var/log/httpd/*log {
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        /sbin/service httpd reload > /dev/null 2>/dev/null || true
    endscript
}
```

この例では、以下の通りログローテーションの処理が行われます。

対象となるログファイルは/var/log/httpdディレクトリ内の、ファイル名がlogで終わるすべてのログファイルです。デフォルトではaccess_log、error_logというファイル名のログファイルが作成されています。

* 1行目のmissingokでログファイルが実在しなかったとしてもエラーを出さずに処理を続行します。
* 2行目のnotifemptyで元のログファイルが空ならばローテーションしません。
* 3行目のsharedscriptsでprerotate,postrotate のスクリプトを一度だけ実行します。
* 4行目のdelaycompressで圧縮処理を次のローテーションまで遅らせます。
* 5行目の"postrotate"から"endscript"までが、ローテーションが行われた後に実行されるスクリプトです。serviceコマンドを実行してhttpdサービスをreloadすることで、新しいログファイルが生成されます。

## ネットワークツールを使ったトラブルシューティング
サーバに接続できないなどネットワークに起因する問題が発生した場合、基本的な原因の調査を行うためのツールとして、以下のようなネットワークツールを使用します。

* ping
* traceroute
* netstat
* tcpdump
* Wireshark

これらのツールを使用した、トラブルシューティングについて解説します。一般的には、外部からサービスへの接続ができなくなった場合には、以下のような手順で原因の調査を行います。

1. ログの確認
1. pingコマンドによるIP通信の確認
1. telnetコマンドによるTCP通信の確認
1. netstatコマンドによるポートの状況の確認
1. 通信内容の確認

### pingコマンドによるIP通信の確認
pingコマンドを使って、サーバに対する通信が行えるかどうかを確認します。pingコマンドはICMPを使った通信でIP通信が可能か確認できます。サーバに対するpingに応答が無い場合、以下のような問題が考えられます。

#### サーバ自身の問題
IPアドレスやデフォルトゲートウェイが適切に設定されていなかったり、iptablesなどのパケットフィルタリングでICMPを通さない設定になっていることが考えられます。
サーバのネットワーク設定を再度確認してみます。また、サーバ側から他のホストへpingコマンドを実行して、応答があるか確認してみます。

#### ネットワーク経路の問題
ネットワーク通信経路上にあるケーブルやスイッチ、ルーター、ファイアーウォールやロードバランサーなどのネットワーク機器に問題が無いかを確認します。
ルーティングに問題があるかを確認するためにはtracerouteコマンドを使用しますが、tracerouteコマンドはICMPを使用しているため、途中のルーターでICMPを通さない場合、すべての経路が確認できないことがあります。

### telnetコマンドによるTCP通信の確認
telnetコマンドは2番目の引数にポート番号を指定して、サーバのサービスに接続することができるので、TCP通信が可能か確認できます。

```
telnet 接続先IPアドレス ポート番号
```

ただし、ディストリビューションによってはtelnetコマンドがインストールされていないので、インストールする必要があります。

```
# yum install telnet
```

サービスに接続できない場合には、以下のような問題が考えられます。

#### ネットワーク経路の問題
iptablesやネットワーク経路上のファイアーウォールなどで、指定されたポートへの通信が許可されていない。
iptablesやファイアーウォールのポート許可設定を確認します。

#### サーバ自身の問題
サービスが停止しており、指定されたポートをListenしていない。あるいは、ローカルループバックアドレス（127.0.0.1）のみListenしており、接続先に指定したIPアドレスにポートがバインドされていない。
netstatコマンドやlsofコマンドなどを使用して、ポートの状態を確認します。

### netstatでのポートの状況の確認
netstatコマンドを使って、サービスプロセスとポート番号、さらにIPアドレスとのバインドの状況が確認できます。

netstatコマンドに-pオプションを指定して実行します。

```
# netstat -anp | grep sshd
tcp        0      0 0.0.0.0:22     0.0.0.0:*  LISTEN   1493/sshd
```

この結果から、以下のことが分かります。

* sshdのプロセスIDが1493であること
* TCPポート番号22番でLISTENしていること
* ポート番号22番がサーバのすべてのIPアドレス（0.0.0.0:22）にバインドされていること
* 送信元制限を行っていないこと（0.0.0.0:*）

### パケットキャプチャによる通信内容の確認
サーバとの接続が行えており、ログにも手がかりとなるエラーが無いが、サービスが正しく動作しないような場合には、通信パケットをキャプチャして、通信内容を確認します。パケットをキャプチャすることで、サーバとクライアントの間でどのような通信が行われているかを確認できます。
パケットキャプチャのツールとしては、GUIで操作できるWiresharkなどがあります。

### Wiresharkを使った確認
tcpdumpの出力ファイルは少量のパケットを見る場合には充分ですが、大量のパケットを確認するには可読性が低いのが難点です。

GUIを持つパケットキャプチャリングソフトであるWiresharkを使えば、パケットキャプチャリングを行ったパケットの中身を見たり、フィルタリング機能で必要なパケットのみに絞り込んでパケットを確認することができます。

Wiresharkをインストールします。GUI版をインストールするため、wireshark-gnomeパッケージをインストールします。

```
# yum install wireshark-gnome
```

1. Wiresharkを起動します。
CentOSにGUIでログインし、端末からwiresharkコマンドを実行するか、「アプリケーション」メニュー→「インターネット」→「Wireshark Network Analyzer」を起動します。

```
# wireshark &
```

＃2

2. キャプチャを行うデバイスを選びます。

![「Capture」メニュー→「Interfaces」を選択します](wireshark1.png)

「Capture」メニュー→「Interfaces」を選択し、パケットキャプチャを行いたいデバイスを選びます。

＃3

3. パケットキャプチャを開始します。

![eth0を選択します](wireshark2.png)

外部との通信をパケットキャプチャするためにeth0を選びます。「Start」ボタンをクリックして、パケットキャプチャを開始します。

＃4

4. Webサーバにアクセスします。
サーバと通信を行ってパケットキャプチャを行います。クライアントでWebブラウザを起動し、サーバのWebサーバにアクセスします。

＃5

5. パケットキャプチャを停止します。
「Capture」メニュー→「Stop」を選択し、パケットキャプチャを停止します。

＃6

6. 結果の絞り込みを行います。

![httpで絞り込みを行います](wireshark3.png)

「Filter:」のテキストボックスに「http」と入力して、Enterキーを押して絞り込みます。
参照したいパケットを選択し、ウインドウ真ん中の詳細情報で「Hypertext Transfer Protocol」をダブルクリックして、HTTP通信の内容を確認します。


※以下、Wiresharkで同様のことをやるときの参考用にキープ

### tcpdumpコマンドを使ったパケットキャプチャ
tcpdumpコマンドは、送受信しているパケットをキャプチャして、その情報を標準出力に出力するコマンドです。
tcpdumpコマンドはデフォルトでは全てのパケットの情報を出力するので、オプションで出力結果をフィルタリングして、必要な情報を得られるようにします。

例として、-iオプションでネットワークインターフェースを指定して、eth0を通じて入ってくる通信のパケットを取得してみます。

サーバ上でtcpdumpコマンドを実行します。結果をリダイレクトして、tcpdump.outファイルに記録します。

```
# tcpdump -i eth0 > tcpdump.out
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
```

クライアントからSSHでサーバにログインし、ログアウトします。

サーバでCtrl+Cキーを入力して、tcpdumpコマンドを終了します。

```
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
※^C※216 packets captured ※←Ctrl+Cキーを入力
216 packets received by filter
0 packets dropped by kernel
```

作成されたtcpdump.outファイルの内容を確認します。

```
# grep ssh tcpdump.out
13:17:06.041096 IP client.example.com.43880 > server.example.com.ssh: ※Flags [S]※, seq 4050960604, win 14600, options [mss 1460,sackOK,TS val 13231 ecr 0,nop,wscale 6], length 0
13:17:06.041125 IP server.example.com.ssh > client.example.com.43880: ※Flags [S.]※, seq 3335753529, ※ack 4050960605※, win 14480, options [mss 1460,sackOK,TS val 22019990 ecr 13231,nop,wscale 6], length 0
13:17:06.041240 IP client.example.com.43880 > server.example.com.ssh: ※Flags [.]※, ※ack 1※, win 229, options [nop,nop,TS val 13231 ecr 22019990], length 0
```

左から時間（マイクロ秒単位)、送信元IPアドレス.ポート番号、通信の向きの矢印、宛先ホスト.ポート番号、フラグ（SYN)、シーケンス、ウィンドウ、オプション、最大セグメントサイズとなっています。

#### 1行目
クライアントのポート43880からサーバのポート22（ssh）に向けてSYNフラグのTCPパケットと送信して接続の要求

#### 2行目
1行目のパケットに対して、SYN+ACKフラグのTCPパケットを送信

#### 3行目
ACKフラグのTCPパケットを送信して、TCPのスリーウェイハンドシェイクが完了

このように、サーバとクライアントの間の通信を確認できます。

