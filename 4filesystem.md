#ファイルシステムの管理

## アクセス権の管理
LinuxはPOSIXで示されているアクセス制御に準拠しています。POSIXとは「Portable Operating System Interface for UNIX」の略で、IEEE（Institute of Electrical and Electronics Engineers、アイ・トリプル・イー）によって定められた、UNIXベースのOSの仕様セットです。ユーザーID（uid）/グループID（gid）とパーミッションの組み合わせでファイルに対するアクセス権を管理しています。

### UIDとGID
ユーザーID（uid：User Identifier)はLinuxシステムでユーザーを識別するためのユニークな番号です。Linuxで追加されたユーザーカウントには、それぞれ個別にuidが割り振られます。
uidは0から65535までの値をとります。0は特別なユーザーIDで、管理者権限を持つrootユーザーに付与されています。

グループID（gid: Group Identifier）はグループを識別するためのユニークな番号です。Linuxのユーザーは、1つ以上のグループに所属することができます。
gidは0から65535までの値をとります。

### 検証用ユーザー、グループの確認
アクセス制御の動作確認のため、検証用のユーザーを用意します。すでにユーザーsuzukiは作成しているので、ユーザーsatoを追加します。



```
$ sudo useradd sato
$ id sato
uid=1004(sato) gid=1004(sato) groups=1004(sato)
$ id suzuki
uid=1001(suzuki) gid=1001(suzuki) groups=1001(suzuki),5001(power)
```

### 別々のユーザーとして作業する
ユーザーsatoとユーザーsuzuki での操作をスムーズに行うため、それぞれ別々のユーザーでログインします。

Linuxサーバーとは別の端末からSSHでリモートログインして操作を行っている場合には、それぞれのユーザーでリモートログインします。

Linuxサーバー上のGUIで操作を行っている場合には、適当なユーザーでログインした後、別々のターミナルを起動し、suコマンドを使ってユーザーを切り替えるとよいでしょう。


ターミナルAでユーザーsuzukiに切り替えます。

```
$ sudo su - suzuki
$ id
uid=1001(suzuki) gid=1001(suzuki) groups=1001(suzuki),5001(power) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

ターミナルBでユーザーsatoに切り替えます。

```
$ sudo su - sato
$ id
uid=1004(sato) gid=1004(sato) groups=1004(sato) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023```

### プロセスの実行権の管理
Linuxでは、rootユーザーを除いて他のユーザーが起動したプロセスを停止させることはできません。

以下の例では、ユーザーsatoでviエディタ（vim）を起動して/tmpにファイルを作成しようとしているプロセスをユーザーsuzukiがkillコマンドで停止しようとしますが、停止できません。


ユーザーsatoがviエディタで/tmp/satoを作成します。

```
[sato@vbox ~]$ vi /tmp/sato
```

ユーザーsuzukiがvimプロセスを確認します。

```
[suzuki@vbox ~]$ ps aux | grep vim
sato        2351  0.0  0.5 229720  9472 pts/1    S+   18:15   0:00 /usr/bin/vim /tmp/sato
suzuki      2355  0.0  0.1 221676  2304 pts/0    S+   18:15   0:00 grep --color=auto vim
```

ユーザーsuzukiがユーザーsatoが実行中のvimエディタのプロセスをkillコマンドで停止しようとしますが、停止できません。指定するプロセスIDは、psコマンドの2番目の表示項目です。

```
[suzuki@vbox ~]$ kill 2351
-bash: kill: (2351) - 許可されていない操作です
```

ユーザーsatoは、エディタで「sato」と記述し、「:wq」と入力してvimエディタを終了します。

### ファイルのアクセス権の管理
ユーザーsatoが作成したファイル/tmp/satoを使って、アクセス権の動作を検証します。

ユーザーsatoでファイル/tmp/satoのアクセス権を確認します。その他のユーザーへのアクセス権は読み取りのみ与えられています。

```
[sato@vbox ~]$ ls -l /tmp/sato
-rw-r--r--. 1 sato sato 5  7月 26 18:17 /tmp/sato
```

ユーザーsuzukiでcatコマンドを実行し、ファイル/tmp/satoの内容を確認します。その他のユーザーへの読み取りは許可されているので、内容を確認できます。

```
[suzuki@vbox ~]$ cat /tmp/sato
sato
```

ユーザーsuzukiでファイル/tmp/satoに追記してみます。書き込みのアクセス権は与えられていないのでエラーとなります。

```
[suzuki@vbox ~]$ echo "suzuki" >> /tmp/sato
-bash: /tmp/sato: 許可がありません
```

### umaskとデフォルトのパーミッションの関係
umaskとは、ファイルやディレクトリが新規に作成される際にデフォルトのパーミッションを決定するための値です。umaskコマンドで確認できます。

```
[sato@vbox ~]$ umask
0022
```

umaskの設定値には、新しくファイルを作成する際に設定しない（許可しない）パーミッションを8進数で指定します。

| | 読み取り | 書き込み | 実行 |
|-------|-------|-------|-------|
| パーミッション | r | w | x |
| 8進数値 | 4 | 2 | 1 |

ファイルとディレクトリでは設定されるデフォルトのパーミッションが変わるので、それぞれ確認してみましょう。

### ファイル作成のパーミッションとumask
ファイルが新規作成される際にはファイルの実行パーミッション(eXecute)は設定しないので、0666(rw-rw-rw-)に対してumaskの値が適用されます。

umaskが0022と設定されていると、グループとその他のユーザーの書き込みのパーミッション（w）が設定されていないファイル（-rw-r--r--、0644）が作成されます。

```
[sato@vbox ~]$ umask
0022
[sato@vbox ~]$ touch testfile
[sato@vbox ~]$ ls -l testfile
-rw-r--r--. 1 sato sato 0  7月 26 18:19 testfile
```

### ディレクトリ作成のパーミッションとumask
ディレクトリが新規作成される際には、実行パーミッション(eXecute)が必要になるので、0777(rwxrwxrwx)に対してumaskの値が適用されます。実行パーミッションが必要になるのは、1章でも説明したとおり、そのディレクトリをカレントディレクトリにするためには実行パーミッションが必要になるからです。

umaskが0022と設定されていると、グループとその他のユーザーの書き込みのパーミッション（w）が設定されないディレクトリ（-rwxr-xr-x、0755）が作成されています。

```
[sato@vbox ~]$ umask
0022
[sato@vbox ~]$ mkdir testdir
[sato@vbox ~]$ ls -ld testdir
drwxr-xr-x. 2 sato sato 6  7月 26 18:20 testdir
```

### umaskが4桁の理由
パーミッションは通常、ユーザー、グループ、その他のユーザーの3つに対するアクセス権が設定されますが、umaskの値は4桁になっています。これは、通常のパーミッションの先頭に、setUID/setGID/スティッキービットを表す桁が含まれるためです。setUIDなどについては後述します。
また、通常setUIDなどをデフォルトパーミッションとして設定することはないので、umaskは先頭を省略して3桁で設定することもできます。
以下の例では、umaskを022と3桁で設定していますが、umaskコマンドの結果は0022になっています。

```
[sato@server ~]$ umask 022
[sato@server ~]$ umask
0022
```

### umaskを変更する
umaskを変更したい場合には、umaskコマンドで設定したumask値を引数として与えます。
以下の例では、umaskの値を0002に変更したので、新規に作成したファイルのアクセス権は664(-rw-rw-r--)に設定されています。

```
[sato@server ~]$ umask 0002
[sato@server ~]$ touch umasktest
[sato@server ~]$ ls -l umasktest 
-rw-rw-r--. 1 sato sato 0  7月 26 18:21 umasktest
```

### デフォルトのumask
デフォルトのumaskの値は0022ですが、これは/etc/login.defsにUMASKとして定義されています。

```
$ cat /etc/login.defs
（略）
# Default initial "umask" value used by login(1) on non-PAM enabled systems.
# Default "umask" value for pam_umask(8) on PAM enabled systems.
# UMASK is also used by useradd(8) and newusers(8) to set the mode for new
# home directories if HOME_MODE is not set.
# 022 is the default value, but 027, or even 077, could be considered
# for increased privacy. There is no One True Answer here: each sysadmin
# must make up their mind.
UMASK		022
（略）

