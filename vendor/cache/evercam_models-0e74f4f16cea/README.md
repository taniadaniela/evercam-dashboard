# EvercamModels

This gem library encapsulates the functionality around active record (the design
pattern, not the library) models used within the Evercam API and systems.

## Installation

Add this line to your application's Gemfile:

    gem 'evercam_models', git: 'git@github.com:evercam/evercam_models.git'

And then execute:

    $ bundle

## Usage

Once the dependency has been established in the Gemfile you can incorporate
the model classes into your code using a line such as...

    require 'evercam_models'

Note that, as the library loads models classes which are linked to database
tables you must have established a database connection before requiring the
library in. So, more realistically, you would have to do something like the
following...

    connection = Sequel.connect("postgres://localhost/evercam_dev")
    require 'evercam_models'

Obviously it would be better if you could make the connection aspect more
configurable compared the example given here where the connection URL is hard
coded.

## Building The Gem

You can build a .gem file from this project by using the following command from
within the root directory of the repository...

    gem build evercam_models.gemspec

## Testing

You will to create a .env file in the root directory of the respository to run
the tests. Note that you should not check this file in as it will contain some
sensitive information. The contents of this file will look something like the
following...

    DATABASE_URL=postgres://localhost/evercam_dev
    INTERCOM_API_KEY=abcdefg1234567hijklmnopq890rstuvwxyz1234
    AWS_SECRET_KEY=AbcDefghiJk8LmnopqRStuvw+XyZ123456789/12
    THREESCALE_PROVIDER_KEY=a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6

Note all of the keys listed above are completely fictional, you will need to
obtain actual keys for your copy of the file. You run the tests by invoking the
following command from the root directory of the repository...

    $ rspec
