Object subclass: GCRegistry [
    | git |
    
    <category: 'Gitocello-Core'>
    <comment: 'In my class I keep all the information on where to create/find git repositories in the file system (RepositoryRoot) and which Repositories have been created and how far they are along compared to their Monticello history.

My instance (of which there is only one) is used to create, remove and update repositories 
through the interface exposed in the ''commands'' category.

I am well aware of the conversion to Gnu Smalltalk going on here, and I call the appropriate classes to do the conversion.'>

    GCRegistry class [
	| instance |
	
    ]

    Repositories := nil.
    RepositoryRoot := nil.

    GCRegistry class >> at: aPackage [
	<category: 'accessing'>
	^self repositories at: aPackage
    ]

    GCRegistry class >> createDirectoryStructure: aString [
	"Create the directory structure beneath the current image"

	<category: 'class initialization'>
	| repoDir |
	repoDir := Directory working.
	(aString findBetweenSubStrs: Directory pathSeparator asString) do: 
		[:each | 
		(File path: each) exists ifFalse: [repoDir createDirectory: each].
		repoDir := repoDir / each].
	^repoDir
    ]

    GCRegistry class >> initialize [
	<category: 'class initialization'>
	super initialize.
	Smalltalk addToStartUpList: self.
	self startUp.
	self instance: nil
    ]

    GCRegistry class >> new [
	"One global Registry is enough"

	<category: 'class initialization'>
	^self instance ifNil: [instance := super new] ifNotNil: [:foo | instance]
    ]

    GCRegistry class >> startUp [
	<category: 'class initialization'>
	self 
	    repositoryRoot: 'package-cache' , FileDirectory slash , 'git-repositories'.
	self repositories keys copy do: 
		[:each | 
		(self repositoryRoot directoryNames includes: each) 
		    ifFalse: [Repositories removeKey: each]]
    ]

    GCRegistry class >> doesNotUnderstand: aMessage [
	<category: 'error handling'>
	(self new respondsTo: aMessage selector) 
	    ifTrue: 
		[^self instance perform: aMessage selector withArguments: aMessage arguments].
	^super doesNotUnderstand: aMessage
    ]

    GCRegistry class >> instance [
	<category: 'class variables'>
	^instance
    ]

    GCRegistry class >> instance: anObject [
	<category: 'class variables'>
	instance := anObject
    ]

    GCRegistry class >> repositories [
	<category: 'class variables'>
	Repositories ifNil: [Repositories := Dictionary new].
	^Repositories
    ]

    GCRegistry class >> repositories: aDictionary [
	<category: 'class variables'>
	Repositories := aDictionary
    ]

    GCRegistry class >> repositoryRoot [
	"Return the FileDirectory"

	<category: 'class variables'>
	^RepositoryRoot
    ]

    GCRegistry class >> repositoryRoot: aStringOrDirectory [
	"Set the FileDirectory either directly or from String"

	<category: 'class variables'>
	RepositoryRoot := aStringOrDirectory isString 
		    ifTrue: [self createDirectoryStructure: aStringOrDirectory]
		    ifFalse: [self createDirectoryStructure: aStringOrDirectory name]
    ]

    GCRegistry class >> tracksPackage: aPackageNameOrMCPackage [
	<category: 'class variables'>
	^(self repositories keys includes: aPackageNameOrMCPackage) 
	    or: [self repositories keys includes: aPackageNameOrMCPackage name]
    ]

    at: aPackage [
	<category: 'accessing'>
	^self repositories at: aPackage
    ]

    repositories [
	<category: 'accessing'>
	^Repositories
    ]

    commit: aPackage [
	"This is part of the class interface - try not to break it"

	<category: 'commands'>
	self
	    createFilesFor: aPackage;
	    run: #add
		in: aPackage asString
		with: #();
	    run: #commit:
		in: aPackage asString
		with: (Array with: (self commitMessagesFor: aPackage))
    ]

    createRepositoryFor: aPackage [
	"This will do everything in its power to commit that package to git!!"

	<category: 'commands'>
	(Repositories includesKey: aPackage) 
	    ifFalse: 
		[Repositories add: aPackage -> (GCPackage newFor: aPackage).
		self createFilesFor: aPackage.
		self run: #init in: aPackage asString].
	self commit: aPackage
    ]

    dumpImage [
	"Dump all packages currently in the system"

	<category: 'commands'>
	(SmalltalkImage current organization categories 
	    collect: [:c | c asString copyUpTo: $-]) asSet 
	    do: [:package | GCRegistry new createRepositoryFor: package]
    ]

    pull: aPackage [
	"This might be removed at some time in the future"

	<category: 'commands'>
	self run: #pull in: aPackage asString
    ]

    push: aPackage [
	"This might be removed at some time in the future"

	<category: 'commands'>
	self run: #push in: aPackage asString
    ]

    removeRepositoryFor: aPackage [
	"This will not touch the filesystem, only our registry"

	<category: 'commands'>
	Repositories removeKey: aPackage ifAbsent: []
    ]

    commitMessagesFor: aPackage [
	"Creates a git-commit-msg from the non-commited Monticello versions"

	<category: 'monticello-helpers'>
	| cr messages |
	cr := Character lf asString.
	messages := WriteStream on: (String new: 100).
	((MCPackage named: aPackage) workingCopy ancestry breadthFirstAncestors 
	    copyUpTo: (self at: aPackage) lastCommit) do: 
		    [:next | 
		    messages 
			nextPutAll: cr , cr , next date asString , ': ' , next author 
				, ' from Squeak: ' , next message].
	(self at: aPackage) 
	    lastCommit: ((MCPackage named: aPackage) workingCopy ancestry ancestors 
		    ifEmpty: [nil]
		    ifNotEmpty: [:o | o first]).
	^self escapeForBash: messages contents
    ]

    escapeForBash: aString [
	<category: 'monticello-helpers'>
	^(((aString replaceAll: Character cr with: Character lf) replaceAll: $!
	    with: $.) replaceAll: $" with: $') 
	    replaceAll: $$
	    with: $S
    ]

    storeVersion: aWorkingCopy [
	<category: 'monticello-helpers'>
	| package |
	package := aWorkingCopy package name.
	self
	    pull: package;
	    commit: package;
	    push: package
    ]

    createFilesFor: aPackage [
	<category: 'fileOut'>
	| files pkg |
	pkg := aPackage isString ifTrue: [self at: aPackage] ifFalse: [aPackage].
	files := (GCMapper newFor: pkg)
		    repoDir: RepositoryRoot / pkg packageName;
		    fileOutPackage;
		    files.
	files do: 
		[:file | 
		GCGstConvertCommand 
		    convert: file
		    from: 'squeak'
		    to: 'gst'].
	(GCGstPackageWriter newFor: pkg)
	    repoDir: RepositoryRoot / pkg packageName;
	    fileOutPackageXml
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	git := GCGitWrapper new
    ]

    run: aGitCommand in: aPackage [
	<category: 'helpers'>
	self 
	    run: aGitCommand
	    in: aPackage
	    with: (Array new: 0)
    ]

    run: aGitCommand in: aPackage with: anArgumentsArray [
	"Set the details we need and run"

	<category: 'helpers'>
	git
	    localPath: RepositoryRoot name , Directory pathSeparator asString 
			, aPackage;
	    perform: aGitCommand withArguments: anArgumentsArray
    ]
]



Eval [
    GCRegistry initialize
]

