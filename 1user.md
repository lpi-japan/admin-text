# ユーザとグループの管理

## ユーザの管理
WindowsやmacOSなどの「デスクトップOS」では、基本的には1人のユーザが1台のマシンを占有して利用します。
それに対して、Linuxなどの「サーバOS」では、複数のユーザが同時に利用できるように最適化された環境になっています。そのため、管理者は利用者一人一人にユーザアカウントを作成し、ユーザは自分専用のユーザアカウントでログインする仕組みとなっています。

### ユーザアカウントの種類
ユーザアカウントの種類には、一般アカウントの「一般ユーザ」と、管理者権限である「rootユーザ」(スーパーユーザ)、そしてアプリケーションで利用される「システムユーザ」が存在します。

| ユーザの種類 | 用途 |
| ------- | ------- |
| 一般ユーザ | ユーザ個人のアカウント |
| rootユーザ(スーパーユーザ) | 管理者権限を持つユーザ |
| システムユーザ | システムやアプリケーションで使用するユーザ |

### 一般ユーザ
通常のユーザがサーバにログインして利用するためのアカウントです。
ユーザ情報の確認は、idコマンドを使います。以下の例では、OSインストール時に作成したユーザsatoでログインした後、idコマンドでユーザ情報を確認しています。

```shell-session
$ id
uid=500(sato) gid=500(sato) 所属グループ=500(sato) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

uidはユーザを識別するためのID、gidは主グループIDを示しています。所属グループ（groups）には所属している主グループIDおよびサブグループIDが表示されます。
一般ユーザのuidは、CentOS 6では500〜65535までが使用できます（ディストリビューションによって範囲が異なります）。

### rootユーザ
管理者権限を持っている特別なユーザでuidには0が付与されています。スーパーユーザとも呼ばれます。
rootユーザになるには、主に以下の方法があります。

#### Linuxのローカルコンソールからrootユーザでログインする
Linuxの動作しているマシンを直接操作できる時には、ローカルコンソールからrootユーザでログインできます。

#### 一般ユーザでログインした後、suコマンドを実行する
一般ユーザからrootユーザになるには、suコマンドを使います。suコマンドを実行するときに-（ハイフンのみ）オプションを付けると、そのユーザでログインしたのと同じことになります。

```shell-session
$ su -
Password: ※rootユーザのパスワードを入力
#
```

プロンプトがrootユーザ用の「#」に変わったのが分かります。
idコマンドで、ユーザ識別子を表示します。

```shell-session
# id
uid=0(root) gid=0(root) 所属グループ=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

rootユーザのuidは必ず0になります。

rootユーザは一般ユーザのように常用してはいけません。何故なら、入力したコマンドの間違い等のオペレーションミスで、システム障害に繋がる危険性があるからです。
安全なroot権限の使い方については別章で説明します。

### システムユーザ
システムユーザは、バックグラウンドで動くサービスが使用するユーザです。AlmaLinuxではuidの1から499がシステムユーザ用に予約されています。一般ユーザのようにログインをして利用するユーザではありません。

たとえば、SSHを動作させるためには、「sshd」ユーザがシステム内部でsshdデーモンを実行しています。rootユーザはidコマンドを使って、他のユーザの情報を確認できます。sshdサービスのシステムユーザの情報を確認しましょう。

```shell-session
# id sshd
uid=74(sshd) gid=74(sshd) 所属グループ=74(sshd)
```

### useraddコマンドによる一般ユーザの作成
新規に一般ユーザを作成するには、rootユーザでuseraddコマンドを実行します。必要に応じてpasswdコマンドでパスワードを設定します。
useraddコマンドの引数にユーザ名を指定します。

以下の例では、-cオプションででコメントを入れています。

```shell-session
# useradd -c "Ichiro Suzuki" suzuki
# id suzuki
uid=501(suzuki) gid=501(suzuki) 所属グループ=501(suzuki)
```

useraddコマンドの主なオプションは以下の通りです。

|オプション|説明|
|-------|-------|
|-u|ユーザIDを指定する|
|-g|主グループ名または主グループIDを指定する|
|-G|サブグループを指定する。複数指定するときはカンマ(,)で区切る|
|-s shell|ユーザのログインシェルを指定する|
|-c コメント|コメントを入れる（ユーザのフルネームなど）|
|-d ディレクトリ名|ホームディレクトリを指定する|
|-e YYYY-MM-DD|ユーザアカウントが無効になる年月日を指定する|

### パスワードの設定
次に、passwdコマンドを使って、指定ユーザの初期パスワードを設定します。

```shell-session
# passwd suzuki
ユーザー suzuki のパスワードを変更。
新しいパスワード: ※ユーザsuzukiの新しいパスワードを入力
新しいパスワードを再入力してください: ※ユーザsuzukiの新しいパスワードを再入力
passwd: 全ての認証トークンが正しく更新できました。
```

管理者であるrootユーザが初期パスワードを設定した場合、該当のユーザがログインをしてパスワードを変更します。この時、既存のパスワードと新しく設定するパスワードの両方を聞かれます。新しく設定するパスワードは、誕生日や名前など推測されやすいパスワードにしないように注意しましょう。

以下の例では、ユーザsuzukiでログインした後、パスワードを変更しています。

```shell-session
$ passwd
ユーザー suzuki のパスワードを変更。
suzuki 用にパスワードを変更中
現在のUNIXパスワード: ※ユーザsuzukiの現在のパスワードを入力
新しいパスワード: ※ユーザsuzukiの新しいパスワードを入力
新しいパスワードを再入力してください: ※ユーザsuzukiの新しいパスワードを再入力
passwd: 全ての認証トークンが正しく更新できました。
```

### ユーザ情報の確認
ユーザ情報は/etc/passwdファイルに保管されています。
ファイルの内容を閲覧するcatコマンドを使って/etc/passwdファイルを確認します。

```shell-session
# cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
（略）
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
tcpdump:x:72:72::/:/sbin/nologin
sato:x:500:500::/home/sato:/bin/bash
suzuki:x:501:501:Ichiro Suzuki:/home/suzuki:/bin/bash
```

/etc/passwdは左から順に以下の情報が入っていて、コロン(:)で区切られています。

|項目|意味|
|-------|-------|
|ユーザ名|ユーザアカウント名|
|パスワード|xはシャドウパスワードが設定されている|
|ユーザID|ユーザID|
|グループID|グループID|
|コメント|ユーザに関するコメント|
|ホームディレクトリ|ユーザのホームディレクトリ|
|シェル|ログインした時に起動するシェル|

### シャドウパスワードについて
かつてのUNIXでは、ユーザのパスワードを暗号化して/etc/passwdに記録していました。しかし、/etc/passwdは誰でも内容を読むことができるファイルのため、一般ユーザにパスワードを解析されてしまう危険性がありました。
そのため、rootユーザのみ読み取れるシャドウファイル(/etc/shadow)を用意し、暗号化（ハッシュ化）したパスワードを別途格納しています。暗号化は元に戻すこと（復号）ができますが、ハッシュ化は元に戻すことができない（困難）な仕組みです。パスワードがシャドウファイルに格納されていると、/etc/passwdのパスワード部分にはxが入るようになっています。

ちなみに、/etc/shadowのパーミッションは000に設定されています（ディストリビューションによっては400）。rootユーザはパーミッションに関係なく読み取ることができますが、その他のユーザは読み書きすることができません。パーミッションの詳細については後述します。

```shell-session
# ls -l /etc/shadow
----------. 1 root root 1164  1月  6 06:48 2015 /etc/shadow
```

rootユーザで、ユーザsuzukiのシャドウパスワードを確認してみましょう。

```shell-session
# grep suzuki /etc/shadow
suzuki:$6$Tq1q9Ztw$8sh1KFpEGFAmU68P8hYLuGjImlO1omSdTELmhGNFLWdielH8CzmLLrIc88G.yGqxty4vuI3xiTKWKJ6HOoBAV.:16384:0:99999:7:::
```

## グループの管理
ユーザを管理するひとつの単位として、「グループ」機能があります。
この「グループ」では、所属する部署やユーザの役割などによってユーザにグループを割当て、グループ単位での適切な管理が行えます。

たとえば、特定のディレクトリ配下へのアクセスや、特定のファイルの読み書きを特定のグループのみに制限したいとき、「パーミッション」という機能を使って管理できます。

### 主グループとサブグループ
ユーザは、1つ以上のグループに所属している必要があります。ユーザが最初に所属するグループを「主グループ」(またはプライマリーグループ)といいます。
所属できる主グループは一つのみで、複数のグループにユーザを所属させたい場合はサブグループを割り当てます。

