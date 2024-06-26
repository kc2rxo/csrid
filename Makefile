DRAFT:=csrid
VERSION:=$(shell ./getver ${DRAFT}.md )
EXAMPLES=
OPEN=$(word 1, $(wildcard /usr/bin/xdg-open /usr/bin/open /bin/echo))

${DRAFT}-${VERSION}.txt: ${DRAFT}.txt
	cp ${DRAFT}.txt ${DRAFT}-${VERSION}.txt

%.xml: %.md
	kramdown-rfc2629 ${DRAFT}.md > ${DRAFT}.xml
	xml2rfc --v2v3 ${DRAFT}.xml
	mv ${DRAFT}.v2v3.xml ${DRAFT}.xml
	xml2rfc --v3 --html ${DRAFT}.xml
	$(OPEN) ${DRAFT}.html

%.txt: %.xml
	xml2rfc --text -o $@ $?

version:
	echo Version: ${VERSION}

clean:
	rm -f ${DRAFT}.xml ${DRAFT}.txt ${DRAFT}.html ${DRAFT}-${VERSION}.txt

.PRECIOUS: ${DRAFT}.xml