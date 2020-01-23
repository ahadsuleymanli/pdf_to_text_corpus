import argparse
import io 
import nltk
import re
from alphabet_detector import AlphabetDetector
import tempfile, shutil, os

ap = argparse.ArgumentParser()
# ap.add_argument("target_file_path",nargs=1)
# ap.add_argument('--newline_sentences', action='store_true')
ap.add_argument('--pdf_path', type=str,default="")
args = ap.parse_args()

def txt2paragraph(filepath):
    with io.open(filepath, "r",encoding="utf-8", errors='ignore') as f:
        lines = f.readlines()
    paragraph = ''
    for line in lines:
        if line.isspace():
            if paragraph:
                yield paragraph
                paragraph = ''
            else:
                continue
        else:
            paragraph += ' ' + line.strip()
    yield paragraph

def filter_non_printable(str):
  return ''.join([c for c in str if ord(c) > 31 or ord(c) == 9])
ad = AlphabetDetector()
file = args.pdf_path
pre, ext = os.path.splitext(file)
with open(pre+".pdfdata", 'w') as target_file:
    sentences = []
    for paragraph in txt2paragraph(file):
        paragraph=paragraph.replace('"',' ')
        paragraph=paragraph.replace('”',' ')
        paragraph=paragraph.replace('“',' ')
        paragraph=paragraph.replace('•',' ')
        paragraph=paragraph.replace('?','.')
        paragraph=paragraph.replace('!','.')
        paragraph=paragraph.replace(';',' ')
        paragraph=paragraph.replace(':',' ')
        paragraph=paragraph.replace("’","'")
        paragraph=' '.join(paragraph.split())
        temp = nltk.sent_tokenize(paragraph)
        sentences.extend(temp)
        if len(temp)>1 and temp[-1].endswith('.'):
            paragraph = ""
            for sentence in sentences:
                sentence = filter_non_printable(sentence)
                if ad.is_latin(sentence) and not re.search(r"([\s.!#?^@-\\\|\*,]+\w[\s.!#?^@-\\\|\*,]+)+\w[\s.!#?^@-\\\|\*,]+",sentence) and not re.search(r"\/\d+|\d+\/",sentence):
                    if paragraph!="":
                        paragraph+=" "
                    paragraph += sentence
            if paragraph is not "":
                target_file.write(paragraph + "\n")
            # else:
            #     print(sentences)
            sentences.clear()
os.remove(file)
