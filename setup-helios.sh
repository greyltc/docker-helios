#!/usr/bin/env bash

pacman -S --needed --noconfirm --noprogressbar git base-devel python2 python2-pip postgresql

git clone https://github.com/benadida/helios-server.git
cd helios-server
sed -i 's,kombu==3.0.26,kombu==3.0.30,g' requirements.txt
pip2 install -r requirements.txt

cat <<EOF > reset.sh
#!/usr/bin/env bash
dropdb helios
createdb helios
python2 manage.py syncdb
python2 manage.py migrate
echo "from helios_auth.models import User; User.objects.create(user_type='google',user_id='grey@christoforo.net', info={'name':'Grey Christoforo'})" | python2 manage.py shell
EOF
chmod +x reset.sh

su postgres -c 'pg_ctl -s -D /var/lib/postgres/data start -w -t 120'
./reset.sh
su postgres -c '/usr/bin/pg_ctl -s -D /var/lib/postgres/data stop -m fast'

sed -i ',</VirtualHost>,d' /etc/httpd/conf/extra/httpd-ssl.conf
sed -i ',SSLProtocol All -SSLv2 -SSLv3,d' /etc/httpd/conf/extra/httpd-ssl.conf

cat <<EOF >> /etc/httpd/conf/extra/httpd-ssl.conf
<Proxy *>
  Order deny,allow
  Allow from all
</Proxy>
ProxyPass / http://localhost:8000/
ProxyPassReverse / http://localhost:8000/
<VirtualHost _default_:443>
SSLProtocol All -SSLv2 -SSLv3
EOF

# reduce docker layer size
cleanup-image
