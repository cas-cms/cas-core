# Cas

For branches for specific versions: [rails-5](https://github.com/cas-cms/cas-core/tree/rails-5)

## Usage

Add this line to your application's Gemfile:

```ruby
gem 'cas'
```

### Installation

```
bin/rails generate cas:install
```

This adds an `/admin` entry to `config/routes.rb` and generates a new file,
`config/cas.config.yml` which contains all sections your site is supposed to
have. [See the documentation for the config file](docs/config.md).

Once the file is edited, run

```
bin/rails cas:apply_config
```

### File Uploads

You need S3 credentials to use Cas (for file uploads). Set the
following ENV vars (e.g paste in your `~/.bash_profile` or use the `dotenv`
gem in your main Rails application):

    export S3_ACCESS_KEY_ID="value"
    export S3_SECRET_ACCESS_KEY="value"
    export S3_REGION="value"
    export S3_BUCKET="value"

## Development

Quick start:

```
bundle install
bundle exec rake db:create db:migrate db:test:prepare
cd spec/test_app/ && bin/rails server
```

### The Longer Version



## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
