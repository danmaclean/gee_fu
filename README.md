## What is Gee Fu?
Gee Fu is an application that holds Gene Feature data. It has been designed with the needs of researchers wanting to keep, share and annotate sequence and feature data.
Gee Fu is a Ruby on Rails based RESTful web-service application that stores and serves sequence assembly and genome feature data on request. 


GeeFu can be used as a base that can be easily extended into fuller customised web-applications using the powerful Rails framework.

Gee Fu is ideally suited to serving large amounts of data such as those from high-throughput sequencing experiments via bio-samtools and BAM files. 

Gee Fu is capable of receiving and handling requests from AnnoJ , a web service based viewing engine for genomic data. It can return JSON data which AnnoJ is able to render. We anticipate being able to serve up data in formats suitable for different applications as development progresses and we become aware of other rendering engines and web services that request data. 


## Guick Install

## Setting up Gee Fu

* Install [rvm](https://rvm.io/) using:
  `\curl -L https://get.rvm.io | bash -s stable --rails --autolibs=enabled --ruby=1.9.3-p286`
* Install redis
* Install git
  `brew install git`
* Install postgres
* Clone the GeeFU repo
  `git clone git://github.com/danmaclean/gee_fu.git geefu`
* `cd gee_fu`
* Accept the .rvmrc as trusted
* Install bundler
  `gem install bundler`
* Setup the repo
  `bundle install`


* Signup for a [Mandrill](http://mandrill.com/) account and grab an API key
* Create a .env file in the root folder with:

```
EMAIL_SENDER=My Name <me@example.com>
MANDRILL_USERNAME=me@example.com
MANDRILL_APIKEY=[insert API key]
```

* Update 'config.action_mailer.default_url_options' inside 'config/environments/development.rb' to reflect your sites base URL.
* Create a Postgres user called gee_fu with no password
* Change the attributes of Postgres user gee_fu to allow database creation `ALTER USER gee_fu CREATEDB;`
* Run `rake db:setup`
* Follow the instructions at README_FOR_DATA.mdown
* Start the gee-fu server with `foreman start`
* Visit http://localhost:5000
* Once you've signed up as the first user use `rake admin:set email=me@example.com` to set your account as an admin to add Organisms

## Running as a service (linux)

* 'sudo foreman export --app geefu --user UserToRunAs upstart /etc/init'
* You may then start/stop via 'start geefu' / 'stop geefu'
* Logs will be available via /var/log/geefu/

## Development log

The development log (log/development.log) spits out almost everything that happens in geefu. It is reccomended to add it to log rotation

## Schema
The schema is very straightforward and easily extended. It consists of a central Features table and a many to many join table Parents that indicates which features are parents (according to their gff records) of which other features.

## Extending the database and creating new functionality
You can extend the database exactly as if it were any other Rails application. See the Rails documentation for conventions for creating and naming new tables, Rails prefers convention over configuration so you should pay attention to these. Adding new functionality to the web app is covered by the same documentation. 

## Where to find more info
If you get really frustrated with the software, feel free to complain to me `dan.maclean@tsl.ac.uk`. A lot of your initial problems will be answered in the Rails community pages, please look there if your problem looks like it might be related to Rails more directly than this particular instance of a Rails app.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/wookoouk/gee_fu/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
