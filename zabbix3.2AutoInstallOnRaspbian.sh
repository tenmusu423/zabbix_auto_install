#!/bin/sh

# 本スクリプトはroot権限で実行して下さい。
# Raspbian(Jessie)でZabbix3.2を自動でインストールします。
# 必要なパッケージ類等も全て自動でインストールします。
# DBにはMariaDB、Webにはnginx1.10.3、PHPは7.0を利用しています。
# パスワードはデフォルトになっている為、必要であれば適宜修正して下さい。
# php5等古いバージョンのものはアンインストールしますのでご注意ください。

# パッケージのアップデートとアップグレードを実施します。
apt-get update -y && apt-get upgrade -y

# 現在のカレントディレクトリを環境変数に格納します。
dir=$(pwd)

# nginx.serviceを/etc/init.d/配下に保存します。
mv nginx /etc/init.d/ && chmod +x /etc/init.d/nginx

# nginxのコンパイルに必要なパッケージをインストールする。
apt-get install -y gcc checkinstall libpcre3-dev zlib1g-dev libssl-dev geoip-bin libfontconfig1-dev libgd-dev libgeoip-dev libice-dev libjbig-dev libjpeg-dev libjpeg62-turbo-dev liblzma-dev libpthread-stubs0-dev libsm-dev libtiff5-dev libtiffxx5 libvpx-dev libx11-dev libx11-doc libxau-dev libxcb1-dev libxdmcp-dev libxpm-dev libxslt1-dev libxt-dev x11proto-core-dev x11proto-input-dev x11proto-kb-dev xorg-sgml-doctools xtrans-dev expect tcl-expect

# wgetでnginx1.10.3のソースを保存する。
wget https://nginx.org/download/nginx-1.10.3.tar.gz

# 展開しディレクトリ名を変更した後、取得したファイルを削除しnginxディレクトリへ移動します。
tar zxvf nginx-1.10.3.tar.gz && mv nginx-1.10.3 nginx && rm nginx-1.10.3.tar.gz && cd nginx

# コンパイルする。
./configure --group=nginx --user=nginx --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --pid-path=/var/run/nginx.pid
make && cd ../

mv nginx_comp.exp nginx/ && cd nginx

# dpkg作成する。手入力を省くためexpectでパッケージを作成する。
expect nginx_comp.exp

# dpkgで/etc/nginxにインストールし、立つ鳥跡を濁さずでゴミを削除する。
dpkg -i nginx_1.10.3-1_armhf.deb && rm -rf ${dir}/nginx

# log格納用のディレクトリを作成します。
mkdir /var/log/nginx

# サービスに登録し起動します。
systemctl enable nginx.service && systemctl start nginx.service

exit
