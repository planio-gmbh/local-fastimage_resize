# frozen_string_literal: true

require 'test_helper'

class FastImageResizeTest < Minitest::Test

  PathHere = File.dirname(__FILE__)
  FixturePath = File.join(PathHere, "fixtures")

  GoodFixtures = {
    "test.gif" => [:gif, [17, 32]],
    "test.jpg" => [:jpeg, [882, 470]],
    "test.png" => [:png, [30, 20]],
    "test.tif" => [:tiff, [882, 470]]
    }

  BadFixtures = [
    "test.bmp",
    "faulty.jpg",
    "test.ico",
    "bad.gif"
  ]

  OrientationFixtures = Dir[File.join(FixturePath, 'orientation', '*.jpg')]

  def test_resize_image_types_from_files
    GoodFixtures.each do |fn, info|
      outfile = File.join(PathHere, "fixtures", "resized_" + fn)
      FastImage.resize(File.join(FixturePath, fn), info[1][0] / 3, info[1][1] / 2, outfile: outfile)
      assert_equal [info[1][0] / 3, info[1][1] / 2], FastImage.size(outfile)
      File.unlink outfile
    end
  end

  def test_resize_image_types_from_io_objects
    GoodFixtures.each do |fn, info|
      outfile = File.join(PathHere, "fixtures", "resized_" + fn)
      File.open(File.join(FixturePath, fn)) do |io|
        FastImage.resize(io, info[1][0] / 3, info[1][1] / 2, outfile: outfile)
        assert_equal [info[1][0] / 3, info[1][1] / 2], FastImage.size(outfile)
        File.unlink outfile
      end
    end
  end

  def test_resize_to_temp_file
    GoodFixtures.each do |fn, info|
      File.open(File.join(FixturePath, fn)) do |io|
        outfile = FastImage.resize(io, info[1][0] / 3, info[1][1] / 2)
        assert_equal [info[1][0] / 3, info[1][1] / 2], FastImage.size(outfile)
      end
    end
  end

  def test_should_raise_for_bmp_files
    fn = BadFixtures[0]
    outfile = File.join(PathHere, "fixtures", "resized_" + fn)
    assert_raises(FastImage::FormatNotSupported) do
      FastImage.resize(File.join(FixturePath, fn), 20, 20, outfile: outfile)
    end
  end

  def test_should_raise_for_faulty_files
    fn = BadFixtures[1]
    outfile = File.join(PathHere, "fixtures", "resized_" + fn)
    assert_raises(FastImage::SizeNotFound) do
      FastImage.resize(File.join(FixturePath, fn), 20, 20, outfile: outfile)
    end
  end

  def test_should_not_segfault_on_faulty_gif
    fn = BadFixtures[3]
    outfile = File.join(PathHere, "fixtures", "resized_" + fn)
    assert_raises(FastImage::ImageProcessingError) do
      FastImage.resize(File.join(FixturePath, fn), 20, 20, outfile: outfile)
    end
  end

  def test_should_raise_for_ico_files
    fn = BadFixtures[2]
    outfile = File.join(PathHere, "fixtures", "resized_" + fn)
    assert_raises(FastImage::FormatNotSupported) do
      FastImage.resize(File.join(FixturePath, fn), 20, 20, outfile: outfile)
    end
  end

  def test_should_resize_names_with_spaces
    outfile = File.join(PathHere, "fixtures", "resized_test with space.jpg")
    FastImage.resize(File.join(FixturePath, "test with space.jpg"), 10, 10, outfile: outfile)
    assert File.exist?(outfile)
    File.unlink outfile
  end

  def test_resized_jpg_is_reasonable_size_for_quality
    outfile = File.join(PathHere, "fixtures", "resized_test.jpg")
    FastImage.resize(File.join(FixturePath, "test.jpg"), 200, 200, outfile: outfile)
    size = File.size(outfile)
    assert size < 30000
    assert size > 10000
    FastImage.resize(File.join(FixturePath, "test.jpg"), 200, 200, outfile: outfile, jpeg_quality: 5)
    size = File.size(outfile)
    assert size < 3500
    assert size > 1500
    File.unlink outfile
  end

  def test_output_tempfile_has_right_extension
    outfile = FastImage.resize(File.join(FixturePath, "test.jpg"), 200, 200)
    assert outfile.path =~ /\.jpg$/
    outfile = FastImage.resize(File.join(FixturePath, "test.gif"), 200, 200)
    assert outfile.path =~ /\.gif$/
    outfile = FastImage.resize(File.join(FixturePath, "test.png"), 200, 200)
    assert outfile.path =~ /\.png$/
  end

  def test_zero_width_scales_proportionately
    GoodFixtures.each do |fn, info|
      File.open(File.join(FixturePath, fn)) do |io|
        halfHeight = (info[1][1] / 2).round
        outfile = FastImage.resize(io, 0, halfHeight)
        newWidth = (halfHeight * info[1][0] / info[1][1]).round
        assert_equal [newWidth, halfHeight], FastImage.size(outfile)
      end
    end
  end

  def test_zero_height_scales_proportionately
    GoodFixtures.each do |fn, info|
      File.open(File.join(FixturePath, fn)) do |io|
        halfWidth =  (info[1][0] / 2).round
        outfile = FastImage.resize(io, halfWidth, 0)
        newHeight = (halfWidth * info[1][1] / info[1][0]).round
        assert_equal [halfWidth, newHeight], FastImage.size(outfile)
      end
    end
  end

  def test_keeps_size_if_height_and_width_are_zero
    GoodFixtures.each do |fn, info|
      File.open(File.join(FixturePath, fn)) do |io|
        outfile = FastImage.resize(io, 0, 0)
        assert_equal info[1], FastImage.size(outfile)
      end
    end
  end

  def test_preserves_orientation_when_scaling
    OrientationFixtures.each do |fn|
      outfile = FastImage.resize(fn, 240, 0)
      fi = FastImage.new(outfile)

      assert_equal [480, 640], FastImage.size(fn), 'Orientation read improperly from source'
      assert_equal [240, 320], fi.size,            'Orientation applied improperly to target'
      assert_equal 1, fi.orientation,              'Orientation meta data stored improperly to target'
    end
  end

  def test_preserves_orientation_without_scaling
    OrientationFixtures.each do |fn|
      outfile = FastImage.resize(fn, 0, 0)
      fi = FastImage.new(outfile)

      assert_equal [480, 640], FastImage.size(fn), 'Orientation read improperly from source'
      assert_equal [480, 640], fi.size,            'Orientation applied improperly to target'
      assert_equal 1, fi.orientation,              'Orientation meta data stored improperly to target'
    end
  end
end
