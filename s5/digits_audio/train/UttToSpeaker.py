# utt2spk :- <utterance_ID> <speaker_ID>
with open("../../../data/train/wav.scp",'r') as f:
    with open('../../../data/train/utt2spk','w') as fi:
        x=f.readlines()
        for line in x:
            words= line.split(" ")
            print(words[0] + " " + words[0][:-6],file=fi)