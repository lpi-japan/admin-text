# 『Linuxシステム管理標準教科書』改訂プロジェクト
LPI-Japanは、Linux/OSS技術者教育に利用していただくことを目的とした教材「Linuxシステム管理標準教科書」を開発し、無償にて公開しています。

このリポジトリでは、2015年にリリースされたVer.1を改訂し、Ver.2にする作業を行っています。

## 現在の公開ページ
簡単な登録でPDF版がダウンロードできます。

https://linuc.org/textbooks/admin/

## ローカルビルド

原稿とメタデータ（`config-*.yaml`）はリポジトリ直下。Docker / pandoc スクリプトは `build/`。

```bash
docker build -t ghcr.io/lpi-japan/admin-text:local build
./build/build-pdf.sh
./build/build-epub.sh
```