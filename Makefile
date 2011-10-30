install: **/*.st package.xml
	mkdir -p ${HOME}/.st
	gst-package -t ${HOME}/.st/ package.xml

uninstall:
	rm ${HOME}/.st/Gitocello.star

