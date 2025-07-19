#ファイルシステムの管理

## アクセス権の管理
LinuxはPOSIXで示されているアクセス制御に準拠しています。POSIXとは「Portable Operating System Interface for UNIX」の略で、IEEE（Institute of Electrical and Electronics Engineers、アイ・トリプル・イー）によって定められた、UNIXベースのOSの仕様セットです。ユーザーID（uid）/グループID（gid）とパーミッションの組み合わせでファイルに対するアクセス権を管理しています。

### UIDとGID
ユーザーID（uid：User Identifier)はLinuxシステムでユーザーを識別するためのユニークな番号です。Linuxで追加されたユーザーカウントには、それぞれ個別にuidが割り振られます。
uidは0から65535までの値をとります。0は特別なユーザーIDで、管理者権限を持つrootユーザーに付与されています。

グループID（gid: Group Identifier）はグループを識別するためのユニークな番号です。Linuxのユーザーは、1つ以上のグループに所属することができます。
gidは0から65535までの値をとります。

### 検証用ユーザー、グループの確認
アクセス制御の動作確認のため、検証用のユーザーを用意します。すでに1章で作成していますが、作成されていない場合にはuseraddコマンド、grooupaddコマンドなどを使用して作成して下さい。

ユーザーsatoとユーザーsuzukiが作成されており、ユーザーsuzukiはwheelグループとeigyouグループに所属しています。

```
# id sato
uid=500(sato) gid=500(sato) 所属グループ=500(sato)
# id suzuki
uid=501(suzuki) gid=501(suzuki) 所属グループ=501(suzuki),10(wheel),5000(eigyou)
```

### 別々のユーザーとして作業する
ユーザーsatoとユーザーsuzuki での操作をスムーズに行うため、それぞれ別々のユーザーでログインします。

Linuxサーバーとは別の端末で操作を行っている場合には、それぞれのユーザーでログインします。

Linuxサーバー上のGUIで操作を行っている場合には、rootユーザーでログインした後、別々のターミナルを起動し、suコマンドを使ってユーザーを切り替えるとよいでしょう。


ターミナルAでユーザーsatoに切り替えます。

```
[root@server ~]# su - sato
[sato@server ~]$ id
uid=500(sato) gid=500(sato) 所属グループ=500(sato) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

ターミナルBでユーザーsuzukiに切り替えます。

```
[root@server ~]# su - suzuki
[suzuki@server ~]$ id
uid=501(suzuki) gid=501(suzuki) 所属グループ=501(suzuki),10(wheel),5000(eigyou) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

### プロセスの実行権の管理
Linuxでは、rootユーザーを除いて他のユーザーが起動したプロセスを停止させることはできません。

以下の例では、ユーザーsatoでviエディタ（vim）を起動して/tmpにファイルを作成しようとしているプロセスをユーザーsuzukiがkillコマンドで停止しようとしますが、停止できません。


ユーザーsatoがviエディタで/tmp/satoを作成します。

```
[sato@server ~]$ vi /tmp/sato
```

ユーザーsuzukiがvimプロセスを確認します。

```
[suzuki@server ~]$ ps aux | grep vim
sato      6456  0.1  0.3 148100  3692 pts/2    S+   19:46   0:00 vim /tmp/sato
suzuki    6462  0.0  0.0 107464   916 pts/3    S+   19:46   0:00 grep vim
```

ユーザーsuzukiがユーザーsatoが実行中のvimエディタのプロセスをkillコマンドで停止しようとしますが、停止できません。指定するプロセスIDは、psコマンドの2番目の表示項目です。

```
[suzuki@server ~]$ kill 6456
-bash: kill: (6456) - 許可されていない操作です
```

ユーザーsatoは「:q!」と入力してvimエディタを終了します。

### ファイルのアクセス権の管理
ユーザーsatoが作成したファイル/tmp/satoを使って、アクセス権の動作を検証します。

ユーザーsatoでファイル/tmp/satoのアクセス権を確認します。その他のユーザーへのアクセス権は読み取りのみ与えられています。

