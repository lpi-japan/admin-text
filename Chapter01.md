# ユーザーとグループの管理

## ユーザーの管理
WindowsやmacOSなどの「デスクトップOS」では、基本的に1人のユーザーが1台のマシンを占有して利用します。

それに対して、Linuxなどの「サーバーOS」では、複数のユーザーが同時に利用できるように最適化された環境になっています。そのため、管理者は利用者一人一人にユーザーアカウントを作成し、ユーザーは自分専用のユーザーアカウントでログインする仕組みとなっています。

### ユーザーアカウントの種類
ユーザーアカウントの種類には、一般アカウントの「一般ユーザー」と、管理者権限である「rootユーザー」(スーパーユーザー)、そしてアプリケーションで利用される「システムユーザー」が存在します。

| ユーザーの種類 | 用途 |
| ------- | ------- |
| 一般ユーザー | ユーザー個人のアカウント |
| rootユーザー(スーパーユーザー) | 管理者権限を持つユーザー |
| システムユーザー | システムやアプリケーションで使用するユーザー |

### 一般ユーザー
一般ユーザーは、通常のユーザーがサーバーにログインして利用するためのアカウントです。

ユーザー情報の確認は、idコマンドを使います。以下の例では、OSインストール時に作成したユーザーlinucでログインした後、idコマンドでユーザー情報を確認しています。

```
$ id
uid=1000(linuc) gid=1000(linuc) groups=1000(linuc),10(wheel) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

uidはユーザーを識別するためのユーザーID、gidは主グループIDを示しています。所属グループ（groups）には所属している主グループIDおよびサブグループIDが表示されます。

一般ユーザーのuidは、AlmaLinuxでは1000〜65535が使用されます。値はディストリビューションによって範囲が異なります。

### rootユーザー
rootユーザーは、管理者権限を持っている特別なユーザーでuidには0が付与されています。スーパーユーザーとも呼ばれます。

rootユーザーになるには、主に以下の方法があります。

#### Linuxのローカルコンソールからrootユーザーでログインする
Linuxの動作しているマシンを直接操作できる時には、ローカルコンソールからrootユーザーでログインできます。

#### 一般ユーザーでログインした後、suコマンドを実行する
一般ユーザーからrootユーザーになるには、suコマンドを使います。suコマンドを実行するときに-（ハイフンのみ）オプションを付けると、そのユーザーでログインしたのと同じことになります。ただし、rootユーザーにパスワードが設定されていないと行えません。あるいは、sudoコマンド（後述）を使ってsuコマンドを実行することも可能です。

以下の例は、sudoコマンドを使ってsuコマンドを実行した例です。

```
$ sudo su -
[sudo] linuc のパスワード:
#
```

プロンプトがrootユーザー用の「#」に変わったのが分かります。
idコマンドで、ユーザー識別子を表示します。

```
# id
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

rootユーザーのuidは必ず0になります。

rootユーザーは一般ユーザーのように常用してはいけません。何故なら、入力したコマンドの間違い等のオペレーションミスで、システム障害に繋がる危険性があるからです。rootユーザーの権限が必要なコマンドの実行は、次に解説するsudoコマンドを使用します。

### 一般ユーザーがsudoコマンドを実行する
sudoコマンドを使うと、一般ユーザーはコマンドをroot権限で実行できます。特定のユーザーやグループに対して、特定のコマンドのみ実行できるように設定するなど細かい制御ができます。suコマンドと異なり、sudoコマンドの実行には、実行したユーザーのパスワードを入力して認証を行う必要があります。

sudoコマンドは実行履歴がログに残るので、後からいつ、誰が、どのコマンドを実行したのか調査できる点にメリットがあります。また、実行時の認証が実行ユーザーのパスワードなので、rootユーザーのパスワードを共有したり、管理したりする必要がなくなります。

本教科書では、原則sudoコマンドを使って実習を進めていきます。

### システムユーザー
システムユーザーは、バックグラウンドで動くサービスが使用するユーザーです。AlmaLinuxではuidの1から999がシステムユーザー用に予約されています。一般ユーザーのようにログインして利用するユーザーではありません。

たとえば、SSHを動作させるためには、「sshd」ユーザーがシステム内部でsshdデーモンを実行しています。rootユーザーはidコマンドを使って、他のユーザーの情報を確認できます。sshdサービスのシステムユーザーの情報を確認しましょう。

```
$ id sshd
uid=74(sshd) gid=74(sshd) groups=74(sshd)
```

### useraddコマンドによる一般ユーザーの作成
新規に一般ユーザーを作成するには、rootユーザーでuseraddコマンドを実行します。useraddコマンドの引数にユーザー名を指定します。

ユーザーを作成後、必要に応じてpasswdコマンドでパスワードを設定します。

以下の例では、-cオプションでコメントを入れています。

```
$ sudo useradd -c "Ichiro Suzuki" suzuki
$ id suzuki
uid=1001(suzuki) gid=1001(suzuki) groups=1001(suzuki)
```

useraddコマンドの主なオプションは以下の通りです。

|オプション|説明|
|-------|-------|
|-u|ユーザーIDを指定する|
|-g|主グループ名または主グループIDを指定する|
|-G|サブグループを指定する。複数指定するときはカンマ(,)で区切る|
|-s shell|ユーザーのログインシェルを指定する|
|-c コメント|コメントを入れる（ユーザーのフルネームなど）|
|-d ディレクトリ名|ホームディレクトリを指定する|
|-e YYYY-MM-DD|ユーザーアカウントが無効になる年月日を指定する|

### パスワードの設定
passwdコマンドを使って、引数で指定したユーザーのパスワードを設定します。

```
$ sudo passwd suzuki
ユーザー suzuki のパスワードを変更。
新しい パスワード:
新しい パスワードを再入力してください:
passwd: すべての認証トークンが正しく更新できました。
```

管理者であるrootユーザーがパスワードを設定した場合、該当のユーザーがログインしてパスワードを変更することが推奨されます。この時、既存のパスワードと新しく設定するパスワードの両方を聞かれます。新しく設定するパスワードは、誕生日や名前など推測されやすいパスワードにしないように注意しましょう。

以下の例では、ユーザーsuzukiでログインした後、パスワードを変更しています。

```
[suzuki@vbox ~]$ passwd
ユーザー suzuki のパスワードを変更。
Current password: ※ユーザーsuzukiの現在のパスワードを入力
新しい パスワード: ※ユーザーsuzukiの新しいパスワードを入力
新しい パスワードを再入力してください: ※ユーザーsuzukiの新しいパスワードを再入力
passwd: すべての認証トークンが正しく更新できました。
```

### ユーザー情報の確認
ユーザー情報は/etc/passwdファイルに保管されています。
ファイルの内容を閲覧するcatコマンドを使って/etc/passwdファイルを確認します。

```
$ cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
（略）
linuc:x:1000:1000:LinuC:/home/linuc:/bin/bash
suzuki:x:1001:1001:Ichiro Suzuki:/home/suzuki:/bin/bash
```

/etc/passwdは左から順に以下の情報が入っていて、コロン(:)で区切られています。

|項目|意味|
|-------|-------|
|ユーザー名|ユーザーアカウント名|
|パスワード|xはシャドウパスワードが設定されている|
|ユーザーID|ユーザーID|
|グループID|グループID|
|コメント|ユーザーに関するコメント|
|ホームディレクトリ|ユーザーのホームディレクトリ|
|シェル|ログインした時に起動するシェル|

### シャドウパスワードについて
かつてのUNIXでは、ユーザーのパスワードを暗号化（ハッシュ化）して/etc/passwdに記録していました。しかし、/etc/passwdは誰でも内容を読むことができるファイルのため、一般ユーザーにパスワードを解析されてしまう危険性がありました。

そのため、rootユーザーのみ読み取れるシャドウファイル(/etc/shadow)を用意し、暗号化（ハッシュ化）したパスワードを別途格納しています。暗号化は元に戻すこと（復号）ができますが、ハッシュ化は元に戻すことができない（困難）な仕組みです。パスワードがシャドウファイルに格納されていると、/etc/passwdのパスワード部分にはxが入るようになっています。

