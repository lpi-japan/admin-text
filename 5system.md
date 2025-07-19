# システムのメンテナンス

## パッケージ管理
Linuxの各ディストリビューションでは、Linuxカーネルやアプリケーションなどシステムに必要なソフトウェアをパッケージ形式でインストール、管理する仕組みを持っています。
パッケージは、たとえばLinuxカーネルであればカーネル本体およびカーネルモジュールを1つのパッケージファイルにまとめたものです。

Red Hat Enterprise LinuxやAlmaLinux、Rocky Linux、SUSE Linuxなどでは、パッケージ管理にRPM(Red Hat Package Manager)が採用されています。また、アップデート時のバージョン管理等を行う為に開発されたYum（Yellowdog Updater Modified）が、システムの更新等で広く使われるようになり、現在ではYumの後継であるDNF（Dandified Yum）が使われるようになっています。

Debian GNU/LinuxやUbuntuなどのディストリビューションでは、パッケージ管理にDebianパッケージ（deb形式）が採用されています。パッケージ管理ツールとしてAPT（Advanced Package Tool）が使われています。 

本教科書では、AlmaLinuxのパッケージ管理ツールであるDNFの使用方法について解説します。

### DNFとは
以前はRPMパッケージの管理にはrpmコマンドが使用されていましたが、パッケージ間の依存関係を自動的に解決できなかったため、パッケージのインストールを行う際に管理者が自分で依存関係を確認しながら、手動で必要なパッケージを指定する必要がありました。そのため、依存関係で必要となるパッケージが多数あった場合、インストール作業が大変でした。

DNFでは、dnfコマンドを使ったパッケージのインストール時に依存関係の解決を自動的に行い、必要となるパッケージも同時にインストールするため、パッケージ管理が簡単になっています。

DNFやその前に使われていたYumの後継のため、現在でも設定ファイルなどはYumの頃と同じものが使われています。また、dnfコマンドとyumコマンドの間で基本的なサブコマンドには互換性があります。

### DNFの設定
DNFでは、RPMパッケージをまとめて置いておく場所を「リポジトリ」と呼びます。パッケージのインストールの際には、リポジトリから必要なRPMパッケージを取得します。

リポジトリの設定ファイルは/etc/yum.repos.dディレクトリにあります。

```
# ls /etc/yum.repos.d
almalinux-appstream.repo  almalinux-extras.repo            almalinux-plus.repo              almalinux-sap.repo
almalinux-baseos.repo     almalinux-highavailability.repo  almalinux-resilientstorage.repo  almalinux-saphana.repo
almalinux-crb.repo        almalinux-nfv.repo               almalinux-rt.repo
```

それぞれのリポジトリ設定ファイルに、リポジトリの参照先などが記述されています。

デフォルトで利用されるalmalinux-baseos.repoの中身は以下の通りです。

```
# cat /etc/yum.repos.d/CentOS-Base.repo 
[baseos]
name=AlmaLinux $releasever - BaseOS
mirrorlist=https://mirrors.almalinux.org/mirrorlist/$releasever/baseos
# baseurl=https://repo.almalinux.org/almalinux/$releasever/BaseOS/$basearch/os/
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-9
metadata_expire=86400
enabled_metadata=1
（略）
[baseos-source]
name=AlmaLinux $releasever - BaseOS - Source
mirrorlist=https://mirrors.almalinux.org/mirrorlist/$releasever/baseos-source
# baseurl=https://vault.almalinux.org/$releasever/BaseOS/Source/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-9
metadata_expire=86400
enabled_metadata=0
```

設定項目mirrorlistで指定したmirrors.almalinux.orgは、リポジトリのミラーリストから返される、ネットワークで接続しやすいリポジトリのアドレスに置き換えられます。

設定項目enabledの値が0に設定されていると、そのリポジトリはdnfコマンドの--enablerepoオプションで指定されなければ参照しません。

dnfコマンドは、インターネットに接続し、HTTPでインストールするパッケージをダウンロードすることができる必要があります。もし、PROXYサーバを経由する必要がある場合には、dnfコマンドの設定ファイル/etc/dnf/dnf.confにPROXYサーバに関する設定を記述する必要があります。設定項目は以下の通りです。

