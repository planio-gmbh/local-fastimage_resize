# Local FastImage Resize

This is a fork of the [FastImage
Resize](https://github.com/sdsykes/fastimage_resize) gem.

It features the following differences:

* Removal of all remote image handling code
* Minor changes to code organization

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



## Usage

See [README.textile](README.textile) for more documentation. Everything should
work as advertised, except for remote images of course.



## License

MIT, see file [MIT-LICENSE](MIT-LICENSE)
