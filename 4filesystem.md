# ファイルシステムの管理

## アクセス権の管理

LinuxはPOSIXで示されているアクセス制御に準拠しています。POSIXとは「Portable Operating System Interface for UNIX」の略で、IEEEによって定められた、UNIXベースのOSの仕様セットです。ユーザID（uid）/グループID（gid）とパーミッションの組み合わせでファイルに対するアクセス権を管理しています。

### UIDとGID

ユーザID（uid：User Identifier)はLinuxシステムでユーザを識別するためのユニークな番号です。Linuxで追加されたユーザカウントには、それぞれ個別にuidが割り振られます。
uidは0から65535までの値をとります。0は特別なユーザIDで、管理者権限を持つrootユーザに付与されています。

グループID（gid: Group Identifier）はグループを識別するためのユニークな番号です。Linuxのユーザは、1つ以上のグループに所属することができます。
gidは0から65535までの値をとります。

### 検証用ユーザ、グループの確認

アクセス制御の動作確認のため、検証用のユーザを用意します。すでに1章で作成していますが、作成されていない場合にはuseraddコマンド、grooupaddコマンドなどを使用して作成して下さい。

ユーザsatoとユーザsuzukiが作成されており、ユーザsuzukiはwheelグループとeigyouグループに所属しています。

```shell-session
# id sato
uid=500(sato) gid=500(sato) 所属グループ=500(sato)
# id suzuki
uid=501(suzuki) gid=501(suzuki) 所属グループ=501(suzuki),10(wheel),5000(eigyou)
```

### 別々のユーザとして作業する

ユーザsatoとユーザsuzuki での操作をスムーズに行うため、それぞれ別々のユーザでログインします。

Linuxサーバとは別の端末で操作を行っている場合には、それぞれのユーザでログインします。

Linuxサーバ上のX Window Systemで操作を行っている場合には、rootユーザでログインした後、別々のターミナルを起動し、suコマンドを使ってユーザを切り替えるとよいでしょう。

ターミナルAでユーザsatoに切り替えます。

```shell-session
[root@server ~]# su - sato
[sato@server ~]$ id
uid=500(sato) gid=500(sato) 所属グループ=500(sato) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

ターミナルBでユーザsuzukiに切り替えます。

```shell-session
[root@server ~]# su - suzuki
[suzuki@server ~]$ id
uid=501(suzuki) gid=501(suzuki) 所属グループ=501(suzuki),10(wheel),5000(eigyou) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

### プロセスの実行権の管理

Linuxでは、rootユーザを除いて他のユーザが起動したプロセスを停止させることはできません。

以下の例では、ユーザsatoでviエディタ（vim）を起動して/tmpにファイルを作成しようとしているプロセスをユーザsuzukiがkillコマンドで停止しようとしますが、停止できません。

ユーザsatoがviエディタで/tmp/satoを作成します。

```shell-session
[sato@server ~]$ vi /tmp/sato
```

ユーザsuzukiがvimプロセスを確認します。

```shell-session
[suzuki@server ~]$ ps aux | grep vim
sato      6456  0.1  0.3 148100  3692 pts/2    S+   19:46   0:00 vim /tmp/sato
suzuki    6462  0.0  0.0 107464   916 pts/3    S+   19:46   0:00 grep vim
```

ユーザsuzukiがユーザsatoが実行中のvimエディタのプロセスをkillコマンドで停止しようとしますが、停止できません。指定するプロセスIDは、psコマンドの2番目の表示項目です。

```shell-session
[suzuki@server ~]$ kill 6456
-bash: kill: (6456) - 許可されていない操作です
```

ユーザsatoは「:q!」と入力してvimエディタを終了します。

### ファイルのアクセス権の管理

ユーザsatoが作成したファイル/tmp/satoを使って、アクセス権の動作を検証します。

ユーザsatoでファイル/tmp/satoのアクセス権を確認します。その他のユーザへのアクセス権は読み取りのみ与えられています。

```shell-session
[sato@server ~]$ ls -l /tmp/sato
-rw-rw-r--. 1 sato sato 5 12月  9 17:51 2014 /tmp/sato
```

ユーザsuzukiでcatコマンドを実行し、ファイル/tmp/satoの内容を確認します。その他のユーザへの読み取りは許可されているので、内容を確認できます。

```shell-session
[suzuki@server ~]$ cat /tmp/sato
sato
```

ユーザsuzukiでファイル/tmp/satoに追記してみます。書き込みのアクセス権は与えられていないのでエラーとなります。

```shell-session
[suzuki@server ~]$ echo "suzuki" >> /tmp/sato
-bash: /tmp/sato: 許可がありません
```

### umaskとデフォルトのパーミッションの関係

umaskとは、ファイルやディレクトリが新規に作成される際にデフォルトのパーミッションを決定するための値です。umaskコマンドで確認できます。

```shell-session
[sato@server ~]$ umask
0002
```

umaskの設定値には、新しくファイルを作成する際に設定しない（許可しない）パーミッションを8進数で指定します。

|                | 読み取り | 書き込み | 実行 |
| -------------- | -------- | -------- | ---- |
| パーミッション | r        | w        | x    |
| 8進数値        | 4        | 2        | 1    |

ファイルとディレクトリでは設定されるデフォルトのパーミッションが変わるので、それぞれ確認してみましょう。

### ファイル作成のパーミッションとumask

ファイルが新規作成される際にはファイルの実行パーミッション(eXecute)は設定しないので、0666(rw-rw-rw-)に対してumaskの値が適用されます。

umaskが0002と設定されていると、その他のユーザの書き込みのパーミッション（w）が設定されていないファイル（-rw-rw-r--、0664）が作成されます。

```shell-session
[sato@server ~]$ umask
0002
[sato@server ~]$ touch testfile
[sato@server ~]$ ls -l testfile
-rw-rw-r--. 1 sato sato 0  1月 14 19:51 2015 testfile
```

### ディレクトリ作成のパーミッションとumask

ディレクトリが新規作成される際には、実行パーミッション(eXecute)が必要になるので、0777(rwxrwxrwx)に対してumaskの値が適用されます。実行パーミッションが必要になるのは、1章でも説明したとおり、そのディレクトリをカレントディレクトリにするためには実行パーミッションが必要になるからです。

umaskが0002と設定されていると、その他のユーザの書き込みのパーミッション（w）が設定されないディレクトリ（-rwxrwxr-x、0775）が作成されています。

```shell-session
[sato@server ~]$ umask
0002
[sato@server ~]$ mkdir testdir
[sato@server ~]$ ls -ld testdir
drwxrwxr-x. 2 sato sato 4096  1月 14 19:52 2015 testdir
```

### umaskが4桁の理由

パーミッションは通常、ユーザ、グループ、その他のユーザの3つに対するアクセス権が設定されますが、umaskの値は4桁になっています。これは、通常のパーミッションの先頭に、setUID/setGID/スティッキービットを表す桁が含まれるためです。setUIDなどについては後述します。
また、通常setUIDなどをデフォルトパーミッションとして設定することはないので、umaskは先頭を省略して3桁で設定することもできます。
以下の例では、umaskを022と3桁で設定していますが、umaskコマンドの結果は0022になっています。

```shell-session
[sato@server ~]$ umask 022
[sato@server ~]$ umask
0022
```

### umaskを変更する