|項目|設定する値|
|-------|-------|
|proxy|PROXYサーバのURL|
|proxy_username|PROXYサーバの認証ユーザ名|
|proxy_password|PROXYサーバの認証パスワード|

また、インターネットに接続できない場合には、インストール用のDVDメディアをリポジトリとして参照する方法が利用できます。具体的な手順は後述します。

### dnfコマンドの基本的な使い方
dnfコマンドは、引数として様々なサブコマンドを指定して使用します。主なサブコマンドは以下の通りです。

#### パッケージのインストール
指定されたパッケージをインストールします。

```
dnf install パッケージ名
```

#### パッケージのアンインストール（削除）
指定されたパッケージをアンインストール（削除）します。

```
dnf remove パッケージ名
```

#### パッケージの更新の確認
インストールされているパッケージの更新があるかを確認します。

```
dnf check-update
```

#### パッケージの更新
インストールされているパッケージを更新します。パッケージ名を指定しなかった場合には、すべての更新可能なパッケージが対象となります。

```
dnf update [パッケージ名]
```

#### パッケージグループの一覧表示
利用可能なパッケージグループを表示します。

```
dnf grouplist
```

#### パッケージグループのインストール
指定されたパッケージグループに含まれるすべてのパッケージをまとめてインストールします。

```
dnf groupinstall パッケージグループ名
```

#### パッケージグループのアンインストール（削除）
指定されたパッケージグループに含まれるすべてのパッケージをまとめてアンインストール（削除）します。

```
dnf groupremove パッケージグループ名
```

### パッケージグループを指定したインストール
dnfコマンドを使ってパッケージグループを指定したインストールを行います。

以下の例では、コンパイラーなどが含まれている「開発ツール」パッケージグループをインストールします。

利用可能なパッケージグループを表示します。

```
# dnf grouplist
AlmaLinux 9 - AppStream                                                               7.1 MB/s |  14 MB     00:01
AlmaLinux 9 - BaseOS                                                                  7.0 MB/s |  14 MB     00:02
AlmaLinux 9 - Extras                                                                   28 kB/s |  20 kB     00:00
メタデータの期限切れの最終確認: 0:00:01 前の 2025年07月19日 16時36分27秒 に実施しました。
利用可能な環境グループ:
   サーバー
   最小限のインストール
（略）
利用可能なグループ:
   コンソールインターネットツール
   .NET Development
   RPM 開発ツール
   開発ツール
（略）
```

「開発ツール」パッケージグループをインストールします。

