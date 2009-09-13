Object subclass: GCMapper [
    | systemOrganizer packageName repoDir files |
    
    <category: 'Gitocello-Core'>
    <comment: 'I am used to file out a package to a repository. I do not care at all what kind of repository. 
''repoDir'' and ''packageName'' are the only options that should be set on me.
You can use my ''files'' field to find out which files I have filed out during my lifetime.

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
			|- Class1.st'>

    GCMapper class >> newFor: aPackage [
	<category: 'instance creation'>
	^(self basicNew)
	    packageName: aPackage;
	    initialize;
	    yourself
    ]

    createFolder: aSubfolder [
	<category: 'fileOut'>
	(File path: aSubfolder) exists 
	    ifFalse: [repoDir createDirectory: aSubfolder]
    ]

    fileOutCategory: aCategory [
	"This creates a sub-folder in the repository for the categories classes"

	<category: 'fileOut'>
	| subfolder |
	subfolder := (aCategory asString findBetweenSubStrs: '-') last.
	self createFolder: subfolder.
	(systemOrganizer superclassOrder: aCategory) 
	    do: [:each | self fileOutClass: each in: (repoDir / subfolder) name]
    ]

    fileOutClass: aClass in: aPath [
	"This files out the class in the according sub-folder"

	<category: 'fileOut'>
	| stream path |
	stream := WriteStream on: (String new: 100).
	aClass 
	    fileOutOn: stream
	    moveSource: false
	    toFile: 0.
	path := aPath , Directory pathSeparator asString , aClass name.
	self writeSourceCodeFrom: stream to: path
    ]

    fileOutExtensions: extensionMethods [
	"For each extended class collect the extension Methods and file them out"

	<category: 'fileOut'>
	| dict |
	self createFolder: 'Extensions'.
	dict := Dictionary new.
	extensionMethods do: 
		[:each | 
		dict at: each classSymbol ifAbsentPut: OrderedCollection new.
		(dict at: each classSymbol) add: each methodSymbol].
	dict keysDo: 
		[:key | 
		| stream file |
		stream := WriteStream on: (String new: 1000).
		file := (repoDir / 'Extensions') name , Directory pathSeparator asString 
			    , key asString.
		(dict at: key) do: 
			[:method | 
			(Smalltalk classNamed: key) 
			    printMethodChunk: method
			    withPreamble: true
			    on: stream
			    moveSource: false
			    toFile: 0].
		self writeSourceCodeFrom: stream to: file]
    ]

    fileOutPackage [
	"Files out the entire package into a folder structure"

	<category: 'fileOut'>
	| packageInfo |
	packageInfo := PackageInfo named: self packageName.
	packageInfo systemCategories 
	    do: [:category | self fileOutCategory: category].
	packageInfo extensionMethods 
	    ifNotEmpty: [self fileOutExtensions: packageInfo extensionMethods]
    ]

    writeSourceCodeFrom: aStream to: aFile [
	"This writes the source code and adds to files"

	<category: 'fileOut'>
	| converter f fileName |
	aStream contents isAsciiString 
	    ifTrue: [converter := MacRomanTextConverter new]
	    ifFalse: [converter := UTF8TextConverter new].
	fileName := aFile , ($. printString , ($s printString , $t printString)).
	f := MultiByteFileStream new open: fileName forWrite: true.
	f ifNil: [^self error: 'Cannot open file'].
	(converter isMemberOf: UTF8TextConverter) 
	    ifTrue: 
		[f binary.
		UTF8TextConverter writeBOMOn: f].
	f text.
	f converter: converter.
	f nextPutAll: aStream contents.
	f close.
	files add: fileName
    ]

    files [
	<category: 'accessing'>
	^files
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

    repoDir [
	<category: 'accessing'>
	^repoDir
    ]

    repoDir: aFileDirectory [
	<category: 'accessing'>
	aFileDirectory createDirectories.
	repoDir := aFileDirectory
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	files := Set new.
	systemOrganizer := Smalltalk organization
    ]
]

