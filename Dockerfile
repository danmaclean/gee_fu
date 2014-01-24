# DOCKER-VERSION 0.3.4

from ubuntu:12.04

maintainer wookoouk "wookoouk@gmail.com"

# update / install deps
run apt-get update
run apt-get -q -y install curl git postgresql

# instal rvm + ruby version ruby=1.9.3 with patch 286
run \curl -L https://get.rvm.io | bash -s stable --rails --autolibs=enabled --ruby=1.9.3-p286

# source rvm
source /etc/profile.d/rvm.sh

# checkout gee_fu
un cd /opt && git clone https://github.com/wookoouk/gee_fu geefu

# bypass interactice screen when going to folder with .rvmrc
run rm /opt/geefu/.rvmrc
run rvm ruby-1.9.3-p286@gee_fu --create

# pass a customised .env file to the app.
add .env /opt/geefu

# init db for postgres
run mkdir /opt/pg_data
run chown postgres /opt/pg_data
run su postgres && initdb --pgdata=/opt/pg_data -E 'UTF-8' --lc-collate='en_US.UTF-8' --lc-ctype='en_US.UTF-8'

# start services
run /etc/init.d/postgresql start
run /etc/init.d/redis start

# generate schema in DB
run cd /opt/geefu && rake db:setup

# start geefu
run start geefu