# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fastimage/resize/version"

Gem::Specification.new do |s|
  s.name = "local-fastimage_resize"
  s.version = FastImage::Resize::VERSION
  s.authors = ["Stephen Sykes", "Gregor Schmidt (Planio)"]
  s.email = ["sdsykes@gmail.com", "gregor@plan.io", "support@plan.io"]

  s.summary = "Local FastImage Resize - Image resizing fast and simple"
  s.description = "Local FastImage Resize is an extremely light solution for resizing images in ruby by using libgd."
  s.homepage = "http://github.com/planio-gmbh/local-fastimage_resize"

  s.requirements = ["libgd, see www.libgd.org"]

  s.license = "MIT"

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(bin|test)/}) }
  s.require_paths = ["lib"]

  s.extensions = "ext/fastimage_native_resize/extconf.rb"

  s.add_dependency "local-fastimage", "~> 3.0"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "rake-compiler"
end
