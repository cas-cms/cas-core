# Cas
Short description and motivation.

## Usage

How to use my plugin.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cas-cms'
```

### Setup

**Engine:** Cas is mounted in your main Rails application. Say your application
is called MyBlog, you make can make it accessible at `myblog.com/admin`
by setting the following in the `config/routes.rb` file in your main
application:

```ruby
Rails.application.routes.draw do
   mount Cas::Engine, at: "/admin"

   # ... other routes
end
```

**S3:** you need S3 credentials to use Cas (for file uploads). Set the
following ENV vars (e.g paste in your `~/.bash_profile` or use the `dotenv`
gem in your main Rails application):

    export S3_ACCESS_KEY_ID="value"
    export S3_SECRET_ACCESS_KEY="value"
    export S3_REGION="value"
    export S3_BUCKET="value"

## Developing Cas

### Running tests

**Ruby tests** can be run using `bundle exec rspec spec`.

**Javascript tests** have to be run from within `spec/test_app` until
[this PR](https://github.com/searls/jasmine-rails/pull/227) is merged.

Until then, run

```
cd spec/test_app
bundle exec rake spec:javascript
```

Javascript tests are written in `spec/javascripts`.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