/etc/shadowのパーミッションは000、あるいは400に設定されています。rootユーザーはパーミッションに関係なく読み取ることができますが、その他のユーザーは読み書きすることができません。パーミッションの詳細については後述します。

```
$ ls -l /etc/shadow
----------. 1 root root 1157  7月 20 20:48 /etc/shadow
```

rootユーザーで、ユーザーsuzukiのシャドウパスワードを確認してみましょう。

```
$ sudo cat /etc/shadow | grep suzuki
suzuki:$6$rounds=100000$LJ9X08ZYN/zXIRaf$MlFDUV8wemu1kcBDCmfR0kt0d7thdFo7Y9dZ9sK
HlG6ua8TrIcMmrHkN3IGdSwFtHaW1sKdNINZtAXNAlmzl.:20289:0:99999:7:::
```

ユーザー名の後にある文字列がパスワードをハッシュ化したものです。$で区切られており、それぞれの項目の意味は以下の通りです。

| 項目 | 意味 |
| - | - |
| 6 | ハッシュ方式。6はSHA-512 |
| rounds=100000 | パスワードのハッシュ化を繰り返す回数。総当たり攻撃の速度を遅らせる役割を持っている |
| LJ9X08ZYN/zXIRaf| ソルトと呼ばれる入力されたパスワードの文字数を増やす値 |
| MlF...mzl.| ハッシュ化されたパスワード |

## グループの管理
ユーザーを管理するひとつの単位として、グループ機能があります。このグループでは、所属する部署やユーザーの役割などによってユーザーにグループを割当て、グループ単位での適切な管理が行えます。

たとえば、特定のディレクトリ配下へのアクセスや、特定のファイルの読み書きを特定のグループのみに制限したいとき、「パーミッション」という機能を使って管理できます。

### 主グループとサブグループ
ユーザーは、1つ以上のグループに所属している必要があります。ユーザーが最初に所属するグループを「主グループ」(またはプライマリーグループ)といいます。所属できる主グループは一つのみで、複数のグループにユーザーを所属させたい場合はサブグループを割り当てます。

```
$ id suzuki
uid=1001(suzuki) gid=1001(suzuki) groups=1001(suzuki)
```

gidが主グループです。所属グループはユーザーが所属しているすべてのグループが表示されます。

### /etc/groupを確認する
グループの設定は/etc/groupファイルに格納されていますので、確認してみましょう。

```
$ cat /etc/group
root:x:0:
bin:x:1:
（略）
linuc:x:1000:
suzuki:x:1001:
```

useraddコマンドは、主グループの指定が無かった場合には作成するユーザーと同じ名前のグループを作成し、そのグループをユーザーの主グループに指定します。グループIDも、作成するユーザーのuidと同じになります。

### グループの作成
groupaddコマンドでグループを作成します。グループIDを指定したい時は-gオプションを使います。グループIDが指定されなかった時には、自動的に割り当てられます。

groupaddコマンドの書式は以下の通りです。

```
groupadd [-g グループID] グループ名
```

グループID 5000を指定してgrouptestというグループを作成します。

```
$ sudo groupadd -g 5000 grouptest
```

/etc/groupファイルを確認します。

```
$ cat /etc/group | grep grouptest
grouptest:x:5000:
```

### グループ名の変更
groupmodコマンドでグループ名を変更します。

groupmodコマンドの書式は以下の通りです。

```
groupmod [-n 新しいグループ名] グループ名
```

グループ名をgrouptestからeigyouに変更します。

```
$ sudo groupmod -n eigyou grouptest
```

/etc/groupファイルを確認します。

```
$ cat /etc/group | grep eigyou
eigyou:x:5000:
```

同じグループIDで、グループ名がeigyouに変更になりました。

### ユーザーをサブグループに所属させる
ユーザーをサブグループに所属させるときは、usermodコマンドを使います。-G（大文字）オプションで所属させたいサブグループをカンマ区切りですべて指定します。所属していたサブグループの指定を忘れると、そのサブグループの所属から外れてしまうので注意してください。所属しているサブグループが多い場合には、-aオプションを使って所属サブグループを追加する指定を行うか、後述するgpasswdコマンドを使用してください。

usermodコマンドの書式は以下の通りです。

```
usermod [-G サブグループ名 [,...]] [-a] ユーザー名
```

ユーザーsuzukiの所属するサブグループとしてeigyouグループを指定します。

```
$ sudo usermod -G eigyou suzuki
```

idコマンドでサブグループが追加されているか確認します。

```
# id suzuki
uid=1001(suzuki) gid=1001(suzuki) groups=1001(suzuki),5000(eigyou)
```

所属グループにeigyouサブグループが追加されているのが分かります。

### サブグループの所属ユーザーを確認する
グループにサブグループとして所属しているユーザーは、/etc/groupに記述されています。

```
$ cat /etc/group
（略）
suzuki:x:1001:
eigyou:x:5000:suzuki
```

ユーザーsuzukiが、eigyouグループにサブグループとして所属しているのが分かります。

### gpasswdコマンドを使ってサブグループを管理する
ユーザーの所属しているサブグループが多い場合、gpasswdコマンドを使うのが便利です。gpasswdコマンドは、追加や除外したいサブグループを1つだけ指定できます。

gpasswdコマンドの書式は以下の通りです。

```
gpasswd -a 追加するユーザー名 グループ名
gpasswd -d 除外するユーザー名 グループ名
```

ユーザーsuzukiの所属するサブグループからeigyouグループを除外します。

```
$ sudo gpasswd -d suzuki eigyou
ユーザー suzuki をグループ eigyou から削除
$ id suzuki
uid=1001(suzuki) gid=1001(suzuki) groups=1001(suzuki)
```

/etc/groupを確認して、eigyouグループからユーザーsuzukiが削除されていることを確認します。

```
$ cat /etc/group
（略）
suzuki:x:1001:
eigyou:x:5000:
```

eigyouグループからユーザーsuzukiが除外されているのが分かります。

再度、ユーザーsuzukiの所属するサブグループにeigyouグループを指定します。

```
$ sudo gpasswd -a suzuki eigyou
ユーザー suzuki をグループ eigyou に追加
$ id suzuki
uid=1001(suzuki) gid=1001(suzuki) groups=1001(suzuki),5000(eigyou)
```

ユーザーsuzukiの所属グループにeigyouグループが追加されました。

## パーミッションを使ったファイルシステムのアクセス管理
ファイルシステムのアクセス管理を行うには、「パーミッション」という機能を利用します。パーミッション(permission)とは、日本語で「許可」を意味します。

許可されたユーザーやグループのみが特定のファイルやディレクトリにアクセスでき、読み取り・書き込み・スクリプト等の実行ができるように設定できます。

### パーミッションの確認
ユーザーのホームディレクトリに移動します。cdコマンドにオプションや引数を付けなければ、ユーザーのホームディレクトリに移動できます。ホームディレクトリとは、ユーザー個人に割り当てられた領域になり、ここにユーザーが作ったファイルやプログラムを保存したり、ユーザー独自の設定ファイルを格納したりしています。

pwdコマンドで現在のディレクトリがホームディレクトリになっていることを確認します。

```
$ cd
$ pwd
/home/linuc
```

次にtouchコマンドで、空のファイルを作ります。

```
$ touch test.txt
```

lsコマンドに、-lオプションを付けて実行し、ファイルの詳細を表示します。

```
$ ls -l test.txt
-rw-r--r--. 1 linuc linuc 0  7月 20 21:54 test.txt
```

ファイル表示の一番左にある「-rw-r- -r- -」がパーミッションです。

なお、AlmaLinuxの環境では、llコマンドでも「ls -l」と同様の結果が得られます。「ll」は「ls -l」のエイリアスとなるように設定されています。

```
$ ll test.txt
-rw-r--r--. 1 linuc linuc 0  7月 20 21:54 test.txt
```

設定されているエイリアスはaliasコマンドで確認できます。