```

また、ログインシェル以外でのumaskの設定は、bashシェルを起動する際に読み込まれるシェルスクリプト/etc/bashrcの中でumaskが設定されています。

```
$ cat /etc/bashrc
（略）
    # Set default umask for non-login shell only if it is set to 0
    [ `umask` -eq 0 ] && umask 022
（略）
```

### setUIDの確認
setUIDが実行ファイルに設定されていると、その実行ファイルは所有ユーザーの権限で実行されます。setUIDが設定されている場合、lsコマンドの出力で所有ユーザーの実行パーミッションが「s」と表示されます。

setUIDが設定されている例として、passwdコマンドがあります。一般ユーザーがパスワードを変更するには、rootユーザーだけが書き込める/etc/shadowファイルに対する変更が必要です。パスワードを変更するpasswdコマンドは、所有ユーザーがrootユーザーでsetUIDが設定されているので、一般ユーザーがpasswdコマンドを実行すると、rootユーザーの権限で実行されて/etc/shadowファイルに変更を加えることができます。

コマンドを実行したユーザーを「実行ユーザー」、setUIDで権限が変更されたユーザーを「実効ユーザー」と呼びます。

以下の例では、passwdコマンドを一時停止して、psコマンドで実効ユーザーを確認しています。

setUIDが設定されていることを確認します。

```
$ ls -l /usr/bin/passwd
-rwsr-xr-x. 1 root root 32656  4月 14  2022 /usr/bin/passwd
```

passwdを実行し、Ctrl+Zキーで一時停止します。一時停止後、シェルプロンプトに戻すためにはEnterキーを押す必要があります。

```
$ passwd
ユーザー sato のパスワードを変更。
Current password: ※Enterキーを入力

