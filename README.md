# Cas

## Usage

Add this line to your application's Gemfile:

```ruby
gem 'cas'
```

### Engine

_Cas_ is mounted on your main Rails application. Say your application is called
MyBlog, you make can make it accessible at `myblog.com/admin` by setting the
following in the `config/routes.rb` file in your main application:

```ruby
Rails.application.routes.draw do
   mount Cas::Engine, at: "/admin"

   # ...
end
```

### Migrations

Generate 

### Configuration

```
bin/rails generate cas:install
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
