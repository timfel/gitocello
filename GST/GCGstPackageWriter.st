Object subclass: GCGstPackageWriter [
    | packageName packageXmlStream newline repoDir |
    
    <category: 'Gitocello-GST'>
    <comment: 'I am very specific to GNU Smalltalk integration, as I write the package.xml file required to create GNU Smalltalk *.star format package files.
For now I honour dependencies as set in Monticello and simply file in all the classes in the package at once.
I will at some stage be able to properly handle test cases, which will make porting so much easier.'>

    GCGstPackageWriter class >> newFor: aPackage [
	<category: 'instance creation'>
	^(self new)
	    packageName: aPackage;
	    yourself
    ]

    requiredPackages [
	<category: 'information-retrieval'>
	^(MCPackage named: self packageName) workingCopy requiredPackages
    ]

    classFilePathFor: aClass [
	"Find the path to the classes fileOut"

	<category: 'stream-writing'>
	| subfolder |
	subfolder := (aClass category asString findBetweenSubStrs: '-') last.
	^subfolder , Directory pathSeparator asString , aClass name asString 
	    , $. printString , ($s printString , $t printString)
    ]

    classes [
	<category: 'stream-writing'>
	| packageInfo |
	packageInfo := PackageInfo named: self packageName.
	^(packageInfo classes asSet)
	    addAll: packageInfo extensionClasses;
	    yourself
    ]

    createPackageXml [
	<category: 'stream-writing'>
	self packageXmlStream reset.
	self
	    preamble;
	    requires;
	    tests;
	    fileIns;
	    files.
	self packageXmlStream nextPutAll: self postfix
    ]

    fileIn: aClass [
	<category: 'stream-writing'>
	self putAttribute: 'filein' with: (self classFilePathFor: aClass)
    ]

    fileIns [
	<category: 'stream-writing'>
	self classes reject: [:class | class allSuperclasses includes: TestCase]
	    thenDo: [:class | self fileIn: class]
    ]

    files [
	<category: 'stream-writing'>
	self classes 
	    do: [:class | self putAttribute: 'file' with: (self classFilePathFor: class)]
    ]

    preamble [
	<category: 'stream-writing'>
	
	{'<package>'.
	'<!-- THIS FILE IS GENERATED! EDITS _WILL_ BE LOST ON UPDATE! -->'.
	''} 
		do: [:s | self packageXmlStream nextPutAll: s]
		separatedBy: [self packageXmlStream nextPut: newline].
	self
	    putAttribute: 'name' with: self packageName;
	    putAttribute: 'namespace' with: self packageName
    ]

    putAttribute: anXmlAttribute with: someContent [
	<category: 'stream-writing'>
	(self packageXmlStream)
	    nextPutAll: '<' , anXmlAttribute , '>';
	    nextPutAll: someContent;
	    nextPutAll: '</' , anXmlAttribute , '>';
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

    requires [
	<category: 'stream-writing'>
	self requiredPackages do: [:pkg | self require: pkg]
    ]

    tests [
	"Prepare the tests for usage with Gnu Smalltalk"

	<category: 'stream-writing'>
	| testClasses testCases |
	testClasses := self classes 
		    select: [:class | class allSuperclasses includes: TestCase].
	testCases := testClasses inject: String new
		    into: [:s :class | s , self packageName , '.' , class name asString , newline asString].
	self packageXmlStream nextPutAll: '<test>' , newline asString.
	testClasses do: [:class | self fileIn: class].
	self putAttribute: 'sunit' with: testCases.
	self packageXmlStream nextPutAll: '</test>' , newline asString
    ]

    fileOutPackageXml [
	<category: 'fileOut'>
	| fileName converter file |
	self createPackageXml.
	self packageXmlStream contents isAsciiString 
	    ifTrue: [converter := MacRomanTextConverter new]
	    ifFalse: [converter := UTF8TextConverter new].
	fileName := self repoDir , Directory pathSeparator asString 
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
	    ifFalse: [repoDir := aDirectory name]
    ]

    postfix [
	<category: 'literals'>
	^'</package>'
    ]
]