```shell-session
# id suzuki
uid=501(suzuki) gid=501(suzuki) 所属グループ=501(suzuki)
```

gidが主グループです。所属グループはユーザが所属しているすべてのグループが表示されます。

### /etc/groupを確認する
グループの設定は/etc/groupファイルに格納されていますので、確認してみましょう。

```shell-session
# cat /etc/group
root:x:0:
bin:x:1:bin,daemon
（略）
sato:x:500:
suzuki:x:501:
```

useraddコマンドは、主グループの指定が無かった場合には作成するユーザと同じ名前のグループを作成し、そのグループをユーザの主グループに指定します。グループIDも、作成するユーザのuidと同じになります。

### グループの作成
groupaddコマンドでグループを作成します。グループIDを指定したい時は-gオプションを使います。グループIDが指定されなかった時には、自動的に割り当てられます。

groupaddコマンドの書式は以下の通りです。

```
groupadd [-g グループID] グループ名
```

グループID 5000を指定してgrouptestというグループを作成します。

```shell-session
# groupadd -g 5000 grouptest
```

/etc/groupファイルを確認します。

```shell-session
# grep grouptest /etc/group
grouptest:x:5000:
```

### グループ名の変更
groupmodコマンドでグループ名を変更します。

groupmodコマンドの書式は以下の通りです。

```
groupmod [-n 新しいグループ名] グループ名
```

グループ名をgrouptestからeigyouに変更します。

```shell-session
# groupmod -n eigyou grouptest
```

/etc/groupファイルを確認します。

```shell-session
# grep eigyou /etc/group
eigyou:x:5000:
```

### ユーザをサブグループに所属させる
ユーザをサブグループに所属させるときは、usermodコマンドを使います。-G（大文字）オプションで所属させたいサブグループをカンマ区切りですべて指定します。所属していたサブグループの指定を忘れると、そのサブグループの所属から外れてしまうので注意してください。所属しているサブグループが多い場合には、後述するgpasswdコマンドを使用すると、サブグループを一つずつ指定できます。

usermodコマンドの書式は以下の通りです。

```
usermod [-G サブグループ名 [,...]] ユーザ名
```

ユーザsuzukiの所属するサブグループとしてeigyouグループを指定します。

```shell-session
# usermod -G eigyou suzuki
```

idコマンドでサブグループが追加されているか確認します。

```shell-session
# id suzuki
uid=501(suzuki) gid=501(suzuki) 所属グループ=501(suzuki),5000(eigyou)
```

所属グループにeigyouサブグループが追加されているのが分かります。

### サブグループの所属ユーザを確認する
グループにサブグループとして所属しているユーザは、/etc/groupに記述されています。

```shell-session
# grep eigyou /etc/group
eigyou:x:5000:suzuki
```

ユーザsuzukiが、eigyouグループにサブグループとして所属しているのが分かります。

### gpasswdコマンドを使ってサブグループを管理する
ユーザの所属しているサブグループが多い場合、gpasswdコマンドを使うのが便利です。gpasswdコマンドは、追加や除外したいサブグループを1つだけ指定できます。

gpasswdコマンドの書式は以下の通りです。

```
gpasswd -a 追加するユーザ名 グループ名
gpasswd -d 除外するユーザ名 グループ名
```

ユーザsuzukiの所属するサブグループからeigyouグループを除外します。

```shell-session
# gpasswd -d suzuki eigyou
Removing user suzuki from group eigyou
# id suzuki
uid=501(suzuki) gid=501(suzuki) 所属グループ=501(suzuki)
```

/etc/groupを確認して、eigyouグループからユーザsuzukiが削除されていることを確認します。

```shell-session
# grep eigyou /etc/group
eigyou:x:5000:
```

eigyouグループからユーザsuzukiが除外されているのが分かります。

再度、ユーザsuzukiの所属するサブグループにeigyouグループを指定します。

```shell-session
# gpasswd -a suzuki eigyou
Adding user suzuki to group eigyou
# id suzuki
uid=501(suzuki) gid=501(suzuki) 所属グループ=501(suzuki),5000(eigyou)
```

ユーザsuzukiのサブグループにeigyouグループが追加されました。

## パーミッションを使ったファイルシステムのアクセス管理
ファイルシステムのアクセス管理を行うには、「パーミッション」という機能を利用します。パーミッション(permission)とは、日本語で「許可」を意味します。
許可されたユーザやグループのみが特定のファイルやディレクトリにアクセスでき、読み取り・書き込み・スクリプト等の実行ができるように設定できます。

### パーミッションの確認
ユーザのホームディレクトリに移動します。cdコマンドにオプションや引数を付けなければ、ユーザのホームディレクトリに移動できます。ホームディレクトリとは、ユーザ個人に割り当てられた領域になり、ここにユーザが作ったファイルやプログラムを保存したり、ユーザ独自の設定ファイルを格納しています。

pwdコマンドで現在のディレクトリがホームディレクトリになっていることを確認します。

```shell-session
$ cd
$ pwd
/home/suzuki
```

次にtouchコマンドで、空のファイルを作ります。

```shell-session
$ touch test.txt
```

lsコマンドに、-lオプションを付けて実行し、ファイルの詳細を表示します。

```shell-session
$ ls -l
合計 0
-rw-rw-r--. 1 suzuki suzuki 0  1月  6 07:34 2015 test.txt
```

上記の「rw-rw-r--」がパーミッションです。

なお、AlmaLinuxの環境では、llコマンドでも「ls -l」と同様の結果が得られます。「ll」は「ls -l」のエイリアスとなるように設定されています。

```shell-session
$ ll
合計 0
-rw-rw-r--. 1 suzuki suzuki 0  1月  6 07:34 2015 test.txt
```

設定されているエイリアスはaliasコマンドで確認できます。

```shell-session
$ alias 
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias vi='vim'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
```

### パーミッションの表記方法
パーミッションはrwxの3つの文字で表されます。それぞれの意味は以下の通りです。また、各パーミッションは数値で表記することもできます。数値表記はchmodコマンドなどで使用されます。

|意味|文字表記|数値表記|
|-------|-------|-------|
|読取許可(Readable)|r|4|
|書込許可(Writable)|w|2|
|実行許可(eXecutable)|x|1|
|何も許可しない|-|0|

上記test.txtのアクセス権限は以下のようになっています。

||所有ユーザ（user）|所有グループ(group)|その他(other)|
|-------|-------|-------|-------|
|文字表記|rw-|rw-|r--|
|数値表記|4+2+0=6|4+2+0=6|4+0+0=4|

先頭から、所有ユーザ、グループ、どちらにも該当しないその他のユーザのアクセス権限を示しています。

* 先頭の「rw-」が所有ユーザ、すなわちユーザsuzukiの権限で、読取・書込ができます。
* 次の「rw-」が所有グループ、すなわちsuzukiグループの権限で、読取・書込ができます。
* 最後の「r--」がユーザにもグループにも該当しないその他のユーザの権限で、読み取りのみ可能です。

### パーミッションの数値表記
パーミッションの数値表記は、設定したい権限に対応する数値の合計値を、所有ユーザ、所有グループ、その他の順に並べた3桁の数値で表されます。

たとえば、上記の例の「rw-rw-r--」というパーミッションを数字で表記すると「664」になります。

###  ディレクトリのパーミッション
ディレクトリのパーミッションも、基本的な考え方はファイルのパーミッションと同じです。異なる点として、実行権限が無いとそのディレクトリに移動してカレントディレクトリにすることができません。

mkdirコマンドでtestdirという新規ディレクトリを作成し、アクセス権限を変更してみます。

```shell-session
$ mkdir testdir
$ ls -l
合計 4
-rw-rw-r--. 1 suzuki suzuki    0  1月  6 07:34 2015 test.txt
drwxrwxr-x. 2 suzuki suzuki 4096  1月  6 07:42 2015 testdir
```

testdirディレクトリのパーミッション表記の先頭にディレクトリを識別するdが付いていることが確認できます。
このディレクトリのパーミッションは、rwx(4+2+1)、rwx(4+2+1)、r-x(4+1)で775になっています。その他のユーザはこのディレクトリにアクセスすることはできますが、書き込みは行えません。

パーミッションの変更はchmodコマンドを使用します。chmodコマンドの書式は以下の通りです。

```
chmod モード ファイル
```

モードの指定は文字表記、数値表記の両方が行えます。数値表記は指定された値に設定しますが、文字表記は+と-でパーミッションの付与、または解除を指定します。

以下、文字表記でのモード指定の例です。

