#!/usr/bin/env bash

pacman -S --needed --noconfirm --noprogressbar git base-devel python2 python2-pip postgresql opensmtpd

git clone https://github.com/benadida/helios-server.git
cd helios-server
sed -i 's,kombu==3.0.26,kombu==3.0.30,g' requirements.txt
pip2 install -r requirements.txt

cp /reset.sh reset.sh
chmod +x reset.sh

su postgres -c 'pg_ctl -s -D /var/lib/postgres/data start -w -t 120'
./reset.sh
su postgres -c '/usr/bin/pg_ctl -s -D /var/lib/postgres/data stop -m fast'

sed -i '/<\/VirtualHost>/d' /etc/httpd/conf/extra/httpd-ssl.conf
sed -i '/SSLProtocol All -SSLv2 -SSLv3/d' /etc/httpd/conf/extra/httpd-ssl.conf

cat <<EOF >> /etc/httpd/conf/extra/httpd-ssl.conf
<Proxy *>
  Order deny,allow
  Allow from all
</Proxy>
ProxyPass / http://localhost:8000/
ProxyPassReverse / http://localhost:8000/
</VirtualHost>
SSLProtocol All -SSLv2 -SSLv3
EOF

rm -rf /srv/http/info.php
echo "This site is https only." > /srv/http/index.html

# reduce docker layer size
cleanup-image
