# Prerequisites to installing Tesseract from GitHub repositories
Tesseract library and Leptonica library development packages must be installed.

# Debugging

On my Fedora installation, I needed to do something similar to:

dnf debuginfo-install giflib-5.1.4-2.fc29.x86_64 jbigkit-libs-2.1-15.fc29.x86_64 leptonica-1.77.0-1.fc29.x86_64 libjpeg-turbo-2.0.0-3.fc29.x86_64 libpng-1.6.34-7.fc29.x86_64 libtiff-4.0.10-4.fc29.x86_64 libwebp-1.0.2-1.fc29.x86_64 zlib-1.2.11-14.fc29.x86_64

Additionally, you may also need to install glibc debugging package via something similar to:

dnf debuginfo-install glibc-2.28-26.fc29.x86_64



# Construction of MEX wrappers

MATLAB wrappers were constructed for Tesseract 3 and 4, using the
approach of [matlab-tesseract-ocr](https://github.com/supersom/matlab-tesseract-ocr).

We did not clone the entire repository, but rather use the code there
to construct a minimalistic wrapper for doing OCR on MATLAB image.  It
turns out that the 2012 code compiles with the MEX compiler with no
trouble (with R2018b) and with Tessseract 4 if setlocale is called
with some valid locale, e.g. "C".


