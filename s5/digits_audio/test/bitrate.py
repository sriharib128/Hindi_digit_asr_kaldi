# wav.scp => <utterance_ID> <full_path_to_audio_file>
import os

folder_dir=[os.path.abspath(name) for name in os.listdir(".") if os.path.isdir(name)]
folder_name = [os.path.basename(name) for name in folder_dir]
# with open('../../../data/test/wav.scp', 'w') as f:
for k in range(len(folder_dir)):
    os.chdir(folder_dir[k])
    os.system("rm -r ./new")
    os.makedirs("./new")
    for name in os.listdir("."):
        if ((os.path.isdir(name))== False):
            os.system(("ffmpeg -i "+ os.path.abspath(name) +" -acodec pcm_s16le -ac 1 -ar 16000 "+folder_dir[k]+"/new/"+name))
    os.system("rm ./*.wav")
    os.system("cp ./new/*.wav ./")
    os.system("rm -r ./new/")