```
[sato@server ~]$ ls -l /tmp/sato
-rw-rw-r--. 1 sato sato 5 12月  9 17:51 2014 /tmp/sato
```

ユーザーsuzukiでcatコマンドを実行し、ファイル/tmp/satoの内容を確認します。その他のユーザーへの読み取りは許可されているので、内容を確認できます。

```
[suzuki@server ~]$ cat /tmp/sato
sato
```

ユーザーsuzukiでファイル/tmp/satoに追記してみます。書き込みのアクセス権は与えられていないのでエラーとなります。

```
[suzuki@server ~]$ echo "suzuki" >> /tmp/sato
-bash: /tmp/sato: 許可がありません
```

### umaskとデフォルトのパーミッションの関係
umaskとは、ファイルやディレクトリが新規に作成される際にデフォルトのパーミッションを決定するための値です。umaskコマンドで確認できます。

```
[sato@server ~]$ umask
0002
```

umaskの設定値には、新しくファイルを作成する際に設定しない（許可しない）パーミッションを8進数で指定します。

| | 読み取り | 書き込み | 実行 |
|-------|-------|-------|-------|
| パーミッション | r | w | x |
| 8進数値 | 4 | 2 | 1 |

ファイルとディレクトリでは設定されるデフォルトのパーミッションが変わるので、それぞれ確認してみましょう。

### ファイル作成のパーミッションとumask
ファイルが新規作成される際にはファイルの実行パーミッション(eXecute)は設定しないので、0666(rw-rw-rw-)に対してumaskの値が適用されます。

umaskが0002と設定されていると、その他のユーザーの書き込みのパーミッション（w）が設定されていないファイル（-rw-rw-r--、0664）が作成されます。

```
[sato@server ~]$ umask
0002
[sato@server ~]$ touch testfile
[sato@server ~]$ ls -l testfile
-rw-rw-r--. 1 sato sato 0  1月 14 19:51 2015 testfile
```

### ディレクトリ作成のパーミッションとumask
ディレクトリが新規作成される際には、実行パーミッション(eXecute)が必要になるので、0777(rwxrwxrwx)に対してumaskの値が適用されます。実行パーミッションが必要になるのは、1章でも説明したとおり、そのディレクトリをカレントディレクトリにするためには実行パーミッションが必要になるからです。

umaskが0002と設定されていると、その他のユーザーの書き込みのパーミッション（w）が設定されないディレクトリ（-rwxrwxr-x、0775）が作成されています。

