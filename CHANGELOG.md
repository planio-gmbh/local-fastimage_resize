# 3.2.0 - 2017-09-08

Check for some error cases in gd calls which might have resulted in null-pointer exceptions and subsequent segfaults.

If the resized image could not be created for any reason, we now raise a `FastImage::ImageFetchFailure` exception.

# 3.1.1 - 2016-06-03

Fix native code structure to work after gem install.

# 3.1.0 - 2016-06-03

Replacing RubyInline with native extension.

# 3.0.1 - 2016-06-02

Updating meta data in gemspec, no code changes.

# 3.0.0 - 2016-06-02

Removing remote image support.