```
$ alias 
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias xzegrep='xzegrep --color=auto'
alias xzfgrep='xzfgrep --color=auto'
alias xzgrep='xzgrep --color=auto'
alias zegrep='zegrep --color=auto'
alias zfgrep='zfgrep --color=auto'
alias zgrep='zgrep --color=auto'
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

||所有ユーザー|所有グループ|その他|
|-------|-------|-------|-------|
|文字表記|rw-|r- -|r- -|
|数値表記|4+2+0=6|4+0+0=4|4+0+0=4|

先頭から、所有ユーザー（user）、グループ(group)、どちらにも該当しないその他のユーザー(other)のアクセス権限を示しています。

* 先頭の「rw-」が所有ユーザー、すなわちユーザーlinucの権限で、読取・書込ができます。
* 次の「r- -」が所有グループ、すなわちlinucグループの権限で、読み取りのみ可能です。
* 最後の「r- -」がユーザーにもグループにも該当しないその他のユーザーの権限で、読み取りのみ可能です。

### パーミッションの数値表記
パーミッションの数値表記は、設定したい権限に対応する数値の合計値を、所有ユーザー、所有グループ、その他の順に並べた3桁の数値で表されます。

たとえば、上記の例の「rw-r- -r- -」というパーミッションを数字で表記すると「644」になります。

###  ディレクトリのパーミッション
ディレクトリのパーミッションも、基本的な考え方はファイルのパーミッションと同じです。異なる点として、実行権限が無いとそのディレクトリに移動してカレントディレクトリにすることができません。

mkdirコマンドでtestdirという新規ディレクトリを作成し、アクセス権限を変更してみます。

```
$ mkdir testdir
$ ls -ld testdir
drwxr-xr-x. 2 linuc linuc 6  7月 20 22:01 testdir
```

lsコマンドの-dオプションは、ディレクトリそのもののパーミッションなどを確認します。-dオプションが無いと、引数で指定されたディレクトリ内のファイルを表示しようとします。


```
$ ls -l testdir
合計 0
```

testdirディレクトリのパーミッション表記の先頭にディレクトリを識別するdが付いていることが確認できます。このディレクトリのパーミッションは、rwx(4+2+1)、r-x(4+0+1)、r-x(4+0+1)で755になっています。suzukiグループ所属のユーザーや、その他のユーザーはこのディレクトリにアクセスできますが、書き込みは行えません。

パーミッションの変更はchmodコマンドを使用します。chmodコマンドの書式は以下の通りです。

```
chmod モード ファイル
```

モードの指定は文字表記、数値表記の両方が行えます。数値表記は指定された値に設定しますが、文字表記は+と-でパーミッションの付与、または解除を指定します。

以下、文字表記でのモード指定の例です。

|モード指定|意味|
|-------|-------|
|ug+x|ユーザーとグループに実行権限を付与|
|a+x|すべてのユーザーに実行権限を付与|
|g-w|グループの書き込み権限を解除|

以下の例では、chmodコマンドでディレクトリのパーミッションからユーザー自身の実行権限を解除することで、カレントディレクトリにできなくなることを確認しています。

```
$ chmod u-x testdir
$ ls -ld testdir
drw-r-xr-x. 2 linuc linuc 6  7月 20 22:01 testdir
$ cd testdir
-bash: cd: testdir: 許可がありません
$ chmod u+x testdir
$ cd testdir
$ pwd
/home/linuc/testdir
```

### ユーザーアカウントの有効期限を設定する
ユーザーアカウントが使用できる有効期限を設定できます。たとえば、期限が決まっているプロジェクトなど、ユーザーアカウントの使用が期間限定の場合に有効期限を設定します。

新規アカウント追加時にはuseraddコマンド、すでに存在するアカウントの場合にはusermodコマンドに-eオプションを付与して有効期限を指定できます。

ユーザーアカウントの有効期限設定の書式は以下の通りです。

```
useradd -e YYYY-MM-DD ユーザー名
usermod -e YYYY-MM-DD ユーザー名
```

usermodコマンドで既存ユーザーアカウントの有効期限を設定します。ユーザーアカウントに有効期限を設定すると、設定日にアカウントがロックされて使用できなくなります。

以下の例では、動作確認のために有効期限を本日の日付で設定しています。

```
$ sudo usermod -e 2025-7-21 suzuki
```

アカウント有効期限を確認するために、chageコマンドを使います。-lオプションを付与して実行することで、引数で指定したユーザーの各種有効期限などが表示されます。

```
$ sudo chage -l suzuki
最終パスワード変更日				: 7月 20, 2025
パスワード期限:					: なし
パスワード無効化中					: なし
アカウント期限切れ						:  7月 21, 2025
パスワードが変更できるまでの最短日数		: 0
パスワードを変更しなくてよい最長日数		: 99999
パスワード期限が切れる前に警告される日数		: 7
```

確認のため、アカウント有効期限を設定したユーザーアカウントでログインします。「Your account has expired」と表示され、アカウントがロックされている状態になっています。

```
login: suzuki
Password: ※ユーザーsuzukiのパスワードを入力
Your account has expired; please contact your system administrator
```

有効期限をリセットして無期限有効にするには、以下のように「''」（シングルクォート2つ）で空の有効期限を指定します。アカウント期限切れがなしに設定されます。

```
$ sudo usermod -e '' suzuki
$ sudo chage -l suzuki
最終パスワード変更日				: 7月 20, 2025
パスワード期限:					: なし
パスワード無効化中					: なし
アカウント期限切れ						: なし
パスワードが変更できるまでの最短日数		: 0
パスワードを変更しなくてよい最長日数		: 99999
パスワード期限が切れる前に警告される日数		: 7
```

### パスワードの有効期限を設定する
ユーザーのパスワードの有効期限を設定したいときは、chageコマンドを使います。-Mオプションでパスワードの有効な日数を指定します。

以下の例ではパスワードの有効日数を30に設定しているので、30日毎にパスワードを再設定する必要があります。

```
$ sudo chage -M 30 suzuki
```

パスワードの有効期限を確認します。パスワード期限で表示された日付の翌日以降になると、ユーザーログイン時、強制的にパスワードの変更要求を行います。

```
$ sudo chage -l suzuki
最終パスワード変更日				: 7月 21, 2025
パスワード期限:					:  8月 20, 2025
パスワード無効化中					: なし
アカウント期限切れ						: なし
パスワードが変更できるまでの最短日数		: 0
パスワードを変更しなくてよい最長日数		: 30
パスワード期限が切れる前に警告される日数		: 7
```

パスワードの有効期限を即座に失効させるには、-d オプションで0を指定します。このオプションは、パスワードが最後に変更された日付の値を 1970 年 1 月 1 日に設定し、即座にパスワードを失効させ、ユーザーログイン時に強制的にパスワード変更を要求できます。

```
$ sudo chage -d 0 suzuki
```

chageコマンドでアカウントの情報を確認してみると、最終パスワード変更日、パスワード期限、パスワード無効化中の値が「パスワードは変更しなければなりません」になっていることが分かります。

```
$ sudo chage -l suzuki
最終パスワード変更日				:パスワードは変更しなければなりません
パスワード期限:					: パスワードは変更しなければなりません
パスワード無効化中					: パスワードは変更しなければなりません
アカウント期限切れ						: なし
パスワードが変更できるまでの最短日数		: 0
パスワードを変更しなくてよい最長日数		: 30
パスワード期限が切れる前に警告される日数		: 7
```

確認のため、設定したユーザーアカウントでログインします。即座にパスワード再設定が要求されます。以下の実行例では、ログインの代わりにsuコマンドを使用しています。

```
[linuc@vbox ~]$ su - suzuki
You are required to change your password immediately (administrator enforced).
Current password: ※ユーザーsuzukiの現在のパスワードを入力
新しい パスワード: ※ユーザーsuzukiの新しいパスワードを入力
新しい パスワードを再入力してください: ※ユーザーsuzukiの新しいパスワードを再入力
[suzuki@vbox ~]$ 
```

パスワード変更後、再度ログインすると、今度はログインできます。パスワードは30日間有効になります。

```
[suzuki@vbox ~]$ chage -l suzuki
最終パスワード変更日				: 7月 21, 2025
パスワード期限:					:  8月 20, 2025
パスワード無効化中					: なし
アカウント期限切れ						: なし
パスワードが変更できるまでの最短日数		: 0
パスワードを変更しなくてよい最長日数		: 30
パスワード期限が切れる前に警告される日数		: 7
```

### ユーザーの削除
ユーザーを削除します。ユーザーの削除後はログインできなくなります。

以下の例では、ユーザーtestuserを追加し、削除しています。

```
$ sudo useradd testuser
$ id testuser
uid=1002(testuser) gid=1002(testuser) groups=1002(testuser)
$ sudo userdel testuser
$ id testuser
id: `testuser': no such user
```