```
[sato@server ~]$ umask
0002
[sato@server ~]$ mkdir testdir
[sato@server ~]$ ls -ld testdir
drwxrwxr-x. 2 sato sato 4096  1月 14 19:52 2015 testdir
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
以下の例では、umaskの値を0022に変更したので、新規に作成したファイルのアクセス権は644(-rw-r--r--)に設定されています。

```
[sato@server ~]$ umask 0022
[sato@server ~]$ touch umasktest
[sato@server ~]$ ls -l umasktest 
-rw-r--r--. 1 sato sato 0  1月 14 19:53 2015 umasktest
```

### デフォルトのumask
デフォルトのumaskの値は0022ですが、これは/etc/login.defsにUMASKとして定義されています。

```
[root@server ~]# cat /etc/login.defs
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
# cat /etc/bashrc
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
[sato@server ~]$ ls -l /usr/bin/passwd 
-rwsr-xr-x. 1 root root 30768  2月 22 20:48 2012 /usr/bin/passwd
```

passwdを実行し、Ctrl+Zキーで一時停止します。一時停止後、シェルプロンプトに戻すためにはEnterキーを押す必要があります。

```
[sato@server ~]$ passwd
ユーザー sato のパスワードを変更。
sato 用にパスワードを変更中
現在のUNIXパスワード: ※Ctrl+Zキーを入力後、Enterキーを押す
[1]+  停止                  passwd
```

psコマンドで実効ユーザーを確認します。passwdコマンドの実効ユーザーがrootであることが確認できます。

```
[sato@server ~]$ ps aux | grep passwd
root     15052  0.0  0.2 164012  2068 pts/1    T    10:47   0:00 passwd
sato     15178  0.0  0.0 107464   916 pts/1    S+   10:48   0:00 grep passwd
```

fgコマンドで一時停止したpasswdコマンドをフォアグラウンドプロセスに戻し、Ctrl+Cキーで終了します。

```
[sato@server ~]$ fg
passwd
※^C ←Ctrl+Cキーを入力
[sato@server ~]$ 
```

### setGIDの確認
setGIDが設定されていると、所有グループの権限で実行されます。setGIDは所有グループの実行パーミッションが「s」と表示されます。

setGIDが設定されている例として、writeコマンドがあります。

```
$ ls -l /usr/bin/write
-rwxr-sr-x  1 root tty 10124 2月 18日  2011 /usr/bin/write
```

writeコマンドは、ログインしている他のユーザーに対してメッセージを送るコマンドです。以下の例では、writeコマンドを一時停止して、psコマンドで実効グループを確認しています。

2つのユーザーアカウントでログインします。同じユーザーアカウントでも構いません。
writeコマンドを実行し、Ctrl+Zキーで一時停止します。

```
[sato@server ~]$ write suzuki
※^Z ←Ctrl+Zキーを入力
[1]+  停止                  write suzuki
```

psコマンドで実効グループを確認します。

```
[sato@server ~]$ ps a -eo "%p %u %g %G %y %c" | grep write
23400 sato     sato     ※tty※      pts/1    write
```

表示は左から、プロセスID（%p）、実行ユーザー（%u）、実行グループ（%g）、実効グループ（%G）、実行端末（%y）、コマンド（%c）となっています。実行したのはユーザーsatoですが、setGIDされているためttyグループとして動作していることが確認できます。

ttyとは「Tele-TYpewriter」の意味で、端末を表します。writeコマンドはログインしている他のユーザーの端末にメッセージを表示するためにsetGIDを行って実効グループをttyグループにしているわけです。

### スティッキービット
スティッキービットが設定されたファイルやディレクトリは、「すべてのユーザーが書き込めるが、所有者しか削除できない」というアクセス権限が設定されます。

たとえば/tmpディレクトリに対してスティッキービットが設定されています。/tmpディレクトリは全てのユーザーやアプリケーションが書き込めるディレクトリとして、一時ファイルの作成などに使用されています。しかし/tmpディレクトリのパーミッションを777（rwxrwxrwx）に設定すると、作成したファイルを他のユーザーが削除できてしまいます。そこで/tmpディレクトリにスティッキービットを設定すると、そのファイルを削除できるのは作成したユーザーのみとなります。

スティッキービットが設定されていると、lsコマンドの出力でその他のユーザーの実行パーミッションが「t」と表示されます。

```
[sato@server ~]$ ls -ld /tmp
drwxrwxrwt. 16 root root 4096  1月 14 20:26 2015 /tmp
```

ユーザーsatoで/tmp/sbittestを作成し、パーミッションを666に設定します。

```
[sato@server ~]$ touch /tmp/sbittest
[sato@server ~]$ chmod 666 /tmp/sbittest 
[sato@server ~]$ ls -l /tmp/sbittest 
-rw-rw-rw-. 1 sato sato 0  1月 14 20:28 2015 /tmp/sbittest
```

ユーザーsuzukiで/tmp/sbittestに書き込みをします。その他のユーザーに対する書き込みのパーミッションが付与されているので書き込みが行えます。

```
[suzuki@server ~]$ echo "suzuki" >> /tmp/sbittest
[suzuki@server ~]$ cat /tmp/sbittest
suzuki
```

ユーザーsuzukiで/tmp/sbittestを削除しようとしますが、スティッキービットが働いて削除できません。

```
[suzuki@server ~]$ rm /tmp/sbittest 
rm: cannot remove `/tmp/sbittest': 許可されていない操作です
```

ユーザーsatoで/tmp/sbittestを削除します。所有ユーザーは削除が行えます。

