# text ⇒ <utterance_ID> <text_transcription>
with open("../../../data/test/wav.scp",'r') as f:
    with open('../../../data/test/text','w') as fi:
        x=f.readlines()
        for line in x:
            words= line.split(" ")
            print( (words[0] + " " + " ".join(words[0][-5:].split("_")) ) , file = fi )