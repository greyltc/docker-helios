#!/usr/bin/env bash

pacman -S --needed --noconfirm --noprogressbar git base-devel

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

./reset.sh