```
# dnf groupinstall "開発ツール"
メタデータの期限切れの最終確認: 1:12:32 前の 2025年07月19日 15時26分14秒 に実施しました。
依存関係が解決しました。
======================================================================================================================
 パッケージ                                アーキテクチャー バージョン                      リポジトリー        サイズ
======================================================================================================================
アップグレード:
 glibc                                     x86_64           2.34-168.el9_6.20               baseos              1.9 M
 glibc-all-langpacks                       x86_64           2.34-168.el9_6.20               baseos               18 M
 glibc-common                              x86_64           2.34-168.el9_6.20               baseos              295 k
 glibc-gconv-extra                         x86_64           2.34-168.el9_6.20               baseos              1.5 M
 glibc-langpack-ja                         x86_64           2.34-168.el9_6.20               baseos              328 k
group/moduleパッケージをインストール:
 asciidoc                                  noarch           9.1.0-3.el9                     appstream           237 k
 autoconf                                  noarch           2.69-39.el9                     appstream           665 k
 automake                                  noarch           1.16.2-8.el9                    appstream           662 k
 bison                                     x86_64           3.7.4-5.el9                     appstream           920 k
 byacc                                     x86_64           2.0.20210109-4.el9              appstream            88 k
 diffstat                                  x86_64           1.64-6.el9                      appstream            43 k
 flex                                      x86_64           2.6.4-9.el9                     appstream           307 k
 gcc                                       x86_64           11.5.0-5.el9_5.alma.1           appstream            32 M
 gcc-c++                                   x86_64           11.5.0-5.el9_5.alma.1           appstream            13 M
 gdb                                       x86_64           14.2-4.1.el9_6                  appstream           139 k
 git                                       x86_64           2.47.1-2.el9_6                  appstream            50 k
 glibc-devel                               x86_64           2.34-168.el9_6.20               appstream            32 k
 intltool                                  noarch           0.51.0-20.el9                   appstream            55 k
 jna                                       x86_64           5.6.0-8.el9                     appstream           268 k
 libtool                                   x86_64           2.4.6-46.el9                    appstream           577 k
 ltrace                                    x86_64           0.7.91-43.el9                   appstream           137 k
 make                                      x86_64           1:4.3-8.el9                     baseos              530 k
 patchutils                                x86_64           0.4.2-7.el9                     appstream            99 k
 perl-Fedora-VSP                           noarch           0.001-23.el9                    appstream            23 k
 perl-generators                           noarch           1.13-1.el9                      appstream            15 k
 pesign                                    x86_64           115-6.el9_1                     appstream           167 k
 redhat-rpm-config                         noarch           209-1.el9.alma.1                appstream            66 k
 rpm-build                                 x86_64           4.16.1.3-37.el9                 appstream            59 k
 rpm-sign                                  x86_64           4.16.1.3-37.el9                 baseos               17 k
 source-highlight                          x86_64           3.1.9-12.el9                    appstream           609 k
 systemtap                                 x86_64           5.2-2.el9                       appstream           8.4 k
 valgrind                                  x86_64           1:3.24.0-3.el9                  appstream           4.7 M
 valgrind-devel                            x86_64           1:3.24.0-3.el9                  appstream            47 k
依存関係のインストール:
 annobin                                   x86_64           12.92-1.el9                     appstream           1.1 M
 boost-filesystem                          x86_64           1.75.0-10.el9                   appstream            55 k
 boost-regex                               x86_64           1.75.0-10.el9                   appstream           275 k
 boost-system                              x86_64           1.75.0-10.el9                   appstream            11 k
 boost-thread                              x86_64           1.75.0-10.el9                   appstream            53 k
 copy-jdk-configs                          noarch           4.0-3.el9                       appstream            27 k
 debugedit                                 x86_64           5.0-5.el9                       appstream            75 k
 docbook-dtds                              noarch           1.0-79.el9                      appstream           280 k
 docbook-style-xsl                         noarch           1.79.2-16.el9                   appstream           1.2 M
 dwz                                       x86_64           0.14-3.el9                      appstream           127 k
 dyninst                                   x86_64           12.1.0-1.el9                    appstream           3.8 M
 efi-srpm-macros                           noarch           6-2.el9_0.0.1                   appstream            21 k
 elfutils                                  x86_64           0.192-5.el9                     baseos              563 k
 elfutils-devel                            x86_64           0.192-5.el9                     appstream            46 k
 elfutils-libelf-devel                     x86_64           0.192-5.el9                     appstream            37 k
 fonts-srpm-macros                         noarch           1:2.0.5-7.el9.1                 appstream            27 k
 gcc-plugin-annobin                        x86_64           11.5.0-5.el9_5.alma.1           appstream            39 k
 gdb-headless                              x86_64           14.2-4.1.el9_6                  appstream           4.8 M
 gettext-common-devel                      noarch           0.21-8.el9                      appstream           405 k
 gettext-devel                             x86_64           0.21-8.el9                      appstream           199 k
 ghc-srpm-macros                           noarch           1.5.0-6.el9                     appstream           7.8 k
 git-core                                  x86_64           2.47.1-2.el9_6                  appstream           4.7 M
 git-core-doc                              noarch           2.47.1-2.el9_6                  appstream           2.8 M
 glibc-headers                             x86_64           2.34-168.el9_6.20               appstream           437 k
 go-srpm-macros                            noarch           3.6.0-10.el9_6                  appstream            26 k
 graphviz                                  x86_64           2.44.0-26.el9                   appstream           3.3 M
 gtk2                                      x86_64           2.24.33-8.el9                   appstream           3.5 M
 ibus-gtk2                                 x86_64           1.5.25-6.el9                    appstream            23 k
 java-1.8.0-openjdk-headless               x86_64           1:1.8.0.452.b09-3.el9           appstream            33 M
 javapackages-filesystem                   noarch           6.4.0-1.el9                     appstream            10 k
 kernel-headers                            x86_64           5.14.0-570.26.1.el9_6           appstream           3.3 M
 kernel-srpm-macros                        noarch           1.0-13.el9                      appstream            15 k
 libXaw                                    x86_64           1.0.13-19.el9                   appstream           197 k
 libipt                                    x86_64           2.0.4-5.el9                     appstream            55 k
 libstdc++-devel                           x86_64           11.5.0-5.el9_5.alma.1           appstream           2.2 M
 libxcrypt-devel                           x86_64           4.4.18-3.el9                    appstream            28 k
 libzstd-devel                             x86_64           1.5.5-1.el9                     appstream            50 k
 lksctp-tools                              x86_64           1.0.19-3.el9_4                  baseos               96 k
 lua                                       x86_64           5.4.4-4.el9                     appstream           187 k
 lua-posix                                 x86_64           35.0-8.el9                      appstream           131 k
 lua-srpm-macros                           noarch           1-6.el9                         appstream           8.4 k
 m4                                        x86_64           1.4.19-1.el9                    appstream           294 k
 mkfontscale                               x86_64           1.2.1-3.el9                     appstream            31 k
 nss-tools                                 x86_64           3.101.0-10.el9_2                appstream           435 k
 ocaml-srpm-macros                         noarch           6-6.el9                         appstream           7.7 k
 openblas-srpm-macros                      noarch           2-11.el9                        appstream           7.3 k
 openssl-devel                             x86_64           1:3.2.2-6.el9_5.1               appstream           3.2 M
 patch                                     x86_64           2.7.6-16.el9                    appstream           127 k
 perl-Error                                noarch           1:0.17029-7.el9                 appstream            41 k
 perl-File-Compare                         noarch           1.100.600-481.el9               appstream            12 k
 perl-File-Copy                            noarch           2.34-481.el9                    appstream            19 k
 perl-Git                                  noarch           2.47.1-2.el9_6                  appstream            37 k
 perl-TermReadKey                          x86_64           2.38-11.el9                     appstream            36 k
 perl-Thread-Queue                         noarch           3.14-460.el9                    appstream            21 k
 perl-XML-Parser                           x86_64           2.46-9.el9                      appstream           229 k
 perl-lib                                  x86_64           0.65-481.el9                    appstream            13 k
 perl-macros                               noarch           4:5.32.1-481.el9                appstream           9.2 k
 perl-srpm-macros                          noarch           1-41.el9                        appstream           8.1 k
 perl-threads                              x86_64           1:2.25-460.el9                  appstream            57 k
 perl-threads-shared                       x86_64           1.61-460.el9                    appstream            44 k
 pyproject-srpm-macros                     noarch           1.16.2-1.el9                    appstream            13 k
 python-srpm-macros                        noarch           3.9-54.el9                      appstream            16 k
 qt5-srpm-macros                           noarch           5.15.9-1.el9                    appstream           7.8 k
 rust-srpm-macros                          noarch           17-4.el9                        appstream           9.2 k
 sgml-common                               noarch           0.6.3-58.el9                    appstream            54 k
 systemtap-client                          x86_64           5.2-2.el9                       appstream           3.7 M
 systemtap-devel                           x86_64           5.2-2.el9                       appstream           2.2 M
 systemtap-runtime                         x86_64           5.2-2.el9                       appstream           440 k
 tbb                                       x86_64           2020.3-9.el9                    appstream           168 k
 tzdata-java                               noarch           2025b-1.el9                     appstream           145 k
 xorg-x11-fonts-ISO8859-1-100dpi           noarch           7.5-33.el9                      appstream           1.0 M
 xz-devel                                  x86_64           5.2.5-8.el9_0                   appstream            52 k
 zlib-devel                                x86_64           1.2.11-40.el9                   appstream            44 k
 zstd                                      x86_64           1.5.5-1.el9                     baseos              462 k
弱い依存関係のインストール:
 adwaita-gtk2-theme                        x86_64           3.28-14.el9                     appstream           136 k
 kernel-devel                              x86_64           5.14.0-570.26.1.el9_6           appstream            18 M
 libcanberra-gtk2                          x86_64           0.30-27.el9                     appstream            25 k
 perl-version                              x86_64           7:0.99.28-4.el9                 appstream            62 k
グループのインストール中:
 Development Tools

トランザクションの概要
======================================================================================================================
インストール    106 パッケージ
アップグレード    5 パッケージ

ダウンロードサイズの合計: 176 M
これでよろしいですか? [y/N]: y
パッケージのダウンロード:
(1/111): asciidoc-9.1.0-3.el9.noarch.rpm                                              1.9 MB/s | 237 kB     00:00
(2/111): adwaita-gtk2-theme-3.28-14.el9.x86_64.rpm                                    992 kB/s | 136 kB     00:00
(3/111): annobin-12.92-1.el9.x86_64.rpm                                               4.8 MB/s | 1.1 MB     00:00
(4/111): autoconf-2.69-39.el9.noarch.rpm                                              3.5 MB/s | 665 kB     00:00
(5/111): automake-1.16.2-8.el9.noarch.rpm                                             3.6 MB/s | 662 kB     00:00
(6/111): boost-filesystem-1.75.0-10.el9.x86_64.rpm                                    1.1 MB/s |  55 kB     00:00
(7/111): boost-system-1.75.0-10.el9.x86_64.rpm                                        202 kB/s |  11 kB     00:00
(8/111): boost-regex-1.75.0-10.el9.x86_64.rpm                                         1.9 MB/s | 275 kB     00:00
(9/111): boost-thread-1.75.0-10.el9.x86_64.rpm                                        1.1 MB/s |  53 kB     00:00
(10/111): byacc-2.0.20210109-4.el9.x86_64.rpm                                         1.9 MB/s |  88 kB     00:00
（略）
```

