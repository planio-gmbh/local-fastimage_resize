require "bundler/gem_tasks"

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

require "rake/extensiontask"

Rake::ExtensionTask.new do |ext|
  ext.name = "native_resize"
  ext.ext_dir = "ext/fastimage_resize"
  ext.lib_dir = "lib/fastimage/resize"
end

Rake::Task[:test].prerequisites << :compile

task :default => :test
