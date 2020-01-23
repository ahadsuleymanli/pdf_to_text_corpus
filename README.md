#### A tool for batch conversion of pdf texts/books into text corpora.<br/> The tool cleans up the latin unicode text to some extent.
This tool iterates over the sub-directories converting, processing and concatenating all the text from the pdf files in each directory.
The tool is intended for corpus creation out of large amounts of pdf documents, books, etc. 
This tool is intented for latin unicode texts. Was originally designed for Turkish. 
#### Setup:
1. Install requirements:
```
pip3 install --user --requirement requirements.txt
```
2. Setup the directories: 
```
	{pdf_root}
	├─ {dir1}
	│   ├── {file1}.pdf
	│   └── {file2}.pdf
	│   └── ...
	├─ {dir2}
	│   ├── {file99}.pdf
	│   └── ...
```
3. Edit config.ini:
```
PDFDIR = /home/corpora/pdf
TEXTDIR = /home/corpora/text/
```
4. Run the conversion:
```
./pdf_to_text.sh
```