[1]+  停止                  passwd
$
```

psコマンドで実効ユーザーを確認します。passwdコマンドの実効ユーザーがrootであることが確認できます。

```
$ ps aux | grep passwd
root        2377  0.0  0.4 233672  7296 pts/1    T    18:22   0:00 passwd
sato        2380  0.0  0.1 221676  2304 pts/1    S+   18:23   0:00 grep --color=auto passwd
```

fgコマンドで一時停止したpasswdコマンドをフォアグラウンドプロセスに戻します。

```
$ fg
passwd
passwd: 認証トークン操作エラー
$ 
```

### setGIDの確認
setGIDが設定されていると、所有グループの権限で実行されます。setGIDは所有グループの実行パーミッションが「s」と表示されます。

setGIDが設定されている例として、writeコマンドがあります。

```
$ ls -l /usr/bin/write
-rwxr-sr-x. 1 root tty 23984  3月 13 15:30 /usr/bin/write
```

writeコマンドは、ログインしている他のユーザーに対してメッセージを送るコマンドです。以下の例では、writeコマンドを一時停止して、psコマンドで実効グループを確認しています。

2つのユーザーアカウントでログインします。同じユーザーアカウントでも構いません。suコマンドで変更しているユーザーにはwriteコマンドでメッセージを送ることはできないので、ログインユーザーを確認してwriteコマンドを実行し、Ctrl+Zキーで一時停止します。

```
[sato@vbox ~]$ write linuc
^Z
[1]+  停止                  write linuc
[sato@vbox ~]$
```

psコマンドで実効グループを確認します。

```
$ ps a -eo "%p %u %g %G %y %c" | grep write
     37 root     root     root     ?        kworker/R-write
   2388 sato     sato     tty      pts/1    write