umaskを変更したい場合には、umaskコマンドで設定したumask値を引数として与えます。
以下の例では、umaskの値を0022に変更したので、新規に作成したファイルのアクセス権は644(-rw-r--r--)に設定されています。

```shell-session
[sato@server ~]$ umask 0022
[sato@server ~]$ touch umasktest
[sato@server ~]$ ls -l umasktest
-rw-r--r--. 1 sato sato 0  1月 14 19:53 2015 umasktest
```

### rootユーザのumaskとデフォルトのumask

一般ユーザのumaskの値は0002ですが、rootユーザのumaskの値は0022に設定されています。

```shell-session
[root@server ~]# umask
0022
```

これは、bashシェルを起動する際に読み込まれるシェルスクリプト/etc/bashrcの中でデフォルトのumaskが設定されているためです。以下のように、uidが200以上で、かつuidとgidが同じ場合にはumaskの値は0002（002と3桁表記）、それ以外は0022に設定されるように処理されています。

同様の処理は/etc/profileでも行われています。

```shell-session
# cat /etc/bashrc
（略）
    # By default, we want umask to get set. This sets it for non-login shell.
    # Current threshold for system reserved uid/gids is 200
    # You could check uidgid reservation validity in
    # /usr/share/doc/setup-*/uidgid file
    if [ $UID -gt 199 ] && [ "`id -gn`" = "`id -un`" ]; then
       umask 002
    else
       umask 022
    fi
（略）
```

uidとgidが同じであることを確認しているのは、useraddコマンドでユーザアカウントを新規に作成すると、特別設定しない限り指定されたユーザ名と同じ名前のグループを作成し、uidとgidが同じになるためです。つまり、uidとgidが同じユーザは、useraddコマンドを使ってシンプルに作成されたユーザアカウントと判定できるということになります。

### setUIDの確認

setUIDが実行ファイルに設定されていると、その実行ファイルは所有ユーザの権限で実行されます。setUIDが設定されている場合、lsコマンドの出力で所有ユーザの実行パーミッションが「s」と表示されます。

setUIDが設定されている例として、passwdコマンドがあります。一般ユーザがパスワードを変更するには、rootユーザだけが書き込める/etc/shadowファイルに対する変更が必要です。パスワードを変更するpasswdコマンドは、所有ユーザがrootユーザでsetUIDが設定されているので、一般ユーザがpasswdコマンドを実行すると、rootユーザの権限で実行されて/etc/shadowファイルに変更を加えることができます。

コマンドを実行したユーザを「実行ユーザ」、setUIDで権限が変更されたユーザを「実効ユーザ」と呼びます。

以下の例では、passwdコマンドを一時停止して、psコマンドで実効ユーザを確認しています。

setUIDが設定されていることを確認します。

```shell-session
[sato@server ~]$ ls -l /usr/bin/passwd
-rwsr-xr-x. 1 root root 30768  2月 22 20:48 2012 /usr/bin/passwd
```

passwdを実行し、Ctrl+Zキーで一時停止します。一時停止後、シェルプロンプトに戻すためにはEnterキーを押す必要があります。

```shell-session
[sato@server ~]$ passwd
ユーザー sato のパスワードを変更。
sato 用にパスワードを変更中
現在のUNIXパスワード: ※Ctrl+Zキーを入力後、Enterキーを押す
[1]+  停止                  passwd
```

psコマンドで実効ユーザを確認します。passwdコマンドの実効ユーザがrootであることが確認できます。

```shell-session
[sato@server ~]$ ps aux | grep passwd
root     15052  0.0  0.2 164012  2068 pts/1    T    10:47   0:00 passwd
sato     15178  0.0  0.0 107464   916 pts/1    S+   10:48   0:00 grep passwd
```

fgコマンドで一時停止したpasswdコマンドをフォアグラウンドプロセスに戻し、Ctrl+Cキーで終了します。

```shell-session
[sato@server ~]$ fg
passwd
※^C ←Ctrl+Cキーを入力
[sato@server ~]$
```

### setGIDの確認

setGIDが設定されていると、所有グループの権限で実行されます。setGIDは所有グループの実行パーミッションが「s」と表示されます。

setGIDが設定されている例として、writeコマンドやslocateコマンドがあります。

```shell-session
$ ls -l /usr/bin/write
-rwxr-sr-x  1 root tty 10124 2月 18日  2011 /usr/bin/write
$ ls -l /usr/bin/slocate
-rwxr-sr-x  1 root slocate 38516 11月 17日  2007 /usr/bin/slocate
```

writeコマンドは、ログインしている他のユーザに対してメッセージを送るコマンドです。以下の例では、writeコマンドを一時停止して、psコマンドで実効グループを確認しています。

2つのユーザアカウントでログインします。同じユーザアカウントでも構いません。
writeコマンドを実行し、Ctrl+Zキーで一時停止します。

```shell-session
[sato@server ~]$ write suzuki
※^Z ←Ctrl+Zキーを入力
[1]+  停止                  write suzuki
```

psコマンドで実効グループを確認します。

```shell-session
[sato@server ~]$ ps a -eo "%p %u %g %G %y %c" | grep write
23400 sato     sato     ※tty※      pts/1    write
```

表示は左から、プロセスID（%p）、実行ユーザ（%u）、実行グループ（%g）、実効グループ（%G）、実効端末（%y）、コマンド（%c）となっています。実行したのはユーザsatoですが、setGIDされているためttyグループとして動作していることが確認できます。

ttyとは「Tele-TYpewriter」の意味で、端末を表します。writeコマンドはログインしている他のユーザの端末にメッセージを表示するためにsetGIDを行って実効グループをttyグループにしているわけです。

### スティッキービット

スティッキービットが設定されたファイルやディレクトリは、「すべてのユーザが書き込めるが、所有者しか削除できない」というアクセス権限が設定されます。

たとえば/tmpディレクトリに対してスティッキービットが設定されています。/tmpディレクトリは全てのユーザやアプリケーションが書き込めるディレクトリとして、一時ファイルの作成などに使用されています。しかし/tmpディレクトリのパーミッションを777（rwxrwxrwx）に設定すると、作成したファイルを他のユーザが削除できてしまいます。そこで/tmpディレクトリにスティッキービットを設定すると、そのファイルを削除できるのは作成したユーザのみとなります。

スティッキービットが設定されていると、lsコマンドの出力でその他のユーザの実行パーミッションが「t」と表示されます。

```shell-session
[sato@server ~]$ ls -ld /tmp
drwxrwxrwt. 16 root root 4096  1月 14 20:26 2015 /tmp
```

ユーザsatoで/tmp/sbittestを作成し、パーミッションを666に設定します。

```shell-session
[sato@server ~]$ touch /tmp/sbittest
[sato@server ~]$ chmod 666 /tmp/sbittest
[sato@server ~]$ ls -l /tmp/sbittest
-rw-rw-rw-. 1 sato sato 0  1月 14 20:28 2015 /tmp/sbittest
```

ユーザsuzukiで/tmp/sbittestに書き込みをします。その他のユーザーに対する書き込みのパーミッションが付与されているので書き込みが行えます。

```shell-session
[suzuki@server ~]$ echo "suzuki" >> /tmp/sbittest
[suzuki@server ~]$ cat /tmp/sbittest
suzuki
```

ユーザsuzukiで/tmp/sbittestを削除しようとしますが、スティッキービットが働いて削除できません。

