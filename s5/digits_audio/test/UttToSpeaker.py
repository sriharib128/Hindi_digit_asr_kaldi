# utt2spk ⇒ <utterance_ID> <speaker_ID>
with open("../../../data/test/wav.scp",'r') as f:
    with open('../../../data/test/utt2spk','w') as fi:
        x=f.readlines()
        for line in x:
            words= line.split(" ")
            print(words[0] + " " + words[0][:-6],file=fi)