```

表示は左から、プロセスID（%p）、実行ユーザー（%u）、実行グループ（%g）、実効グループ（%G）、実行端末（%y）、コマンド（%c）となっています。実行したのはユーザーsatoですが、setGIDされているためttyグループとして動作していることが確認できます。

ttyとは「Tele-TYpewriter」の意味で、端末を表します。writeコマンドはログインしている他のユーザーの端末にメッセージを表示するためにsetGIDを行って実効グループをttyグループにしているわけです。

一時停止しているwriteコマンドをフォアグラウンドに戻し、終了しておきます。

```
[sato@vbox ~]$ fg
write linuc
^C[sato@vbox ~]$
```

### スティッキービット
スティッキービットが設定されたファイルやディレクトリは、「すべてのユーザーが書き込めるが、所有者しか削除できない」というアクセス権限が設定されます。

たとえば/tmpディレクトリに対してスティッキービットが設定されています。/tmpディレクトリは全てのユーザーやアプリケーションが書き込めるディレクトリとして、一時ファイルの作成などに使用されています。しかし/tmpディレクトリのパーミッションを777（rwxrwxrwx）に設定すると、作成したファイルを他のユーザーが削除できてしまいます。そこで/tmpディレクトリにスティッキービットを設定すると、そのファイルを削除できるのは作成したユーザーのみとなります。

スティッキービットが設定されていると、lsコマンドの出力でその他のユーザーの実行パーミッションが「t」と表示されます。

```
$ ls -ld /tmp
drwxrwxrwt. 17 root root 4096  7月 26 18:17 /tmp
```

ユーザーsatoで/tmp/sbittestを作成し、パーミッションを666に設定します。

```
[sato@vbox ~]$ touch /tmp/sbittest
[sato@vbox ~]$ chmod 666 /tmp/sbittest
[sato@vbox ~]$ ls -l /tmp/sbittest
-rw-rw-rw-. 1 sato sato 0  7月 26 18:29 /tmp/sbittest
```

ユーザーsuzukiで/tmp/sbittestに書き込みをします。その他のユーザーに対する書き込みのパーミッションが付与されているので書き込みが行えます。

```
[suzuki@vbox ~]$ echo "suzuki" >> /tmp/sbittest
[suzuki@vbox ~]$ cat /tmp/sbittest
suzuki
```

ユーザーsuzukiで/tmp/sbittestを削除しようとしますが、スティッキービットが働いて削除できません。

```
[suzuki@vbox ~]$ rm /tmp/sbittest
rm: '/tmp/sbittest' を削除できません: 許可されていない操作です
```

ユーザーsatoで/tmp/sbittestを削除します。所有ユーザーは削除が行えます。

```
[sato@vbox ~]$ rm /tmp/sbittest
[sato@vbox ~]$ ls -l /tmp/sbittest
ls: '/tmp/sbittest' にアクセスできません: そのようなファイルやディレクトリはありません
```

## SELinux
SELinuxはLinuxカーネル2.6から実装された、rootユーザーの特権に対しても制限を掛けることができる強制アクセス制御（MAC、Mandatory Access Control）の仕組みです。

本教科書では、SELinuxの基本的な管理について解説します。SELinuxのより詳しい説明については、『Linuxセキュリティ標準教科書』を参照してください。

### SELinuxの仕組み
SELinuxでは、プロセスやファイルなどLinuxの全てのリソースに対して「コンテキスト」（contexts）と呼ばれるラベルを付加し、「サブジェクト」（subject。アクセスする側。主にプロセス）が「オブジェクト」（object。アクセスされる側。主にファイルやディレクトリ、プロセス）に対してアクセスを行う際に、そのコンテキストを比較することによりアクセス制御を行います。

複数のコンテキストを組み合わせて、アクセスの可否を行うルールをSELinuxでは「ポリシー」と呼びます。ポリシーの詳細な説明と修正に関しては、『Linuxセキュリティ標準教科書』を参照してください。

### SELinuxの有効、無効の確認
SELinuxの状態はgetenforceコマンドで確認できます。

```
$ getenforce
Enforcing
```

getenforceコマンドの結果は以下の通りです。

|結果|状態|
|-------|-------|
|Enforcing|SELinuxによるアクセス制御が有効|
|Permissive|SELinuxは有効であるが動作拒否は行わない|
|Disabled|SELinuxによるアクセス制御が無効|

SELinuxの状態は、setenforceコマンドによる動的な変更か、設定ファイル/etc/selinux/configによる永続的な変更のいずれかで変更できます。

### SELinuxの強制
最近のディストリビューションでは、SELinuxを無効（Disabled）にするのは推奨されず、また動的変更、設定ファイルによる変更も行えなくなっているので、無効化の方法については解説しません。SELinuxを無効化するのではなく、正しく設定する方法、また正常に動作しない場合にはPermissiveに一時的に設定してログを確認し、適切に設定する方法を学んでください。

### setenforceコマンドによるSELinuxの動的な変更
setenforceコマンドでSELinuxの状態を動的に変更できます。変更はrootユーザーで実行する必要があります。

ただし、動的に変更できるのはEnforcingとPermissiveの切り替えのみで、SELinuxを有効から無効（Disabled）に、あるいは無効から有効に変更することはできません。

```
setenforce [ Enforcing | Permissive | 1 | 0 ]
```

たとえば、システムのSELinuxによるアクセス制御を一時的に適用しないようにしたいときには状態をPermissiveに変更します。SELinuxによるアクセス制御での動作の拒否は行われなくなりますが、デバッグなどの用途のためにSELinuxのポリシー違反が発生するとログは出力されます。
システムが思ったように動作せず、SELinuxが原因と思われる時などにPermissiveに設定して、SELinuxが原因かどうかの切り分け作業を行います。

```
$ sudo setenforce permissive
$ getenforce 
Permissive
```

### SELinuxの永続的な変更
SELinuxを無効にする、あるいは無効から有効に変更するにはSELinuxの設定ファイル/etc/selinux/configの設定を変更します。システムを再起動すると、設定が反映されます。

/etc/selinux/configを編集し、設定項目SELINUXの値をpermissiveに変更します。

```
$ sudo vi /etc/selinux/config
```

設定を変更します。

```
#SELINUX=enforcing
SELINUX=permissive
```

システムを再起動し、再度ログインしてgetenforceコマンドでSELinuxがPermissiveになったことを確認します。

```
$ getenforce
Permissive
```

/etc/selinux/configを編集し、設定項目SELINUXの値をenforcingに変更します。

```
$ sudo vi /etc/selinux/config
```

```
SELINUX=enforcing
#SELINUX=permissive
```

システムを再起動し、再度ログインしてgetenforceコマンドでSELinuxが有効（Enforcing）になったことを確認します。

```
$ getenforce
Enforcing
```

### コンテキストの確認
コンテキストはファイルなどに設定され、SELinuxのアクセス制御に利用されます。コンテキストは、次の4つの識別子で構成されています。

* ユーザー(user)
* ロール(role)
* タイプ(type)：プロセスの場合には特に「ドメイン」とも言います
* MLS：高度なMulti Level Securityを提供できますが、通常のシステムではあまり使われません

コンテキストは、これらの識別子を組み合わせて、以下の形式で表されます。

```
ユーザー:ロール:タイプ:MLSレベル
```

SELinuxでのアクセス制御は、タイプ／ドメインに対して許可する動作を定義した「ポリシー」に基づいて行われます。タイプ／ドメインの名前は、役割やプロセス名からつけられています。たとえば、Apache Webサーバーのプロセスであるhttpdには「httpd_t」というドメインがつけられています。

### Apache Webサーバーのインストール
この後のSELinuxの動作確認ではApache Webサーバーを使います。まだインストールされていない場合には、dnfコマンドを使ってインストールします。dnfコマンドについては第5章で詳しく解説します。

```
$ sudo dnf install httpd -y
```

### コンテキストの確認
SELinuxのアクセス制御で用いられるコンテキストは、プロセスやファイルを参照するコマンドに-Zオプションをつけて実行することで確認できます。

たとえば、ファイルやディレクトリに付与されているコンテキストを確認するにはls -lZコマンドを実行します。例として、Apache Webサーバー（httpd）に関するファイルを確認してみます。

```
$ ls -lZ /var/www
合計 0
drwxr-xr-x. 2 root root system_u:object_r:httpd_sys_script_exec_t:s0  6  3月 13 03:17 cgi-bin
drwxr-xr-x. 2 root root system_u:object_r:httpd_sys_content_t:s0     24  3月 13 03:17 html
```

Webサーバーのコンテンツを含む/var/www/htmlディレクトリには「httpd_sys_content_t」というタイプが付与されています。この/var/www/htmlディレクトリ内にファイルを作成すると、親ディレクトリのコンテキストに従ってファイルにコンテキストが付与されます。

確認のために、/var/www/htmlディレクトリ以下にindex.htmlファイルを作成してみます。
親ディレクトリからコンテキストを継承し、index.htmlファイルに「httpd_sys_content_t」というタイプが付与されています。

```
$ sudo touch /var/www/html/index.html 
$ ls -lZ /var/www/html/index.html 
-rw-r--r--. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0 0  7月 26 18:40 /var/www/html/index.html
```

また、プロセスのコンテキストの情報を確認するには、ps axZコマンドを実行します。

以下の例では、httpdのプロセスを確認すると、httpd_tドメインが付与されていることが分かります。

```
$ sudo systemctl start httpd
$ ps axZ | grep httpd
system_u:system_r:httpd_t:s0       2412 ?        Ss     0:00 /usr/sbin/httpd -DFOREGROUND
system_u:system_r:httpd_t:s0       2413 ?        S      0:00 /usr/sbin/httpd -DFOREGROUND
（略）
```

SELinuxのポリシーでは、httpdプロセスに付与されているhttpd_tドメインが、「httpd_sys_content_t」などのタイプが付与されているファイルにread（読み取り）などが行えるように権限が設定されています。

### Booleanを使ったSELinuxの制御
SELinuxを有効にしてアプリケーションがうまく動作しない場合には、SELinuxのアクセス制御によってプロセスがファイルやディレクトリにアクセスできないことが原因の場合があります。そのような時には、SELinuxのポリシーを設定する必要があります。

一般的なポリシーの設定は「Boolean」（ブーリアン）と呼ばれる設定の有効、無効で対応できます。Booleanは、パッケージをインストールすると、そのソフトウェア用に用意されたBooleanが追加される場合があります。

もし、独自のアプリケーションを使用したり、アプリケーションの設定を大幅に変更した場合には、ポリシーを追加、修正する必要があります。ポリシーの追加、修正方法については『Linuxセキュリティ標準教科書』を参照してください。

以下の例では、Apache Webサーバー(httpd)に関するポリシーを設定しています。

getseboolコマンドでBooleanの設定状況一覧を確認します。Boolean名には関係するプロセス名が含まれているので、grepコマンドで「httpd」をキーワードにして検索します。

```
$ getsebool -a | grep httpd
httpd_anon_write --> off
httpd_builtin_scripting --> on
（略）
httpd_enable_homedirs --> off
（略）
```

後の作業でhttpd_enable_homedirsのBooleanを設定します。このBooleanは、Apache Webサーバーのユーザーホームディレクトリ機能に関する設定です。ユーザーホームディレクトリ機能は、各ユーザーのホームディレクトリに作成されたpublic_htmlディレクトリ内をWebコンテンツとして公開する仕組みです。

Apache Webサーバーの設定ファイル/etc/httpd/conf.d/userdir.confを修正し、UserDirディレクティブを設定してユーザーホームディレクトリ機能を有効にします。

```
$ sudo vi /etc/httpd/conf.d/userdir.conf