### パッケージグループ名を英語表記で表示する
yumコマンドはロケール（Locale）に対応しているため、環境変数LANGの値が日本語に設定されているとパッケージグループ名が日本語で表示されます。このため、yum groupinstallコマンドを実行する際に日本語でパッケージグループ名を指定しなければなりません。

日本語がうまく表示できない、あるいは日本語が入力できない環境の場合、yumコマンドの前に「LANG=C」と入力することでパッケージグループ名を英語表記で表示できます。この方法は環境変数LANGの値を一時的に変更した状態で、yumコマンドを実行したことになります。

```
# LANG=C dnf grouplist
Last metadata expiration check: 1:10:25 ago on Sat Jul 19 16:36:27 2025.
Available Environment Groups:
   Server
   Minimal Install
   Workstation
   Virtualization Host
   Custom Operating System
Installed Environment Groups:
   Server with GUI
Installed Groups:
   Container Management
   Development Tools
   Headless Management
Available Groups:
   Console Internet Tools
   .NET Development
   RPM Development Tools
   Graphical Administration Tools
   Legacy UNIX Compatibility
   Network Servers
   Scientific Support
   Security Tools
   Smart Card Support
   System Tools
```

インストール時には、ローケルを指定しないでも英語表記のままパッケージグループ名を指定できます。パッケージグループ名に空白が含まれている場合には「"」（ダブルクォート）でパッケージグループ名を括って下さい。

