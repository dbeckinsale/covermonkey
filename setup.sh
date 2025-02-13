#!/usr/bin/env sh

TITLE='[CoverMonkey Setup]:'
PACKAGEMGR=apt

#if lsb_release -d
#then
#	PACKAGEMGR=apt
#else
#	PACKAGEMGR=yum
#fi

sudo $PACKAGEMGR update
sudo $PACKAGEMGR install python3 python3-venv
python3 -m pip install -U pip --user

if [ ! -d "venv" ]
then
	python3 -m venv venv
else
	echo 'venv already exists'
fi

#sudo $PACKAGEMGR install python python-pip
#python -m pip install -U pip --user
#python -m pip install supervisor --user

#mkdir -p supervisor/conf.d
#echo_supervisord_conf > supervisor/conf.d/covermonkey.conf
#echo -e "[program:covermonkey]\ncommand=$HOME/venv/bin/gunicorn -b localhost:8000 covermonkey:app\ndirectory=$HOME/covermonkey\nuser=$USER\nautostart=true\nautorestart=true\nstopasgroup=true\nkillasgroup=true" >> supervisor/conf.d/covermonkey.conf
#sudo mv supervisor /etc/
#supervisord -c /etc/supervisor/conf.d/covermonkey.conf

#sudo $PACKAGEMGR install nginx
#sudo rm /etc/nginx/sites-enabled/default
#sudo cp nginx.covermonkey /etc/nginx/sites-enabled/covermonkey

#mkdir covermonkey/certs
#openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -keyout covermonkey/certs/key.pem -out covermonkey/certs/certs.pem

source venv/bin/activate
cd covermonkey
pip3 install -r requirements.txt

export FLASK_APP='covermonkey.py'
echo "$TITLE set FLASK_APP=$FLASK_APP"

if [ ! -e "app.db" ] && [ ! -d "migrations" ]
then
	flask db init
	flask db migrate -m "initial"
	flask db upgrade
	python3 init_db.py
else
	echo "$TITLE db file and migrations directory already exist"
fi

#supervisorctl reload
#sudo service nginx reload
cd
gunicorn -b 0.0.0.0:8000 covermonkey:app
#echo 'Covermonkey listening on port 8000'