```
[sato@server ~]$ rm /tmp/sbittest
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
[root@server ~]# getenforce 
Enforcing
```

getenforceコマンドの結果は以下の通りです。

|結果|状態|
|-------|-------|
|Enforcing|SELinuxによるアクセス制御が有効|
|Permissive|SELinuxは有効であるが動作拒否は行わない|
|Disabled|SELinuxによるアクセス制御が無効|

SELinuxの状態は、setenforceコマンドによる動的な変更か、設定ファイル/etc/selinux/configによる永続的な変更のいずれかで変更できます。
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
# setenforce permissive
# getenforce 
Permissive
```

### SELinuxの永続的な変更
SELinuxを無効にする、あるいは無効から有効に変更するにはSELinuxの設定ファイル/etc/selinux/configの設定を変更します。システムを再起動すると、設定が反映されます。

/etc/selinux/configを編集し、設定項目SELINUXの値をpermissiveに変更します。

```
# vi /etc/selinux/config

※#※SELINUX=enforcing ※←行頭に#を追加
※SELINUX=permissive ←新たに追加
```

システムを再起動します。

```
# reboot
```

getenforceコマンドでSELinuxが無効（Disabled）になったことを確認します。

```
# getenforce
Permissive
```

/etc/selinux/configを編集し、設定項目SELINUXの値をenforcingに変更します。

```
# vi /etc/selinux/config

SELINUX=enforcing ※←行頭の#を削除
※#※SELINUX=disabled ※←行頭に#を追加
```

システムを再起動します。

```
# reboot
```

getenforceコマンドでSELinuxが有効（Enforcing）になったことを確認します。

```
# getenforce
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

### コンテキストの確認
SELinuxのアクセス制御で用いられるコンテキストは、プロセスやファイルを参照するコマンドに-Zオプションをつけて実行することで確認できます。

たとえば、ファイルやディレクトリに付与されているコンテキストを確認するにはls -lZコマンドを実行します。例として、Apache Webサーバー（httpd）に関するファイルを確認してみます。

```
# ls -lZ /var/www
合計 0
drwxr-xr-x. 2 root root system_u:object_r:httpd_sys_script_exec_t:s0 6  3月 13 03:17 cgi-bin
drwxr-xr-x. 2 root root system_u:object_r:httpd_sys_content_t:s0     6  3月 13 03:17 html
```

Webサーバーのコンテンツを含む/var/www/htmlディレクトリには「httpd_sys_content_t」というタイプが付与されています。この/var/www/htmlディレクトリ内にファイルを作成すると、親ディレクトリのコンテキストに従ってファイルにコンテキストが付与されます。

確認のために、/var/www/htmlディレクトリ以下にindex.htmlファイルを作成してみます。
親ディレクトリからコンテキストを継承し、index.htmlファイルに「httpd_sys_content_t」というタイプが付与されています。

```
# touch /var/www/html/index.html 
# ls -lZ /var/www/html/index.html 
-rw-r--r--. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0 0  7月 19 12:18 index.html
```

また、プロセスのコンテキストの情報を確認するには、ps axZコマンドを実行します。

以下の例では、httpdのプロセスを確認すると、httpd_tドメインが付与されていることが分かります。

```
[root@server ~]# service httpd start
httpd を起動中:                                            [  OK  ]
[root@server ~]# ps axZ | grep httpd
system_u:system_r:httpd_t:s0      37922 ?        Ss     0:00 /usr/sbin/httpd -DFOREGROUND
system_u:system_r:httpd_t:s0      37923 ?        S      0:00 /usr/sbin/httpd -DFOREGROUND
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
# getsebool -a | grep httpd
allow_httpd_anon_write --> off
allow_httpd_mod_auth_ntlm_winbind --> off
（略）
httpd_enable_homedirs --> off
（略）
```

後の作業でhttpd_enable_homedirsのBooleanを設定します。このBooleanは、Apache Webサーバーのユーザーホームディレクトリ機能に関する設定です。ユーザーホームディレクトリ機能は、各ユーザーのホームディレクトリに作成されたpublic_htmlディレクトリ内をWebコンテンツとして公開する仕組みです。

