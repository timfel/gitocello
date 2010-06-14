Object subclass: #GCGstPackageWriter
	instanceVariableNames: 'packageName packageXmlStream newline repoDir'
	classVariableNames: 'WritePackageXml'
	poolDictionaries: ''
	category: 'Gitocello-GST'!
!GCGstPackageWriter commentStamp: 'tfel 9/8/2009 20:24' prior: 0!
I am very specific to GNU Smalltalk integration, as I write the package.xml file required to create GNU Smalltalk *.star format package files.
For now I honour dependencies as set in Monticello and simply file in all the classes in the package at once.
I will at some stage be able to properly handle test cases, which will make porting so much easier.!


!GCGstPackageWriter methodsFor: 'stream-writing' stamp: 'tfel 4/25/2010 17:13:51.474'!
classFilePathFor: aClass
	"Find the path to the classes fileOut"
	| subfolder |
	subfolder := (aClass theNonMetaClass category asString findBetweenSubStrs: '-') last.
	^ subfolder, FileDirectory pathNameDelimiter asString, 
		aClass name asString, FileDirectory dot, FileStream st! !

!GCGstPackageWriter methodsFor: 'stream-writing' stamp: 'tfel 9/20/2009 13:07'!
classes

	^ (GCRegistry at: self packageName) packageClasses! !

!GCGstPackageWriter methodsFor: 'stream-writing' stamp: 'tfel 9/10/2009 14:14'!
createPackageXml

	self packageXmlStream reset.
	self 
		preamble;
		requires;
		tests;
		fileIns;
		files.
	self packageXmlStream nextPutAll: self postfix! !

!GCGstPackageWriter methodsFor: 'stream-writing' stamp: 'tfel 9/10/2009 14:17'!
fileIn: aClass

	self putAttribute: 'filein' with: (self classFilePathFor: aClass)! !

!GCGstPackageWriter methodsFor: 'stream-writing' stamp: 'tfel 9/10/2009 14:17'!
fileIns

	self classes 
		reject: [:class | class allSuperclasses includes: TestCase]
		thenDo: [:class | self fileIn: class]! !

!GCGstPackageWriter methodsFor: 'stream-writing' stamp: 'tfel 9/10/2009 14:15'!
files

	self classes do: [:class | 
		self 
			putAttribute: 'file' 
			with: (self classFilePathFor: class)
	]! !

!GCGstPackageWriter methodsFor: 'stream-writing' stamp: 'tfel 9/10/2009 14:32'!
preamble

	{'<package>' . '<!!-- THIS FILE IS GENERATED!! EDITS _WILL_ BE LOST ON UPDATE!! -->'. ''}
		do: [:s | self packageXmlStream nextPutAll: s]
		separatedBy: [self packageXmlStream nextPut: newline].
	self 
		putAttribute: 'name' with: self packageName;
		putAttribute: 'namespace' with: self packageName.! !

!GCGstPackageWriter methodsFor: 'stream-writing' stamp: 'tfel 9/10/2009 13:58'!
putAttribute: anXmlAttribute with: someContent

	self packageXmlStream
		nextPutAll: '<', anXmlAttribute, '>';
		nextPutAll: someContent;
		nextPutAll: '</', anXmlAttribute, '>';
		nextPut: newline
		! !

!GCGstPackageWriter methodsFor: 'stream-writing' stamp: 'tfel 9/7/2009 20:58'!
require: aPackage

	self packageXmlStream
		nextPutAll: '<prereq>';
		nextPutAll: aPackage;
		nextPutAll: '</prereq>';
		nextPut: newline! !

!GCGstPackageWriter methodsFor: 'stream-writing' stamp: 'tfel 9/10/2009 13:44'!
requires

	self requiredPackages do: [:pkg | self require: pkg]! !

!GCGstPackageWriter methodsFor: 'stream-writing' stamp: 'tfel 9/14/2009 00:58'!
tests
	"Prepare the tests for usage with Gnu Smalltalk"
	| testClasses testCases |
	testClasses := self classes select: [:class | class allSuperclasses includes: TestCase].
	testCases := testClasses inject: String new into: [:s :class |
		s, self packageName, '.', class name asString, newline asString].
	self packageXmlStream nextPutAll: '<test>', newline asString.
	testClasses do: [:class | self fileIn: class].
	self putAttribute: 'sunit' with: testCases.
	self packageXmlStream nextPutAll: '</test>', newline asString.! !


