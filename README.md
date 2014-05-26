Grants
======

The rails app responsible for the AFDC Grants site

###Installation

This installation has several dependencies:

 - Ruby 2.1.1 [via RVM](http://rvm.io/rvm/install)
 - Rails 4.1.1
 - Memcache
 - [Postgres 9.3](http://askubuntu.com/questions/186610/how-do-i-upgrade-to-postgres-9-2) (with the hstore extension)
    - Once the database is installed, you'll need to create a role for this app.
      - sudo apt-get install postgresql-contrib
      - sudo su - postgres
      - psql
      - CREATE ROLE rails_grants WITH LOGIN CREATEDB PASSWORD 'TYPE_YOUR_PASSWORD_HERE';
      - \q
    - After you run `rake db:create` but before you run `rake db:migrate`, you'll need to add the hstore extension:
      - sudo su - postgres
      - psql -d afdc_grants
      - CREATE EXTENSION hstore;
      - \connect afdc_grants_test;
      - CREATE EXTENSION hstore;
      - \q
