# Cas
Short description and motivation.

## Usage

How to use my plugin.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cas'
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

## Tests

```bash
bundle exec rspec   # Ruby specs
npm install         # once
npm test            # JavaScript specs (or: rake js)
```

The JavaScript specs live in `spec/javascripts` and run on vitest. They are a
separate, manual step: `rake` does not run them. They boot real jQuery and the
real vendored jQuery-File-Upload stack inside JSDOM and drive the actual widget,
rather than standing in for it with mocks. The one substitution is the jQuery UI
widget factory, which production takes from the jquery-ui-rails gem.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