|モード指定|意味|
|-------|-------|
|ug+x|ユーザとグループに実行権限を付与|
|a+x|すべてのユーザに実行権限を付与|
|g-w|グループの書き込み権限を解除|

以下の例では、chmodコマンドでディレクトリのパーミッションからユーザ自身の実行権限を解除することで、カレントディレクトリにできなくなることを確認しています。

```shell-session
$ chmod u-x testdir
$ ls -l
合計 4
-rw-rw-r--. 1 suzuki suzuki    0  1月  6 07:34 2015 test.txt
drw-rwxr-x. 2 suzuki suzuki 4096  1月  6 07:42 2015 testdir
$ cd testdir
-bash: cd: testdir: 許可がありません
$ chmod u+x testdir
$ cd testdir
$ pwd
/home/suzuki/testdir
```

### ユーザアカウントの有効期限を設定する
ユーザアカウントが使用できる有効期限を設定できます。
たとえば、期限が決まっているプロジェクトなど、ユーザアカウントの使用が期間限定の場合に有効期限を設定します。
新規アカウント追加時にはuseraddコマンド、すでに存在するアカウントの場合にはusermodコマンドに-eオプションを付与して有効期限を指定できます。

ユーザアカウントの有効期限設定の書式は以下の通りです。

```
useradd -e YYYY-MM-DD ユーザ名
usermod -e YYYY-MM-DD ユーザ名
```

usermodコマンドで既存ユーザアカウントの有効期限を設定します。ユーザアカウントに有効期限を設定すると、設定日にアカウントがロックされて使用できなくなります。

以下の例では、動作確認のために有効期限を本日の日付で設定しています。

```shell-session
# usermod -e 2015-1-6 suzuki
```

アカウント有効期限を確認するために、chage コマンドを使います。

```shell-session
# chage -l suzuki
Last password change				: Jan 05, 2015
Password expires					: never
Password inactive					: never
Account expires						: ※Jan 06, 2015
Minimum number of days between password change		: 0
Maximum number of days between password change		: 99999
Number of days of warning before password expires	: 7
```

確認のため、アカウント有効期限を設定したユーザアカウントでマシンにログインします。「Your account has expired」と表示され、アカウントがロックされている状態になっています。

```shell-session
login: suzuki
Password: ※ユーザsuzukiのパスワードを入力
Your account has expired; please contact your system administrator
```

有効期限をリセットして無期限有効にするには、以下のように「''」（シングルクォート2つ）で空の有効期限を指定します。アカウントの有効期限（Account expires）がneverに設定されます。

```shell-session
# usermod -e '' suzuki
# chage -l suzuki
Last password change				: Jan 05, 2015
Password expires					: never
Password inactive					: never
Account expires						: ※never
Minimum number of days between password change		: 0
Maximum number of days between password change		: 99999
Number of days of warning before password expires	: 7
```

### パスワードの有効期限を設定する
ユーザのパスワードの有効期限を設定したいときは、chageコマンドを使います。-Mオプションでパスワードの有効な日数を指定します。

以下の例ではパスワードの有効日数を30に設定しているので、30日毎にパスワードを再設定する必要があります。

```shell-session
# chage -M 30 suzuki
```

パスワードの有効期限を確認します。Password expiresで表示された日付の翌日以降になると、ユーザログイン時、強制的にパスワードの変更要求を行います。

```shell-session
# chage -l suzuki
Last password change				: Jan 05, 2015
Password expires					: ※Feb 04, 2015
Password inactive					: never
Account expires						: never
Minimum number of days between password change		: 0
Maximum number of days between password change		: 30
Number of days of warning before password expires	: 7
```

パスワードの有効期限を即座に失効させるには、-d オプションで0を指定します。このオプションは、パスワードが最後に変更された日付の値を 1970 年 1 月 1 日に設定し、即座にパスワードを失効させ、ユーザログイン時に強制的にパスワード変更を要求できます。

```shell-session
# chage -d 0 suzuki
```

chageコマンドでアカウントの情報を確認してみると、Last password change、Password expires、Password inactiveの値が「password must be changed」になっていることが分かります。

```shell-session
# chage -l suzuki
Last password change				: ※password must be changed
Password expires					: ※password must be changed
Password inactive					: ※password must be changed
Account expires						: never
Minimum number of days between password change		: 0
Maximum number of days between password change		: 30
Number of days of warning before password expires	: 7
```

確認のため、設定したユーザアカウントでログインします。即座にパスワード再設定が要求されます。

```
login: suzuki
Password: ※ユーザsuzukiの現在のパスワードを入力
You are required to change your password immediately (root enforced)
Changing password for suzuki.
(current) UNIX password: ※ユーザsuzukiの現在のパスワードを入力
New password: ※ユーザsuzukiの新しいパスワードを入力
Retype new password: ※ユーザsuzukiの新しいパスワードを再入力
```

### ユーザの削除
ユーザを削除します。ユーザの削除後はログインできなくなります。

ユーザに登録してあるcronも実行できなくなりますので、念のため確認をしてから削除しましょう。一般ユーザにシステムを動かすために必要なcronを登録しないようにしましょう。そのユーザが削除されてしまった場合、cronが実行されなくなりシステムに重大な障害を与えてしまう場合があります。cronについては第3章で解説します。

以下の例では、ユーザtestuserを追加し、削除しています。

```shell-session
# useradd testuser
# id testuser
uid=502(testuser) gid=502(testuser) 所属グループ=502(testuser)
# userdel testuser
# id testuser
id: testuser: そのようなユーザは存在しません
```

userdelコマンドをオプション無しで実行すると、ユーザのホームディレクトリや受信したメールを格納するメールスプールは削除されません。ユーザ削除と同時にホームディレクトリなども削除したい場合には、userdelコマンドに-rオプションをつけて実行する必要があります。

```
# ls -l /home
合計 28
drwx------.  2 root   root   16384  1月  6 06:07 2015 lost+found
drwx------. 26 sato   sato    4096  1月  6 06:49 2015 sato
drwx------.  5 suzuki suzuki  4096  1月  6 09:00 2015 suzuki
drwx------.  4   ※502    502※  4096  1月  6 09:56 2015 testuser
# ls -l /var/spool/mail
合計 0
合計 0
-rw-rw----. 1 rpc    mail 0  1月  6 06:11 2015 rpc
-rw-rw----. 1 sato   mail 0  1月  6 06:23 2015 sato
-rw-rw----. 1 suzuki mail 0  1月  6 06:48 2015 suzuki
-rw-rw----. 1   ※502※ mail 0  1月  6 09:56 2015 testuser
```

このように、所有ユーザが削除されたディレクトリやファイルは、パーミッションを確認すると所有ユーザが元のユーザIDで表示されるようになります。

再度ユーザtestuserを作成します。

```shell-session
# useradd testuser
useradd: 警告: ホームディレクトリが既に存在します。
skel ディレクトリからのコピーは行いません。
メールボックスファイルを作成します: ファイルが存在します
# ls -l /home
合計 28
drwx------.  2 root     root     16384  1月  6 06:07 2015 lost+found
drwx------. 26 sato     sato      4096  1月  6 06:49 2015 sato
drwx------.  5 suzuki   suzuki    4096  1月  6 09:00 2015 suzuki
drwx------.  4 ※testuser testuser※  4096  1月  6 09:56 2015 testuser
# ls -l /var/spool/mail
合計 0
-rw-rw----. 1 rpc      mail 0  1月  6 06:11 2015 rpc
-rw-rw----. 1 sato     mail 0  1月  6 06:23 2015 sato
-rw-rw----. 1 suzuki   mail 0  1月  6 06:48 2015 suzuki
-rw-rw----. 1 ※testuser※ mail 0  1月  6 09:56 2015 testuser
```

同じユーザID（上記の例では502）でユーザが追加されたので、ホームディレクトリとメールスプールはユーザtestuserが再度所有ユーザになっています。もし、削除後に追加された別のユーザに同じユーザID（502）が割り当てられると、ファイルやディレクトリの所有権が別のユーザに移ってしまうので注意が必要です。

userdel -rコマンドで削除します。ユーザtestuserのホームディレクトリとメールスプールが同時に削除されます。

```shell-session
# userdel -r testuser
# ls -l /home
合計 24
drwx------.  2 root   root   16384  1月  6 06:07 2015 lost+found
drwx------. 26 sato   sato    4096  1月  6 06:49 2015 sato
drwx------.  5 suzuki suzuki  4096  1月  6 09:00 2015 suzuki
# ls -l /var/spool/mail
合計 0
-rw-rw----. 1 rpc    mail 0  1月  6 06:11 2015 rpc
-rw-rw----. 1 sato   mail 0  1月  6 06:23 2015 sato
-rw-rw----. 1 suzuki mail 0  1月  6 06:48 2015 suzuki
```