userdelコマンドをオプション無しで実行すると、ユーザーのホームディレクトリや受信したメールを格納するメールスプールは削除されません。ユーザー削除と同時にホームディレクトリなども削除したい場合には、userdelコマンドに-rオプションをつけて実行する必要があります。

```
$ ls -l /home
合計 4
drwx------. 15 linuc  linuc  4096  7月 20 22:01 linuc
drwx------.  3 suzuki suzuki   99  7月 20 21:35 suzuki
drwx------.  3   1002   1002   78  7月 21 12:03 testuser
$ ls -l /var/spool/mail
合計 0
-rw-rw----. 1 linuc  mail 0  7月 19 11:44 linuc
-rw-rw----. 1 suzuki mail 0  7月 20 20:46 suzuki
-rw-rw----. 1   1002 mail 0  7月 21 12:03 testuser
```

このように、所有ユーザーが削除されたディレクトリやファイルは、パーミッションを確認すると所有ユーザーが元のユーザーIDで表示されるようになります。

再度ユーザーtestuserを作成します。

```
$ sudo useradd testuser
useradd: warning: the home directory /home/testuser already exists.
useradd: Not copying any file from skel directory into it.
メールボックスファイルを作成します: ファイルが存在します
$ ls -l /home
合計 4
drwx------. 15 linuc    linuc    4096  7月 20 22:01 linuc
drwx------.  3 suzuki   suzuki     99  7月 20 21:35 suzuki
drwx------.  3 testuser testuser   78  7月 21 12:03 testuser
$ ls -l /var/spool/mail
合計 0
-rw-rw----. 1 linuc    mail 0  7月 19 11:44 linuc
-rw-rw----. 1 suzuki   mail 0  7月 20 20:46 suzuki
-rw-rw----. 1 testuser mail 0  7月 21 12:03 testuser
```

同じユーザーID（上記の例では1002）でユーザーが追加されたので、ホームディレクトリとメールスプールはユーザーtestuserが再度所有ユーザーになっています。もし、削除後に追加された別のユーザーに同じユーザーID（1002）が割り当てられると、ファイルやディレクトリの所有権が別のユーザーに移ってしまうので注意が必要です。

ホームディレクトリとメールスプールを同時に削除するには、userdel -rコマンドでユーザーを削除します。

```
$ sudo userdel -r testuser
$ ls -l /home
合計 4
drwx------. 15 linuc  linuc  4096  7月 20 22:01 linuc
drwx------.  3 suzuki suzuki   99  7月 20 21:35 suzuki
$ ls -l /var/spool/mail
合計 0
-rw-rw----. 1 linuc  mail 0  7月 19 11:44 linuc
-rw-rw----. 1 suzuki mail 0  7月 20 20:46 suzuki
```

### グループの削除
グループを削除するには、groupdelコマンドを使用します。ユーザーが所属している主グループは削除できませんが、サブグループは警告無しに削除されます。グループを削除する前に/etc/groupを参照して、そのグループに所属しているユーザーがいないか確認しておきます。

以下の例ではユーザーtestuser（主グループtestuser）を作成し、グループtestgroupにサブグループとして所属させています。主グループは削除できませんが、サブグループは削除できます。

```
$ sudo useradd testuser
$ sudo groupadd testgroup
$ sudo gpasswd -a testuser testgroup
ユーザー testuser をグループ testgroup に追加
$ id testuser
uid=1002(testuser) gid=1002(testuser) groups=1002(testuser),5001(testgroup)
$ sudo groupdel testuser
groupdel: ユーザー 'testuser' のプライマリグループは削除できません。
$ sudo groupdel testgroup
$ id testuser
uid=1002(testuser) gid=1002(testuser) groups=1002(testuser)
```

## SSHによるリモートログイン
SSH (Secure Shell) とは、リモート(遠隔)のサーバーにログインしてサーバーを操作するためのプロトコルです。SSHは、外部へ通信の内容が漏れないように通信が暗号化されています。また、パスワード認証よりもセキュリティレベルの高い公開鍵認証ができます。

Linuxでは、OpenSSHのサーバーおよびクライアントが利用できます。また、Linuxサーバーに対してWindowsクライアントからSSHでリモートログインすることもできます。

まずローカルホスト上で公開鍵認証の設定方法を実習し、ホストOSのWindowsから仮想マシン上で動作するゲストOSのLinuxにSSHでログインする方法を解説します。

### SSHサービスの状態確認と開始
AlmaLinuxではOpenSSHサーバーはデフォルトでインストールされて自動的に起動しています。sshdデーモンが起動していることを確認しておきます。SSHプロトコルはポート番号22番を使用しています。

```
$ sudo lsof -i:22
COMMAND  PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd     890   root    3u  IPv4  22943      0t0  TCP *:ssh (LISTEN)
sshd     890   root    4u  IPv6  22945      0t0  TCP *:ssh (LISTEN)
```

### SSHのログイン認証方法
SSHのログイン認証方法には、以下の方法があります。

#### パスワード認証による接続
サーバーに登録済みのユーザー名と、ユーザーのログインパスワードを使ってログイン認証を行います。簡単で分かりやすい認証方式ですが、ユーザー名とパスワードが分かれば誰でもログインできてしまうので、インターネットに接続するサーバーなどでは使用しません。デフォルトで有効になっているので、SSHサーバーの設定を変更して無効にしておきます。

#### 公開鍵認証による接続
事前に作成した公開鍵をログインしたいサーバーに登録しておきます。公開鍵に対応した秘密鍵を持っているユーザーだけがログインできます。パスワード認証に比べて事前の設定が必要になりますが、ログインするためには秘密鍵が必要になるので、パスワード認証より安全な認証の仕組みです。

### パスワード認証による接続
パスワード認証を使って、SSHサーバーに接続してログイン認証を行います。

サーバーに事前にログイン用のユーザーsshuserを作成します。

```
$ sudo useradd sshuser
$ sudo passwd sshuser
ユーザー sshuser のパスワードを変更。
新しいパスワード: ※ユーザーsshuserの新しいパスワードを入力
新しいパスワードを再入力してください: ※ユーザーsshuserの新しいパスワードを再入力
passwd: すべての認証トークンが正しく更新できました。
```

ローカルホストにSSHで接続します。接続するにはsshコマンドを使用します。ユーザー名を省略すると、sshコマンドを実行したユーザーのユーザー名が指定されたことになります。

sshコマンドの書式は以下の通りです。

```
$ ssh [ユーザー名@]接続先
```

接続先にはIPアドレス、又は名前解決できるホスト名を指定します。今回はローカルホスト（localhost）にローカルループバックで接続してみます。ローカルループバックは、IPv4のアドレスでは127.0.0.1、IPv6では::1を宛先アドレスとしたホスト自身に接続する方法です。

```
$ ssh sshuser@localhost
```

SSHサーバーに接続すると、サーバーから「SSHサーバー証明書」が送られてきます。初回の接続時には以下のように尋ねられるので、yesと入力し、作成したユーザーsshuserのパスワードを入力します。ログインすると、コマンドプロンプトの表示が変わってsshuserでログインしたことが分かります。

