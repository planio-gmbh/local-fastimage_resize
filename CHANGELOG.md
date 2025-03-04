# 3.4.1 - 2025-03-04

Improved error handling and memory management to fix segmentation faults that
could occur with malformed images.

Introduced a new `FastImage::Resize::ImageProcessingError` exception class

# 3.4.0 - 2021-02-10

Support for resizing TIFF images. Output of such an operation is always a PNG
image.

# 3.3.0 - 2018-04-24

Support for Exif orientation.

Images are rotated and flipped automatically based on Exif data, so that the
generated thumbnails follow the specified orientation.

Support for easy non-scaling operation

By providing `0` for both width and height, the image will not be scaled but
merely re-encoded to the target location. This may be useful in combination with
the above mentioned automatic Exif orientation handling,

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