### グループの削除
グループを削除するには、groupdelコマンドを使用します。ユーザが所属している主グループは削除できませんが、サブグループは警告無しに削除されます。グループを削除する前に/etc/groupを参照して、そのグループに所属しているユーザがいないか確認しておきます。

以下の例ではユーザtestuser（主グループtestuser）を作成し、グループtestgroupにサブグループとして所属させています。主グループは削除できませんが、サブグループは削除できます。

```shell-session
# useradd testuser
# groupadd testgroup
# gpasswd -a testuser testgroup
Adding user testuser to group testgroup
# id testuser
uid=502(testuser) gid=502(testuser) 所属グループ=502(testuser),5001(testgroup)
# groupdel testuser
groupdel: ユーザ 'testuser' のプライマリグループは削除できません。
# groupdel testgroup
# id testuser
uid=502(testuser) gid=502(testuser) 所属グループ=502(testuser)
```

## SSHによるリモートログイン
SSH (Secure Shell) とは、リモート(遠隔)のサーバにログインしてサーバを操作するためのプロトコルです。SSHは、外部へ通信の内容が漏れないように通信が暗号化されています。

Linuxでは、OpenSSHのサーバおよびクライアントが利用できます。また、Linuxサーバに対してWindowsからSSHでリモートログインすることもできます。

### 環境の準備
※1台に変更
2台のLinuxマシンを使ってSSHによるリモートログインを試してみましょう。SSHクライアントから、SSHサーバに対してSSHを使って接続をします。

以下の例では、2台のLinuxマシンを使って説明します。

|役割|ホスト名|IPアドレス|
|-------|-------|-------|
|サーバ|server.example.com|192.168.0.10|
|クライアント|client.example.com|192.168.0.101|

また、それぞれのLinuxマシンを名前解決できるように、/etc/hostsに以下の記述を追加しておきます。

```shell-session
192.168.0.10	server.example.com server
192.168.0.101	client.example.com client
```

### SSHサービスの状態確認と開始
CentOSではOpenSSHサーバはデフォルトでインストールされて自動的に起動しています。sshdデーモンが起動していることをを確認しておきます。
SSHプロトコルはポート番号22番を使用しています。

```shell-session
[root@server ~]# lsof -i:22
COMMAND   PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd     1718   root    3u  IPv4  13399      0t0  TCP *:ssh (LISTEN)
sshd     1718   root    4u  IPv6  13401      0t0  TCP *:ssh (LISTEN)
```

### SSHのログイン認証方法
SSHのログイン認証方法には、以下の方法があります。

#### パスワード認証による接続
サーバに登録済みのユーザ名と、ユーザのログインパスワードを使ってログイン認証を行います。簡単で分かりやすい認証方式ですが、ユーザ名とパスワードが分かれば誰でもログインできてしまうので、インターネットに接続するサーバなどでは使用しません。デフォルトで有効になっているので、SSHサーバの設定を変更して無効にしておきます。

#### 公開鍵認証による接続
事前に作成した公開鍵をログインしたいサーバに登録しておきます。公開鍵に対応した秘密鍵を持っているユーザだけがログインできます。パスワード認証に比べて事前の設定が必要になりますが、ログインするためには秘密鍵が必要になるので、パスワード認証より安全な認証の仕組みです。

### パスワード認証による接続
パスワード認証を使って、SSHサーバに接続してログイン認証を行います。

サーバに事前にログイン用のユーザsshuserを作成します。

```shell-session
[root@server ~]# useradd sshuser
[root@server ~]# passwd sshuser
ユーザ sshuser のパスワードを変更。
新しいパスワード: ※ユーザsshuserの新しいパスワードを入力
新しいパスワードを再入力してください: ※ユーザsshuserの新しいパスワードを再入力
passwd: 全ての認証トークンが正しく更新できました。
```

クライアントにも同様にユーザsshuserを作成しておきます。SSHクライアントは接続時にログイン認証で使用するユーザ名を指定できるので、クライアントでのユーザ作成は省略しても構いません。

クライアントにユーザsshuserでログインし、サーバにSSHで接続します。接続するにはsshコマンドを使用します。ユーザ名を省略すると、sshコマンドを実行したユーザのユーザ名が指定されたことになります。

sshコマンドの書式は以下の通りです。

```
$ ssh [ユーザ名@]接続先
```

接続先にはIPアドレス、又は名前解決できるホスト名を指定します。

```shell-session
[sshuser@client ~]$ ssh sshuser@server
```

SSHサーバに接続すると、サーバから「SSHサーバ証明書」が送られてきます。初回の接続時には以下のように尋ねられるので、yesと入力し、サーバで作成したユーザsshuserのパスワードを入力します。サーバにログインすると、コマンドプロンプトの表示がサーバ側のものに変わったことが分かります。

```shell-session
[sshuser@client ~]$ ssh sshuser@server
The authenticity of host 'server (192.168.0.10)' can't be established.
RSA key fingerprint is b6:95:54:92:62:cb:c8:f7:17:97:88:8e:69:f9:2a:dd.
Are you sure you want to continue connecting (yes/no)? ※yes ←yesと入力
Warning: Permanently added 'server,192.168.0.10' (RSA) to the list of known hosts.
sshuser@server's password: ※サーバに作成したユーザsshuserのパスワードを入力
[sshuser@server ~]$ 
```

サーバにログインできたら、ifconfig コマンドでIPアドレスを確認しましょう。IPアドレスがサーバ側のもの（192.168.0.10）であることが確認できます。

```shell-session
[sshuser@server ~]$ ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:1C:42:65:AF:C4  
          inet addr:192.168.0.10  Bcast:10.0.0.255  Mask:255.255.255.0
          inet6 addr: fe80::21c:42ff:fe65:afc4/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:19972 errors:0 dropped:0 overruns:0 frame:0
          TX packets:11094 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:15984761 (15.2 MiB)  TX bytes:992110 (968.8 KiB)
```

サーバからログアウトするには、exitコマンドを使用します。

```shell-session
[sshuser@server ~]$ exit
logout
Connection to server closed.
[sshuser@client ~]$ 
```

### sshコマンドの冗長モードによるトラブルシューティング
もし、ログインがうまくいかない場合はsshコマンドに-vオプション(冗長モード)を付けてデバッグ用のメッセージを表示させ、詳細を確認します。

```shell-session
[sshuser@client ~]$ ssh -v sshuser@server
OpenSSH_5.3p1, OpenSSL 1.0.1e-fips 11 Feb 2013
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: Applying options for *
debug1: Connecting to server [192.168.0.10] port 22.
debug1: Connection established.
（以下略）
```

### SSHサーバ証明書による「なりすまし」の防止
一度接続したことのあるサーバのSSHサーバ証明書は、クライアントのホームディレクトリに作られた.sshディレクトリの中に作成されたknown_hostsファイルに保存されます。
2回目以降の接続時には、初回に尋ねられた表示は出ず、すぐに認証のためのパスワード入力が要求されます。

```shell-session
[sshuser@client ~]$ ssh sshuser@server
sshuser@server's password: 
```

catコマンドでクライアントにある~/.ssh/known_hostsファイルの中身を確認してみましょう。

```shell-session
[sshuser@client ~]$ cat ~/.ssh/known_hosts 
server,192.168.0.10 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0xULiTzWSingpALtma51pnsMrOwW8drd+9S2ocC9/LF0ThhnQCZ49xAYx2DRNqTNNSW4Oo0qMCHch4zBse7kOEUk3FexsGRwBtvFXSyU4wOVkXnd42IFXYoKNUEfmcsWS18kslPhIJByfXpQyv6RC4px0W0VlhoK8CA732MnqbEznIRedQ15QymX24M+nJ7oXAIAG8WCViY4b1syL7bKOoAlQ5QiBYh5B4ixL/CSar1Gbz7EdoMQOjoxPUhe4inY4ZRyRwh68hbHpBGfF9FZ1AlIwxdwV0bMQw/shTP24dOaUn8bjimqBGwG/Bwyc4oV96wV9nC47ADl2zG6fb8TXQ==
```

SSHサーバ証明書は、SSHサーバに接続した際にサーバからクライアントに対して送られてきます。初回接続時は~/.ssh/known_hostsに保存されているSSHサーバ証明書が無いので、接続してもよいか確認されます。yesと答えるとサーバ証明書は~/.ssh/known_hostsに保存されます。