```
[linuc@vbox ~]$ ssh sshuser@localhost
The authenticity of host 'localhost (::1)' can't be established.
ED25519 key fingerprint is SHA256:mVq+9GENHHauxEaOHKosLF8VcGW3rqny2PNy1Yio/zk.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes ※yesと入力
Warning: Permanently added 'localhost' (ED25519) to the list of known hosts.
sshuser@localhost's password: ※サーバーに作成したユーザーsshuserのパスワードを入力
[sshuser@vbox ~]$ id
uid=1003(sshuser) gid=1003(sshuser) groups=1003(sshuser) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

ログアウトするには、exitコマンドを使用します。

```
[sshuser@vbox ~]$ exit
ログアウト
Connection to localhost closed.
[linuc@vbox ~]$
```

### sshコマンドの冗長モードによるトラブルシューティング
もし、ログインがうまくいかない場合はsshコマンドに-vオプション(冗長モード)を付けてデバッグ用のメッセージを表示させ、詳細を確認します。

```
[linuc@vbox ~]$ ssh -v sshuser@localhost
OpenSSH_8.7p1, OpenSSL 3.2.2 4 Jun 2024
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: Reading configuration data /etc/ssh/ssh_config.d/50-redhat.conf
debug1: Reading configuration data /etc/crypto-policies/back-ends/openssh.config
debug1: configuration requests final Match pass
debug1: re-parsing configuration
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: Reading configuration data /etc/ssh/ssh_config.d/50-redhat.conf
debug1: Reading configuration data /etc/crypto-policies/back-ends/openssh.config
debug1: Connecting to localhost [::1] port 22.
debug1: Connection established.
（略）
Last login: Mon Jul 21 14:50:00 2025 from ::1
[sshuser@vbox ~]$ exit
[linuc@vbox ~]$ 
```

SSHプロトコルのやり取りが表示されるので、問題になっているやり取りを探すことができます。

### SSHサーバー証明書による「なりすまし」の防止
一度接続したことのあるサーバーのSSHサーバー証明書は、クライアントのホームディレクトリに作られた.sshディレクトリの中に作成されたknown_hostsファイルに保存されます。2回目以降の接続時には、初回に尋ねられた表示は出ず、すぐに認証のためのパスワード入力が要求されます。

```
[linuc@vbox ~]$ ssh sshuser@localhost
sshuser@server's password: 
Last login: Mon Sep  1 07:21:42 2025 from ::1
[sshuser@vbox ~]$ exit
[sshuser@vbox ~]$
```

catコマンドでクライアントにある\~/.ssh/known_hostsファイルの中身を確認してみましょう。

```
[linuc@vbox ~]$ cat .ssh/known_hosts
localhost ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF67wXfBQsFqTo7nM1aPX0yQh4DbQwvYXyBmZPepW6b9
localhost ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPPbQ64LradMJ8nv+A5zIe5VKbawLPNylJznt61j3BUNz6
（略）
localhost ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBpjYw71x2i6
QU0WQa+MWhs3k7G/lJZlDsHA55siz79uQJh7d5Ya5GH8X5AmO1POOX4e3N8/t/3XTyLHwy/RA1A=
```

SSHサーバー証明書は、SSHサーバーに接続した際にサーバーからクライアントに対して送られてきます。初回接続時は\~/.ssh/known_hostsに保存されているSSHサーバー証明書が無いので、接続してもよいか確認されます。yesと答えるとサーバー証明書は\~/.ssh/known_hostsに保存されます。

2回目以降の接続では、送られてきたSSHサーバー証明書とknown_hostsに保存してあるSSHサーバー証明書を比較して、同一であれば同じサーバーであることが分かります。もし異なるSSHサーバー証明書が送られてきた場合には、別のサーバーが「なりすまし」をしている可能性があるので、sshコマンドは警告を表示して接続を中断します。

また、仮にコピーしたSSHサーバー証明書を送ってきてサーバーなりすましをしようとしても、その後の接続手順の中で確認作業を行っているので、やはり接続は中断され、サーバーなりすましは失敗します。SSHサーバーには、SSHサーバー証明書（公開鍵）とサーバー秘密鍵の、ペアになった2つの鍵が必要だからです。公開鍵と秘密鍵については後述します。

サーバーの再インストールなどを行うと、サーバーのSSHサーバー証明書は再作成され、変更されてしまいます。その場合には、クライアントの\~/.ssh/known_hostsファイルに登録されているSSHサーバー証明書を削除して下さい。\~/.ssh/known_hostsファイルは単なるテキストファイルなので、viエディタなどで該当するSSHサーバー証明書を削除するか、後述するssh-keygenコマンドで削除します。

以下の例では、既存のSSHサーバー証明書や対となる秘密鍵を削除して、SSHサーバーを再起動してサーバー証明書を再作成します。再度SSHサーバーに接続することで、接続が拒否されることや、クライアント側に保存されたサーバー証明書を削除することで再度接続できるようになることを確認します。

サーバー証明書は、SSHサーバーの動作しているシステムの/etc/sshディレクトリ内にあるssh_hostで始まるファイルです。

```
$ ls /etc/ssh/ssh_host*
/etc/ssh/ssh_host_ecdsa_key      /etc/ssh/ssh_host_ed25519_key      /etc/ssh/ssh_host_rsa_key
/etc/ssh/ssh_host_ecdsa_key.pub  /etc/ssh/ssh_host_ed25519_key.pub  /etc/ssh/ssh_host_rsa_key.pub
```
ファイル名が_keyで終わるファイルが秘密鍵、_key.pubで終わるファイルがサーバー証明書です。これらを削除してみます。

```
[linuc@vbox ~]$ sudo rm /etc/ssh/ssh_host*
[linuc@vbox ~]$ ls /etc/ssh/ssh_host*
ls: '/etc/ssh/ssh_host*' にアクセスできません: そのようなファイルやディレクトリはありません
```

SSHサーバーを再起動すると、秘密鍵とサーバー証明書が再作成されます。

```
[linuc@vbox ~]$ sudo systemctl restart sshd
[linuc@vbox ~]$ ls /etc/ssh/ssh_host*
/etc/ssh/ssh_host_ecdsa_key      /etc/ssh/ssh_host_ed25519_key      /etc/ssh/ssh_host_rsa_key
/etc/ssh/ssh_host_ecdsa_key.pub  /etc/ssh/ssh_host_ed25519_key.pub  /etc/ssh/ssh_host_rsa_key.pub
```

再度、ローカルホストにSSHでログインしてみます。


```
[linuc@vbox ~]$ ssh sshuser@localhost
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
SHA256:9t/Wd3Arnr427qUAcRCvwMYOEVguhsz4T4cfvLACx5w.
Please contact your system administrator.
Add correct host key in /home/linuc/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /home/linuc/.ssh/known_hosts:3
Host key for localhost has changed and you have requested strict checking.
Host key verification failed.
```

known_hostsに保存されたサーバー証明書と、再作成されて送られて来たサーバー証明書が異なるため、警告が表示されて接続できなくなりました。

known_hostsに保存してあるサーバー証明書を削除します。ssh-keygenコマンドに-Rオプションをつけて実行すると、サーバー証明書を削除できます。

```
[linuc@vbox ~]$ ssh-keygen -R localhost
# Host localhost found: line 1
# Host localhost found: line 2
# Host localhost found: line 3
/home/linuc/.ssh/known_hosts updated.
Original contents retained as /home/linuc/.ssh/known_hosts.old
```

再度接続してみます。新しいサーバー証明書が送られてくるので、保存するためにyesと入力すると正常に接続できます。

```
[linuc@vbox ~]$ ssh sshuser@localhost
The authenticity of host 'localhost (::1)' can't be established.
ED25519 key fingerprint is SHA256:9t/Wd3Arnr427qUAcRCvwMYOEVguhsz4T4cfvLACx5w.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes ※yesと入力
Warning: Permanently added 'localhost' (ED25519) to the list of known hosts.
sshuser@localhost's password:
Last login: Mon Jul 21 13:57:28 2025 from ::1
[sshuser@vbox ~]$
```

実際のシステム管理では、OSを再インストールすることでサーバー証明書が再作成されることがあります。事前にバックアップを取っておき、再インストール後に書き戻すか、クライアント側で以前のサーバー証明書を削除するか、いずれかの方法を採るようにしてください。

### 公開鍵認証による接続
パスワード認証では「ユーザー名」と「パスワード」で認証しますが、もしこのパスワードが漏れてしまうと非常に危険です。また、セキュリティ攻撃用のプログラムを使って手当たり次第にパスワードを試す「総当たり攻撃」の可能性もあります。
そこで、より安全な認証方法として公開鍵認証による接続が利用できます。インターネット上に公開するサーバーの場合には、パスワード認証を禁止し、この公開鍵認証で接続します。

公開鍵認証は、SSH接続用の公開鍵と秘密鍵のキーペアを生成し、接続先のサーバーに公開鍵を登録して認証します。これを「公開鍵認証」といいます。

公開鍵認証の大まかな手順としては、以下のようになります。

1. 公開鍵と秘密鍵のキーペアを生成する
2. クライアントに公開鍵と秘密鍵を設置する
3. サーバーに公開鍵を設置する

### SSH公開鍵・秘密鍵の作成
SSH公開鍵認証に使用する公開鍵と秘密鍵を作成します。Linuxではssh-keygenコマンドを使用します。

公開鍵と秘密鍵の設置場所は、デフォルトではssh-keygenコマンドを実行したユーザーのホームディレクトリにある.sshディレクトリに作成されます。

ssh-keygenコマンドを実行すると、鍵の設置場所とパスフレーズの入力が求められます。パスフレーズは、秘密鍵を有効にするための合言葉のようなものです。万一秘密鍵を盗まれたとしても、パスフレーズが分からなければ鍵の所有ユーザーになりすましてSSHサーバーに接続することはできません。

ユーザーsshuserで公開鍵・秘密鍵を作成します。

```
[linuc@vbox ~]$ sudo su - sshuser
[sshuser@vbox ~]$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/sshuser/.ssh/id_rsa): ※Enterキーを押す
Created directory '/home/sshuser/.ssh'.
Enter passphrase (empty for no passphrase): ※秘密鍵のパスフレーズを入力
Enter same passphrase again: ※秘密鍵のパスフレーズを再入力
Your identification has been saved in /home/sshuser/.ssh/id_rsa
Your public key has been saved in /home/sshuser/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:43Ociwq8FL/su9I+G2awYgv9f4O/YzQz27tnwtuxES4 sshuser@vbox
The key's randomart image is:
+---[RSA 3072]----+
|                 |
|                 |
|                 |
|                 |
|    o   S   .    |
| . . = .=o o .   |
|. + =.=ooBE +    |
| o =.*+o*+++o+   |
|  . o=@X++=Bo    |
+----[SHA256]-----+
```

\~/.sshディレクトリに作成された公開鍵（id_rsa.pub）と秘密鍵(id_rsa)を確認します。.sshディレクトリはsshコマンド実行時、またはssh-keygenコマンド実行時に自動的に作成されます。

```
[sshuser@vbox ~]$ ls -ld .ssh
drwx------. 2 sshuser sshuser 38  7月 21 14:20 .ssh
[sshuser@vbox ~]$ ls -l .ssh
合計 8
-rw-------. 1 sshuser sshuser 2655  7月 21 14:20 id_rsa
-rw-r--r--. 1 sshuser sshuser  566  7月 21 14:20 id_rsa.pub
```

鍵の中身はテキストファイルになっているので、catコマンドで確認できます。

```
[sshuser@vbox ~]$ cat .ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiiI9Fsn0CRxaoO7Xq0q4gEsADAmJNQaWNPOj/licSYrgZ
（略）
sU13lsxJ8= sshuser@vbox
```

公開鍵は1行のテキストですが、秘密鍵は何行かに分かれたフォーマットになっています。

```
[sshuser@vbox ~]$ cat .ssh/id_rsa
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAACmFlczI1Ni1jdHIAAAAGYmNyeXB0AAAAGAAAABAFbcvD8X
iKLcV42cDca6ITAAAAEAAAAAEAAAGXAAAAB3NzaC1yc2EAAAADAQABAAABgQCiiI9Fsn0C
（略）
T8kWVid7AggT/yyOXtxlygEAmC+7g1+NKAkxoqGaVBUOqveGCo+Qn5vLTw5kRHD7dSg3Xo
D7B+VNMSitiB2+f8HwfZJoVBA6I=
-----END OPENSSH PRIVATE KEY-----
```

### SSHクライアントの.sshディレクトリおよび公開鍵・秘密鍵のパーミッション
公開鍵認証に使用する公開鍵・秘密鍵、およびそれらを格納する.sshディレクトリはセキュリティを守るためパーミッションが厳密に決められています。

ssh-keygenコマンドを使用して鍵を作成した際にはパーミッションは適切に設定されていますが、別のマシンで作成した鍵をコピーしてくる場合には、パーミッションを自分で設定する必要があります。

また、所有ユーザーはsshコマンドを実行するユーザーである必要があります。初期設定時などにユーザーの作成から公開鍵・秘密鍵の設置までをrootユーザーで行っていると、所有ユーザーがrootになってしまうので注意が必要です。

設定するパーミッションは以下の通りです。

|ディレクトリおよびファイル|パーミッション|
|-------|-------|
|~/.sshディレクトリ|rwx- - - - - -(700)|
|id_rsa（秘密鍵）|rw- - - - - - -(600)|
|id_rsa.pub（公開鍵）|rw-r- -r- -(644)|

```
[sshuser@vbox ~]$ ls -ld .ssh
drwx------. 2 sshuser sshuser 38  7月 21 14:20 .ssh
[sshuser@vbox ~]$ ls -l .ssh
合計 8
-rw-------. 1 sshuser sshuser 2655  7月 21 14:20 id_rsa
-rw-r--r--. 1 sshuser sshuser  566  7月 21 14:20 id_rsa.pub
```

### サーバーへの公開鍵の設置
次に、クライアントのSSH公開鍵(id_rsa.pub)をサーバーに設置します。以下の手順で設置を行います。

1. クライアントからサーバーに公開鍵をコピー
1. ~/.sshディレクトリを作成
1. ~/.ssh/authorized_keysファイルを作成
1. 公開鍵の内容を~/.ssh/authorized_keysに追加
1. 公開鍵認証でログインできることを確認

これらの手順を自動的に行ってくれるssh-copy-idコマンドもありますが、ファイル名やパーミッションなどの確認も兼ねて手動で実行してみます。

本来であれば、現在使用している仮想マシンとは別の仮想マシンをサーバーとして用意して行いますが、以下の例ではその作業を省略して同一のホストをサーバーと見立てて作業を行っています。別途サーバーを用意できる場合には、あらかじめサーバーにユーザーsshuserを作成し、localhostと記述している箇所をサーバーのIPアドレスに置き換えて実行してみてください。

サーバーに公開鍵（id_rsa.pub）をコピーします。ここではSSHプロトコルを使ったファイルコピーを行うscpコマンドを使います。

scpコマンドの書式は以下の通りです。

```
scp コピー元ファイル ユーザー名@接続先:コピー先ファイル
```

以下のようにscpコマンドを実行して\~/.ssh/id_rsa.pubを、サーバーのユーザーsshuserのホームディレクトリにリモートコピーします。

```
[sshuser@vbox ~]$ scp ~/.ssh/id_rsa.pub sshuser@localhost:~
The authenticity of host 'localhost (::1)' can't be established.
ED25519 key fingerprint is SHA256:9t/Wd3Arnr427qUAcRCvwMYOEVguhsz4T4cfvLACx5w.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'localhost' (ED25519) to the list of known hosts.
sshuser@localhost's password:
id_rsa.pub                                                                                                                              100%  566     1.5MB/s   00:00
合計 4
-rw-r--r--. 1 sshuser sshuser 566  7月 21 14:27 id_rsa.pub

