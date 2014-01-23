from ubuntu:12.04
maintainer wookoouk "wookoouk@gmail.com"
run apt-get update
# run apt-get -q -y install git
run apt-get -q -y install curl postgresql
run \curl -L https://get.rvm.io | bash -s stable --rails --autolibs=enabled --ruby=1.9.3-p286
# run cd /opt && git clone https://github.com/wookoouk/gee_fu.git

# TEST - bypass interactice screen when going to folder with .rvmrc
# run rvm 1.9.3 --rvmrc
run rvm_trust_rvmrcs_flag=1
run rvm ruby-1.9.3-p286@gee_fu --create

# need to pass a .env file to the app.
add . /opt/geefu

# init db for postgres
run mkdir /opt/pg_data
run chown postgres /opt/pg_data
run su postgres && initdb --pgdata=/opt/pg_data -E 'UTF-8' --lc-collate='en_US.UTF-8' --lc-ctype='en_US.UTF-8'


# start services
run /etc/init.d/postgresql start
run /etc/init.d/redis start

run cd /opt/geefu && rake db:setup

# start geefu
run start geefu