!GCGstPackageWriter methodsFor: 'fileOut' stamp: 'tfel 6/14/2010 16:05'!
fileOutPackageXml

	| fileName converter file |
	self class writePackageXml ifTrue: [
		self createPackageXml.
		self packageXmlStream contents isAsciiString 
			ifTrue: [converter := MacRomanTextConverter new]
			ifFalse: [converter := UTF8TextConverter new].
		fileName := self repoDir, FileDirectory pathNameDelimiter asString, 'package.xml'.
		FileDirectory deleteFilePath: fileName.
		file := MultiByteFileStream new open: fileName forWrite: true.
		file 	ifNil: [self error: 'Cannot open file'].
		file text;
			converter: converter;
			nextPutAll: packageXmlStream contents;
			close].! !


!GCGstPackageWriter methodsFor: 'initialize-release' stamp: 'tfel 9/7/2009 21:32'!
initialize

	super initialize.
	newline := Character lf. "This should be configurable"
	self packageXmlStream: (WriteStream on: (String new: 100))! !


!GCGstPackageWriter methodsFor: 'accessing' stamp: 'tfel 9/7/2009 21:25'!
newline
	"Answer the value of newline"

	^ newline! !

!GCGstPackageWriter methodsFor: 'accessing' stamp: 'tfel 9/7/2009 21:25'!
newline: anObject
	"Set the value of newline"

	newline := anObject! !

!GCGstPackageWriter methodsFor: 'accessing' stamp: 'tfel 9/7/2009 20:47'!
packageName
	"Answer the value of packageName"

	^ packageName! !

!GCGstPackageWriter methodsFor: 'accessing' stamp: 'tfel 9/7/2009 20:47'!
packageName: anObject
	"Set the value of packageName"

	packageName := anObject! !

!GCGstPackageWriter methodsFor: 'accessing' stamp: 'tfel 9/7/2009 20:47'!
packageXmlStream
	"Answer the value of packageXmlStream"

	^ packageXmlStream! !

!GCGstPackageWriter methodsFor: 'accessing' stamp: 'tfel 9/7/2009 20:47'!
packageXmlStream: anObject
	"Set the value of packageXmlStream"

	packageXmlStream := anObject! !

!GCGstPackageWriter methodsFor: 'accessing' stamp: 'tfel 9/7/2009 21:25'!
repoDir
	"Answer the value of repoDir"

	^ repoDir! !

!GCGstPackageWriter methodsFor: 'accessing' stamp: 'tfel 9/7/2009 21:28'!
repoDir: aDirectory
	"Set the value of repoDir"

	aDirectory isString
		ifTrue: [repoDir := aDirectory]
		ifFalse: [repoDir := aDirectory pathName]! !


!GCGstPackageWriter methodsFor: 'literals' stamp: 'tfel 9/7/2009 20:55'!
postfix

	^ '</package>'! !


!GCGstPackageWriter methodsFor: 'information-retrieval' stamp: 'tfel 9/7/2009 20:36'!
requiredPackages

	^ (MCPackage named: self packageName) workingCopy requiredPackages! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GCGstPackageWriter class
	instanceVariableNames: ''!

!GCGstPackageWriter class methodsFor: 'preferences' stamp: 'tfel 6/14/2010 15:42'!
writePackageXml

	<preference: 'Write Gnu Smalltalk package.xml files '
		category: 'Gitocello'
		description: ''
		type: #Boolean>
	^ WritePackageXml ifNil: [WritePackageXml := false]
! !

!GCGstPackageWriter class methodsFor: 'preferences' stamp: 'tfel 6/14/2010 15:42'!
writePackageXml: aBoolean

	WritePackageXml := aBoolean
! !


!GCGstPackageWriter class methodsFor: 'instance creation' stamp: 'tfel 4/25/2010 16:52:37.173'!
newFor: aPackage

	^ self new
		packageName: aPackage;
		yourself! !