```

sshuserとしてSSH接続するのが初めてだったので、サーバー証明書の保存が要求されました。ホームディレクトリ内に公開鍵がコピーされています。

\~/.sshディレクトリを作成し、公開鍵の設置を行います。

ホームディレクトリに.sshディレクトリを作成し、chmodコマンドでパーミッションを700に変更します。

```
[sshuser@vbox ~]$ mkdir .ssh
mkdir: ディレクトリ `.ssh' を作成できません: ファイルが存在します
[sshuser@vbox ~]$ chmod 700 .ssh
[sshuser@vbox ~]$ ls -ld .ssh
drwx------. 2 sshuser sshuser 80  7月 21 14:27 .ssh
```

既に.sshディレクトリが作成されているのでエラーが表示されましたが、新規のサーバーの場合には存在しないのでエラーは発生しません。パーミッションの設定も忘れずに行います。

.sshディレクトリの中にauthorized_keysファイルを作成し、パーミッションを変更します。公開鍵はこのファイルの中に追加していきます。

```
[sshuser@vbox ~]$ touch .ssh/authorized_keys
[sshuser@vbox ~]$ chmod 600 .ssh/authorized_keys
[sshuser@vbox ~]$ ls -l .ssh/authorized_keys
-rw-------. 1 sshuser sshuser 0  7月 21 14:31 .ssh/authorized_keys
```

