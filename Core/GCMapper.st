Object subclass: #GCMapper
	instanceVariableNames: 'systemOrganizer packageName repoDir files'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gitocello-Core'!
!GCMapper commentStamp: 'tfel 9/10/2009 11:56' prior: 0!
I am used to file out a package to a repository. I do not care at all what kind of repository. 
'repoDir' and 'packageName' are the only options that should be set on me.
You can use my 'files' field to find out which files I have filed out during my lifetime.

I just map packages and classes to files. Like so:
The packages and classes
		Package (Class1)
		Package-Core (Class2)
		Package-Base (Class3, Class4)
become
		Package/
			|- Core/
				|- Class2.st
			|- Base/
				|- Class3.st
				|- Class4.st
			|- Class1.st!


!GCMapper methodsFor: 'fileOut' stamp: 'tfel 9/7/2009 20:27'!
createFolder: aSubfolder

	(repoDir directoryExists: aSubfolder)
		ifFalse: [repoDir createDirectory: aSubfolder]! !

!GCMapper methodsFor: 'fileOut' stamp: 'tfel 9/7/2009 20:26'!
fileOutCategory: aCategory
	"This creates a sub-folder in the repository for the categories classes"
	| subfolder |
	subfolder := (aCategory asString findBetweenSubStrs: '-') last.
	self createFolder: subfolder.
	(systemOrganizer superclassOrder: aCategory) do: [:each | 
		self 
			fileOutClass: each 
			in: (repoDir directoryNamed: subfolder) pathName]! !

!GCMapper methodsFor: 'fileOut' stamp: 'tfel 9/10/2009 11:53'!
fileOutClass: aClass in: aPath
	"This files out the class in the according sub-folder"
	| stream path |
	stream := WriteStream on: (String new: 100).
	aClass fileOutOn: stream moveSource: false toFile: 0.
	path := (aPath, FileDirectory pathNameDelimiter asString, aClass name).
	self writeSourceCodeFrom: stream to: path! !

!GCMapper methodsFor: 'fileOut' stamp: 'tfel 9/10/2009 10:28'!
fileOutExtensions: extensionMethods
	"For each extended class collect the extension Methods and file them out"
	| dict |
	self createFolder: 'Extensions'.
	dict := Dictionary new.
	extensionMethods do: [:each | 
		dict at: each classSymbol ifAbsentPut: OrderedCollection new.
		(dict at: each classSymbol) add: each methodSymbol].
	dict keysDo: [:key || stream file |
		stream := WriteStream on: (String new: 1000).
		file := (repoDir directoryNamed: 'Extensions') pathName, 
				FileDirectory pathNameDelimiter asString, 
				key asString.
		(dict at: key) do: [:method |
			(Smalltalk classNamed: key) 
				printMethodChunk: method withPreamble: true
				on: stream moveSource: false toFile: 0].
		self writeSourceCodeFrom: stream to: file]! !

!GCMapper methodsFor: 'fileOut' stamp: 'tfel 9/10/2009 11:55'!
fileOutPackage
	"Files out the entire package into a folder structure"
	| packageInfo |
	packageInfo := PackageInfo named: self packageName.
	packageInfo systemCategories do: [:category | self fileOutCategory: category].
	packageInfo extensionMethods 
		ifNotEmpty: [self fileOutExtensions: packageInfo extensionMethods].
	! !

!GCMapper methodsFor: 'fileOut' stamp: 'tfel 1/8/2012 14:52'!
writeSourceCodeFrom: aStream to: aFile
	"This writes the source code and adds to files"
	| converter f fileName |
	aStream contents isAsciiString 
		ifTrue: [converter := MacRomanTextConverter new]
		ifFalse: [converter := UTF8TextConverter new].
	fileName := aFile, (FileDirectory dot, 'st').
	f := MultiByteFileStream new open: fileName forWrite: true.
	f ifNil: [^ self error: 'Cannot open file'].
	f lineEndConvention: #lf.
	(converter isMemberOf: UTF8TextConverter)
		ifTrue: [f binary.
			UTF8TextConverter writeBOMOn: f].
	f text.
	f converter: converter.
	f nextPutAll: aStream contents.
	f close.
	files add: fileName! !


!GCMapper methodsFor: 'accessing' stamp: 'tfel 9/10/2009 11:54'!
files

	^ files! !

!GCMapper methodsFor: 'accessing' stamp: 'tfel 9/6/2009 20:33'!
packageName
	"Answer the value of packageName"

	^ packageName! !

!GCMapper methodsFor: 'accessing' stamp: 'tfel 9/6/2009 20:33'!
packageName: anObject
	"Set the value of packageName"

	packageName := anObject! !

!GCMapper methodsFor: 'accessing' stamp: 'tfel 9/7/2009 02:29'!
repoDir

	^ repoDir! !

!GCMapper methodsFor: 'accessing' stamp: 'tfel 9/13/2009 10:03'!
repoDir: aFileDirectory

	aFileDirectory assureExistence.
	repoDir := aFileDirectory! !


!GCMapper methodsFor: 'initialize-release' stamp: 'tfel 9/10/2009 11:55'!
initialize

	super initialize.
	files := Set new.
	systemOrganizer := Smalltalk organization! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GCMapper class
	instanceVariableNames: ''!

!GCMapper class methodsFor: 'instance creation' stamp: 'tfel 9/6/2009 20:49'!
newFor: aPackage

	^ self basicNew
		packageName: aPackage;
		initialize;
		yourself! !
self! !
