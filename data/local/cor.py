# corpus.txt
with open("../train/text",'r') as f:
    with open('./corpus.txt','w') as fi:
        x=f.readlines()
        for line in x:
            print(line[-7:-1],file=fi)
            # words= line.split(" ")
            # print(words[1] + " " + words[2] + " " + words[3],file=fi)