公開鍵をauthorized_keysに追加します。cat コマンドで出力をリダイレクトします。出力で“>>”を使うと既存ファイルのauthorized_keysファイルを上書きせずに追記する事ができます。
authorized_keysファイルを作成する作業では、cpコマンドやmvコマンドは使用しないでください。authorized_keysファイルを上書きする危険性がある他、SELinuxが有効になっている場合、正常に動作しないことがあります。

```
[sshuser@vbox ~]$ cat id_rsa.pub >> .ssh/authorized_keys
[sshuser@vbox ~]$ cat .ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiiI9Fsn0CRxaoO7Xq0q4gEsADAmJNQaWNPOj/licSYrgZ
（略）
sU13lsxJ8= sshuser@vbox
```

sshuserでログインします。公開鍵が正しく設置されていれば、秘密鍵のパスフレーズの入力が求められます。もしパスワード認証を求められるような場合には、ファイル名やパーミッションなど、設置の手順を再確認してみてください。

```
[sshuser@vbox ~]$ ssh sshuser@localhost
Enter passphrase for key '/home/sshuser/.ssh/id_rsa': ※秘密鍵のパスフレーズを入力
Last login: Mon Jul 21 14:32:36 2025 from ::1
```

sshコマンドを実行するのはsshuserであり、linucユーザーではないことに注意してください。公開鍵認証を行うにはsshコマンドを実行したユーザーのホームディレクトリ以下の.sshディレクトリ内に秘密鍵id_rsaが存在していることが必要です。何度もログインを繰り返していたりすると、秘密鍵が無い別のユーザーからSSHログインしようとしているために接続できないミスがよく発生します。接続できない時は必ず\~/.sshディレクトリに秘密鍵があることを確認してください。

```
[sshuser@vbox ~]$ ls .ssh/
authorized_keys  id_rsa  id_rsa.pub  known_hosts  known_hosts.old
[sshuser@vbox ~]$ exit
ログアウト
Connection to localhost closed.
[sshuser@vbox ~]$ exit
ログアウト
[linuc@vbox ~]$ ls .ssh
known_hosts  known_hosts.old
[linuc@vbox ~]$ ssh sshuser@localhost
sshuser@localhost's password:
Last login: Mon Jul 21 14:33:24 2025 from ::1
```

ここまでの実習では、suコマンドでsshuserに変更し、さらにSSHでログインしています。2回exitコマンドを実行し、linucユーザーに戻ると、秘密鍵も公開鍵も持っていないことがわかります。そして、linucユーザーでは公開鍵認証は行えず、パスワード認証になります。

### ssh-copy-idコマンドを使った公開鍵の設置
SSH公開鍵を手動で登録する方法の他に、ssh-copy-idコマンドを使った公開鍵の登録方法があります。ssh-copy-idコマンド一つで、ホストのauthorized_keysに公開鍵を自動的に登録できます。

ssh-copy-idコマンドの書式は以下の通りです。

```
$ ssh-copy-id ユーザー名@接続先
```

linucユーザーで公開鍵と秘密鍵を作成した後、ssh-copy-idコマンドを実行してサーバーに公開鍵を登録します。

```
[linuc@vbox ~]$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/linuc/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/linuc/.ssh/id_rsa
Your public key has been saved in /home/linuc/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:M3PenKR+5kG9lyRh8Zprpkn99gBEGUNyUutksZRwpjI linuc@vbox
The key's randomart image is:
+---[RSA 3072]----+
|          ++%=   |
|           Xo=o  |
|        E . *o . |
|         o =..+  |
|        S . =+.. |
|         * *.o+..|
|          o.==o..|
|         .. B..+ |
|          .*. ..o|
+----[SHA256]-----+
[linuc@vbox ~]$ ls .ssh
id_rsa  id_rsa.pub  known_hosts  known_hosts.old
```

ssh-copy-idコマンドを実行します。

```
[linuc@vbox ~]$ ssh-copy-id linuc@localhost
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/linuc/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
linuc@localhost's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'linuc@localhost'"
and check to make sure that only the key(s) you wanted were added.
```

公開鍵認証でSSH接続できるか確認します。

```
[linuc@vbox ~]$ ssh linuc@localhost
Enter passphrase for key '/home/linuc/.ssh/id_rsa':
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Sun Jul 20 22:12:53 2025
[linuc@vbox ~]$ exit
ログアウト
Connection to localhost closed.
[linuc@vbox ~]$
```

公開鍵認証で接続できるようになった後は、SSHサーバーの設定を変更してパスワード認証による接続を禁止します。設定方法は後述します。

### scpコマンドを使ったファイル転送
scpコマンドを使うと、SSHプロトコルを使用してファイル転送ができます。クライアントで作成した公開鍵をサーバーにコピーするために既に使用しましたが、ディレクトリ内の複数のファイルを再帰的に転送することもできます。

クライアントのホームディレクトリにtestdirディレクトリを作成し、その中に複数のファイルを作ります。次に、scpコマンドに-rオプションを付与して実行し、ディレクトリの中身をすべてscptestdirディレクトリという新しいディレクトリに再帰的に転送します。

```
[linuc@vbox ~]$ ls
test.txt  testdir  ダウンロード  テンプレート  デスクトップ  ドキュメント  ビデオ  音楽  画像  公開
[linuc@vbox ~]$ touch testdir/file1
[linuc@vbox ~]$ touch testdir/file2
[linuc@vbox ~]$ ls testdir
file1  file2
[linuc@vbox ~]$ scp -r testdir linuc@localhost:~/scptestdir
Enter passphrase for key '/home/linuc/.ssh/id_rsa':
file1                                                  100%    0     0.0KB/s   00:00
file2                                                  100%    0     0.0KB/s   00:00
[linuc@vbox ~]$ ls
scptestdir  test.txt  testdir  ダウンロード  テンプレート  デスクトップ  ドキュメント  ビデオ  音楽  画像  公開
[linuc@vbox ~]$ ls scptestdir/
file1  file2
```

scptestdirディレクトリが作成され、2つのファイルが転送されていることが確認できます。

### sftpコマンドを使ったファイル転送
SFTP (SSH File Transfer Protocol)とは、SSHでファイルを送受信できるプロトコルです。動作はFTPに似ています。

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

接続先でのリモート操作と、接続元でのローカル操作がある点に注意してください。

あらかじめ転送用のファイルを作成した後、sftpコマンドでクライアントからサーバーにログインします。
ログインできると、”sftp>”というプロンプトが表示されます。

```
[linuc@vbox ~]$ touch sftptestfile
[linuc@vbox ~]$ ls
scptestdir  sftptestfile  test.txt  testdir  ダウンロード  テンプレート  デスクトップ  ドキュメント  ビデオ  音楽  画像  公開
[linuc@vbox ~]$ sftp linuc@localhost
Enter passphrase for key '/home/linuc/.ssh/id_rsa': ※秘密鍵のパスフレーズを入力
Connected to localhost.
sftp> 
```

putコマンドでサーバーにファイルを転送できます。

```
sftp> ls
scptestdir            sftptestfile          test.txt              testdir               ダウンロード    テンプレート
デスクトップ    ドキュメント    ビデオ             公開                画像                音楽
sftp> cd testdir
sftp> ls
file1          file2
sftp> lls
scptestdir  sftptestfile  test.txt  testdir  ダウンロード  テンプレート  デスクトップ  ドキュメント  ビデオ  音楽  画像  公開
sftp> put sftptestfile
Uploading sftptestfile to /home/linuc/testdir/sftptestfile
sftptestfile                                            100%    0     0.0KB/s   00:00
sftp> ls
file1          file2          sftptestfile
sftp> exit
```

