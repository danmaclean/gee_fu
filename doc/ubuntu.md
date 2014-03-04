## Installing dependencies on Ubuntu/Debian

* Install [RVM](https://rvm.io/) using:
  `sudo \curl -L https://get.rvm.io | bash -s stable --rails --autolibs=enabled --ruby=1.9.3-p286`
* Install everything else using:
 `sudo apt-get install git redis postgresql `
* Start Postgres on boot:
 `sudo update-rc.d postgresql default`
* Start Redis on boot:
 `sudo update-rc.d redis-server`

## [Return to setup](/README.md#get-geefu)