2回目以降の接続では、送られてきたSSHサーバ証明書とknown_hostsに保存してあるSSHサーバ証明書を比較して、同一であれば同じサーバであることが分かります。もし異なるSSHサーバ証明書が送られてきた場合には、別のサーバが「なりすまし」をしている可能性があるので、sshコマンドは警告を表示して接続を中断します。

また、仮にコピーしたSSHサーバ証明書を送ってきてサーバなりすましをしようとしても、その後の接続手順の中で確認作業を行っているので、やはり接続は中断され、サーバなりすましは失敗します。SSHサーバには、SSHサーバ証明書（公開鍵）とサーバ秘密鍵の、ペアになった2つの鍵が必要だからです。公開鍵と秘密鍵については後述します。

サーバの再インストールなどを行うと、サーバのSSHサーバ証明書は再作成され、変更されてしまいます。その場合には、クライアントの~/.ssh/known_hostsファイルに登録されているSSHサーバ証明書を削除して下さい。~/.ssh/known_hostsファイルは単なるテキストファイルなので、viエディタなどで該当するSSHサーバ証明書を1行削除します。

### 公開鍵認証による接続
パスワード認証では「ユーザ名」と「パスワード」で認証しますが、もしこのパスワードが漏れてしまうと非常に危険です。また、セキュリティ攻撃用のプログラムを使って手当たり次第にパスワードを試す「総当たり攻撃」の可能性もあります。
そこで、より安全な認証方法として公開鍵認証による接続が利用できます。インターネット上に公開するサーバの場合には、パスワード認証を禁止し、この公開鍵認証で接続します。

公開鍵認証は、SSH接続用の公開鍵と秘密鍵のキーペアを生成し、接続先のサーバに公開鍵を登録して認証します。これを「公開鍵認証」といいます。

公開鍵認証の大まかな手順としては、以下のようになります。

1. 公開鍵と秘密鍵のキーペアを生成する
2. クライアントに公開鍵と秘密鍵を設置する
3. サーバに公開鍵を設置する

### SSH公開鍵・秘密鍵の作成
SSH公開鍵認証に使用する公開鍵と秘密鍵を作成します。Linuxではssh-keygenコマンドを使用します。
クライアントで作成すれば、公開鍵・秘密鍵の生成と、クライアントへの鍵の設置が同時に行えるので、以下の作業はクライアント上で行います。鍵の作成後、公開鍵をサーバに設置します。

ssh-keygenコマンドを実行すると、鍵の設置場所とパスフレーズの入力が求められます。
公開鍵と秘密鍵の設置場所は、デフォルトではssh-keygenコマンドを実行したユーザのホームディレクトリにある.sshディレクトリに作成されます。
パスフレーズは、公開鍵認証を行う際に秘密鍵を有効にするためのパスワードのようなものです。万一秘密鍵を盗まれたとしても、パスフレーズが分からなければ鍵の所有ユーザになりすましてSSHサーバに接続することはできません。

```shell-session
[sshuser@client ~]$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/sshuser/.ssh/id_rsa): ※Enterキーを押す
Enter passphrase (empty for no passphrase): ※秘密鍵のパスフレーズを入力
Enter same passphrase again: ※秘密鍵のパスフレーズを再入力
Your identification has been saved in /home/sshuser/.ssh/id_rsa.
Your public key has been saved in /home/sshuser/.ssh/id_rsa.pub.
The key fingerprint is:
91:47:d4:85:39:58:59:7e:d4:0b:50:7c:56:f7:28:45 sshuser@client
The key's randomart image is:
+--[ RSA 2048]----+
|         .o==OE *|
|         o. *= =+|
|        o . ..* +|
|         o   . o |
|        S        |
|                 |
|                 |
|                 |
|                 |
+-----------------+
```

~/.sshディレクトリに作成された公開鍵（id_rsa.pub）と秘密鍵(id_rsa)を確認します。.sshディレクトリはsshコマンド実行時、またはssh-keygenコマンド実行時に自動的に作成されます。

```shell-session
[sshuser@client ~]$ ls -ld .ssh
drwx------. 2 sshuser sshuser 4096  1月  7 14:17 2015 .ssh
[sshuser@client ~]$ ls -l .ssh
合計 8
-rw-------. 1 sshuser sshuser 1743  1月  7 14:17 2015 id_rsa
-rw-r--r--. 1 sshuser sshuser  396  1月  7 14:17 2015 id_rsa.pub
```

鍵の中身はテキストファイルになっているので、catコマンドで確認できます。

```shell-session
[sshuser@client ~]$ cat .ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxaKrCiK5rrJBqtjG3NbWoRlGJMGEqkND6WYTfLhBby55+1C4kLL6GGXkGPWqIIqFk6WLFm7OVbYIh8Gk3IJG2R0xFU5WVBDzxmNPZ2ngP940ACKwh4U+BC+0vqtAg/NNiQRcBf1MOvFnqdnheUBfGA51YM2tjfhgJ+xaF7X8mgGjNColHXY2WUuAe9xIWNNxXUiAflh8jhztguh2HtXh5CoXwqeI9miokC15turklUd2D4mPxfiSrbYSBJUh3ofvgxX0NNAAEg4VlA0eA2pqFbZFMiLHnLBRqHxNiricuqCdueVQQXy0xFcMv8T6qyL7cwrdBSAgcePK3mE+ZmfZTQ== sshuser@client
```

公開鍵は1行のテキストですが、秘密鍵は何行かに分かれたフォーマットになっています。

```shell-session
[sshuser@client .ssh]$ cat id_rsa
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-EDE3-CBC,9A3828879701873A

kSkjcd/9+VWwk2NR8CuET4CXKu7ZIAOkNmvHwUZVMpUlnDwqxeznXP4NVGEq5uFD
（略）
Jw6FruKNyjl8mqLtrj+eltCUh6N4Z+NPVzlAHMQ9IQmBjdpArj0SLQ==
-----END RSA PRIVATE KEY-----
```

### クライアントの.sshディレクトリおよび公開鍵・秘密鍵のパーミッション
公開鍵認証に使用する公開鍵・秘密鍵、およびそれらを格納する.sshディレクトリはセキュリティを守るためパーミッションが厳密に決められています。
ssh-keygenコマンドを使用して鍵を作成した際にはパーミッションは適切に設定されていますが、別のマシンで作成した鍵をコピーしてくる場合には、パーミッションを自分で設定する必要があります。
また、所有ユーザはsshコマンドを実行するユーザである必要があります。初期設定時などにユーザの作成から公開鍵・秘密鍵の設置までをrootユーザで行っていると、所有ユーザがrootになってしまうので注意が必要です。

設定するパーミッションは以下の通りです。

|ディレクトリおよびファイル|パーミッション|
|-------|-------|
|~/.sshディレクトリ|rwx------(700)|
|id_rsa.pub（公開鍵）|rw-r--r--(644)|
|id_rsa（秘密鍵）|rw-------(600)|

### サーバへの公開鍵の設置
次に、クライアントのSSH公開鍵(id_rsa.pub)をサーバに設置します。以下の手順で設置を行います。

1. クライアントからサーバに公開鍵をコピー
1. ~/.sshディレクトリを作成
1. ~/.ssh/authorized_keysファイルを作成
1. 公開鍵の内容を~/.ssh/authorized_keysに追加
1. 公開鍵認証でログインできることを確認

＃1

1. クライアントからサーバに公開鍵をコピー

クライアントからサーバに公開鍵（id_rsa.pub）をコピーします。ここではSSHプロトコルを使ったファイルコピーを行うscpコマンドを使います。

scpコマンドの書式は以下の通りです。

```
scp コピー元ファイル ユーザ名@接続先:コピー先ファイル
```

以下のようにscpコマンドを実行して、~/.ssh/id_rsa.pubを、サーバのユーザsshuserのホームディレクトリにリモートコピーします。

```shell-session
[sshuser@client ~]$ scp ~/.ssh/id_rsa.pub sshuser@server:~
sshuser@server's password: ※サーバに作成したユーザsshuserのパスワードを入力
id_rsa.pub                                    100%  396     0.4KB/s   00:00    
```

＃2

1. ~/.sshディレクトリを作成

sshコマンドでサーバにログインし、公開鍵の設置を行います。

```shell-session
[sshuser@client ~]$ ssh sshuser@server
sshuser@server's password: ※サーバに作成したユーザsshuserのパスワードを入力
Last login: Tue Jan  6 10:58:42 2015 from client
[sshuser@server ~]$
```

公開鍵（id_rsa.pub）がコピーされていることを確認します。

