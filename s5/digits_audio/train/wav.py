# wav.scp ⇒ <utterance_ID> <full_path_to_audio_file>
import os
folder_dir=[os.path.abspath(name) for name in os.listdir(".") if os.path.isdir(name)]
folder_name = [os.path.basename(name) for name in folder_dir]
# os.makedirs("../../../data/train/")
with open('../../../data/train/wav.scp', 'w') as f:
    for k in range(len(folder_dir)):
        os.chdir(folder_dir[k])
        for name in os.listdir("."):
            print((folder_name[k]+ "_" + name[:-4]) + " " + os.path.abspath(name) , file=f)
