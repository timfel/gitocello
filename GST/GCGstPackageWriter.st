Object subclass: GCGstPackageWriter [
    | packageName packageXmlStream newline repoDir |
    
    <category: 'Gitocello-GST'>
    <comment: 'I am very specific to GNU Smalltalk integration, as I write the package.xml file required to create GNU Smalltalk *.star format package files.For now I honour dependencies as set in Monticello and simply file in all the classes in the package at once.I will at some stage be able to properly handle test cases, which will make porting so much easier.'>

    GCGstPackageWriter class >> newFor: aPackage [
	<category: 'instance creation'>
	^(self new)
	    packageName: aPackage;
	    yourself
    ]

    classes [
	<category: 'information-retrieval'>
	| system |
	system := Smalltalk organization.
	^((system categoriesMatching: self packageName) 
	    union: (system categoriesMatching: self packageName , '-*')) 
		inject: OrderedCollection new
		into: [:list :next | list addAll: (system superclassOrder: next)]
    ]

    requiredPackages [
	<category: 'information-retrieval'>
	^(MCPackage named: self packageName) workingCopy requiredPackages
    ]

    createPackageXml [
	<category: 'stream-writing'>
	(self packageXmlStream)
	    reset;
	    nextPutAll: self preamble.
	self requiredPackages do: [:pkg | self require: pkg].
	"self testing."
	self classes do: [:class | self fileIn: class].
	self packageXmlStream nextPutAll: self postfix
    ]

    fileIn: aClass [
	"Create the filein for this particular class in the conventional subfolder"

	<category: 'stream-writing'>
	| subfolder filepath |
	subfolder := (aClass category asString findBetweenSubStrs: '-') last.
	filepath := subfolder , FileDirectory pathNameDelimiter asString 
		    , aClass name asString , '.st'.
	self
	    putAttribute: 'filein' with: filepath;
	    putAttribute: 'file' with: filepath
    ]

    putAttribute: anXmlAttribute with: someContent [
	<category: 'stream-writing'>
	(self packageXmlStream)
	    nextPut: $<;
	    nextPutAll: anXmlAttribute;
	    nextPut: $>;
	    nextPutAll: someContent;
	    nextPutAll: '</';
	    nextPutAll: anXmlAttribute;
	    nextPut: $>;
	    nextPut: newline
    ]

    require: aPackage [
	<category: 'stream-writing'>
	(self packageXmlStream)
	    nextPutAll: '<prereq>';
	    nextPutAll: aPackage;
	    nextPutAll: '</prereq>';
	    nextPut: newline
    ]

    fileOutPackageXml [
	<category: 'fileOut'>
	| fileName converter file |
	self createPackageXml.
	self packageXmlStream contents isAsciiString 
	    ifTrue: [converter := MacRomanTextConverter new]
	    ifFalse: [converter := UTF8TextConverter new].
	fileName := self repoDir , FileDirectory pathNameDelimiter asString 
		    , 'package.xml'.
	file := MultiByteFileStream new open: fileName forWrite: true.
	file ifNil: [self error: 'Cannot open file'].
	file
	    text;
	    converter: converter;
	    nextPutAll: packageXmlStream contents;
	    close
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	newline := Character lf.	"This should be configurable"
	self packageXmlStream: (WriteStream on: (String new: 100))
    ]

    newline [
	"Answer the value of newline"

	<category: 'accessing'>
	^newline
    ]

    newline: anObject [
	"Set the value of newline"

	<category: 'accessing'>
	newline := anObject
    ]

    packageName [
	"Answer the value of packageName"

	<category: 'accessing'>
	^packageName
    ]

    packageName: anObject [
	"Set the value of packageName"

	<category: 'accessing'>
	packageName := anObject
    ]

    packageXmlStream [
	"Answer the value of packageXmlStream"

	<category: 'accessing'>
	^packageXmlStream
    ]

    packageXmlStream: anObject [
	"Set the value of packageXmlStream"

	<category: 'accessing'>
	packageXmlStream := anObject
    ]

    repoDir [
	"Answer the value of repoDir"

	<category: 'accessing'>
	^repoDir
    ]

    repoDir: aDirectory [
	"Set the value of repoDir"

	<category: 'accessing'>
	aDirectory isString 
	    ifTrue: [repoDir := aDirectory]
	    ifFalse: [repoDir := aDirectory pathName]
    ]

    postfix [
	<category: 'literals'>
	^'</package>'
    ]

    preamble [
	<category: 'literals'>
	^'<package>' , newline asString 
	    , '<!-- THIS FILE IS AUTO-GENERATED! EDITS _WILL_ BE LOST ON UPDATE!! --!>' 
		, newline asString , '<name>' 
	    , self packageName , '</name>' 
	    , newline asString , '<namespace>' 
	    , self packageName , '</namespace>' 
	    , newline asString
    ]
]