（略）
<IfModule mod_userdir.c>
    #
    # UserDir is disabled by default since it can confirm the presence
    # of a username on the system (depending on home directory
    # permissions).
    #
    #UserDir disabled ←行頭に#を追加してコメントアウト

    #
    # To enable requests to /~user/ to serve the user's public_html
    # directory, remove the "UserDir disabled" line above, and uncomment
    # the following line instead:
    #
    UserDir public_html ←行頭の#を削除
（略）
```

httpdサービスを再起動します。

```
$ sudo systemctl restart httpd
```

ユーザーlinucのホームディレクトリにpublic_htmlディレクトリを作成します。

```
$ pwd
/home/linuc
$ mkdir public_html
```

/home/linucディレクトリ、/home/linuc/public_htmlディレクトリのパーミッションを711に設定します。

```
$ chmod 711 /home/linuc
$ chmod 711 /home/linuc/public_html/
```

public_htmlディレクトリにindex.htmlファイルを作成します。

```
$ echo "SELinux test" > /home/linuc/public_html/index.html
```

ブラウザを起動し、「http://localhost/~linuc/」にアクセスします。SELinuxのアクセス制御が有効になっているため、「Forbidden」が表示されます。

![Forbidden](Forbidden.png)

ログファイル/var/log/audit/audit.logを確認します。httpd(httpd_t)がユーザーホームディレクトリ(user_home_dir_t)にアクセスできなかったというログが出力されています。

```
$ sudo cat /var/log/audit/audit.log | grep index.html
type=AVC msg=audit(1753523214.725:248): avc:  denied  { getattr } for  pid=2624 comm="httpd" path="/home/linuc/public_html/index.html" dev="dm-0" ino=51579776 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:httpd_user_content_t:s0 tclass=file permissive=0
type=AVC msg=audit(1753523214.725:249): avc:  denied  { getattr } for  pid=2624 comm="httpd" path="/home/linuc/public_html/index.html" dev="dm-0" ino=51579776 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:httpd_user_content_t:s0 tclass=file permissive=0
```

setseboolコマンドを実行して、Boolean「httpd_enable_homedirs」を有効に設定します。

```
$ getsebool httpd_enable_homedirs
httpd_enable_homedirs --> off
$ sudo setsebool httpd_enable_homedirs on
$ getsebool httpd_enable_homedirs
httpd_enable_homedirs --> on
```

再度ブラウザで「http://localhost/~linuc/」にアクセスします。Booleanでアクセスが許可されたので、作成したページが表示されます。

## LVMの設定
LVM（Logical Volume Manager）は、ハードディスクなどの記憶媒体の物理的な状態を隠蔽し、論理的なイメージで管理するための技術です。

LVMを使うことで、複数のハードディスクにまたがったボリュームが作成できるようになり、ファイルシステムの容量が足りなくなった場合の容量の追加が簡単になります。ボリュームの操作は、システムを再起動することなく行うことができます。

また、ハードディスクに障害が発生した時には、新しいHDDを追加して、壊れているHDDを外すなどの障害対応が容易になります。
他にも、スナップショットを取ることができるなどのメリットがあります。

現在の一般的なLinuxディストリビューションでは、インストール時にLVMでパーティションを作成できます。AlmaLinuxでは、インストール時に自動パーティション設定を選択すると、デフォルトでLVMを使用してストレージを設定します。

LVMの詳しい説明に関しては、『高信頼システム構築標準教科書』を参照してください。

### 実習用ディスクの追加
以下の実習では、ディスクを追加し、LVMで管理します。そのための仮想ハードディスクを仮想マシンに追加します。

1. ゲストOSをシャットダウンし、仮想マシンを停止する
1. VirtualBoxの仮想マシンの「設定」で「ストレージ」を開く
1. 「コントローラー:SATA」で仮想ハードディスク追加のボタンをクリックする
1. 「ハードディスク選択」ダイアログで「作成」をクリックする
1. 「仮想ハードディスクの作成」ダイアログで「完了」をクリックする
1. 作成された仮想ハードディスクを選択し、「選択」をクリックする
1. 「コントローラー:SATA」に仮想ハードディスクが追加されたことを確認して、「OK」をクリックする
1. 仮想マシンを起動する

### デバイス名の確認
仮想ハードディスクのデバイス名を確認します。ストレージデバイスの確認にはlsblkコマンドを実行します。

```
$ lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                       8:0    0   20G  0 disk
├─sda1                    8:1    0  600M  0 part /boot/efi
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0 18.4G  0 part
  ├─almalinux_vbox-root 253:0    0 16.4G  0 lvm  /
  └─almalinux_vbox-swap 253:1    0    2G  0 lvm  [SWAP]
