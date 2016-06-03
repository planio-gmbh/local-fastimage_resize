require "mkmf"

abort "missing libgd" unless have_library("gd")

dir_config "fastimage_resize"
create_makefile "native_resize"