以下の例では、開発ツール（Development tools）パッケージグループを指定して、コンパイラなどをインストールしています。

```
# yum groupinstall "Development tools"
```

### インストールDVDメディアをリポジトリにする方法
インターネットに接続できない環境でdnfコマンドを利用する方法として、ISOイメージやDVDなどのインストールメディアをリポジトリとして参照させる方法があります。

インストールメディアをマウントした後、リポジトリの設定ファイル/etc/yum.repos.d/almalinux-media.repoを作成します。内容は以下の通りです。


```
#[media_BaseOS]
name=AlmaLinux 9 Media - BaseOS
baseurl=file:///run/media/linuc/AlmaLinux-9-6-aarch64-dvd/BaseOS/
enabled=0
gpgcheck=0
gpgkey=file:///run/media/linuc/AlmaLinux-9-6-aarch64-dvd/RPM-GPG-KEY-AlmaLinux-9

[media_AppStream]
name=AlmaLinux 9 Media - AppStream
baseurl=file:///run/media/linuc/AlmaLinux-9-6-aarch64-dvd/AppStream/
enabled=0
gpgcheck=0
gpgkey=file:///run/media/linuc/AlmaLinux-9-6-aarch64-dvd/RPM-GPG-KEY-AlmaLinux-9
```

この設定を利用するには、インストールメディアを/run/media/linucディレクトリにマウントし、dnfコマンドにリポジトリ指定のオプションをつけて実行する必要があります。