## WindowsからのSSH接続
Windowsでもsshコマンドが標準で使用できるため、追加のソフトウェア無しでSSH接続が行えます。ホストOSのWindowsから仮想マシン上のゲストOSであるLinuxに公開鍵認証でリモートログインできるようにするまでの手順を解説します。

### 仮想マシン上のLinuxのIPアドレスを確認
LinuxのIPアドレスをip aコマンドで確認します。

```
[linuc@vbox ~]$ ip a
（略）
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:40:b7:96 brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.101/24 brd 192.168.56.255 scope global dynamic noprefixroute enp0s8
       valid_lft 124875sec preferred_lft 124875sec
（略）
```

LinuxのIPアドレスは 192.168.56.101 です。

\pagebreak

### コマンドプロンプトの起動
Windowsの検索ウインドウに「cmd」と入力し、コマンドプロンプトを起動します。

![コマンドプロンプトの起動](image/Ch01/Runcmd.png){width=50%}


### sshコマンドでリモートログインできることを確認
パスワード認証でLinuxにリモートログインできることを確認します。

```
>ssh linuc@192.168.56.101
```

![パスワード認証でLinuxにリモートログイン](image/Ch01/cmdssh.png){width=75%}

\pagebreak

### 公開鍵・秘密鍵を作成
ssh-keygenコマンドで公開鍵・秘密鍵を作成します。

```
>ssh-keygen
```

![ssh-keygenコマンドで公開鍵・秘密鍵を作成](image/Ch01/ssh-keygen.png){width=75%}


### scpで公開鍵をLinuxにコピー
scpで公開鍵をLinuxにコピーします。

```
>cd .ssh
.ssh>dir
.ssh>scp id_ed25519.pub linuc@192.168.56.101:~/ 
```

![scpで公開鍵をLinuxにコピー](image/Ch01/scp.png){width=75%}

\pagebreak

### Linuxに公開鍵を設置
再度Linuxにリモートログインして公開鍵を設置します。

```
>ssh linuc@192.168.56.101
```

以下はログイン後のLinuxでの作業です。

```
[linuc@vbox ~]$ ls -l id_ed25519.pub
[linuc@vbox ~]$ cat id_ed25519.pub >> .ssh/authorized_keys
[linuc@vbox ~]$ exit
```

catコマンドの出力をauthorized_keysに追加リダイレクトすることで、追加で公開鍵が書き込めます。

### 公開鍵認証によるリモートログインの確認
再度Linuxにリモートログインして、公開鍵認証が行われることを確認します。

```
>ssh linuc@192.168.56.101
```

パスフレーズを入力してリモートログインできたら、公開鍵認証の設定は完了です。

![公開鍵認証でLinuxにリモートログイン](image/Ch01/publickey.png){width=75%}


## パスワード認証の禁止と管理者ユーザーrootのログインの禁止
公開鍵認証による接続ができるようになったら、SSHサーバーの設定を変更してパスワード認証による接続を禁止しておきます。

SSHサーバーの設定ファイル/etc/ssh/sshd_configを以下のように設定変更します。

```
$ sudo vi /etc/ssh/sshd_config
```

```
#PasswordAuthentication yes
PasswordAuthentication no ※noに設定
```

また、管理者ユーザーrootの外部からの直接ログインを禁止することもできます。rootユーザーの直接ログインを許すかどうかは後述します。rootユーザーのSSHログインを禁止するには、以下のように変更します。

```
#PermitRootLogin prohibit-password
PermitRootLogin no ※noに設定
```

設定を保存したら、systemctlコマンドでsshdを再起動します。

```
$ sudo systemctl restart sshd
```

これで、外部からのパスワード認証を使ったログインが禁止され、かつrootユーザーでのリモートログインが禁止されました。

## root権限の管理
管理者ユーザーであるrootは最も高い権限を持っているアカウントとなるため、管理方法には注意が必要です。
root権限を取得するには、以下の3つの方法があります。

* rootで直接ログインする
* 一般ユーザーでログインした後、suコマンドを実行して管理者ユーザーrootに切り替える
* 一般ユーザーでログインした後、sudoコマンドを使ってroot権限でコマンドを実行する

どの方法も一長一短がありますが、rootで直接ログインするのは許さず、一般ユーザーでログインした後にsuコマンドかsudoコマンドを使用させることが多いようです。

### suコマンドを実行できるユーザーを制限する
suコマンドはrootパスワードを知っているユーザーなら誰でもrootになれる事が問題になる場合があります。PAM（Pluggable Authentication Modules）の設定を変更して、suコマンドを実行できるユーザーを制限します。

wheelグループに所属しているユーザーのみsuコマンドを実行してrootに切り替えられるように設定します。

PAMの設定ファイル/etc/pam.d/suをviエディタで開いて、行頭のコメントアウトを2カ所外します。上の設定行は、wheelグループに所属しているユーザーはパスワード無しでsuコマンドを実行できる、という設定です。下の設定行は、wheelグループに所属しているユーザーのみsuコマンドを実行できる、という設定です。

```
$ sudo vi /etc/pam.d/su

#%PAM-1.0
auth            required        pam_env.so
auth            sufficient      pam_rootok.so
# Uncomment the following line to implicitly trust users in the "wheel" group.
auth           sufficient      pam_wheel.so trust use_uid ※行頭の#を削除
# Uncomment the following line to require a user to be in the "wheel" group.
auth           required        pam_wheel.so use_uid ※行頭の#を削除
（略）
```

設定変更は修正した設定ファイルを保存するとすぐに反映されるので、システムの再起動などは必要ありません。

確認のため、一般ユーザーlinucでsuコマンドを実行してみます。wheelグループに所属しているため、パスワード無しでrootユーザーに変更できます。

```
$ id
uid=1000(linuc) gid=1000(linuc) groups=1000(linuc),10(wheel) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
$ su -
# id
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

### sudoコマンドを実行できるユーザーを制限する
AlmaLinuxでは、デフォルトではwheelグループに所属しているユーザーのみsudoコマンドを実行でき、一般ユーザーはsudoコマンドを実行する権限が与えられていません。

sudoコマンドの設定は、/etc/sudoersに記述されていますが、パーミッションが440という書き込み権限の無い特殊な設定となっています。

```
$ ls -l /etc/sudoers
-r--r-----. 1 root root 4328  7月  1 07:46 /etc/sudoers
```

/etc/sudoersを編集するには、sudoコマンドを使ってvisudoコマンドを実行します。vimエディタで/etc/sudoersが編集可能な状態で開かれます。

```
$ sudo visudo
```

wheelグループに所属しているユーザーはsudoコマンドを実行できるように設定されている場所を確認します。下記の行がその設定です。

```
%wheel ALL=(ALL)       ALL
```

「%wheel」はwheelグループを指定し、「ALL=(ALL) ALL」ですべてのコマンドを実行可能としています。


visudoコマンドはviエディタを呼び出しただけですので、「:q」と入力して編集を終了します。

### sudoで実行できるコマンドの制限
sudoコマンドでは、ある特定のグループに対して、一部のコマンドのみ実行できるように制限できます。

たとえば、グループpowerに所属しているユーザーに対してシステムの再起動やシャットダウンができるような権限を付与します。

```
$ sudo visudo
```

実行可能なコマンドをカンマ区切りで記述していきます。追加する場所はどこでも構いませんが、ファイルの最後尾に追加しておくと後から追加したと分かってよいでしょう。NOPASSWDはパスワード無しで実行できる権限です。

```
%power       ALL=NOPASSWD:  /usr/sbin/reboot, /usr/sbin/poweroff
```

powerグループを作成し、suzukiユーザーのサブグループに追加します。

```
$ sudo groupadd power
$ sudo usermod -G power suzuki
```

su -コマンドで作成したユーザーsuzukiに切り替えます。

```
$ sudo su - suzuki
$ id
uid=1001(suzuki) gid=1001(suzuki) groups=1001(suzuki),5001(power) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

sudo コマンドを使ってシステムを再起動します。

```
[suzuki@vbox ~]$ sudo reboot
```

システムがシャットダウンされ、再起動するのを確認します。

\pagebreak


