!/bin/bash
# 
# This script is a minimalistic script that
# launches Tesseract 4.0 LSTM training
#

# We train with some Windows fonts
FONTDIR=/home/marek/.wine/drive_c/windows/Fonts

# Where is my tesseract clone from GitHub; certain paths are
# specified relative to this directory
TESSERACT_HOME=/home/marek/TESSERACT/tesseract

cd $TESSERACT_HOME

LANGDATA_DIR='../langdata'
TESSDATA_DIR='/usr/local/share/tessdata'



# List of fonts to train on
MYFONTS=(
    "Arial"
    "Verdana"
)





./src/training/tesstrain.sh --fonts_dir $FONTDIR --lang eng --linedata_only \
		 --fontlist $MYFONTS \
		 --noextract_font_properties --langdata_dir $LANGDATA_DIR \
		 --tessdata_dir  $TESSDATA_DIR --output_dir ~/tesstutorial/engtrain

mkdir -p ~/tesstutorial/engoutput

cd java

../src/training/lstmtraining --debug_interval 100 \
  --traineddata ~/tesstutorial/engtrain/eng/eng.traineddata \
  --net_spec '[1,36,0,1 Ct3,3,16 Mp3,3 Lfys48 Lfx96 Lrx96 Lfx256 O1c111]' \
  --model_output ~/tesstutorial/engoutput/base --learning_rate 20e-4 \
  --train_listfile ~/tesstutorial/engtrain/eng.training_files.txt \
  --eval_listfile ~/tesstutorial/engtrain/eng.training_files.txt \
  --max_iterations 5000 >& ~/tesstutorial/engoutput/basetrain.log

# Watch logfile from another window
# tail -f ~/tesstutorial/engoutput/basetrain.log