以下の手順で、インストールDVDメディアをリポジトリとして参照できるようにします。

1. AlmaLinuxにlinucユーザーとしてグラフィカルログインします。
1. インストールメディアをDVDドライブに挿入します。仮想マシンの場合には、ISOイメージファイルを仮想DVDドライブで参照します。
1. 自動マウントされることを確認します。
1. mountコマンドで確認します。インストールメディアは/run/media/linucディレクトリ内にマウントされています。

```
# mount
（略）
/dev/sr0 on /media/CentOS_6.6_Final type iso9660 (ro,nosuid,nodev,uhelper=udisks,uid=0,gid=0,iocharset=utf8,mode=0400,dmode=0500)
```


dnfコマンドを実行します。--disablerepoオプションですべてのリポジトリを参照不要とし、--enablerepoオプションでc6-mediaリポジトリのみ参照するように指定します。以下の例では、グループリストを取得しています。

```
# dnf --disablerepo=\* --enablerepo=media* grouplist
```

## システム監視
システムを適切に運用していく上で、システム上のリソースが常に有効に使われているか、極端にリソースを占有しているプロセスは無いかを監視することは重要な事です。

システム上のリソースを様々な角度で監視する方法を解説します。

### topコマンドによるシステムリソース監視
topコマンドは、システムのどのプロセスがどの程度のCPUやメモリなどのリソースを消費しているかを簡単に示してくれる対話型のコマンドです。

topコマンドを実行すると、デフォルトでは先頭五行（サマリーエリア）にシステム全体の情報が表示されます。次の行が対話的にコマンドを入力するエリアです。その次の行から、プロセス毎の情報が表示されます。

```
top - 03:11:49 up 16:28,  4 users,  load average: 0.08, 0.03, 0.01
Tasks: 188 total,   1 running, 187 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.0%us,  0.0%sy,  0.0%ni, 99.8%id,  0.2%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   1016372k total,   811796k used,   204576k free,    24736k buffers
Swap:  2064380k total,    41640k used,  2022740k free,   295652k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND           
    1 root      20   0 19364 1304 1036 S  0.0  0.1   0:01.24 init               
    2 root      20   0     0    0    0 S  0.0  0.0   0:00.03 kthreadd           
    3 root      RT   0     0    0    0 S  0.0  0.0   0:00.03 migration/0        
    4 root      20   0     0    0    0 S  0.0  0.0   0:00.09 ksoftirqd/0        
    5 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 stopper/0          
    6 root      RT   0     0    0    0 S  0.0  0.0   0:00.08 watchdog/0         
    7 root      RT   0     0    0    0 S  0.0  0.0   0:00.04 migration/1        
    8 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 stopper/1          
    9 root      20   0     0    0    0 S  0.0  0.0   0:00.07 ksoftirqd/1        
   10 root      RT   0     0    0    0 S  0.0  0.0   0:00.06 watchdog/1         
   11 root      20   0     0    0    0 S  0.0  0.0   0:03.16 events/0           
   12 root      20   0     0    0    0 S  0.0  0.0   0:02.79 events/1           
   13 root      20   0     0    0    0 S  0.0  0.0   0:00.00 cgroup             
   14 root      20   0     0    0    0 S  0.0  0.0   0:00.01 khelper            
   15 root      20   0     0    0    0 S  0.0  0.0   0:00.00 netns              
   16 root      20   0     0    0    0 S  0.0  0.0   0:00.00 async/mgr          
   17 root      20   0     0    0    0 S  0.0  0.0   0:00.00 pm                 
```

先頭の5行には、以下の情報が表示されています。

|行数|意味|
|-------|-------|
|1行目|起動時間、ログインユーザ数、ロードアベレージ|
|2行目|各状態のタスク数|
|3行目|CPUの使用状況|
|4行目|物理メモリの使用状況|
|5行目|スワップ領域の使用状況|

### vmstatコマンドによるシステムリソース監視
vmstatコマンドは、メモリの使用状況やCPUの負荷などを表示するコマンドです。