```shell-session
[suzuki@server ~]$ rm /tmp/sbittest
rm: cannot remove `/tmp/sbittest': 許可されていない操作です
```

ユーザsatoで/tmp/sbittestを削除します。所有ユーザは削除が行えます。

```shell-session
[sato@server ~]$ rm /tmp/sbittest
```

## POSIX ACL

ACL(Access Control List。POSIX準拠のACLのため、POSIX ACLとも呼ばれる)は、Linuxカーネル2.6から標準採用されており、従来のLinuxでのアクセス権限よりも細かにアクセス権限を設定できる技術です。
Linux以外のOS、たとえばWindowsなどでもACLをサポートしており、付加できる権限の種類もより細やかなものになっています。Linuxでも、Windows向けのファイルサーバとしてSambaを利用する場合などには、同様のアクセス権限設定を行うためにACLが必要です。

### ACLを有効にする条件と確認

ACLはファイルシステムの拡張属性を利用しているため、拡張属性がサポートされているファイルシステムを用いる必要があります。ext3やext4、XFSなどほとんどのファイルシステムでは拡張属性がサポートされています。
また、ファイルシステムによってはマウントする際にmountコマンドにaclオプションを指定する必要がありますが、CentOS 6で標準で利用しているext4ではデフォルトでACLが有効になっているので、aclオプションの指定は必要ありません。

ACLが使用できるかは、lsコマンドでパーミッションを確認した時に、パーミッションの最後に"."が表示されていることで判別できます。

"."は、そのファイルにACLが設定されていないことを意味しています。ACLが設定されると"+"に表示が変更されます。

### ACLの設定例

実際にACLを設定してみます。getfaclコマンドはファイルやディレクトリに対して、設定されているACLを表示するコマンドです。また、setfaclはファイルやディレクトリに対して、ACLを設定するコマンドです。

ユーザsatoで/tmp/acltestファイルを作成します。

```shell-session
[sato@server ~]$ touch /tmp/acltest
```

getfaclコマンドで/tmp/acltestファイルのACLを確認します。

```shell-session
[sato@server ~]$ getfacl /tmp/acltest
getfacl: Removing leading '/' from absolute path names
# file: tmp/acltest
# owner: sato
# group: sato
user::rw-
group::r--
other::r--
```

ユーザsuzukiで/tmp/acltestファイルに書き込みをします。その他のユーザにはパーミッションが付与されていないので書き込みが行えません。

```shell-session
[suzuki@server ~]$ echo "suzuki" >> /tmp/acltest
-bash: /var/tmp/acltest: 許可がありません
```

ユーザsatoでsetfaclコマンドを実行して、ユーザsuzukiの/tmp/acltestに対する読み書きのACLを設定します。

```shell-session
[sato@server ~]$ setfacl -m u:suzuki:rw /tmp/acltest
[sato@server ~]$ getfacl /tmp/acltest
getfacl: Removing leading '/' from absolute path names
# file: tmp/acltest
# owner: sato
# group: sato
user::rw-
※user:suzuki:rw- ユーザsuzukiに対するACLが設定されている
group::rw-
mask::rw-
other::r--
```

ユーザsuzukiで再度/tmp/acltestファイルに書き込みをします。ACLが設定されたので書き込みが行えます。

```shell-session
[suzuki@server ~]$ echo "suzuki" >> /tmp/acltest
[suzuki@server ~]$ cat /tmp/acltest
suzuki
```

ユーザsatoでsetfaclコマンドを実行して、ユーザsuzukiの/tmp/acltestに対する読み書きのACLを削除します。

```shell-session
[sato@server ~]$ setfacl -x u:suzuki /tmp/acltest
[sato@server ~]$ getfacl /tmp/acltest
getfacl: Removing leading '/' from absolute path names
# file: tmp/acltest
# owner: sato
# group: sato
user::rw-
group::rw-
mask::rw-
other::r--
```

ユーザsuzukiで/tmp/acltestファイルに再度書き込みをします。ACLが削除されたので書き込みが行えません。

```shell-session
[suzuki@server ~]$ echo "suzuki" >> /tmp/acltest
-bash: /var/tmp/acltest: 許可がありません
```

### SambaとACLの関係

SambaでWindowsクライアントに対してファイル共有を提供した際に、Windowsで設定した細かな権限はLinux上ではACLを用いて実現されています。

例として、/home/sato以下にsamba_ACL_testディレクトリを作成し、ACLの設定を行ってみます。

#### Sambaのインストールと設定

Sambaをインストールします。

```shell-session
# yum install samba
```

Sambaの設定ファイル/etc/samba/smb.confのworkgroup設定を変更します。ワークグループ名はWindowsクライアントの参加しているワークグループに合わせます。WindowsクライアントのデフォルトのワークグループはWORKGROUPです。

```shell-session
vi /etc/samba/smb.conf

        workgroup = ※WORKGROUP ←ワークグループ名を変更※