sdb                       8:16   0   20G  0 disk
sr0                      11:0    1 1024M  0 rom
```

sdbが新たに追加した仮想ハードディスクのデバイス名です。

/devディレクトリにもデバイスファイルが作成されています。

```
$ ls /dev/sd*
/dev/sda  /dev/sda1  /dev/sda2  /dev/sda3  /dev/sdb
```

/dev/sdbが新たに追加した仮想ハードディスクのデバイスファイルです。

### 物理ボリューム（PV）
LVMは、物理ボリューム（PV: Physical Volume）、ボリュームグループ（VG: Volume Group）、論理ボリューム（LV: Logical Volume）の3つで構成されています。

物理ボリューム(PV)は、物理ディスクのパーティション単位で扱われます。一つの物理ディスクすべてを一つのPVとして扱うこともできますし、一つの物理ディスク内にパーティションを複数作成し、それぞれのパーティションを別々のPVとして扱うこともできます。

PVを作成するには、パーティションを作成し、パーティションタイプを8Eに設定します。

以下の例では、Linuxマシンに新規に追加した/dev/sdbとして認識されているハードディスクをLVMで使用できるよう、fdiskでパーティションを作成してPVとして設定しています。同時に、後の作業で領域拡張を行うための追加パーティションも作成しておきます。

```
$ sudo fdisk /dev/sdb

fdisk (util-linux 2.37.4) へようこそ。
ここで設定した内容は、書き込みコマンドを実行するまでメモリのみに保持されます。
書き込みコマンドを使用する際は、注意して実行してください。

デバイスには認識可能なパーティション情報が含まれていません。
新しい DOS ディスクラベルを作成しました。識別子は 0x3370db49 です。

コマンド (m でヘルプ): n ←新規パーティション作成のnを入力
パーティションタイプ
   p   基本パーティション (0 プライマリ, 0 拡張, 4 空き)
   e   拡張領域 (論理パーティションが入ります)
選択 (既定値 p): p ←基本パーティションのpを入力
パーティション番号 (1-4, 既定値 1): 1 ←パーティション番号1を入力
最初のセクタ (2048-41943039, 既定値 2048): ←デフォルトを使うのでEnterを入力
最終セクタ, +/-セクタ番号 または +/-サイズ{K,M,G,T,P} (2048-41943039, 既定値 41943039): +10GB ←+10GBを入力

新しいパーティション 1 をタイプ Linux、サイズ 9.3 GiB で作成しました。

コマンド (m でヘルプ): n ←新規パーティション作成のnを入力
パーティションタイプ
   p   基本パーティション (1 プライマリ, 0 拡張, 3 空き)
   e   拡張領域 (論理パーティションが入ります)
選択 (既定値 p): p ←基本パーティションのpを入力
パーティション番号 (2-4, 既定値 2): 2 ←パーティション番号2を入力
最初のセクタ (19533824-41943039, 既定値 19533824): ←デフォルトを使うのでEnterを入力
最終セクタ, +/-セクタ番号 または +/-サイズ{K,M,G,T,P} (19533824-41943039, 既定値 41943039): ←デフォルトを使うのでEnterを入力