Apache Webサーバーの設定ファイル/etc/httpd/conf/httpd.confを修正し、UserDirディレクティブを設定してユーザーホームディレクトリ機能を有効にします。

```
# vi /etc/httpd/conf/httpd.conf

（略）
<IfModule mod_userdir.c>
    #
    # UserDir is disabled by default since it can confirm the presence
    # of a username on the system (depending on home directory
    # permissions).
    #
    ※#※UserDir disabled ※←行頭に#を追加

    #
    # To enable requests to /~user/ to serve the user's public_html
    # directory, remove the "UserDir disabled" line above, and uncomment
    # the following line instead:
    #
    UserDir public_html ※←行頭の#を削除
（略）
```

httpdサービスを再起動します。

```
# service httpd restart
httpd を停止中:                                            [  OK  ]
httpd を起動中:                                            [  OK  ]
```

ユーザーsatoでログインし、ホームディレクトリにpublic_htmlディレクトリを作成します。

```
$ pwd
/home/sato
$ mkdir public_html
```

/home/satoディレクトリ、/home/sato/public_htmlディレクトリのパーミッションを711に設定します。

```
$ chmod 711 /home/sato
$ chmod 711 /home/sato/public_html/
```

public_htmlディレクトリにindex.htmlファイルを作成します。

```
[sato@server ~]$ echo "SELinux test" > /home/sato/public_html/index.html
```

ブラウザを起動し、「http://192.168.0.10/~sato/」にアクセスします。SELinuxのアクセス制御が有効になっているため、「Forbidden」が表示されます。

![Forbidden](Forbidden.png)

rootユーザーでログファイル/var/log/audit/audit.logを確認します。httpd(httpd_t)がユーザーホームディレクトリ(user_home_dir_t)にアクセスできなかったというログが出力されています。

```
[root@server ~]# tail /var/log/audit/audit.log 
（略）
type=AVC msg=audit(1421241819.317:804): avc:  ※denied  { search }※ for  pid=7357 comm="httpd" name="sato" dev=dm-2 ino=130305 scontext=unconfined_u:system_r:※httpd_t※:s0 tcontext=unconfined_u:object_r:※user_home_dir_t※:s0 tclass=dir
type=SYSCALL msg=audit(1421241819.317:804): arch=c000003e syscall=4 success=no exit=-13 a0=7f7f0adf26e8 a1=7fff803d37c0 a2=7fff803d37c0 a3=1999999999999999 items=0 ppid=7352 pid=7357 auid=0 uid=48 gid=48 euid=48 suid=48 fsuid=48 egid=48 sgid=48 fsgid=48 tty=(none) ses=87 comm="httpd" exe="/usr/sbin/httpd" subj=unconfined_u:system_r:※httpd_t※:s0 key=(null)
type=AVC msg=audit(1421241819.317:805): avc:  ※denied  { getattr }※ for  pid=7357 comm="httpd" ※path="/home/sato"※ dev=dm-2 ino=130305 scontext=unconfined_u:system_r:※httpd_t※:s0 tcontext=unconfined_u:object_r:※user_home_dir_t※:s0 tclass=dir
type=SYSCALL msg=audit(1421241819.317:805): arch=c000003e syscall=6 success=no exit=-13 a0=7f7f0adf2798 a1=7fff803d37c0 a2=7fff803d37c0 a3=1 items=0 ppid=7352 pid=7357 auid=0 uid=48 gid=48 euid=48 suid=48 fsuid=48 egid=48 sgid=48 fsgid=48 tty=(none) ses=87 comm="httpd" exe="/usr/sbin/httpd" subj=unconfined_u:system_r:※httpd_t※:s0 key=(null)
```

setseboolコマンドを実行して、Boolean「httpd_enable_homedirs」を有効に設定します。