```

Sambaを起動します。smbサービスとnmbサービスを起動します。

```shell-session
# service smb start
SMB サービスを起動中:                                      [  OK  ]
# service nmb start
NMB サービスを起動中:                                      [  OK  ]
```

#### iptablesの設定変更

iptablesの設定を変更します。system-config-firewall-tuiコマンドを実行してカスタマイズ設定でSambaを許可するか、/etc/sysconfig/iptablesに以下の4行を設定してiptablesサービスをreloadします。Sambaの使用しているSMB/CIFSプロトコルはTCPとUDPの2種類である点に注意してください。

```shell-session
-A INPUT -m state --state NEW -m udp -p udp --dport 137 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 138 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 139 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 445 -j ACCEPT
```

#### SELinuxの設定変更

SELinuxが有効な場合、SELinuxの設定を変更します。以下のsetseboolコマンドを実行して、Samba経由でユーザのホームディレクトリへのアクセスを許可します。SELinuxの設定については後述します。

```shell-session
# setsebool -P samba_enable_home_dirs on
```

#### Sambaユーザの登録

smbpasswdコマンドでSambaユーザを登録します。ユーザアカウントはあらかじめLinuxに登録されているユーザアカウントを指定する必要があります。ここではユーザsatoを指定しています。入力したパスワードは、Windowsクライアントからファイル共有へアクセスする際の認証に使用します。

```shell-session
# smbpasswd -a sato
New SMB password: ※パスワードを入力
Retype new SMB password: ※パスワードを再入力
Added user sato.
```

#### WindowsクライアントからSambaへのアクセス

WindowsクライアントからSambaのファイル共有にアクセスします。

1. Sambaへのアクセスを指定します。

![Sambaへのアクセス](samba0.png)

「スタート」ボタン→「プログラムとファイルの検索」に「\\server\」、あるいは「\\192.168.0.10」と入力します。

＃2

2. ユーザ認証を行います。

![ユーザ認証](samba1.png)

ユーザ認証が要求された場合には、前の手順で登録したユーザ名、パスワードで認証を行います。

＃3

3. ユーザホーム共有にアクセスします。

![ユーザホーム共有](samba2.png)

ユーザアカウント名のファイル共有（sato）のアイコンをダブルクリックで開きます。これはSambaがユーザのホームディレクトリを自動的に共有として扱う、ユーザホーム共有の機能を使っています。

＃4

4. テスト用のフォルダを作成します。

![samba_acl_testフォルダ](samba3.png)

samba_acl_testフォルダを作成します。

＃5

5. フォルダのプロパティウインドウを呼び出します。

![プロパティ](samba4.png)

Windowsクライアントでsamba_acl_testフォルダを右クリックして、「プロパティ」を選択します。「セキュリティ」タブをクリックして、「詳細設定」ボタンをクリックします。

＃6

6. アクセス許可エントリを確認します。

![読み書きのみ](samba5.png)

「Everyone」をダブルクリックして、「許可」が5つチェックされていることを確認します。「OK」ボタンをクリックします。さらにOKボタンをクリックして、プロパティのウインドウに戻ります。

#### LinuxからACLを確認

1. ユーザsatoでログインし、ホームディレクトリに作られたsamba_acl_testディレクトリのACLを確認します。

```shell-session
[sato@server ~]$ getfacl samba_acl_test/
# file: samba_acl_test/
# owner: sato
# group: sato
user::rwx
group::r-x
other::r-x
```

＃2

2. setfaclコマンドを実行して、samba_acl_testディレクトリに対して、その他のユーザに書き込みのACLを付与します。

```shell-session
[sato@server ~]$ setfacl -m o::rwx samba_acl_test
[sato@server ~]$ getfacl samba_acl_test/
# file: samba_acl_test/
# owner: sato
# group: sato
user::rwx
group::r-x
other::r※w※x ※←書き込み権限が付与されている
```

＃3

3. Windowsクライアントで再度アクセス許可エントリを確認します。

![すべてのアクセス許可](samba5.png)

Windowsクライアントで再度「詳細設定」ボタンをクリックします。「Everyone」をダブルクリックして、すべてのアクセス許可項目がチェックされていることを確認します。

## SELinux

SELinuxはLinuxカーネル2.6から実装された、rootユーザの特権に対しても制限を掛けることができる強制アクセス制御（MAC、Mandatory Access Control）の仕組みです。

本教科書では、SELinuxの基本的な管理について解説します。SELinuxのより詳しい説明については、『Linuxセキュリティ標準教科書』を参照してください。

### SELinuxの仕組み

SELinuxでは、プロセスやファイルなどLinuxの全てのリソースに対して「コンテキスト」（contexts）と呼ばれるラベルを付加し、「サブジェクト」（subject。アクセスする側。主にプロセス）が「オブジェクト」（object。アクセスされる側。主にファイルやディレクトリ、プロセス）に対してアクセスを行う際に、そのコンテキストを比較することによりアクセス制御を行います。

複数のコンテキストを組み合わせて、アクセスの可否を行うルールをSELinuxでは「ポリシー」と呼びます。ポリシーの詳細な説明と修正に関しては、『Linuxセキュリティ標準教科書』を参照してください。

### SELinuxの有効、無効の確認

SELinuxの状態はgetenforceコマンドで確認できます。

```shell-session
[root@server ~]# getenforce
Enforcing
```

getenforceコマンドの結果は以下の通りです。

| 結果       | 状態                                    |
| ---------- | --------------------------------------- |
| Enforcing  | SELinuxによるアクセス制御が有効         |
| Permissive | SELinuxは有効であるが動作拒否は行わない |
| Disabled   | SELinuxによるアクセス制御が無効         |

SELinuxの状態は、setenforceコマンドによる動的な変更か、設定ファイル/etc/selinux/configによる静的な変更のいずれかで変更できます。

### setenforceコマンドによるSELinuxの動的な変更

setenforceコマンドでSELinuxの状態を動的に変更できます。変更はrootユーザで実行する必要があります。

ただし、動的に変更できるのはEnforcingとPermissiveの切り替えのみで、SELinuxを有効から無効（Disabled）に、あるいは無効から有効に変更することはできません。
有効、無効の切り替えは、後述する設定ファイルによる静的な変更とシステムの再起動が必要です。

```
setenforce [ Enforcing | Permissive | 1 | 0 ]
```

たとえば、システムのSELinuxによるアクセス制御を一時的に適用しないようにしたいときには状態をPermissiveに変更します。SELinuxによるアクセス制御での動作の拒否は行われなくなりますが、デバッグなどの用途のためにSELinuxのポリシー違反が発生するとログは出力されます。
システムが思ったように動作せず、SELinuxが原因と思われる時などにPermissiveに設定して、SELinuxが原因かどうかの切り分け作業を行います。

```shell-session
# setenforce permissive
# getenforce
Permissive
```

### SELinuxの無効化

SELinuxを無効にする、あるいは無効から有効に変更するにはSELinuxの設定ファイル/etc/selinux/configの設定を変更します。システムを再起動すると、設定が反映されます。

/etc/selinux/configを編集し、設定項目SELINUXの値をdisabledに変更します。

```shell-session
# vi /etc/selinux/config

※#※SELINUX=enforcing ※←行頭に#を追加
※SELINUX=disabled ←新たに追加
```

システムを再起動します。

```shell-session
# reboot
```

getenforceコマンドでSELinuxが無効（Disabled）になったことを確認します。

```shell-session
# getenforce
Disabled
```

/etc/selinux/configを編集し、設定項目SELINUXの値をenforcingに変更します。

```shell-session
# vi /etc/selinux/config

