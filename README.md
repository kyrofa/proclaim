# Proclaim

Most Rails blogging tools include everything you could ever want, including
things you don't. Proclaim tries to provide the simplest (yet beautiful)
implementation of a blog you could want-- posts, comments, and subscriptions.
It's not meant to *be* your entire website-- it's a mountable engine. Mount it
where you want it, configure it, and you have a blog. It otherwise stays out of
your way.

## Getting Started

### Get Proclaim

Proclaim 0.1 works with Rails 4.2 and on. Add it to your Gemfile with:

```ruby
gem 'proclaim', "~> 0.1.1"
```

Run `bundle install` to install it.


### Install Proclaim

After you've added Proclaim to your gemfile, you can install it with:

```ruby
rails generate proclaim:install
```

The generator will install an initializer which describes all of Proclaim's
configuration options. You should check those out, and change them if necessary.
It will also mount Proclaim in your `config/routes.rb` at the path `/blog`.

Now run `rake db:migrate`


### Setup Assets

Include Proclaim in Javascript manifest file:

```javascript
//= require proclaim
```

Include Proclaim in Stylesheet manifest file:

```scss
*= require proclaim
```


### Setup Mailer and Root Route

Proclaim sends emails when:

- A new subscription is added (A welcome email)
- A new comment is made on a post to which subscriptions exist
- A new post is made and subscriptions exist on the blog itself

Because of this, ensure that the mailer has default URL options in each
environment. Here is a possible configuration for
`config/environments/development.rb`:

```ruby
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

A default root path must also be defined in the application's routes:

```ruby
root to: "home#index"
```


### Engine Configuration Options

The Proclaim engine has a number of configurable parameters that mostly relate
to tying the engine in with the rest of the site. Proclaim tries to be as
unobtrusive as possible-- it doesn't provide users or authentication. It does,
however, require some concept of authors, expecting that they authenticate
somehow, and posts will belong to whichever author publishes them.

All configuration items (and their defaults) follow:

```ruby
Proclaim.author_class = "User"
Proclaim.author_name_method = :name
Proclaim.current_author_method = :current_user
Proclaim.authentication_method = :authenticate_user!
Proclaim.excerpt_length = 500
```

- **Proclaim.author_class**

  The class to which posts belong. Changing this also changes the default
  `Proclaim.current_author_method` and `Proclaim.authentication_method`. For
  example, setting `author_class = "Admin"` changes the default
  `current_author_method` to be `:current_admin`, etc.

- **Proclaim.author_name_method**

  Method to obtain the name of the author. This should be a method on the author
  class.

- **Proclaim.current_author_method**

  Method to obtain the currently-authenticated user. Should return nil if no
  user is currently authenticated.

- **Proclaim.authentication_method**

  Method to verify that a user is authenticated, and if not, will redirect to
  some sort of authentication page.

- **Proclaim.excerpt_length**

  Maximum length for the excerpts shown on the posts index. The excerpts may be
  less than this, but will never exceed it.

Astute readers may note that the defaults corresponds to defaults from Devise (on
the User class). If that's not your setup, all of these options can be changed
in the initializer installed by `rails generate proclaim:install`.


## Customizations

Proclaim was built to help you quickly develop an application that includes a
blog. However, it shouldn't be in your way when you need to customize it. Since
Proclaim is an engine, all of its views are packaged inside the gem. These views
will get you started, and you can always implement new styles via CSS, but you
may wish to change them completely. You can simply copy them into your
application and alter them by using the generator:

```ruby
rails generate proclaim:views
```