# spk2gender ⇒ <speaker_ID> <speaker gender>
import os
names_list=[]
with open("../../../data/test/wav.scp",'r') as f:
        x=f.readlines()
        for line in x:
            words= line.split(" ")
            names_list.append(words[0][:-6])
names_list = list(set(names_list))
with open('../../../data/test/spk2gender','w') as fi:
    print("\n".join(names_list) , file = fi)