SELINUX=enforcing ※←行頭の#を削除
※#※SELINUX=disabled ※←行頭に#を追加
```

システムを再起動します。

```shell-session
# reboot
```

getenforceコマンドでSELinuxが有効（Enforcing）になったことを確認します。

```shell-session
# getenforce
Enforcing
```

### コンテキストの確認

コンテキストはファイルなどに設定され、アクセス制御に利用されます。コンテキストは、次の4つの識別子で構成されています。

- ユーザ(user)
- ロール(role)
- タイプ(type)：プロセスの場合には特に「ドメイン」とも言います
- MLS：高度なMulti Level Securityを提供できますが、通常のシステムではあまり使われません

コンテキストは、これらの識別子を組み合わせて、以下の形式で表されます。

```
ユーザ:ロール:タイプ:MLSレベル
```

SELinuxでのアクセス制御は、タイプ／ドメインに対して許可する動作を定義した「ポリシー」に基づいて行われます。タイプ／ドメインの名前は、役割やプロセス名からつけられています。たとえば、Apache Webサーバのプロセスであるhttpdには「httpd_t」というドメインがつけられています。

### コンテキストの確認

SELinuxのアクセス制御で用いられるコンテキストは、プロセスやファイルを参照するコマンドに-Zオプションをつけて実行することで確認できます。

たとえば、ファイルやディレクトリに付与されているコンテキストを確認するにはls -lZコマンドを実行します。例として、Apache Webサーバ（httpd）に関するファイルを確認してみます。

```shell-session
# ls -lZ /var/www
drwxr-xr-x. root root system_u:object_r:httpd_sys_script_exec_t:s0 cgi-bin
drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 error
drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 html
drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 icons
```

/var/www/htmlディレクトリや/var/www/iconsディレクトリなど、Webサーバのコンテンツを含むディレクトリには「httpd_sys_content_t」というタイプが付与されています。この/var/www/htmlディレクトリ内にファイルを作成すると、親ディレクトリのコンテキストに従ってファイルにコンテキストが付与されます。

確認のために、/var/www/htmlディレクトリ以下にindex.htmlファイルを作成してみます。
親ディレクトリからコンテキストを継承し、index.htmlファイルに「httpd_sys_content_t」というタイプが付与されています。

```shell-session
# touch /var/www/html/index.html
# ls -lZ /var/www/html/index.html
-rw-r--r--. root root unconfined_u:object_r:※httpd_sys_content_t※:s0 /var/www/html/index.html
```

また、プロセスのコンテキストの情報を確認するには、ps axZコマンドを実行します。

以下の例では、httpdのプロセスを確認すると、httpd_tドメインが付与されていることが分かります。

```shell-session
[root@server ~]# service httpd start
httpd を起動中:                                            [  OK  ]
[root@server ~]# ps axZ | grep httpd
unconfined_u:system_r:httpd_t:s0 27104 ?       Ss     0:00 /usr/sbin/httpd
unconfined_u:system_r:httpd_t:s0 27106 ?       S      0:00 /usr/sbin/httpd
（略）
```

SELinuxのポリシーでは、httpdプロセスに付与されているhttpd_tドメインが、「httpd_sys_content_t」などのタイプが付与されているファイルにread（読み取り）などが行えるように権限が設定されています。

### Booleanを使ったSELinuxの制御

SELinuxを有効にしてアプリケーションがうまく動作しない場合には、SELinuxのアクセス制御によってプロセスがファイルやディレクトリにアクセスできないことが原因の場合があります。そのような時には、SELinuxのポリシーを設定する必要があります。

一般的なポリシーの設定は「Boolean」（ブーリアン）と呼ばれる設定の有効、無効で対応できます。Booleanで設定できる項目は、CentOS 6では、200種ほどあります。

もし、独自のアプリケーションを使用したり、アプリケーションの設定を大幅に変更した場合には、ポリシーを追加、修正する必要があります。ポリシーの追加、修正方法については『Linuxセキュリティ標準教科書』を参照してください。

以下の例では、Apache Webサーバ(httpd)に関するポリシーを設定しています。

getseboolコマンドでBooleanの設定状況一覧を確認します。Boolean名には関係するプロセス名が含まれているので、grepコマンドで「httpd」をキーワードにして検索します。

```shell-session
# getsebool -a | grep httpd
allow_httpd_anon_write --> off
allow_httpd_mod_auth_ntlm_winbind --> off
（略）
httpd_enable_homedirs --> off
（略）
```

後の作業でhttpd_enable_homedirsのBooleanを設定します。このBooleanは、Apache Webサーバのユーザホームディレクトリ機能に関する設定です。ユーザホームディレクトリ機能は、各ユーザのホームディレクトリに作成されたpublic_htmlディレクトリ内をWebコンテンツとして公開する仕組みです。

Apache Webサーバの設定ファイル/etc/httpd/conf/httpd.confを修正し、UserDirディレクティブを設定してユーザホームディレクトリ機能を有効にします。

```shell-session
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

```shell-session
# service httpd restart
httpd を停止中:                                            [  OK  ]
httpd を起動中:                                            [  OK  ]
```

ユーザsatoでログインし、ホームディレクトリにpublic_htmlディレクトリを作成します。

```shell-session
$ pwd
/home/sato
$ mkdir public_html
```

/home/satoディレクトリ、/home/sato/public_htmlディレクトリのパーミッションを711に設定します。

```shell-session
chmod 711 /home/sato
chmod 711 /home/sato/public_html/
```

public_htmlディレクトリにindex.htmlファイルを作成します。

```shell-session
[sato@server ~]$ echo "SELinux test" > /home/sato/public_html/index.html
```

ブラウザを起動し、「<http://192.168.0.10/~sato/」にアクセスします。SELinuxのアクセス制御が有効になっているため、「Forbidden」が表示されます。>

![Forbidden](Forbidden.png)

rootユーザでログファイル/var/log/audit/audit.logを確認します。httpd(httpd_t)がユーザホームディレクトリ(user_home_dir_t)にアクセスできなかったというログが出力されています。

```shell-session
[root@server ~]# tail /var/log/audit/audit.log
（略）
type=AVC msg=audit(1421241819.317:804): avc:  ※denied  { search }※ for  pid=7357 comm="httpd" name="sato" dev=dm-2 ino=130305 scontext=unconfined_u:system_r:※httpd_t※:s0 tcontext=unconfined_u:object_r:※user_home_dir_t※:s0 tclass=dir
type=SYSCALL msg=audit(1421241819.317:804): arch=c000003e syscall=4 success=no exit=-13 a0=7f7f0adf26e8 a1=7fff803d37c0 a2=7fff803d37c0 a3=1999999999999999 items=0 ppid=7352 pid=7357 auid=0 uid=48 gid=48 euid=48 suid=48 fsuid=48 egid=48 sgid=48 fsgid=48 tty=(none) ses=87 comm="httpd" exe="/usr/sbin/httpd" subj=unconfined_u:system_r:※httpd_t※:s0 key=(null)
type=AVC msg=audit(1421241819.317:805): avc:  ※denied  { getattr }※ for  pid=7357 comm="httpd" ※path="/home/sato"※ dev=dm-2 ino=130305 scontext=unconfined_u:system_r:※httpd_t※:s0 tcontext=unconfined_u:object_r:※user_home_dir_t※:s0 tclass=dir
type=SYSCALL msg=audit(1421241819.317:805): arch=c000003e syscall=6 success=no exit=-13 a0=7f7f0adf2798 a1=7fff803d37c0 a2=7fff803d37c0 a3=1 items=0 ppid=7352 pid=7357 auid=0 uid=48 gid=48 euid=48 suid=48 fsuid=48 egid=48 sgid=48 fsgid=48 tty=(none) ses=87 comm="httpd" exe="/usr/sbin/httpd" subj=unconfined_u:system_r:※httpd_t※:s0 key=(null)
```

setseboolコマンドを実行して、Boolean「httpd_enable_homedirs」を有効に設定します。

```shell-session
[root@server ~]# getsebool httpd_enable_homedirs
httpd_enable_homedirs --> off
[root@server ~]# setsebool httpd_enable_homedirs on
[root@server ~]# getsebool httpd_enable_homedirs
httpd_enable_homedirs --> on
```

再度ブラウザで「<http://192.168.0.10/~sato/」にアクセスします。Booleanでアクセスが許可されたので、作成したページが表示されます。>

## LVMの設定

LVM（Logical Volume Manager）は、ハードディスクなどの記憶媒体の物理的な状態を隠蔽し、論理的なイメージで管理するための技術です。

LVMを使うことで、複数のハードディスクにまたがったボリュームが作成できるようになり、ファイルシステムの容量が足りなくなった場合の容量の追加が簡単になります。ボリュームの操作は、システムを再起動することなく行うことができます。

また、ハードディスクに障害が発生した時には、新しいHDDを追加して、壊れているHDDを外すなどの障害対応が容易になります。
他にも、スナップショットを取ることができるなどのメリットがあります。

現在の一般的なLinuxディストリビューションでは、インストール時にLVMでパーティションを作成できます。CentOSでは、インストール時に自動パーティション設定を選択すると、デフォルトでLVMを使用してストレージを設定します。

LVMの詳しい説明に関しては、『高信頼システム構築標準教科書』を参照してください。

LVMは、物理ボリューム（PV: Physical Volume）、ボリュームグループ（VG: Volume Group）、論理ボリューム（LV: Logical Volume）の3つで構成されています。

### 物理ボリューム（PV）

