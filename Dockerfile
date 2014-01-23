from ubuntu:12.04
maintainer wookoouk "wookoouk@gmail.com"
run apt-get update
run apt-get -y install git curl
run \curl -L https://get.rvm.io | bash -s stable --rails --autolibs=enabled --ruby=1.9.3-p286
run cd /opt && git clone https://github.com/wookoouk/gee_fu.git