```
[root@server ~]# getsebool httpd_enable_homedirs
httpd_enable_homedirs --> off
[root@server ~]# setsebool httpd_enable_homedirs on
[root@server ~]# getsebool httpd_enable_homedirs
httpd_enable_homedirs --> on
```

再度ブラウザで「http://192.168.0.10/~sato/」にアクセスします。Booleanでアクセスが許可されたので、作成したページが表示されます。

## LVMの設定
LVM（Logical Volume Manager）は、ハードディスクなどの記憶媒体の物理的な状態を隠蔽し、論理的なイメージで管理するための技術です。

LVMを使うことで、複数のハードディスクにまたがったボリュームが作成できるようになり、ファイルシステムの容量が足りなくなった場合の容量の追加が簡単になります。ボリュームの操作は、システムを再起動することなく行うことができます。

また、ハードディスクに障害が発生した時には、新しいHDDを追加して、壊れているHDDを外すなどの障害対応が容易になります。
他にも、スナップショットを取ることができるなどのメリットがあります。

現在の一般的なLinuxディストリビューションでは、インストール時にLVMでパーティションを作成できます。AlmaLinuxでは、インストール時に自動パーティション設定を選択すると、デフォルトでLVMを使用してストレージを設定します。

LVMの詳しい説明に関しては、『高信頼システム構築標準教科書』を参照してください。

LVMは、物理ボリューム（PV: Physical Volume）、ボリュームグループ（VG: Volume Group）、論理ボリューム（LV: Logical Volume）の3つで構成されています。

### 物理ボリューム（PV）
物理ボリューム(PV)は、物理ディスクのパーティション単位で扱われます。一つの物理ディスクすべてを一つのPVとして扱うこともできますし、一つの物理ディスク内にパーティションを複数作成し、それぞれのパーティションを別々のPVとして扱うこともできます。

PVを作成するには、パーティションを作成し、パーティションタイプを8Eに設定します。

以下の例では、Linuxマシンに新規に追加した/dev/sdbとして認識されているハードディスクをLVMで使用できるよう、fdiskでパーティションを作成してPVとして設定しています。同時に、後の作業で領域拡張を行うための追加パーティションも作成しておきます。

```
# fdisk /dev/sdb
デバイスは正常な DOS 領域テーブルも、Sun, SGI や OSF ディスクラベルも
含んでいません
（略）

コマンド (m でヘルプ): ※n ←新規パーティション作成のnを入力
コマンドアクション
   e   拡張
   p   基本パーティション (1-4)
※p ←基本パーティションのpを入力
パーティション番号 (1-4): ※1 ←パーティション番号1を入力
最初 シリンダ (1-8354, 初期値 1): ※1 ←パーティション番号1を入力
Last シリンダ, +シリンダ数 or +size{K,M,G} (1-8354, 初期値 8354): ※+2G ←容量として+2GBを入力

コマンド (m でヘルプ): ※n ←新規パーティション作成のnを入力
コマンドアクション
   e   拡張
   p   基本パーティション (1-4)
※p ←基本パーティションのpを入力
パーティション番号 (1-4): ※2 ←パーティション番号2を入力
最初 シリンダ (263-8354, 初期値 263): ※Enterキーを入力
初期値 263 を使います
Last シリンダ, +シリンダ数 or +size{K,M,G} (263-8354, 初期値 8354): ※+2G ←容量として+2GBを入力

コマンド (m でヘルプ): ※t ←パーティションタイプ変更のtを入力
パーティション番号 (1-4): ※1 ←パーティション番号1を入力
16進数コード (L コマンドでコードリスト表示): ※8e ←LVM用の8eを入力
領域のシステムタイプを 1 から 8e (Linux LVM) に変更しました

コマンド (m でヘルプ): ※t ←パーティションタイプ変更のtを入力
パーティション番号 (1-4): ※2 ←パーティション番号2を入力
16進数コード (L コマンドでコードリスト表示): ※8e ←LVM用の8eを入力
領域のシステムタイプを 2 から 8e (Linux LVM) に変更しました

コマンド (m でヘルプ): ※w ←パーティション情報を書き込むwを入力
パーティションテーブルは変更されました！

ioctl() を呼び出してパーティションテーブルを再読込みします。
ディスクを同期しています。
```