新しいパーティション 2 をタイプ Linux、サイズ 10.7 GiB で作成しました。

コマンド (m でヘルプ): p ←設定を確認するのでpを入力
ディスク /dev/sdb: 20 GiB, 21474836480 バイト, 41943040 セクタ
ディスク型式: VBOX HARDDISK
単位: セクタ (1 * 512 = 512 バイト)
セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト
ディスクラベルのタイプ: dos
ディスク識別子: 0x3370db49

デバイス   起動 開始位置 終了位置   セクタ サイズ Id タイプ
/dev/sdb1           2048 19533823 19531776   9.3G 83 Linux
/dev/sdb2       19533824 41943039 22409216  10.7G 83 Linux

コマンド (m でヘルプ): t ←パーティションのタイプを変更するtを入力
パーティション番号 (1,2, 既定値 2): 1 ←パーティション番号1を入力
16 進数コード または別名 (L で利用可能なコードを一覧表示します): 8e ←Linux LVMのコード8eを入力

パーティションのタイプを 'Linux' から 'Linux LVM' に変更しました。

コマンド (m でヘルプ): t ←パーティションのタイプを変更するtを入力
パーティション番号 (1,2, 既定値 2): 2 ←パーティション番号2を入力
16 進数コード または別名 (L で利用可能なコードを一覧表示します): 8e ←Linux LVMのコード8eを入力

パーティションのタイプを 'Linux' から 'Linux LVM' に変更しました。

コマンド (m でヘルプ): p ←設定を確認するのでpを入力
ディスク /dev/sdb: 20 GiB, 21474836480 バイト, 41943040 セクタ
ディスク型式: VBOX HARDDISK
単位: セクタ (1 * 512 = 512 バイト)
セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト
ディスクラベルのタイプ: dos
ディスク識別子: 0x3370db49

デバイス   起動 開始位置 終了位置   セクタ サイズ Id タイプ
/dev/sdb1           2048 19533823 19531776   9.3G 8e Linux LVM
/dev/sdb2       19533824 41943039 22409216  10.7G 8e Linux LVM

コマンド (m でヘルプ): w ←パーティション情報を書き込むwを入力
パーティション情報が変更されました。
ioctl() を呼び出してパーティション情報を再読み込みします。
ディスクを同期しています。
```

デバイスファイルを確認します。

```
$ lsblk /dev/sdb
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sdb      8:16   0   20G  0 disk
├─sdb1   8:17   0  9.3G  0 part
└─sdb2   8:18   0 10.7G  0 part
$ ls /dev/sdb*
/dev/sdb  /dev/sdb1  /dev/sdb2
```

デバイスファイルに/dev/sdb1と/dev/sdb2が追加されたのが確認できます。

### ボリュームグループ（VG）
ボリュームグループ(VG)は、1つ以上の物理ボリューム（PV）をひとまとめにしたものです。これは仮想的なディスクに相当します。

ボリュームグループはvgcreateコマンドで作成します。

```
vgcreate ボリューム名 PVデバイス名 [PVデバイス名 ...]
```

たとえば、物理ボリューム（PV）として作成した/dev/sdb1を使ってVolume00という名前のボリュームグループを作成するには、以下のvgcreateコマンドを実行します。

```
$ sudo vgcreate Volume00 /dev/sdb1
  Physical volume "/dev/sdb1" successfully created
  Volume group "Volume00" successfully created
```

また、ボリュームグループの情報はvgscanコマンドで確認できます。

```
$ sudo vgscan
  Found volume group "almalinux_vbox" using metadata type lvm2
  Found volume group "Volume00" using metadata type lvm2
```

### 論理ボリューム（LV）
論理ボリューム（LV）は、ボリュームグループ（VG）上に作成する仮想的なパーティションです。Linuxからはデバイスとして認識されます。ハードディスクに物理パーティションを作成する場合と同様に、ボリュームグループをすべて一つの論理ボリュームとすることもできますし、一つのボリュームグループを複数の論理ボリュームに分割して使用することもできます。

論理ボリュームはlvcreateコマンドを使って作成します。

```
lvcreate -L サイズ -n 論理ボリューム名 ボリュームグループ名
```

たとえば、ボリュームグループVolume00にサイズ1GB、論理ボリューム名「LogVol01」の論理ボリュームを作成するには、以下のlvcreateコマンドを実行します。

```
$ sudo lvcreate -L 1024M -n LogVol01 Volume00
  Logical volume "LogVol01" created.
```

### 論理ボリュームにファイルシステムの作成
作成した論理ボリュームを利用するには、通常のパーティションと同じく論理ボリューム上にファイルシステムを作成します。論理ボリュームは、以下のようなデバイスとして扱うことができます。

```
/dev/ボリュームグループ名/論理ボリューム名
```

/dev/Volume00/LogVol01上にext4ファイルシステムを作成するために、mkfsコマンドを実行します。

```
$ sudo mkfs -t ext4 /dev/Volume00/LogVol01 
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: 5ca94cf6-2d63-4ce2-89da-c2dc251d9e42
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

mountコマンドを使って、/dev/Volume00/LogVol01をマウントします。