物理ボリューム(PV)は、物理ディスクのパーティション単位で扱われます。一つの物理ディスクすべてを一つのPVとして扱うこともできますし、一つの物理ディスク内にパーティションを複数作成し、それぞれのパーティションを別々のPVとして扱うこともできます。

PVを作成するには、パーティションを作成し、パーティションタイプを8Eに設定します。

以下の例では、Linuxマシンに新規に追加した/dev/sdbとして認識されているハードディスクをLVMで使用できるよう、fdiskでパーティションを作成してPVとして設定しています。同時に、後の作業で領域拡張を行うための追加パーティションも作成しておきます。

```shell-session
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

```shell-session
# vgcreate Volume00 /dev/sdb1
  Physical volume "/dev/sdb1" successfully created
  Volume group "Volume00" successfully created
```

また、ボリュームグループの情報はvgscanコマンドで確認できます。

```shell-session
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

```shell-session
# lvcreate -L 1024M -n LogVol01 Volume00
```

### 論理ボリュームにファイルシステムの作成

作成した論理ボリュームを利用するには、通常のパーティションと同じく論理ボリューム上にファイルシステムを作成します。論理ボリュームは、以下のようなデバイスとして扱うことができます。

```
/dev/ボリュームグループ名/論理ボリューム名
```

/dev/Volume00/LogVol01上にext4ファイルシステムを作成するために、mkfsコマンドを実行します。

```shell-session
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

```shell-session
# mkdir /mnt/LVMtest
# mount -t ext4 /dev/Volume00/LogVol01 /mnt/LVMtest/
# mount /mnt/LVMtest/
mount: /dev/mapper/Volume00-LogVol01 は マウント済か /mnt/LVMtest が使用中です
mount: mtab によると、/dev/mapper/Volume00-LogVol01 は /mnt/LVMtest にマウント済です
```

### ボリュームグループへのディスクの追加

既存のボリュームグループVolume00に物理ボリューム/dev/sdb2を追加します。

vgextendコマンドを実行して、物理ボリューム/dev/sdb2をボリュームグループVolume00に追加します。

```shell-session
# vgextend Volume00 /dev/sdb2
  Physical volume "/dev/sdb2" successfully created
  Volume group "Volume00" successfully extended
```

vgdisplayコマンドを実行して、ボリュームグループVolume00の情報を確認します。PV（Physical volume）の数が2となっており、/dev/sdb2が加わっていることが分かります。

```shell-session
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

```shell-session
# df /mnt/LVMtest/
Filesystem           1K-blocks  Used Available Use% Mounted on
/dev/mapper/Volume00-LogVol01
                        999320  1284    945608   1% /mnt/LVMtest
```

lvextendコマンドを実行して、論理ボリュームLogVol01のサイズを2Gまで拡大します。

```shell-session
# lvextend -L 2G /dev/Volume00/LogVol01
 Size of logical volume Volume00/LogVol01 changed from 1.00 GiB (256 extents) to 2.00 GiB (512 extents).
  Logical volume LogVol01 successfully resized
```

resize2fsコマンドを実行して、ファイルシステムを拡大します。

```shell-session
# resize2fs /dev/Volume00/LogVol01
resize2fs 1.41.12 (17-May-2010)
Filesystem at /dev/Volume00/LogVol01 is mounted on /mnt/LVMtest; on-line resizing required
old desc_blocks = 1, new_desc_blocks = 1
Performing an on-line resize of /dev/Volume00/LogVol01 to 524288 (4k) blocks.
The filesystem on /dev/Volume00/LogVol01 is now 524288 blocks long.
```

dfコマンドで再度容量を確認します。容量が2GBに増えていることが確認できます。

```shell-session
# df /mnt/LVMtest/
Filesystem           1K-blocks  Used Available Use% Mounted on
/dev/mapper/Volume00-LogVol01
                       2031440  1536   1925060   1% /mnt/LVMtest
```

### 論理ボリュームの縮小

運用上、他の論理ボリュームを拡大したい等の理由で使用率の低い論理ボリュームの縮小を行う場合があります。
論理ボリュームを縮小するには、先にファイルシステムを縮小し、その後に論理ボリュームを縮小する必要があります。ファイルシステムの縮小はマウントしたままでは行えないので、作業中は一度アンマウントしておく必要があります。

縮小したいボリュームをアンマウントします。umountコマンドを実行して、/mnt/LVMtestをアンマウントします。

```shell-session
# umount /mnt/LVMtest/
```

縮小したい論理ボリューム/dev/Volume00/LogVol01に対してfsckコマンドを実行します。強制的にチェックを行うために-fオプションを付与して実行します。

```shell-session
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

```shell-session
# resize2fs /dev/Volume00/LogVol01 1G
resize2fs 1.41.12 (17-May-2010)
Resizing the filesystem on /dev/Volume00/LogVol01 to 262144 (4k) blocks.
The filesystem on /dev/Volume00/LogVol01 is now 262144 blocks long.
```

lvreduceコマンドを実行して、論理ボリューム/dev/Volume00/LogVol01を縮小します。

```shell-session
# lvreduce -L 1G /dev/Volume00/LogVol01
  WARNING: Reducing active logical volume to 1.00 GiB
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce LogVol01? [y/n]: ※y ←yを入力
  Size of logical volume Volume00/LogVol01 changed from 2.00 GiB (512 extents) to 1.00 GiB (256 extents).
  Logical volume LogVol01 successfully resized
```

/mnt/LVMtestに再マウントして、容量を確認します。

```shell-session
# mount -t ext4 /dev/Volume00/LogVol01 /mnt/LVMtest/
# df /mnt/LVMtest/
Filesystem           1K-blocks  Used Available Use% Mounted on
/dev/mapper/Volume00-LogVol01
                        999320  1284    945616   1% /mnt/LVMtest