```shell-session
[sshuser@server ~]$ ls -l
合計 4
-rw-r--r--. 1 sshuser sshuser 396  1月  6 10:56 2015 id_rsa.pub
[sshuser@server ~]$ cat id_rsa.pub 
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxaKrCiK5rrJBqtjG3NbWoRlGJMGEqkND6WYTfLhBby55+1C4kLL6GGXkGPWqIIqFk6WLFm7OVbYIh8Gk3IJG2R0xFU5WVBDzxmNPZ2ngP940ACKwh4U+BC+0vqtAg/NNiQRcBf1MOvFnqdnheUBfGA51YM2tjfhgJ+xaF7X8mgGjNColHXY2WUuAe9xIWNNxXUiAflh8jhztguh2HtXh5CoXwqeI9miokC15turklUd2D4mPxfiSrbYSBJUh3ofvgxX0NNAAEg4VlA0eA2pqFbZFMiLHnLBRqHxNiricuqCdueVQQXy0xFcMv8T6qyL7cwrdBSAgcePK3mE+ZmfZTQ== sshuser@client
```

ホームディレクトリに.sshディレクトリを作成し、chmodコマンドでパーミッションを変更します。

```shell-session
[sshuser@server ~]$ mkdir .ssh
[sshuser@server ~]$ chmod 700 .ssh
[sshuser@server ~]$ ls -ld .ssh
drwx------. 2 sshuser sshuser 4096  1月  6 10:59 2015 .ssh
```

＃3

1. ~/.ssh/authorized_keysファイルを作成

.sshディレクトリの中にauthorized_keysファイルを作成し、パーミッションを変更します。公開鍵はこのファイルの中に追加していきます。

```shell-session
[sshuser@server ~]$ touch .ssh/authorized_keys
[sshuser@server ~]$ chmod 600 .ssh/authorized_keys
[sshuser@server ~]$ ls -l .ssh
合計 0
-rw-------. 1 sshuser sshuser 0  1月  6 10:59 2015 authorized_keys
```

＃4

1. 公開鍵の内容を~/.ssh/authorized_keysに追加

公開鍵をauthorized_keysに追加します。cat コマンドで出力をリダイレクトします。出力で“>>”を使うと既存ファイルのauthorized_keysファイルを上書きせずに追記する事ができます。
authorized_keysファイルを作成する作業では、cpコマンドやmvコマンドは使用しないでください。authorized_keysファイルを上書きする危険性がある他、SELinuxが有効になっている場合、正常に動作しないことがあります。

```shell-session
[sshuser@server ~]$ cat id_rsa.pub >> .ssh/authorized_keys
[sshuser@server ~]$ cat .ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxaKrCiK5rrJBqtjG3NbWoRlGJMGEqkND6WYTfLhBby55+1C4kLL6GGXkGPWqIIqFk6WLFm7OVbYIh8Gk3IJG2R0xFU5WVBDzxmNPZ2ngP940ACKwh4U+BC+0vqtAg/NNiQRcBf1MOvFnqdnheUBfGA51YM2tjfhgJ+xaF7X8mgGjNColHXY2WUuAe9xIWNNxXUiAflh8jhztguh2HtXh5CoXwqeI9miokC15turklUd2D4mPxfiSrbYSBJUh3ofvgxX0NNAAEg4VlA0eA2pqFbZFMiLHnLBRqHxNiricuqCdueVQQXy0xFcMv8T6qyL7cwrdBSAgcePK3mE+ZmfZTQ== sshuser@client
```

＃5

1. 公開鍵認証でログインできることを確認

一旦サーバからログアウトし、再度接続します。公開鍵が正しく設置されていれば、秘密鍵のパスフレーズの入力が求められます。
もしパスワード認証を求められるような場合には、ファイル名やパーミッションなど、設置の手順を再確認してみてください。

```shell-session
[sshuser@server ~]$ exit
logout
Connection to server closed.
[sshuser@client ~]$ ssh sshuser@server
Enter passphrase for key '/home/sshuser/.ssh/id_rsa': ※秘密鍵のパスフレーズを入力
Last login: Tue Jan  6 10:59:03 2015 from client
[sshuser@server ~]$ 
```

### ssh-copy-idコマンドを使った公開鍵の設置
SSH公開鍵を手動で登録する方法の他に、ssh-copy-idコマンドを使った公開鍵の登録方法があります。
ssh-copy-idコマンド一つで、ホストのauthorized_keysに公開鍵を自動的に登録できます。

ssh-copy-idコマンドの書式は以下の通りです。

```
$ ssh-copy-id ユーザ名@接続先
```

公開鍵と秘密鍵を作成した後、ssh-copy-idコマンドを実行してサーバに公開鍵を登録します。

```shell-session
[sshuser@client ~]$ ssh-copy-id sshuser@server
sshuser@server's password: 
Now try logging into the machine, with "ssh 'sshuser@server'", and check in:

  .ssh/authorized_keys

to make sure we haven't added extra keys that you weren't expecting.
```

公開鍵認証でSSH接続できるか確認します。

```shell-session
[sshuser@client ~]$ ssh sshuser@server
Enter passphrase for key '/home/sshuser/.ssh/id_rsa': ※秘密鍵のパスフレーズを入力
Last login: Tue Jan  6 11:01:52 2015 from client
[sshuser@server ~]$ 
```

公開鍵認証で接続できるようになったら、OpenSSHサーバの設定を変更してパスワード認証による接続を禁止します。設定方法は後述します。

### scpコマンドを使ったファイル転送
scpコマンドを使うと、SSHプロトコルを使用してファイル転送ができます。
クライアントで作成した公開鍵をサーバにコピーするために既に使用しましたが、ディレクトリ内の複数のファイルを再帰的に転送することもできます。

クライアントのホームディレクトリにtestdirディレクトリを作成し、その中に複数のファイルを作ります。次に、scpコマンドに-rオプションを付与して実行し、ディレクトリの中身をすべて再帰的に転送します。

```shell-session
[sshuser@client ~]$ mkdir testdir
[sshuser@client ~]$ cd testdir
[sshuser@client testdir]$ touch testfile1 testfile2
[sshuser@client testdir]$ ls
testfile1  testfile2
[sshuser@client testdir]$ cd 
[sshuser@client ~]$ scp -r testdir sshuser@server:~
Enter passphrase for key '/home/sshuser/.ssh/id_rsa': ※秘密鍵のパスフレーズを入力
testfile1                                     100%    0     0.0KB/s   00:00    
testfile2                                     100%    0     0.0KB/s   00:00    
```

転送先のサーバでファイルが転送されたか確認します。

```shell-session
[sshuser@client ~]$ ssh sshuser@server
Enter passphrase for key '/home/sshuser/.ssh/id_rsa': ※秘密鍵のパスフレーズを入力
Last login: Tue Jan  6 11:02:46 2015 from client
[sshuser@server ~]$ ls
id_rsa.pub  testdir
[sshuser@server ~]$ ls -l testdir
合計 0
-rw-rw-r--. 1 sshuser sshuser 0  1月  6 11:04 2015 testfile1
-rw-rw-r--. 1 sshuser sshuser 0  1月  6 11:04 2015 testfile2
```

### sftpコマンドを使ったファイル転送
SFTP (SSH File Transfer Protocol)とは、SSHでファイルを送受信できるプロトコルです。動作はFTPに似ています。

あらかじめ転送用のファイルを作成した後、sftpコマンドでクライアントからサーバにログインします。
ログインできると、”sftp>”というプロンプトが表示されます。

```shell-session
[sshuser@client ~]$ touch sftptestfile
[sshuser@client ~]$ ls
sftptestfile  testdir
[sshuser@client ~]$ sftp sshuser@server
Connecting to server...
Enter passphrase for key '/home/sshuser/.ssh/id_rsa': ※秘密鍵のパスフレーズを入力
sftp> 
```

“put ファイル名”でサーバにファイルを転送できます。

```shell-session
sftp> put sftptestfile
Uploading sftptestfile to /home/sshuser/sftptestfile
sftptestfile                                  100%    0     0.0KB/s   00:00    
```

lsコマンドでファイルの確認ができます。

```shell-session
sftp> ls
id_rsa.pub      sftptestfile    testdir         
sftp> ls -l
-rw-r--r--    1 sshuser  sshuser       396 Jan  6 10:56 id_rsa.pub
-rw-rw-r--    1 sshuser  sshuser         0 Jan  6 11:20 sftptestfile
drwxrwxr-x    2 sshuser  sshuser      4096 Jan  6 11:04 testdir
sftp> exit
[sshuser@client ~]$ 
```

SFTPの主なコマンドは以下の通りです。

