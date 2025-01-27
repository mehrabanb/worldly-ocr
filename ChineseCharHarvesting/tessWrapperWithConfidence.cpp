/**
 * @file   tessWrapperWithConfidence.cpp
 * @author Marek Rychlik <marek@cannonball.lan>
 * @date   Wed Jul 17 13:24:56 2019
 * 
 * @brief  Tesseract wrapper with confidence levels
 * 
 * 
 */

#include <tesseract/baseapi.h>
#include "mex.h"
#include "matrix.h"
#include <vector>
#include <utility>

#ifndef DEBUG
#define DEBUG 0
#endif

/** 
 * A MEX wrapper around Tesseract 4
 * The function accepts these arguments (passed in array prhs):
 *    - An image, which must be a byte array (monochromatic)
 *    - A language spec, string like "chi_sim" or "eng"
 *    - ROI - region of interest (one for now)
 *
 * The output (passed to the caller in prhs[0]) is the Unicode
 * encoded text.
 * 
 * Explanations of arguments for MEX beginners below.
 *
 * @param nlhs              Number of left-hand sides.
 * @param plhs              Pointers to left-hand sides (must be allocated in the wrapper!).
 * @param nrhs              Number of right-hand sides passed as arguments.
 * @param prhs              Pointers to right-hand sides.
 * 
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  // This change required for Tesseract 4.0 (Marek Rychlik)
  setlocale (LC_ALL, "C");


  if (nrhs < 1 || !mxIsUint8(prhs[0])) mexErrMsgTxt("Must call tessWrapper with the image to OCR.");

  char lang[16] = "chi_tra";	// Crashes with chi_tra_vert?

  if (nrhs >= 2) {

    int len = mxGetM(prhs[1]) * mxGetN(prhs[1]);

    if (!mxIsChar(prhs[1])) {
      mexErrMsgTxt("You must specify the language as a string (typically 3 letters).");
    }

    if (len > 0) mxGetString(prhs[1],lang,sizeof(lang));
  }

  char tessbase[1024] = "/usr/share/tesseract/tessdata";//{0};

  if (nrhs >= 3) {
    mxGetString(prhs[2], tessbase, sizeof(tessbase));
  }

  mexPrintf("Tessdata directory: %s\n", tessbase);


  tesseract::TessBaseAPI ocrApi;
  if (ocrApi.Init(tessbase, lang)) {

    mxArray *rhs[1], *lhs[1];
    char *path, *name;

    rhs[0] = mxCreateString("fullpath");
    mexCallMATLAB(1, lhs, 1, rhs, "mfilename");
    mxDestroyArray(rhs[0]);
    path = mxArrayToString(lhs[0]);
    mxDestroyArray(lhs[0]);

    if (ocrApi.Init(path, lang)) {
      mexWarnMsgTxt("Can not find language, defaulting to English.");
    }
#if 0
    if (ocrApi.Init(path, "eng")) {
      mexErrMsgTxt("error initializing tesseract");
    }
#endif

    mxFree(path);
  }

  // This is the function used to pass an array
  // of bytes directly to the Tesseract engine.
  // We bypass Leptonica, no image file.
  //
  // From the documentation:
  // void tesseract::TessBaseAPI::SetImage(
  //            const   unsigned char *imagedata,
  // 		int  	width,
  // 		int  	height,
  // 		int  	bytes_per_pixel,
  // 		int  	bytes_per_line 
  // 	) 		
  //
  // Provide an image for Tesseract to recognize. Format is as
  // TesseractRect above. Does not copy the image buffer, or take
  // ownership. The source image may be destroyed after Recognize is
  // called, either explicitly or implicitly via one of the Get*Text
  // functions. SetImage clears all recognition results, and sets the
  // rectangle to the full image, so it may be followed immediately by a
  // GetUTF8Text, and it will automatically perform recognition.

  int width = mxGetM(prhs[0]);
  int height = mxGetN(prhs[0]);


  ocrApi.SetImage((unsigned char*)mxGetPr(prhs[0]),
		  width,
		  height,
		  1,
		  width);

  /**
   * Set the resolution of the source image in pixels per inch so font size
   * information can be calculated in results.  Call this after SetImage().
   *   void SetSourceResolution(int ppi);
   */
  ocrApi.SetSourceResolution(70);


  if (nrhs >= 4) {

#if DEBUG
    mexPrintf("ROI:\n");
    mexCallMATLAB(0,NULL,1,(mxArray **)&prhs[3],"disp");
#endif

    // Get ROI
    mwSize M = mxGetM(prhs[3]);
    mwSize N = mxGetN(prhs[3]);

    mexPrintf("ROI rows: %d, ROI cols: %d\n", M, N);

    if(N != 4) {
      mexErrMsgTxt("ROI matrix must have 4 columns");
    }

    mxDouble *roi = mxGetPr(prhs[3]);

    mwSize dims[2] = {M,1};
    const char *field_names[] = {"Symbol", "Confidence", "Choices"};
    
    const int NUMBER_OF_FIELDS = 3;
    plhs[0] = mxCreateStructArray(2, dims, NUMBER_OF_FIELDS, field_names);

    /*
     * Process regions of interest in succession
     */
    for(int r = 0; r < M; ++r) {
      ocrApi.SetRectangle(roi[0 * M + r], roi[1 * M + r], roi[2 * M + r], roi[3 * M + r]);
      ocrApi.Recognize(NULL);
#if DEBUG
      mexPrintf("Processing ROI #%d...\n", r);
#endif

      tesseract::ResultIterator* ri = ocrApi.GetIterator();
      tesseract::PageIteratorLevel level = tesseract::RIL_SYMBOL;

      if(ri != 0) {
	do {
	  const char* symbol = ri->GetUTF8Text(level);
	  float conf = ri->Confidence(level);
	  if(symbol != 0) {
#if DEBUG
	    printf("symbol %s, conf: %f", symbol, conf);
#endif

	    mxSetFieldByNumber(plhs[0],r,0,mxCreateString(symbol));

	    mxArray *field_value = mxCreateDoubleMatrix(1,1,mxREAL);
	    *mxGetPr(field_value) = conf;
	    mxSetFieldByNumber(plhs[0],r,1,field_value);

	    bool indent = false;
	    tesseract::ChoiceIterator ci(*ri);

	    /*
	     * Compute alternatives
	     */
	    std::vector<std::pair<const char*, float>> buf;
	    do {
#if DEBUG
	      if (indent) printf("\t\t ");
	      printf("\t- ");
#endif

	      const char* choice = ci.GetUTF8Text();
	      float choice_conf = ci.Confidence();

#if DEBUG
	      printf("%s conf: %f\n", choice, choice_conf);
#endif

	      buf.push_back(std::make_pair(choice, choice_conf));

	      indent = true;
	    } while(ci.Next());
	    
	    if(buf.size() > 0) {
	      // Skip the "Choices" field
	      mwSize alt_dims[2] = {buf.size(),1};
	      mxArray *alt = mxCreateStructArray(2, alt_dims, NUMBER_OF_FIELDS-1, field_names);

	      for(int i = 0; i < buf.size(); ++i) {
		auto& choice = buf[i].first;
		auto& conf = buf[i].second;

		mxSetFieldByNumber(alt,i,0,mxCreateString(choice));

		mxArray *field_value = mxCreateDoubleMatrix(1,1,mxREAL);
		*mxGetPr(field_value) = conf;
		mxSetFieldByNumber(alt,i,1,field_value);
	      }
	      mxSetFieldByNumber(plhs[0],r,2,alt);	      
	    }

	  }

#if DEBUG
	  printf("---------------------------------------------\n");
#endif

	  //delete[] symbol;
      
	} while((ri->Next(level)));
      }
    }
  }
  ocrApi.End();
}