### ボリュームグループ（VG）
ボリュームグループ(VG)は、1つ以上の物理ボリューム（PV）をひとまとめにしたものです。これは仮想的なディスクに相当します。

ボリュームグループはvgcreateコマンドで作成します。

```
vgcreate ボリューム名 PVデバイス名 [PVデバイス名 ...]
```

たとえば、物理ボリューム（PV）として作成した/dev/sdb1を使ってVolume00という名前のボリュームグループを作成するには、以下のvgcreateコマンドを実行します。

```
# vgcreate Volume00 /dev/sdb1
  Physical volume "/dev/sdb1" successfully created
  Volume group "Volume00" successfully created
```

また、ボリュームグループの情報はvgscanコマンドで確認できます。

```
# vgscan
  Reading all physical volumes.  This may take a while...
  Found volume group "Volume00" using metadata type lvm2
  Found volume group "vg_server" using metadata type lvm2
```

### 論理ボリューム（LV）
論理ボリューム（LV）は、ボリュームグループ（VG）上に作成する仮想的なパーティションです。Linuxからはデバイスとして認識されます。ハードディスクに物理パーティションを作成する場合と同様に、ボリュームグループをすべて一つの論理ボリュームとすることもできますし、一つのボリュームグループを複数の論理ボリュームに分割して使用することもできます。

論理ボリュームはlvcreateコマンドを使って作成します。

```
lvcreate -L サイズ -n 論理ボリューム名 ボリュームグループ名
```

たとえば、ボリュームグループVolume00にサイズ1GB、論理ボリューム名「LogVol01」の論理ボリュームを作成するには、以下のlvcreateコマンドを実行します。

```
# lvcreate -L 1024M -n LogVol01 Volume00
```

### 論理ボリュームにファイルシステムの作成
作成した論理ボリュームを利用するには、通常のパーティションと同じく論理ボリューム上にファイルシステムを作成します。論理ボリュームは、以下のようなデバイスとして扱うことができます。

```
/dev/ボリュームグループ名/論理ボリューム名
```

/dev/Volume00/LogVol01上にext4ファイルシステムを作成するために、mkfsコマンドを実行します。

```
# mkfs -t ext4 /dev/Volume00/LogVol01 
mke2fs 1.41.12 (17-May-2010)
Discarding device blocks: done                            
Filesystem label=
OS type: Linux
（略）
This filesystem will be automatically checked every 33 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.
```

mountコマンドを使って、/dev/Volume00/LogVol01をマウントします。

```
# mkdir /mnt/LVMtest
# mount -t ext4 /dev/Volume00/LogVol01 /mnt/LVMtest/
# mount /mnt/LVMtest/
mount: /dev/mapper/Volume00-LogVol01 は マウント済か /mnt/LVMtest が使用中です
mount: mtab によると、/dev/mapper/Volume00-LogVol01 は /mnt/LVMtest にマウント済です
```

### ボリュームグループへのディスクの追加
既存のボリュームグループVolume00に物理ボリューム/dev/sdb2を追加します。

vgextendコマンドを実行して、物理ボリューム/dev/sdb2をボリュームグループVolume00に追加します。

```
# vgextend Volume00 /dev/sdb2
  Physical volume "/dev/sdb2" successfully created
  Volume group "Volume00" successfully extended
```

vgdisplayコマンドを実行して、ボリュームグループVolume00の情報を確認します。PV（Physical volume）の数が2となっており、/dev/sdb2が加わっていることが分かります。

```
# vgdisplay Volume00
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
  Cur PV                ※2
  Act PV                ※2
  VG Size               4.01 GiB
  PE Size               4.00 MiB
  Total PE              1026
  Alloc PE / Size       256 / 1.00 GiB
  Free  PE / Size       770 / 3.01 GiB
  VG UUID               yTTwWd-G5tb-FzNb-Ow0L-ebvr-1n9I-ikLWo2
```

