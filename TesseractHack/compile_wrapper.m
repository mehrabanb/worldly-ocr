% setenv('LD_LIBRARY_PATH','/usr/local/lib');

mex -I/usr/local/include ...
     tessWrapper.cpp ...
    -L/usr/local/lib ...
    -ltesseract

     


