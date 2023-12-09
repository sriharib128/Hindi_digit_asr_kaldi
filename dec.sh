#!/bin/bash
 . ./path.sh || exit 1
 . ./cmd.sh || exit 1
# 4 parallel jobs
nj=2

 # language model order is equal to 1 (n-gram quantity)
lm_order=1
. utils/parse_options.sh || exit 1
[[ $# -ge 1 ]] && { echo "Wrong arguments!"; exit 1; }
# this use to remove the data results of last execution
# rm -rf exp mfcc data/train/spk2utt data/train/cmvn.scp data/train/feats.scp data/train/split1 
rm -rf data/test/spk2utt data/test/cmvn.scp data/test/feats.scp data/test/split1 
# rm -rf data/local/lang data/lang data/local/tmp data/local/dict/lexiconp.txt

echo
echo "===== PREPARING ACOUSTIC DATA ====="
echo
echo
echo " Needs to be created as the following:
spk2gender [<speaker-id> <gender>]
wav.scp [<uterranceID> <full_path_to_audio_file>]
text [<uterranceID> <text_transcription>]
utt2spk [<uterranceID> <speakerID>]
corpus.txt [<text_transcription>]"
echo
echo
echo "wait until creating spk2utt files........."
echo
# creating the spk2utt for train and test
# utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt
utils/utt2spk_to_spk2utt.pl data/test/utt2spk > data/test/spk2utt
echo
echo "spk2utt files has been created sucessfully!!"
echo
echo
echo "===== FEATURES EXTRACTION ====="
echo

# creating feats.scp
mfccdir=mfcc
# # script for checking prepared data (train)
# utils/validate_data_dir.sh data/train 
# utils/fix_data_dir.sh data/train
# steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/train exp/make_mfcc/train $mfccdir
# script for checking prepared data (test)
utils/validate_data_dir.sh data/test
utils/fix_data_dir.sh data/test
steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/test exp/make_mfcc/test $mfccdir
# # creating cmvn.scp
# steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train $mfccdir
steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test $mfccdir

# echo
# echo "===== PREPARING LANGUAGE DATA ====="        
# echo

# # It should be created as the following:
# #
# # lexicon.txt [<word> <phone 1> <phone 2> ...]
# # nonsilence_phones.txt [<phone>]
# # silence_phones.txt [<phone>]
# # optional_silence.txt [<phone>]
#  utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/lang
# echo
# echo "===== CREATING lm.arpa ====="
# echo

loc=`which ngram-count`;
# if [ -z $loc ]; then
#  if uname -a | grep 64 >/dev/null; then
#  sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64
#  else
#  sdir=$KALDI_ROOT/tools/srilm/bin/i686
#  fi
#  if [ -f $sdir/ngram-count ]; then
#  echo "Using SRILM language modelling tool from $sdir"
#  export PATH=$PATH:$sdir
#  else
#  echo "SRILM toolkit is probably not installed.
#  Instructions: tools/install_srilm.sh"
#  exit 1 

#  fi
# fi

local=data/local
# mkdir $local/tmp
# ngram-count -order $lm_order -write-vocab $local/tmp/vocab-full.txt -wbdiscount -text $local/corpus.txt -lm $local/tmp/lm.arpa

#  echo
#  echo "===== CREATING G.fst ====="
#  echo

lang=data/lang
# arpa2fst --disambig-symbol=#0 --read-symbol-table=$lang/words.txt $local/ tmp/lm.arpa $lang/G.fst

# echo
# echo "===== MONO TRAINING ====="
# echo

# steps/train_mono.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono || exit 1

#  echo
# echo "===== MONO DECODING ====="
#  echo

# utils/mkgraph.sh --mono data/lang exp/mono exp/mono/graph || exit 1
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/mono/graph data/test exp/mono/decode

# echo
# echo "===== MONO ALIGNMENT ====="
# echo

# steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono exp/mono_ali || exit 1

# echo
# echo "===== TRI1 (first triphone pass) TRAINING ====="
# echo

# steps/train_deltas.sh --cmd "$train_cmd" 300 3000 data/train data/lang exp/mono_ali exp/tri1 || exit 1

# echo 

# echo "===== TRI1 (first triphone pass) DECODING ====="
# echo

# utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph || exit 1
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri1/graph data/test exp/tri1/decode
# echo
# echo"=========THE TREE PDF FILE========"
# echo
# draw-tree data/lang/phones.txt exp/tri1/tree | dot -Tps -Gsize=100,100 | ps2pdf - tree.pdf
# echo
# echo "=======align for the tri1========="
# echo
# steps/align_si.sh --nj $nj --cmd "$train_cmd" \
#  --use-graphs true data/train data/lang exp/tri1 exp/tri1_ali
# echo
# echo "======= train tri2a [delta+delta-deltas]========="
# echo
#  steps/train_deltas.sh --cmd "$train_cmd" 300 3000 \
#  data/train data/lang exp/tri1_ali exp/tri2a
# echo
# echo " ==============decode tri2a ==============="
# echo
#  utils/mkgraph.sh data/lang exp/tri2a exp/tri2a/graph
 steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
 exp/tri2a/graph data/test exp/tri2a/decode
# echo
# echo " ========train and decode tri2b [LDA+MLLT]==========="
# echo
# steps/train_lda_mllt.sh --cmd "$train_cmd" \
#  --splice-opts "--left-context=3 --right-context=3" \
#  300 3000 data/train data/lang exp/tri1_ali exp/tri2b 

# utils/mkgraph.sh data/lang exp/tri2b exp/tri2b/graph
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
 exp/tri2b/graph data/test exp/tri2b/decode
# echo
# echo "=====Align all data with LDA+MLLT system [tri2b] ======"
# echo
# steps/align_si.sh --nj $nj --cmd "$train_cmd" --use-graphs true \
#  data/train data/lang exp/tri2b exp/tri2b_ali
# echo
# echo "=============Do MMI on top of LDA+MLLT=============="
# echo
# steps/make_denlats.sh --nj $nj --cmd "$train_cmd" \
#  data/train data/lang exp/tri2b exp/tri2b_denlats
# steps/train_mmi.sh data/train data/lang exp/tri2b_ali exp/tri2b_denlats exp/tri2b_mmi
steps/decode.sh --config conf/decode.config --iter 4 --nj $nj --cmd "$decode_cmd" \
 exp/tri2b/graph data/test exp/tri2b_mmi/decode_it4
steps/decode.sh --config conf/decode.config --iter 3 --nj $nj --cmd "$decode_cmd" \
 exp/tri2b/graph data/test exp/tri2b_mmi/decode_it3
# echo
# echo "============== Do the same with boosting==============="
# echo
# steps/train_mmi.sh --boost 0.05 data/train data/lang \
#  exp/tri2b_ali exp/tri2b_denlats exp/tri2b_mmi_b0.05
steps/decode.sh --config conf/decode.config --iter 4 --nj $nj --cmd "$decode_cmd" \
 exp/tri2b/graph data/test exp/tri2b_mmi_b0.05/decode_it4
steps/decode.sh --config conf/decode.config --iter 3 --nj $nj --cmd "$decode_cmd" \
 exp/tri2b/graph data/test exp/tri2b_mmi_b0.05/decode_it3
# echo
# echo "===================Do MPE======================="
# echo
# steps/train_mpe.sh data/train data/lang exp/tri2b_ali exp/tri2b_denlats exp/tri2b_mpe
steps/decode.sh --config conf/decode.config --iter 4 --nj $nj --cmd "$decode_cmd" \
 exp/tri2b/graph data/test exp/tri2b_mpe/decode_it4 

steps/decode.sh --config conf/decode.config --iter 3 --nj $nj --cmd "$decode_cmd" \
 exp/tri2b/graph data/test exp/tri2b_mpe/decode_it3
# echo
# echo "============Do LDA+MLLT+SAT, and decode============="
# echo " 1986 the Carnegie Mellon University [CMU] "
# steps/train_sat.sh 300 3000 data/train data/lang exp/tri2b_ali exp/tri3b
# utils/mkgraph.sh data/lang exp/tri3b exp/tri3b/graph
steps/decode_fmllr.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
 exp/tri3b/graph data/test exp/tri3b/decode
# echo
# echo "===== Align all data with LDA+MLLT+SAT system [tri3b] ========"
# echo
# steps/align_fmllr.sh --nj $nj --cmd "$train_cmd" --use-graphs true \
#  data/train data/lang exp/tri3b exp/tri3b_ali
# echo
echo "=====summerizing the final results====="
echo
for x in exp/*/decode*; do [ -d $x ] && [[ $x =~ "$1" ]] && grep WER $x/wer_*|
utils/best_wer.sh; done
exit 0
echo
echo "=====run.sh is finished successfully ====="
echo