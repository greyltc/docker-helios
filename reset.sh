#!/usr/bin/env bash
dropdb helios
createdb helios
python2 manage.py syncdb
python2 manage.py migrate
echo "from helios_auth.models import User; User.objects.create(user_type='google',user_id='grey@christoforo.net', info={'name':'Grey Christoforo'})" | python2 manage.py shell