|コマンド|動作|
|-------|-------|
|pwd|カレントディレクトリの表示|
|ls|ファイルの表示|
|cd [パス]|カレントディレクトリの移動|
|put [-P] ローカルパス [リモートパス]|ファイルをリモートに転送。-Pオプションは所有権やパーミッションを維持|
|get [-P] リモートパス [ローカルパス]|ファイルをローカルに転送。-Pオプションは所有権やパーミッションを維持|
|rm パス|ファイルを削除|
|mkdir パス|ディレクトリを作成|
|rmdir パス|ディレクトリを削除|
|lpwd|ローカルのカレントディレクトリの表示|
|lls [lsコマンドのオプション] [パス]|ローカルのファイルの表示|
|lcd パス|ローカルのカレントディレクトリの移動|
|lmkdir パス|ローカルのディレクトリを作成|


### Windowsの標準クライアントを使ったSSH接続
### Tera Term を使ったWindowsクライアントからのパスワード認証による接続
WindowsクライアントからTera Termを使ってSSHでOpenSSHサーバにログインできます。また、Tera Termの機能の一つである「SSH SCP」でファイルを送受信できます。

Tera Termはインターネット上にあるTera TermのWebサイトからダウンロードして、インストールできます。インストーラーでインストールしたい場合には.EXE形式のファイルをダウンロードして実行します。

```
http://sourceforge.jp/projects/ttssh2/
```

クライアントにインストールしたTera Termを起動して、サーバに接続します。

1. Tera Termを起動します。「新しい接続」ダイアログが表示されます。

![接続先のIPアドレス、あるいはホスト名を指定します](teraterm1.png)

「ホスト」に接続先としてIPアドレスか名前解決可能なホスト名を入力します。サービスは「SSH」を選択します。「OK」ボタンをクリックして接続します。

＃2

2. 初回のみ、「セキュリティ警告」が表示されます。

![セキュリティ警告は初回のみ表示されます](teraterm2.png)

初めての接続先の場合、「セキュリティ警告」ダイアログが表示されます。接続先から送られてきたサーバ証明書がknows hostsリストに登録されていないためです。確認の上、「続行」ボタンをクリックします。

＃3

3. パスワード認証を行います。

![ユーザ名とパスワードを入力します](teraterm3.png)

「SSH認証」ダイアログが表示されるので、ユーザ名、パスフレーズ（パスワード）を入力して、パスワード認証でサーバにログインします。

＃4

4. ターミナル画面が表示されます。

![ターミナル画面が表示されます](teraterm4.png)

パスワード認証が成功すると、ターミナル画面が表示されてログインシェルが起動します。

### Tera Termを使った公開鍵・秘密鍵の作成
Tera Termの公開鍵・秘密鍵の作成機能を使って鍵を作成し、サーバに転送して公開鍵認証を行えるようにします。

1. 鍵生成ダイアログを呼び出します。

![「生成」ボタンをクリックします](teraterm5.png)

Tera Termのターミナル画面の「設定」メニューから「SSH鍵生成」を選択します。サーバに接続していない場合には、「新しい接続」ダイアログのキャンセルボタンをクリックすれば、サーバ接続を行わずにターミナル画面を表示できます。「TTSSH:鍵生成」ダイアログが表示されるので「生成」ボタンをクリックします。

＃2

2. 公開鍵と秘密鍵を保存します。

![パスフレーズを入力して、公開鍵と秘密鍵をそれぞれ保存します](teraterm6.png)

パスフレーズを入力し、「公開鍵の保存」ボタン、「秘密鍵の保存」ボタンをクリックして、それぞれの鍵ファイルを保存します。

＃3

3. 鍵生成ダイアログを閉じます。

保存後、「キャンセル」ボタンをクリックしてダイアログを閉じます。

### Tera Termを使ったファイル転送
Tera TermはSSH SCP機能でファイルの送受信が行えます。作成した公開鍵をサーバに設置するために、公開鍵（id_rsa.pub）をサーバにコピーします。

1. Secure File Copyダイアログを呼び出します。

![「From:」に作成した公開鍵を指定します](teraterm7.png)

TeraTermでサーバにログインした状態のまま、「ファイル」メニューから「SSH SCP」を選択します。

＃2

2. 公開鍵ファイルを選択します。
「TTSSH: Secure File Copy」ダイアログが表示されます。上側の「From:」の右横にある「...」ボタンをクリックしてファイルダイアログを開き、保存した公開鍵ファイル（id_rsa.pub）ファイルを選択します。

3. 公開鍵ファイルをコピーします。
「Send」ボタンをクリックすると、ファイルがサーバ側のユーザのホームディレクトリにコピーされます。

4. 公開鍵ファイルを確認します。

```shell-session
[sshuser@server ~]$ ls
id_rsa.pub  sftptestfile  testdir
```

5. 公開鍵ファイルを設置します。
コピーした公開鍵は、Linuxでの公開鍵の設置と同じ手順でauthorized_keysに追加しておきます。以下は、初めてサーバに公開鍵を登録する場合のコマンド例です。

```shell-session
[sshuser@server ~]$ mkdir .ssh
[sshuser@server ~]$ chmod 700 .ssh
[sshuser@server ~]$ touch .ssh/authorized_keys 
[sshuser@server ~]$ chmod 600 .ssh/authorized_keys 
[sshuser@server ~]$ cat id_rsa.pub >>  .ssh/authorized_keys 
```

### Tera Term を使ったWindowsクライアントからの公開鍵認証による接続
Tera Termを使って、公開鍵認証でサーバに接続します。

1. Tera Termを起動し、サーバに接続します。
2. 「SSH認証」ダイアログで、ユーザ名、パスフレーズ（秘密鍵に設定したもの）を入力します。
3. 「RSA/DSA/EC DSA鍵を使う」を選択し、「秘密鍵」ボタンをクリックして保存しておいた秘密鍵ファイル（id_rsa）を選択し、「OK」ボタンをクリックします。

![「RSA/DSA/EC DSA鍵を使う」を選択して、秘密鍵を指定します](teraterm8.png)

これで、TeraTermを使って公開鍵認証でログインができました。

### パスワード認証の禁止と管理者ユーザrootのログインの禁止
公開鍵認証による接続ができるようになったら、OpenSSHサーバの設定を変更してパスワード認証による接続を禁止しておきます。

OpenSSHサーバの設定ファイル/etc/ssh/sshd_configを以下のように設定変更します。

```shell-session
[root@server ~]# vi /etc/ssh/sshd_config

PasswordAuthentication ※no ←noに変更
```

また、管理者ユーザrootの外部からの直接ログインを禁止することもできます。rootユーザの直接ログインを許すかどうかは後述します。rootユーザのSSHログインを禁止するには、以下のように変更します。

```shell-session
PermitRootLogin ※no ←noに変更
```

設定を保存したら、serviceコマンドでsshdを再起動します。

```shell-session
[root@server ~]# service sshd restart
sshd を停止中:                                             [  OK  ]
sshd を起動中:                                             [  OK  ]
```

これで、外部からのパスワード認証を使ったログインが禁止され、かつrootユーザでのSSHログインが禁止されました。

## root権限の管理
管理者ユーザであるrootは最も高い権限を持っているアカウントとなるため、管理方法には注意が必要です。
root権限を取得するには、以下の3つの方法があります。

* rootで直接ログインする
* 一般ユーザでログインした後、suコマンドを実行して管理者ユーザrootに切り替える
* 一般ユーザでログインした後、sudoコマンドを使ってroot権限でコマンドを実行する

どの方法も一長一短がありますが、rootで直接ログインするのは許さず、一般ユーザでログインした後、suコマンドかsudoコマンドを使用させることが多いようです。

また、root権限を使った作業を中断して席を離れる際には、ログアウトするか画面をロックするなどして、他人に勝手に操作されないようにするなど十分注意を払う必要があります。もちろん、一般ユーザでのログイン時も同様に気を付けましょう。

サーバの設置場所も重要です。サーバに物理的にアクセスされてしまうと、システムの様々なセキュリティ対策も用を為さなくなってしまいます。サーバはロックのかかったマシンルームやサーバラック内に設置し、許可された作業者のみアクセスできるようにすることが望ましいでしょう。

### rootユーザで直接ログインする
rootユーザで直接ログインすると、まず誰がログインしたのかログに残らなくない問題があります。
たとえばlastコマンドを実行すると、以下のようにログインしたのはrootユーザであることが分かりますが、作業者は誰なのか分かりません。