```

## バックアップ／リストア

システムを運用していく際には、バックアップは重要です。特に障害からシステムを復旧させるときや、重要なファイルを誤って削除したりするリスクを考えると、きちんとバックアップ／リストアのプランを立てて、前もってテストをしておくことが重要です。

### バックアップメディアについて

最近のストレージの大容量化を考えると、システムとは別のハードディスクにバックアップを取るのが一番簡単な手段です。また、容量を簡単に増やすことができるファイルサーバは、ネットワークを経由したバックアップ先の対象としてもよく利用されています。
また、昔から使われているテープは現在でもバックアップメディアとしてよく利用されています。
他にも、バックアップ対象の容量が多くない場合にはCDやDVDもバックアップメディアの候補となります。ただし、媒体の寿命が比較的短いため、長期保存する場合には保管場所などに注意が必要です。

### 代表的なバックアップツール

企業等の運用現場ではバックアップ専用の商用ソフトウェアが多く使われていますが、Linuxで標準で利用可能な様々なツールも使用されています。それらの中でも代表的な以下のツールについて解説します。

- ddコマンド
- dumpコマンド
- tarコマンド
- rsyncコマンド

### ddコマンド

ディスク全体のイメージを出力するツールです。ddコマンドを用いてバックアップを行うことにより、ディスクの中身を完全にコピーすることができます。

#### ddコマンドの長所

- ディスクの中身を丸ごとコピーできるため、MBR(Master Boot Record)もバックアップできます。
- iノード番号、atime、ctimeなどの属性もバックアップできます。
- ディスクからディスクに直接バックアップを行う場合には、ファイルシステムを介さずに直接コピーを行うので高速です。

#### ddコマンドの短所

- ディスクを丸ごとコピーするため、リストア時にファイルシステムのサイズやパラメータを変更できません。また、ファイルシステムにフラグメント（断片化）がある場合にも、そのままコピーされます。
- バックアップの際には、ファイル変更を避けるためアンマウントする必要があります。

### dumpコマンド

古くからあるバックアップ専用コマンド。ファイルシステム単位でのバックアップを行えます。

#### dumpコマンドの長所

- ファイルシステム単位でバックアップするため、効率よくバックアップができます。
- 差分／増分バックアップが簡単にできます。
- テープへのバックアップができます。
- iノード番号、atime、ctimeなどの属性もバックアップできます。
- リストア時にファイルシステムのサイズやパラメータを変更できます。
- 新しいファイルシステムにリストアすれば、フラグメントを解消できます。

#### dumpコマンドの短所

- ディレクトリ単位やファイル単位でのバックアップはできません。
- バックアップファイルが壊れると、一部のファイルだけを救済できません。
- 速度はあまり速くありません。
- ext2/3/4でしか使用できません。それ以外のファイルシステムの場合、たとえばXFSにはxfsdumpなど専用のコマンドを使用する必要があります。

### tarコマンド

「Tape Archiver」の名前の通り、元々はテープへのアーカイブを作成するためのコマンドですが、ファイルとしてアーカイブを作成することもでき、柔軟性があります。

#### tarコマンドの長所

- ファイル単位のバックアップ、リストアができます。
- 増分バックアップができます。
- テープへのバックアップができます。
- バックアップデータがこわれていても、部分的に復旧できます。

#### tarコマンドの短所

- 速度はあまり速くありません。
- リストア時にiノード番号が変わるため、iノードを直接参照しているプログラムではリストアしたファイルが元のファイルと同じだと認識できません。

### rsyncコマンド

「remote sync」の名前の通り、リモートでファイルやディレクトリを同期するために作られたコマンドですが、バックアップにも使用できます。バックアップ先としてローカルホストを指定することもできるため、ローカルにマウントされた外部ストレージにバックアップすることもできます。

#### rsyncコマンドの長所

- ファイル単位のバックアップ、リストアができます。
- tarコマンドよりも効率よくバックアップできます。
- 増分／差分バックアップができます。

#### rsyncコマンドの短所

- ディスクをまるごとバックアップする場合には、ddやdumpと比べて遅いです。
- リストア時にiノード番号が変わるため、iノードを直接参照しているプログラムではリストアしたファイルが元のファイルと同じだと認識できません。

### バックアップとリストアの準備

各コマンドを使用したバックアップとリストアの方法を、実際にコマンドを動かしながら解説します。

バックアップ対象を/mnt/backup_test（/dev/sdb1）、リストア先を/mnt/restore_test（/dev/sdc1）とします。

仮想マシンに仮想ハードディスクを2つ、同じサイズで追加します。追加した仮想ハードディスクを/dev/sdbと/dev/sdcとしてOSから認識できるように、仮想マシンを再起動します。

物理マシンを使用している場合には、物理ハードディスクを2台追加するか、1台の追加したハードディスクに2つのパーティション（/dev/sdb1と/dev/sdb2）を作成してください。

もし、LVMの実習で使用したハードディスク/dev/sdbをそのまま利用する場合には、アンマウントした後fdiskコマンド等でパーティションを一度削除して実習を行います。

fdiskコマンドなどで/dev/sdbにパーティション/dev/sdb1を作成し、mkfs.ext4コマンドでext4ファイルシステムで初期化した後、/mnt/backup_testにマウントします。具体的なパーティション作成手順は、LVMの実習を参照してください。ただし、この実習ではLVMは使用しないので、パーティションタイプの変更は不要です。

```shell-session
# fdisk /dev/sdb
※パーティションを作成
# mkfs.ext4 /dev/sdb1
# mkdir /mnt/backup_test
# mount -t ext4 /dev/sdb1 /mnt/backup_test/
```

/mnt/backup_testディレクトリに、テスト用のディレクトリとファイルを作成しておきます。

```shell-session
# mkdir /mnt/backup_test/test_dir
# touch /mnt/backup_test/test_dir/test_file
```

### ddコマンドを使ったバックアップ

ddコマンドではファイル単位でバックアップができないため、/dev/sdbデバイス自体をバックアップします。

/dev/sdcは初期化していない状態で、ddコマンドを実行します。/dev/sdbが丸ごと/dev/sdcにバックアップされます。

```shell-session
#  dd if=/dev/sdb of=/dev/sdc
208896+0 records in
208896+0 records out
106954752 bytes (107 MB) copied, 1.29132 s, 82.8 MB/s
```

fdiskコマンドを使って、/dev/sdc1が作成されていることをパーティション情報で確認します。/dev/sdcに書き込まれたパーティション情報をOSに認識させるためにOSの再起動を行ってから、確認します。

```shell-session
# reboot
※システム再起動後に確認
# fdisk /dev/sdc
（略）
コマンド (m でヘルプ): ※p ←パーティション情報表示のpを入力

ディスク /dev/sdc: 106 MB, 106954752 バイト
ヘッド 255, セクタ 63, シリンダ 13
Units = シリンダ数 of 16065 * 512 = 8225280 バイト
セクタサイズ (論理 / 物理): 512 バイト / 4096 バイト
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
ディスク識別子: 0x43b56949

デバイス ブート      始点        終点     ブロック   Id  システム
/dev/sdc1               1          13      104391   83  Linux
Partition 1 does not start on physical sector boundary.

コマンド (m でヘルプ): ※q ←終了のqを入力
```

/dev/sdc1を/mnt/restore_testとしてマウントします。先ほど/mnt/backup_testディレクトリ以下に作成したテスト用のディレクトリおよびファイルがリストアされているのが確認できます。

```shell-session
# mount /dev/sdc1 /mnt/restore_test
# cd /mnt/restore_test
# ls -l
合計 14
drwx------. 2 root root 12288 12月 22 13:16 2014 lost+found
drwxr-xr-x. 3 root root  1024 12月 22 13:16 2014 test_dir
[root@server restore_test]# ls -l test_dir/
合計 0
-rw-r--r--. 1 root root 0  12月 22 13:16 2014 test_file
```

### dumpコマンドによるバックアップ

dumpコマンドによるバックアップはファイルシステム単位で行います。バックアップ対象の選択は、設定ファイル/etc/fstabで行います。

ここでは例として/bootディレクトリ全体をファイルとしてバックアップします。/bootディレクトリは、/（ルート）ディレクトリとは別のパーティションにファイルシステムが作られて/bootディレクトリにマウントされているので、/bootディレクトリ以下をすべてdumpコマンドでバックアップできます。

CentOS 6ではdumpコマンドが標準でインストールされていないため、dumpパッケージをインストールします。

```shell-session
# yum install dump
```

dumpコマンドによるバックアップ対象を/etc/fstabに設定します。/etc/fstabの5番目のフィールド（後から2番目）が「1」に設定されているファイルシステムがdumpコマンドの対象となります。/bootディレクトリにマウントされるファイルシステムがdumpコマンドの対象になっていることを確認します。/procや/sysなどの擬似ファイルシステムは対象外となります。

```shell-session
# vi /etc/fstab

