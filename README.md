# Local FastImage Resize

This is a fork of the [FastImage
Resize](https://github.com/sdsykes/fastimage_resize) gem.

It features the following differences:

* Removal of all remote image handling code
* Replacing RubyInline with native extension
* Minor changes to code organization

[![Build
Status](https://travis-ci.org/planio-gmbh/local-fastimage_resize.svg?branch=master)](https://travis-ci.org/planio-gmbh/local-fastimage_resize)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'local-fastimage_resize', require: 'fastimage/resize'
```

And then execute:

    $ bundle


If you are using Bundler's autorequire, you're good to go. Otherwise make sure
to `require "fastimage/resize"`.

Or install it yourself as:

    $ gem install local-fastimage_resize

Again, make sure to `require "fastimage/resize"`.


### External dependencies

`local-fastimage_resize`, just as `fastimage_resize`, depends on
[libgd](http://www.libgd.org). Therefore you need to have the development
headers installed on your system.

* *Mac OS* (Homebrew): `brew install gd`
* *Debian*: `apt-get install libgd-dev`
* *Ubuntu*: `apt-get install libgd2-noxpm-dev`

The Ubuntu package with XPM support will work just as well. It's just, that
`fastimage_resize` will not make any use of it.


## Usage

See [README.textile](README.textile) for more documentation. Everything should
work as advertised, except for remote images of course.



## License

MIT, see file [MIT-LICENSE](MIT-LICENSE)
