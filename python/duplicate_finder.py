import os, hashlib

def file_hash(path):
    h = hashlib.md5()
    with open(path, 'rb') as f:
        h.update(f.read())
    return h.hexdigest()

seen = {}
root = "/your/path"

for dirpath, _, files in os.walk(root):
    for file in files:
        full = os.path.join(dirpath, file)
        h = file_hash(full)
        if h in seen:
            print("Duplicate:", full, "<-->", seen[h])
        else:
            seen[h] = full