/dev/mapper/vg_cent65-lv_root /                       ext4    defaults
1 1
UUID=fe4d3f56-a570-44b4-a863-418b789b42bc /boot                   ext4
defaults        ※1※ 2
/dev/mapper/vg_cent65-lv_swap swap                    swap    defaults
0 0
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
```

dumpコマンドを実行して、/bootディレクトリをバックアップします。通常はテープなどのバックアップメディアに対してバックアップを行いますが、dumpコマンドの出力をパイプでddコマンドに渡すことでファイルとしてバックアップできます。
付与しているオプションの意味は以下の通りです。例では、出力先に標準出力である「-」（ハイフン）を指定している点に注意してください。

| オプション | 意味                                                             |
| ---------- | ---------------------------------------------------------------- |
| -0         | レベル0のバックアップを取得する。レベル0はフルバックアップ       |
| -u         | バックアップ完了後、/etc/dumpdatesを更新。差分バックアップに必要 |
| -a         | 自動サイズ。バックアップメディアから終了通知があるまで書き込む   |
| -n         | operatorグループに対して通知を行う                               |
| -f         | 出力先を指定                                                     |

```shell-session
# dump -0uan -f - /boot | dd of=/tmp/boot.dump
  DUMP: No group entry for operator.
  DUMP: Date of this level 0 dump: Thu Jan 15 00:07:19 2015
  DUMP: Dumping /dev/sda1 (/boot) to standard output
（略）
  DUMP: Date this dump completed:  Thu Jan 15 00:07:20 2015
  DUMP: Average transfer rate: 26570 kB/s
  DUMP: DUMP IS DONE
53140+0 records in
53140+0 records out
27207680 bytes (27 MB) copied, 0.202273 s, 135 MB/s

# ls -l /tmp/boot.dump
-rw-r--r--. 1 root root 27207680  1月 15 00:07 2015 /tmp/boot.dump
```

restoreコマンドを実行して、/tmp/restore_testディレクトリにリストアします。-rオプションは、ファイルシステムをすべてリストアすることを指定しています。-fオプションは、入力として標準入力である「-」（ハイフン）を指定しています。dumpコマンドで作成したバックアップファイルをcatコマンドで読み込み、標準出力をパイプでrestoreコマンドの標準入力に渡しています。

```shell-session
# mkdir /tmp/restore_test
# cd /tmp/restore_test
# cat /tmp/boot.dump | restore -rf -
# ls
System.map-2.6.32-504.el6.x86_64  initramfs-2.6.32-504.el6.x86_64.img
config-2.6.32-504.el6.x86_64      lost+found
efi                               symvers-2.6.32-504.el6.x86_64.gz
grub                              vmlinuz-2.6.32-504.el6.x86_64
```

/tmp/restore_testディレクトリ内のファイルをすべて削除します。

```shell-session
# rm -rf /tmp/restore_test/*
```

### tarコマンドによるバックアップ

tarコマンドはファイル、ディレクトリをアーカイブとしてひとまとめにしてバックアップが行えます。バックアップを目的とした使用のほか、たとえばLinuxカーネルのソースコードなどを一つにまとめて配布する目的でも使用されています。

/bootディレクトリ以下のファイルおよびディレクトリをバックアップします。アーカイブファイルは/tmp/boot_backup.tarとします。アーカイブの作成は、tarコマンドに-cオプションを付与して実行します。

```shell-session
# tar -cvf /tmp/boot_backup.tar /boot
tar: メンバ名から先頭の `/' を取り除きます
/boot/
/boot/grub/
（略）
/boot/System.map-2.6.32-504.el6.x86_64
/boot/.vmlinuz-2.6.32-504.el6.x86_64.hmac

# ls -l /tmp/boot_backup.tar
-rw-r--r--. 1 root root 26982400  1月 15 00:15 2015 /tmp/boot_backup.tar
```

/tmp/restore_testディレクトリにファイルをリストアします。アーカイブからのファイルの取り出しは、tarコマンドに-xオプションを付与して実行します。ファイルはカレントディレクトリ以下に展開されます。

```shell-session
# cd /tmp/restore_test
# tar -xvf /tmp/boot_backup.tar
boot/
boot/grub/
（略）
boot/System.map-2.6.32-504.el6.x86_64
boot/.vmlinuz-2.6.32-504.el6.x86_64.hmac
# ls -l
合計 4
dr-xr-xr-x. 5 root root 4096  1月  6 06:20 2015 boot
# ls boot/
System.map-2.6.32-504.el6.x86_64  initramfs-2.6.32-504.el6.x86_64.img
config-2.6.32-504.el6.x86_64      lost+found
efi                               symvers-2.6.32-504.el6.x86_64.gz
grub                              vmlinuz-2.6.32-504.el6.x86_64
```

/tmp/restore_testディレクトリ内のファイルを削除します。

```shell-session
# rm -rf /tmp/restore_test/*
```

### rsyncコマンドによるバックアップ

rsyncコマンドは、ファイル、ディレクトリをバックアップすることができます。ネットワーク経由で別のホストへバックアップを行うなどの用途に使用します。特徴として、新たに追加されたファイルのみバックアップすることができます。

以下の例では、同一ホスト内で/bootディレクトリ内のファイルを別のディレクトリにバックアップしています。

rsyncコマンドを実行して、/bootディレクトリを/tmp/restore_testディレクトリ以下にバックアップします。

```shell-session
# rsync -av /boot /tmp/restore_test
sending incremental file list
boot/
boot/.vmlinuz-2.6.32-504.el6.x86_64.hmac
（略）
boot/grub/xfs_stage1_5
boot/lost+found/

sent 26964672 bytes  received 457 bytes  53930258.00 bytes/sec
total size is 26959690  speedup is 1.00
```

/tmp/restore_testディレクトリ以下のファイルを確認します。

```shell-session
# ls -l /tmp/restore_test
合計 4
dr-xr-xr-x. 5 root root 4096  1月  6 06:20 2015 boot
# ls -l /tmp/restore_test/boot
合計 25848
-rw-r--r--. 1 root root  2544748 10月 15 13:54 2014 System.map-2.6.32-504.el6.x86_64
-rw-r--r--. 1 root root   106308 10月 15 13:54 2014 config-2.6.32-504.el6.x86_64
（略）
-rw-r--r--. 1 root root   200191 10月 15 13:55 2014 symvers-2.6.32-504.el6.x86_64.gz
-rwxr-xr-x. 1 root root  4152336 10月 15 13:54 2014 vmlinuz-2.6.32-504.el6.x86_64
```

/boot/rsync_testファイルを新規に作成します。

```shell-session
# touch /boot/rsync_test
# ls -l /boot/rsync_test
-rw-r--r--. 1 root root 0  1月 15 00:23 2015 /boot/rsync_test
```

再度rsyncコマンドを実行します。新たに追加されたファイルのみバックアップされます。

```shell-session
# rsync -av /boot /tmp/restore_test
sending incremental file list
boot/
boot/rsync_test

sent 832 bytes  received 40 bytes  1744.00 bytes/sec
total size is 26959690  speedup is 30917.08
```

新たにバックアップされたファイルを確認します。

```shell-session
# ls -l /tmp/restore_test/boot/rsync_test
-rw-r--r--. 1 root root 0  1月 15 00:23 2015 /tmp/restore_test/boot/rsync_test
```

tmp/restore_testディレクトリ内のファイルを削除します。

```shell-session
# rm -rf /tmp/restore_test/*
```
