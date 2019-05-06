import os

from os.path import join, getsize

for root, dirs, files in os.walk('.', topdown=True):
    #print(root, dirs, files)
    #print(root, dirs)
    #print(files)
    for filename in files:
        #print(root)
        print(os.path.join(root, filename))
    #print(root, "consumes", end=" ")
    print(sum(getsize(join(root, name)) for name in files), end=" ")
    print()
    #print("bytes in", len(files), "non-directory files")
    #if 'opt' in dirs:
    #    dirs.remove('opt')  # don't visit opt directories
