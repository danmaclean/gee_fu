# What is Gee Fu?
Gee Fu is an application that holds Gene Feature data. It has been designed with the needs of researchers wanting to keep, share and annotate sequence and feature data.
Gee Fu is a Ruby on Rails based RESTful web-service application that stores and serves sequence assembly and genome feature data on request. 


GeeFu can be used as a base that can be easily extended into fuller customised web-applications using the powerful Rails framework.

Gee Fu is ideally suited to serving large amounts of data such as those from high-throughput sequencing experiments via bio-samtools and BAM files. 

Gee Fu is capable of receiving and handling requests from AnnoJ , a web service based viewing engine for genomic data. It can return JSON data which AnnoJ is able to render. We anticipate being able to serve up data in formats suitable for different applications as development progresses and we become aware of other rendering engines and web services that request data. 


## Live Sites
[Open Ash Dieback](https://geefu.oadb.tsl.ac.uk)

YellowRust (Available Soon)

## Demo Install (not advised for production)
* Install [Docker](https://www.docker.io/gettingstarted/#h_installation)
* Get the Dockerfile TODO
* Run the image TODO

## Full Install

### Dependencies:

[Ubuntu/Debian](doc/ubuntu.md)

[OSX](doc/osx.md)

Windows (Coming Soon!)

### Get GeeFu:

* Clone the GeeFU repo: `git clone git://github.com/wookoouk/gee_fu.git geefu`
* Go into geefu folder: `cd geefu`
* Accept the .rvmrc as trusted

### Configure GeeFu:

* Install bundler
  `gem install bundler`
* Set up the repo
  `bundle install`
* Sign up for a [Mandrill](http://mandrill.com/) account and grab an API key
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
* Once you've signed up as the first user use `rake admin:set email=me@example.com` to set your account as an admin to be able add Organisms

### Start GeeFu

##### With Rake
`bundle exec rails server`

##### With Foreman
`foreman start`
##### With Passenger
[Install Passenger](http://www.modrails.com/documentation/Users%20guide%20Apache.html#installation)

[Link to Apache config]()


Ubuntu/Debian: `sudo /etc/init.d/httpd/restart`

Centos: `sudo /etc/init.d/apach2/restart`

OSX: `sudo /usr/sbin/apachectl restart`
