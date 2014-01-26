# Snailmail

## What?

A demonstration of connecting [Twillo](https://www.twilio.com/), [Lob](https://www.lob.com), [Redis](http://redis.io), [Heroku](http://www.heroku.com) and [Sinatra](http://www.sinatrarb.com/).

This app takes a incoming phone-call, the caller's selections, and a recording, then will generate and mail a postcard with the contents of the recording on the back.

## Why?

I made a joke on an IRC channel about a service that could take voice-mails and mail them to you. This is a proof of concept that such a service could actually exist.

Also it's fun.

## How?

Requires:

- Ruby 2.1
- Redis
- ffmpeg on `$PATH`
- Lob API key

Heroku setup:

```bash
heroku addons:add redistogo
heroku config:set PATH=/app/bin:/app/vendor/bundle/ruby/2.1.0/bin:/app/vendor/bundle/bin:/usr/local/bin:/usr/bin:/bin:vendor/
heroku config:set LOB_APIKEY=YOUR_LOB_API_KEY_HERE
```

Optional (if you want email alerts when someone uses the app):
- Sendgrid

Heroku setup:

```bash
heroku addons:add sendgrid:starter
heroku config:set ADMIN_EMAIL=YOUR_EMAIL_HERE
```

To get it running, follow the [instructions](https://devcenter.heroku.com/articles/rack) on Heroku.

The only way to communicate with the app is via the Redis database, and the admin console. To get access, just `bundle exec pry` (heroku: `heroku run pry`)

Once inside the application console, add a new user with:

```ruby
user = User.create({
  name: "Name that will appear on Postcard and in UI",
  address_line1: "Mailing Address Line 1",
  address_line2: "Mailing Address Line 2",
  city: "Mailing City",
  state: "Two letter state code",
  country: "Mailing Country",          # Optional
  short_code: "String of digits, 0-9"  # Code that references this instance on the keypad
})

# The app keeps track of uses to prevent abuse,
# so each user has a :uses_remaining field that
# will lock a user out if it drops to 0, so add
# some uses!

user.incr(:uses_remaining, 10)

# Postcards need to go someplace, so also add
# one or more recipients.

Recipient.create({
  name: "Name that will appear on Postcard and in UI",
  address_line1: "Mailing Address Line 1",
  address_line2: "Mailing Address Line 2",
  city: "Mailing City",
  state: "Two letter state code",
  country: "Mailing Country",          # Optional
  short_code: "String of digits, 0-9"  # Code that references this instance on the keypad
  user: user                           # User this Recipient belongs to
})

```

Last step, in your Twillo App settings, add an incoming call endpoint to POST to your heroku instance's hostname `telephony/incoming` route.

Then call your Twillio number, enter in the short-code of the user you generated above, the recipient short code, and await your postcard!

## Who?

[Paul Bergeron](http://pauldbergeron.com/) wrote this.

Images for postcard fronts from [Unsplash](http://unsplash.com/).
