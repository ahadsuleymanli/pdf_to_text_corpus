#!/usr/bin/env bash
CURDIR=$(cd $(dirname $0); pwd)
if test -f "${CURDIR}/../config.ini"; then
    CONFIGPATH="${CURDIR}/../config.ini"
else
    CONFIGPATH="${CURDIR}/config.ini"
fi
source <(sed -n '/^\[DATA\]/,/^\[/p' ${CONFIGPATH} | grep PDFDIR | sed 's/ *= */=/g')
source <(sed -n '/^\[DATA\]/,/^\[/p' ${CONFIGPATH} | grep TEXTDIR | sed 's/ *= */=/g')
source <(sed -n '/^\[CORPUS\]/,/^\[/p' ${CONFIGPATH} | grep cocatd_text_name | sed 's/ *= */=/g')

function cleanup {
    for DIR in $( find ${PDFDIR} -mindepth 1 -type d ); do
        for FILE in $( find ${DIR} -type f -name "*.pdfdata" ); do rm ${FILE}; done
    done
}
# delete temp files on exit
trap cleanup EXIT

# replace spaces in names of pdf files
for DIR in $( find ${PDFDIR} -type d ); do
    cd ${DIR} && \
    for f in *\ *; do mv "$f" "${f// /_}"; done
done

# check for duplicate files accross directories
duplicates=$(fdupes -r ${PDFDIR} | grep -e '.pdf$' -e '^$' | uniq)
if [[ $? != 0 ]]; then
    echo "fdupes failed please fix it."
elif [[ $duplicates ]]; then
    echo "duplicate files, please remove."
    printf '%s\n' "${duplicates[@]}"
    echo "exiting."
    exit 0
fi

# go through subdirectories and convert pdfs to text
for DIR in $( find ${PDFDIR} -mindepth 1 -type d ); do
    i=0 &&
    echo "Processing directory ${DIR}" && \
    for FILE in $( find ${DIR} -type f -name "*.pdf" ); do
        pdftotext -eol unix -enc UTF-8 ${FILE} "${DIR}/$i.pdftext" 2> /dev/null && \
        python3 ${CURDIR}/process_text.py --pdf_path "${DIR}/$i.pdftext" & \
        ((i=i+1))
    done
    wait && \
    DIRNAME=$(basename ${DIR}) && \
    rm -f ${DIR}/${DIRNAME}.txt && \
    for f in $( find ${DIR} -name "*.pdfdata" ); do cat $f >> ${DIR}/${DIRNAME}.txt; done && \
    mkdir -p ${TEXTDIR}/${DIRNAME} && \
    cp ${DIR}/${DIRNAME}.txt ${TEXTDIR}/${DIRNAME}/${cocatd_text_name}
done
wait
