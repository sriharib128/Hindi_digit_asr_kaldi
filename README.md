# Hindi-Digit-ASR
Digit ASR for Hindi Digits using Kaldi
### 1. Audio Recording
 - collecting training data 
 - Record 10 "*.wav" files with 16KHz sampling rate from 10 speakers each which gives us 100 "*.wav" files
 - each recording must have 3 digits spoken in hindi
 - Use this naming system in order to use the python scripts
    - speakername_1stdigit_2nddigit_3rddigit
    - Eg:- abc_1_0_4
- now create a folder Hindi-Digit-ASR
- create a subfolder s5/digits_audio/train
- place these recorded files in this folder.
    - place all the recordings of a particular speaker in one folder
    - so on will have 10 folders inside the train folder.
        - each of this folder will have 10 wav files each having recording of 3 digits
### 2. Data Preparation
 - place the python script files in ./s5/digits_audio/train folder
 - run these script files and the required files will be created
 - go to ./data/train/spk2gender file and edit the genders by deafult all speakers get **f** change to **m** for corresponding speakers