```
$ sudo mkdir /mnt/LVMtest
$ sudo mount -t ext4 /dev/Volume00/LogVol01 /mnt/LVMtest
$ mount | grep /mnt/LVMtest
/dev/mapper/Volume00-LogVol01 on /mnt/LVMtest type ext4 (rw,relatime,seclabel)
```

### ボリュームグループへのディスクの追加
既存のボリュームグループVolume00に物理ボリューム/dev/sdb2を追加します。

vgextendコマンドを実行して、物理ボリューム/dev/sdb2をボリュームグループVolume00に追加します。

```
$ sudo vgextend Volume00 /dev/sdb2
  Physical volume "/dev/sdb2" successfully created.
  Volume group "Volume00" successfully extended
```

vgdisplayコマンドを実行して、ボリュームグループVolume00の情報を確認します。PV（Physical volume）の数が2となっており、/dev/sdb2が加わっていることが分かります。

```
$ sudo vgdisplay Volume00
  --- Volume group ---
  VG Name               Volume00
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <20.00 GiB
  PE Size               4.00 MiB
  Total PE              5119
  Alloc PE / Size       256 / 1.00 GiB
  Free  PE / Size       4863 / <19.00 GiB
  VG UUID               HsR4Jt-H94l-Ulsw-rvaz-Jebs-6my2-eGtfcD
```

### 論理ボリュームの拡張
LVMでは、論理ボリュームのサイズを変更できます。また、LVMの論理ボリューム上に作成されたext4ファイルシステムは、ファイルシステムをマウントしたまま拡張できます。

dfコマンドを実行して、現在のファイルシステムの容量を確認します。現在の容量は1GBです。

```
$ df -h /mnt/LVMtest
ファイルシス                  サイズ  使用  残り 使用% マウント位置
/dev/mapper/Volume00-LogVol01   974M   24K  907M    1% /mnt/LVMtest
```

lvextendコマンドを実行して、論理ボリュームLogVol01のサイズを2Gまで拡大します。

```
$ sudo lvextend -L 2G /dev/Volume00/LogVol01
  Size of logical volume Volume00/LogVol01 changed from 1.00 GiB (256 extents) to 2.00 GiB (512 extents).
  Logical volume Volume00/LogVol01 successfully resized.
```

resize2fsコマンドを実行して、ファイルシステムを拡大します。

```
$ sudo resize2fs /dev/Volume00/LogVol01
resize2fs 1.46.5 (30-Dec-2021)
Filesystem at /dev/Volume00/LogVol01 is mounted on /mnt/LVMtest; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 1
The filesystem on /dev/Volume00/LogVol01 is now 524288 (4k) blocks long.
```

dfコマンドで再度容量を確認します。容量が2GBに増えていることが確認できます。

```
$ $ df -h /mnt/LVMtest
ファイルシス                  サイズ  使用  残り 使用% マウント位置
/dev/mapper/Volume00-LogVol01   2.0G   24K  1.9G    1% /mnt/LVMtest
```

### 論理ボリュームの縮小
運用上、他の論理ボリュームを拡大したい等の理由で使用率の低い論理ボリュームの縮小を行う場合があります。
論理ボリュームを縮小するには、先にファイルシステムを縮小し、その後に論理ボリュームを縮小する必要があります。ファイルシステムの縮小はマウントしたままでは行えないので、作業中は一度アンマウントしておく必要があります。

縮小したいボリュームをアンマウントします。umountコマンドを実行して、/mnt/LVMtestをアンマウントします。

```
$ sudo umount /mnt/LVMtest
```

縮小したい論理ボリューム/dev/Volume00/LogVol01に対してfsckコマンドを実行します。強制的にチェックを行うために-fオプションを付与して実行します。

```
$ sudo fsck -f /dev/Volume00/LogVol01
fsck from util-linux 2.37.4
e2fsck 1.46.5 (30-Dec-2021)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/mapper/Volume00-LogVol01: 11/131072 files (0.0% non-contiguous), 17196/524288 blocks
```

resize2fsコマンドを実行して、ファイルシステムを縮小します。例として、1GBまで縮小します。

```
$ sudo resize2fs /dev/Volume00/LogVol01 1G
resize2fs 1.46.5 (30-Dec-2021)
Resizing the filesystem on /dev/Volume00/LogVol01 to 262144 (4k) blocks.
The filesystem on /dev/Volume00/LogVol01 is now 262144 (4k) blocks long.
```

lvreduceコマンドを実行して、論理ボリューム/dev/Volume00/LogVol01を縮小します。

```
$ sudo lvreduce -L 1G /dev/Volume00/LogVol01
  File system ext4 found on Volume00/LogVol01.
  File system size (1.00 GiB) is equal to the requested size (1.00 GiB).
  File system reduce is not needed, skipping.
  Size of logical volume Volume00/LogVol01 changed from 2.00 GiB (512 extents) to 1.00 GiB (256 extents).
  Logical volume Volume00/LogVol01 successfully resized.
```

/mnt/LVMtestに再マウントして、容量を確認します。

```
$ sudo mount -t ext4 /dev/Volume00/LogVol01 /mnt/LVMtest
$ df -h /mnt/LVMtest
ファイルシス                  サイズ  使用  残り 使用% マウント位置
/dev/mapper/Volume00-LogVol01   974M   24K  912M    1% /mnt/LVMtest
```