### 論理ボリュームの拡張
LVMでは、論理ボリュームのサイズを変更できます。また、LVMの論理ボリューム上に作成されたext4ファイルシステムは、ファイルシステムをマウントしたまま拡張できます。

dfコマンドを実行して、現在のファイルシステムの容量を確認します。現在の容量は1GBです。

```
# df /mnt/LVMtest/
Filesystem           1K-blocks  Used Available Use% Mounted on
/dev/mapper/Volume00-LogVol01
                        999320  1284    945608   1% /mnt/LVMtest
```

lvextendコマンドを実行して、論理ボリュームLogVol01のサイズを2Gまで拡大します。

```
# lvextend -L 2G /dev/Volume00/LogVol01
 Size of logical volume Volume00/LogVol01 changed from 1.00 GiB (256 extents) to 2.00 GiB (512 extents).
  Logical volume LogVol01 successfully resized
```

resize2fsコマンドを実行して、ファイルシステムを拡大します。

```
# resize2fs /dev/Volume00/LogVol01
resize2fs 1.41.12 (17-May-2010)
Filesystem at /dev/Volume00/LogVol01 is mounted on /mnt/LVMtest; on-line resizing required
old desc_blocks = 1, new_desc_blocks = 1
Performing an on-line resize of /dev/Volume00/LogVol01 to 524288 (4k) blocks.
The filesystem on /dev/Volume00/LogVol01 is now 524288 blocks long.
```

dfコマンドで再度容量を確認します。容量が2GBに増えていることが確認できます。

```
# df /mnt/LVMtest/
Filesystem           1K-blocks  Used Available Use% Mounted on
/dev/mapper/Volume00-LogVol01
                       2031440  1536   1925060   1% /mnt/LVMtest
```

### 論理ボリュームの縮小
運用上、他の論理ボリュームを拡大したい等の理由で使用率の低い論理ボリュームの縮小を行う場合があります。
論理ボリュームを縮小するには、先にファイルシステムを縮小し、その後に論理ボリュームを縮小する必要があります。ファイルシステムの縮小はマウントしたままでは行えないので、作業中は一度アンマウントしておく必要があります。

縮小したいボリュームをアンマウントします。umountコマンドを実行して、/mnt/LVMtestをアンマウントします。

```
# umount /mnt/LVMtest/
```

縮小したい論理ボリューム/dev/Volume00/LogVol01に対してfsckコマンドを実行します。強制的にチェックを行うために-fオプションを付与して実行します。

```
# fsck -f /dev/Volume00/LogVol01 
fsck from util-linux-ng 2.17.2
e2fsck 1.41.12 (17-May-2010)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/mapper/Volume00-LogVol01: 11/131072 files (0.0% non-contiguous), 16812/524288 blocks
```

resize2fsコマンドを実行して、ファイルシステムを縮小します。例として、1GBまで縮小します。

```
# resize2fs /dev/Volume00/LogVol01 1G
resize2fs 1.41.12 (17-May-2010)
Resizing the filesystem on /dev/Volume00/LogVol01 to 262144 (4k) blocks.
The filesystem on /dev/Volume00/LogVol01 is now 262144 blocks long.
```

lvreduceコマンドを実行して、論理ボリューム/dev/Volume00/LogVol01を縮小します。

```
# lvreduce -L 1G /dev/Volume00/LogVol01
  WARNING: Reducing active logical volume to 1.00 GiB
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce LogVol01? [y/n]: ※y ←yを入力
  Size of logical volume Volume00/LogVol01 changed from 2.00 GiB (512 extents) to 1.00 GiB (256 extents).
  Logical volume LogVol01 successfully resized
```

/mnt/LVMtestに再マウントして、容量を確認します。

```
# mount -t ext4 /dev/Volume00/LogVol01 /mnt/LVMtest/
# df /mnt/LVMtest/
Filesystem           1K-blocks  Used Available Use% Mounted on
/dev/mapper/Volume00-LogVol01
                        999320  1284    945616   1% /mnt/LVMtest
```

