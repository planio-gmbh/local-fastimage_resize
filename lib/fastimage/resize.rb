# frozen_string_literal: true
#
# FastImage Resize is an extremely light solution for resizing images in ruby by using libgd
#
# === Examples
#
#   require 'fastimage_resize'
#
#   FastImage.resize("image.gif", 100, 20, outfile: "thumbnail.gif")
#   => 1
#
# === Requirements
#
# RubyInline and FastImage (installed via RubyGems) and libgd
#
# See http://www.libgd.org/
#
# Libgd is commonly available on most unix platforms, including OSX.
#
# === References
#
# * http://blog.new-bamboo.co.uk/2007/12/3/super-f-simple-resizing

require 'tempfile'
require 'fastimage'
require 'fastimage_native_resize'

module FastImage::Resize
  SUPPORTED_FORMATS = [:jpeg, :png, :gif]
  FILE_EXTENSIONS = [:jpg, :png, :gif]  # prefer jpg to jpeg as an extension

  class FormatNotSupported < FastImage::FastImageException # :nodoc:
  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # Resizes an image, storing the result in a file given in file_out
    #
    # Input can be a filename, a uri, or an IO object.
    #
    # FastImage Resize can resize GIF, JPEG and PNG files.
    #
    # Giving a zero value for width or height causes the image to scale proportionately.
    #
    # === Example
    #
    #   require 'fastimage_resize'
    #
    #   FastImage.resize("http://stephensykes.com/images/ss.com_x.gif", 100, 20, outfile: "my.gif")
    #
    # === Supported options
    # [:jpeg_quality]
    #   A figure passed to libgd to determine quality of output jpeg (only useful if input is jpeg)
    # [:outfile]
    #   Name of a file to store the output in, in this case a temp file is not used
    #
    def resize(source, width, height, options={})
      new(source, raise_on_failure: true).resize(width, height, options)
    end
  end

  def resize(width, height, options = {})
    jpeg_quality = options[:jpeg_quality] || -1
    file_out = options[:outfile]

    type_index = SUPPORTED_FORMATS.index(type)
    raise FormatNotSupported unless type_index

    if !file_out
      temp_file = Tempfile.new(["fastimage-resize-", ".#{FILE_EXTENSIONS[type_index]}"])
      temp_file.binmode
      file_out = temp_file.path
    else
      temp_file = nil
    end

    FastImage.native_resize(path, file_out.to_s, width.to_i, height.to_i, type_index, jpeg_quality.to_i, orientation)

    raise FastImage::ImageFetchFailure, 'Image could be created' unless File.exist?(file_out.to_s)

    temp_file
  rescue RuntimeError => e
    raise FastImage::ImageFetchFailure, e.message
  end
end

FastImage.send(:include, FastImage::Resize)