vmstatコマンドを引数無しで実行すると、コマンドを実行した時点のメモリやCPU、ディスクの使用状況が表示されます。

```
# vmstat
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 8  0 116104 408536  58692  71292    0    1    10    11  251   66  2  2 97  0  0
```

表示される内容は以下の表のとおりです。

|項目|意味|
|-------|-------|
|r|実行待ちプロセス数|
|b|割り込み不可のスリープ状態にあるプロセス数|
|swpd|スワップアウトされたメモリ量|
|free|空きメモリの容量|
|buff|バッファに使用されているメモリの容量|
|cache|キャッシュに使用されているメモリの容量|
|si|1秒あたりのディスクからスワップインされているメモリの容量|
|so|1秒あたりのディスクにスワップアウトされているメモリの容量|
|bi|1秒あたりのブロックデバイスに送られたブロック|
|bo|1秒あたりのブロックデバイスから受け取ったブロック|
|in|1秒あたりの割り込みの回数|
|cs|1秒あたりのコンテキストスイッチの回数|
|us|CPU総時間当たりのユーザー時間の割合|
|sy|CPU総時間当たりのシステム時間の割合|
|id|CPU総時間当たりのアイドル時間の割合|

vmstatコマンドに引数として数値を与えると、秒間隔でシステムのリソース情報を出力し続けます。終了するにはCtrl+Cキーを入力します。

```
# vmstat 5
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
10  0 116104 261708  65040  79460    0    1    11    11  253   70  2  2 97  0  0
 9  0 116104 358068  65712  80356    0    0   189   242 5411 8564 42 58  0  0  0
 7  0 116104 301924  66184  81372    0    0   202   308 4610 7441 41 59  0  0  0
※^C Ctrl+Cキーを入力する
```

### sysstatによるシステムリソース監視
稼働中のLinuxのシステム情報を継続して集めるには、sysstatパッケージに含まれているiostatコマンドやsarコマンドなどを使うと便利です。

sysstatパッケージをインストールします。

```
# yum install sysstat
```

sysstatパッケージをインストールすると、デフォルトで10分間隔でシステムのリソース情報が取得されるようにcronが設定されます。

```
# cat /etc/cron.d/sysstat 
# Run system activity accounting tool every 10 minutes
*/10 * * * * root /usr/lib64/sa/sa1 1 1
# 0 * * * * root /usr/lib64/sa/sa1 600 6 &
# Generate a daily summary of process accounting at 23:53
53 23 * * * root /usr/lib64/sa/sa2 -A
```

10分間隔で起動される/usr/lib64/sa/sa1スクリプトは、内部で/usr/lib64/sa/sadcを実行し、システムのリソース情報を取得して/var/log/sa/saDDファイル（DDは2桁の日付）に保存しています。
23:53に実行される/usr/lib64/sa/sa2スクリプトは、sa1スクリプトで取得した情報をまとめて/var/log/sa/sarDD（DDは2桁の日付）というファイルを生成し、古くなった情報を削除します。デフォルトでは28日分を保存しておきます。期間を変更したい場合には設定ファイル/etc/sysconfig/sysstatファイル内のHISTORY変数を変更します。

まとめられた情報は、後述するsarコマンドで参照できます。

### iostatコマンドによるシステムリソース監視
sysstatパッケージに含まれるiostatコマンドは、CPUの使用率や各種I/Oの利用状況を確認するためのコマンドです。I/Oは、ハードディスクやテープドライブ、ネットワークマウントしたファイルシステム、端末入出力等の入出力性能を監視できます。

iostatコマンドを実行すると、システムが起動してからiostatコマンドを実行した時点までの間のCPUおよびI/Oの状況が表示されます。

```
# iostat
Linux 2.6.32-504.el6.x86_64 (server.example.com) 	2015年01月15日 	_x86_64(2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.72    0.00    1.95    0.03    0.00   96.30

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
sda               1.89        44.06       117.04    2720068    7224884
scd0              0.01         0.18         0.00      11204          0
dm-0              6.51        41.98        42.57    2591466    2627904
dm-1              0.49         0.17        74.44      10552    4595040
dm-2              0.01         0.06         0.03       3522       1856
```

表示される内容は以下の表のとおりです。

