from PIL import Image
import sys

# python gen.py test2.jpeg
# sys.argv -> ["gen.py", "test2.jpeg"]
# sys.argv[1] -> "test2.jpeg"
# outName -> "test2.txt"

fileName = sys.argv[1]
outName = fileName.split('.')[0] + ".txt"

img = Image.open(fileName).convert('L')
w, h = img.size

asciiList = [" ",".",",",":","^","+","u","o","e","a","*","$","&","%","#","@"]

with open(outName, 'w') as f:
    for b in range(h):
        for a in range(w):
            intensity = img.getpixel((a, b))
            i = 15-intensity//16
            f.write(asciiList[i])
            f.write(asciiList[i])
        f.write("\n")