```shell-session
# last
root     ttyS0                         Mon Aug 11 12:56   still logged in
root     ttyS0                         Mon Aug 11 12:23 - 12:56  (00:32)
root     ttyS0                         Mon Aug 11 01:11 - 12:23  (11:11)
```

また、rootパスワードの管理も煩雑になります。たとえば、担当者が異動や退職したタイミングで全部のサーバのrootパスワードを変更すべきですし、サーバの管理台数が多くなるとrootパスワードを変更するための作業に大変な手間がかかります。

OpenSSHの設定でrootユーザの直接ログインを許すと、パスワードの総当たり攻撃(ブルートフォース攻撃)の標的とされてしまう危険性もあります。SSH接続のパスワード認証を禁止にし、SSH公開鍵認証方式を利用する、ファイアウォールでOpenSSHサーバに対して接続できるIPアドレスを制限する等の対策が必要です。

### 一般ユーザからsuコマンドでユーザrootに切り替える
一般ユーザでログインした後、suコマンドを実行して管理者ユーザrootに切り替えると、どのユーザがrootユーザに切り替えたかログで確認できます。

以下の例では、uidが501のユーザsuzukiがsuコマンドを実行したことが分かります。

```shell-session
$ su -
パスワード:
# tail /var/log/secure
（略）
Jan  6 11:33:55 server su: pam_unix(su-l:session): session opened for user root by suzuki(uid=501)
```

ただし、rootとして実行したコマンドのログは記録されないので、複数の管理者がrootとして作業すると、ファイルの削除やシステムの設定変更などが行われても、誰がいつ行ったのか後からログで調査することが難しくなってしまいます。

suコマンドは、システムの初期設定時など一人のユーザが操作を行い、操作のログを残しておく必要が無いような場合に向いているといえます。

### suコマンドを実行できるユーザを制限する
suコマンドはrootパスワードを知っているユーザなら誰でもrootになれる事が問題になる場合があります。PAM（Pluggable Authentication Modules）の設定を変更して、suコマンドを実行できるユーザを制限します。

wheelグループに所属しているユーザのみsuコマンドを実行してrootに切り替えられるように設定します。

PAMの設定ファイル/etc/pam.d/suをviエディタで開いて、行頭のコメントアウトを2カ所外します。
上の設定行は、wheelグループに所属しているユーザはパスワード無しでsuコマンドを実行できる、という設定です。
下の設定行は、wheelグループに所属しているユーザのみsuコマンドを実行できる、という設定です。

```shell-session
#  vi /etc/pam.d/su

#%PAM-1.0
auth            sufficient      pam_rootok.so
# Uncomment the following line to implicitly trust users in the "wheel" group.
auth           sufficient      pam_wheel.so trust use_uid ※←行頭の#を削除
# Uncomment the following line to require a user to be in the "wheel" group.
auth           required        pam_wheel.so use_uid ※←行頭の#を削除
auth            include         system-auth
account         sufficient      pam_succeed_if.so uid = 0 use_uid quiet
account         include         system-auth
password        include         system-auth
session         include         system-auth
session         optional        pam_xauth.so
```

設定変更はすぐに反映されるので、システムの再起動などは必要ありません。

確認のため、一般ユーザsuzukiでsuコマンドを実行してみます。正しいrootのパスワードを入力しても、rootの切り替えることができません。

```shell-session
$ id suzuki
uid=501(suzuki) gid=501(suzuki) 所属グループ=501(suzuki),5000(eigyou)
$ su -
パスワード:
su: パスワードが違います
```

rootユーザでgpasswdコマンドを実行して、ユーザsuzukiをwheelグループに所属させます。

```shell-session
# gpasswd -a suzuki wheel
Adding user suzuki to group wheel
```

所属グループはログイン時に設定されます。ユーザsuzukiでログインし直して、再度suコマンドを実行します。今度はパスワード無しでrootに切り替わります。

```shell-session
$ id suzuki
uid=501(suzuki) gid=501(suzuki) 所属グループ=501(suzuki),10(wheel),5000(eigyou)
$ su -
[root@server ~]# 
```

### 一般ユーザがsudoコマンドを実行する
sudoコマンドを使うと、一般ユーザはコマンドをroot権限で実行できます。特定のユーザやグループに対して、特定のコマンドのみ実行できるように設定するなど細かい制御ができます。suコマンドと異なり、sudoコマンドの実行には、実行したユーザのパスワードを入力して認証を行う必要があります。

sudoコマンドは実行履歴がログに残るので、後からいつ、誰が、どのコマンドを実行したのか調査できる点にメリットがあります。また、実行時の認証が実行ユーザのパスワードなので、rootユーザのパスワードを共有したり、管理したりする必要がなくなります。

CentOSでは、デフォルトでは一般ユーザはsudoコマンドを実行する権限が与えられていません。

```shell-session
$ id suzuki
uid=501(suzuki) gid=501(suzuki) 所属グループ=501(suzuki),10(wheel),5000(eigyou) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
$ sudo cat /etc/shadow

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for suzuki: ※ユーザsuzukiのパスワードを入力
suzuki は sudoers ファイル内にありません。この事象は記録・報告されます。
```

sudoコマンドの設定を行って、wheelグループに所属しているユーザはsudoコマンドを実行できるように設定します。
管理者ユーザrootでvisudoコマンドを実行し、設定ファイル/etc/sudoersを編集して、wheelグループに所属しているユーザのみsudoコマンドを使えるように設定します。

```shell-session
# visudo
```

下記の行の行頭のコメントを外して有効にします。「%wheel」はwheelグループを指定し、「ALL=(ALL) ALL」ですべてのコマンドを実行可能としています。

```shell-session
%wheel ALL=(ALL)       ALL ※←行頭の#を削除
```

visudoコマンドはviエディタを呼び出しただけですので、「:wq」と入力して編集を終了します。終了時に文法のチェックが行われ、間違いがあった場合にはエラーが表示されます。

確認のため、sudoコマンドでuseraddコマンドを実行してユーザ作成を行います。

```shell-session
$ sudo useradd testuser
[sudo] password for suzuki: ※ユーザsuzukiのパスワードを入力
[suzuki@server ~]$ id testuser
uid=503(testuser) gid=503(testuser) 所属グループ=503(testuser)
```

### sudoで実行できるコマンドの制限
sudoコマンドでは、ある特定のグループに対して、一部のコマンドのみ実行できるように制限できます。

たとえば、グループwebadmに所属しているユーザに対してWebサーバ（httpd）の起動や停止、再起動ができるような権限を付与するには、visudoを実行して以下の1行を追加します。実行可能なコマンドをカンマ区切りで記述していきます。

```shell-session
$ sudo visudo

%webadm       ALL=NOPASSWD:  /sbin/service httpd start, /sbin/service httpd stop, /sbin/service httpd restart
```

webadmグループに所属するユーザアカウントを作成します。useraddコマンドに-G（大文字）オプションを付与して実行すると、ユーザアカウント作成時にサブグループへの所属を指定できます。

```shell-session
$ sudo groupadd webadm
$ sudo useradd -G webadm httpdtest
```

su -コマンドで作成したユーザhttpdtestに切り替えます。

```shell-session
$ sudo su - httpdtest
$ id
uid=504(httpdtest) gid=504(httpdtest) 所属グループ=504(httpdtest),5001(webadm)
```

sudo コマンドを使ってWebサーバ を起動します。

```shell-session
$ sudo service httpd start
httpd を起動中: httpd: Could not reliably determine the server's fully qualified domain name, using 192.168.0.10 for ServerName
                                                           [  OK  ]
```

警告が出ていますが、ここでは無視して構いません。

Webサーバが起動したか、プロセスを確認します。

```shell-session
$ ps ax | grep httpd
28608 pts/0    S      0:00 su - httpdtest
31175 ?        Ss     0:00 /usr/sbin/httpd
31176 ?        S      0:00 /usr/sbin/httpd
31177 ?        S      0:00 /usr/sbin/httpd
31179 ?        S      0:00 /usr/sbin/httpd
31180 ?        S      0:00 /usr/sbin/httpd
31181 ?        S      0:00 /usr/sbin/httpd
31182 ?        S      0:00 /usr/sbin/httpd
31183 ?        S      0:00 /usr/sbin/httpd
31184 ?        S      0:00 /usr/sbin/httpd
31198 pts/0    S+     0:00 grep httpd
```

Webサーバの停止を行います。

```shell-session
$ sudo service httpd stop
httpd を停止中:                                            [  OK  ]
$ ps ax | grep httpd
28608 pts/0    S      0:00 su - httpdtest
31325 pts/0    S+     0:00 grep httpd
```

一般ユーザでWebサーバの起動や停止ができるようになりました。