|項目|意味|
|-------|-------|
|%user|ユーザプロセスによるCPUの使用率|
|%nice|実行優先度（nice値）を変更したユーザプロセスによるCPUの使用率|
|%system|システムプロセスによるCPUの使用率|
|%iowait|I/O終了待ちとなったCPUの使用率|
|%steal|ハイパーバイザーによる他の仮想CPUの実行待ちとなったCPUの使用率|
|%idle|CPUが何も処理をせずに待機していた時間の割合(ディスクI/O以外）|
|tps|1秒間のI/O転送回数|
|Blk_read/s|1秒間のディスクの読み込み量(ブロック数)|
|Blk_wrtn/s|1秒間のディスクの書き込み量(ブロック数)|
|Blk_read|ディスクの読み込み量(ブロック数)|
|Blk_wrtn|ディスクの書き込み量(ブロック数)|

iostatコマンドに-xオプションを付与して実行すると、表示がKB単位に変わります。

|項目|意味|
|-------|-------|
|kB_read/s|1秒間のディスクの読み込み量(KB単位)|
|kB_wrtn/s|1秒間のディスクの書き込み量(KB単位)|
|kB_read|ディスクの読み込み量(KB単位)|
|kB_wrtn|ディスクの書き込み量(KB単位)|

iostatコマンドに引数として数値を与えて実行すると、1回目の表示はシステム起動からiostatコマンド実行時までの間の情報ですが、その後指定された秒間隔で全てのデバイスのI/Oの利用状況が出力されます。終了するにはCtrl+Cを入力します。。

```
# iostat 5
Linux 2.6.32-504.el6.x86_64 (server.example.com) 	2015年01月15日 	_x86_64(2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.76    0.00    2.01    0.03    0.00   96.20

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
sda               1.89        44.02       116.93    2720092    7225892
scd0              0.01         0.18         0.00      11204          0
dm-0              6.51        41.94        42.54    2591474    2628888
dm-1              0.49         0.17        74.36      10552    4595040
dm-2              0.01         0.06         0.03       3522       1856

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          44.30    0.00   55.70    0.00    0.00    0.00

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
sda               0.00         0.00         0.00          0          0
scd0              0.00         0.00         0.00          0          0
dm-0              0.00         0.00         0.00          0          0
dm-1              0.00         0.00         0.00          0          0
dm-2              0.00         0.00         0.00          0          0

※^C ←Ctrl+Cキーを入力する
```

iostatコマンドに-xオプションを付与して実行します。結果が拡張フォーマットで表示されます。

```
# iostat -x
Linux 2.6.32-504.el6.x86_64 (server.example.com) 	2015年01月15日 	_x86_64(2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.78    0.00    2.04    0.03    0.00   96.16

Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.83     4.90    0.83    1.06    44.00   116.88    85.16     0.00    0.57   0.30   0.06
scd0              0.04     0.00    0.01    0.00     0.18     0.00    27.00     0.00   14.24   9.61   0.01
dm-0              0.00     0.00    1.17    5.33    41.92    42.52    12.98     0.02    3.17   0.10   0.06
dm-1              0.00     0.00    0.02    0.47     0.17    74.33   150.83     0.00    1.80   0.03   0.00
dm-2              0.00     0.00    0.01    0.00     0.06     0.03     7.97     0.00    0.37   0.27   0.00
```

表示される内容は以下の表のとおりです。

|項目|意味|
|-------|-------|
|rrqm/s|1秒間デバイスへマージされた読み込みリクエスト数|
|wrqm/s|1秒間デバイスへマージされた書き込みリクエスト数|
|r/s|1秒間の読み込みリクエスト数|
|w/s|1秒間の書き込みリクエスト数|
|rsec/s|1秒間の読み込みセクタ数|
|wsec/s|1秒間の書き込みセクタ数|
|rkB/s|1秒間の読み込みキロバイト（KB）数|
|wkB/s|1秒間の読み込みキロバイト（KB）数|
|avgrq-sz|デバイスへのIOリクエストの平均サイズ|
|avgqu-sz|デバイスへのIOリクエストのキューの平均サイズ|
|await|デバイスへのIOリクエストの平均待ち時間|
|svctm|デバイスへのIOリクエストの平均処理時間|
|%util|デバイスへのIOリクエスト期間CPUの使用率|

