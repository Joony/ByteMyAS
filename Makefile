make:
	mxmlc -sp='src/' -library-path='lib/' -debug=true -target-player='10.0.0' -default-size 633 300 -o='public/swf_editor.swf' src/SWFEditor.as -static-link-runtime-shared-libraries=true
	fdb public/index.html

final:
	mxmlc -sp='src/' -library-path='lib/' -debug=false -target-player='10.0.0' -default-size 633 300 -o='public/swf_editor.swf' src/SWFEditor.as -static-link-runtime-shared-libraries=true -use-network=false
	open public/index.html