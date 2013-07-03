# BSDMakefile

all: fo pdf

fo: book.fo

pdf: book.pdf

html: book.html

book.fo: book.xml
	xsltproc --xinclude  --stringparam profile.condition print --encoding utf8 /usr/local/share/xsl/docbook/fo/profile-docbook.xsl book.xml > book.fo

book.pdf: book.fo
	fop -fo book.fo -param condition print -pdf book.pdf
	rm book.fo
	touch book.xml

book.html: book.xml
	xsltproc --xinclude --stringparam profile.condition web --encoding utf8 -o book.html /usr/local/share/xsl/docbook/html/profile-docbook.xsl book.xml
	touch book.xml
