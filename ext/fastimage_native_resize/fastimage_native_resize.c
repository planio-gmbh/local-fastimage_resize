#include <ruby.h>
#include <gd.h>

static VALUE fastimage_native_resize(
        VALUE self,
        VALUE rb_in, VALUE rb_out,
        VALUE rb_w, VALUE rb_h,
        VALUE rb_image_type,
        VALUE rb_jpeg_quality,
        VALUE rb_orientation
       ) {
  char *filename_in  = StringValuePtr(rb_in);
  char *filename_out = StringValuePtr(rb_out);
  int w              = NUM2INT(rb_w);
  int h              = NUM2INT(rb_h);
  int image_type     = NUM2INT(rb_image_type);
  int jpeg_quality   = NUM2INT(rb_jpeg_quality);
  int orientation    = NUM2INT(rb_orientation);


  gdImagePtr im_in, im_out;
  FILE *in, *out;
  int trans = 0, x = 0, y = 0, f = 0;

  in = fopen(filename_in, "rb");
  if (!in) {
    rb_raise(rb_eIOError, "Could not open input file: %s", filename_in);
  }

  switch(image_type) {
    case 0: im_in = gdImageCreateFromJpeg(in);
            break;
    case 1: im_in = gdImageCreateFromPng(in);
            break;
    case 2: im_in = gdImageCreateFromGif(in);
            if (im_in) {
              trans = gdImageGetTransparent(im_in);
              /* find a transparent pixel, then turn off transparency
                 so that it copies correctly */
              if (trans >= 0) {
                for (x=0; x<gdImageSX(im_in); x++) {
                  for (y=0; y<gdImageSY(im_in); y++) {
                    if (gdImageGetPixel(im_in, x, y) == trans) {
                      f = 1;
                      break;
                    }
                  }
                  if (f) break;
                }
                gdImageColorTransparent(im_in, -1);
                if (!f) trans = -1;  /* no transparent pixel found */
              }
            }
            break;
    case 3: im_in = gdImageCreateFromTiff(in);
            break;
    default:
            fclose(in);
            rb_raise(rb_eArgError, "Unsupported image type: %d", image_type);
  }

  if (!im_in) {
    fclose(in);
    rb_raise(rb_eRuntimeError, "Failed to read image data from: %s", filename_in);
  }



  /*  Handle orientation */
  if (orientation == 5 || orientation == 6) {
    im_in = gdImageRotateInterpolated(im_in, 270.0, 0);
  }
  if (orientation == 7 || orientation == 8) {
    im_in = gdImageRotateInterpolated(im_in, 90.0, 0);
  }
  if (!im_in) {
    fclose(in);
    return Qnil;
  }

  if (orientation == 2 || orientation == 5 || orientation == 7) {
    gdImageFlipHorizontal(im_in);
  }
  if (orientation == 3) {
      gdImageFlipBoth(im_in);
  }
  if (orientation == 4) {
    gdImageFlipVertical(im_in);
  }



  /* Compute target size */
  if (w == 0 || h == 0) {
    int originalWidth  = gdImageSX(im_in);
    int originalHeight = gdImageSY(im_in);
    if (h != 0) {
      w = (int)(h * originalWidth / originalHeight);
    } else if (w != 0) {
      h = (int)(w * originalHeight / originalWidth);
    } else {
      w = originalWidth;
      h = originalHeight;
    }
  }



  im_out = gdImageCreateTrueColor(w, h);  /* must be truecolor */
  if (im_out) {
    if (image_type == 1) {
      gdImageAlphaBlending(im_out, 0);  /* handle transparency correctly */
      gdImageSaveAlpha(im_out, 1);
    }
    fclose(in);
  } else {
    fclose(in);
    return Qnil;
  }

  /* Now copy the original */
  gdImageCopyResampled(im_out, im_in, 0, 0, 0, 0,
    gdImageSX(im_out), gdImageSY(im_out),
    gdImageSX(im_in), gdImageSY(im_in));

  out = fopen(filename_out, "wb");
  if (out) {
    switch(image_type) {
      case 0: gdImageJpeg(im_out, out, jpeg_quality);
              break;
      case 1: gdImagePng(im_out, out);
              break;
      case 2: gdImageTrueColorToPalette(im_out, 0, 256);
              if (trans >= 0) {
                trans = gdImageGetPixel(im_out, x, y);  /* get the color index of our transparent pixel */
                gdImageColorTransparent(im_out, trans); /* may not always work as hoped */
              }
              gdImageGif(im_out, out);
              break;
      case 3: gdImagePng(im_out, out);
              break;
    }
    fclose(out);
  }
  gdImageDestroy(im_in);
  gdImageDestroy(im_out);
  return Qnil;
}

void Init_fastimage_native_resize(void) {
  VALUE cFastImageResize;

  cFastImageResize = rb_const_get(rb_cObject, rb_intern("FastImage"));

  rb_define_singleton_method(cFastImageResize, "native_resize", fastimage_native_resize, 7);
}
