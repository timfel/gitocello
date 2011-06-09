Object subclass: #GCRegistry
	instanceVariableNames: 'git'
	classVariableNames: 'Repositories RepositoryRoot'
	poolDictionaries: ''
	category: 'Gitocello-Core'!
!GCRegistry commentStamp: 'tfel 9/10/2009 11:56' prior: 0!
In my class I keep all the information on where to create/find git repositories in the file system (RepositoryRoot) and which Repositories have been created and how far they are along compared to their Monticello history.

My instance (of which there is only one) is used to create, remove and update repositories 
through the interface exposed in the 'commands' category.

I am well aware of the conversion to Gnu Smalltalk going on here, and I call the appropriate classes to do the conversion.!


!GCRegistry methodsFor: 'accessing' stamp: 'tfel 9/20/2009 13:01'!
at: aPackage

	^ self repositories at: aPackage! !

!GCRegistry methodsFor: 'accessing' stamp: 'tfel 9/7/2009 03:33'!
repositories

	^ Repositories! !


!GCRegistry methodsFor: 'commands' stamp: 'tfel 6/7/2011 15:08:37.292'!
commit: aPackage
	"This is part of the class interface - try not to break it"
	| lastCommit ancestors wc |
	lastCommit := (GCRegistry at: aPackage) lastCommit.
	wc := (MCPackage named: aPackage) workingCopy.
	lastCommit ifNil: [lastCommit := (ListChooser
				chooseItemFrom: wc ancestry breadthFirstAncestors
				title: 'Please choose how far back you want to load and commit packages for import')].
	lastCommit ifNil: [^ self].
	ancestors := (wc ancestry allAncestorsOnPathTo: lastCommit) reverse.
	SystemChangeNotifier uniqueInstance doSilently: [
	ancestors
		do: [:ancestor |
			(wc repositoryGroup versionWithInfo: ancestor)
				ifNil: [self inform: 'Cannot find a package for ', ancestor name, ' in the repositories.',
								Character cr asString, 'I am continuing with the next version, ',
								Character cr asString, 'and will combine the commit messages']
				ifNotNilDo: [:version |
							version load.
							self 
								createFilesFor: aPackage;
								run: #add
									in: aPackage asString
									with: #();
								run: #commit:
									in: aPackage asString
									with: (Array with: (self commitMessagesFor: aPackage)) ]]
		displayingProgress: [:ancestor | 'Commiting ', ancestor name]].
! !

!GCRegistry methodsFor: 'commands' stamp: 'tfel 9/20/2009 13:02'!
createRepositoryFor: aPackage
	"This will do everything in its power to commit that package to git!!"
	(Repositories includesKey: aPackage) ifFalse: [
		Repositories add: (aPackage -> (GCPackage newFor: aPackage)).
		self createFilesFor: aPackage.
		self run: #init in: aPackage asString].
	self commit: aPackage! !

!GCRegistry methodsFor: 'commands' stamp: 'tfel 4/25/2010 17:20:55.312'!
dumpImage
	"Dump all packages currently in the system"
	(SmalltalkImage current organization categories
	collect: [:c | c asString copyUpTo: $-]) asSet
		do: [:package | GCRegistry new createRepositoryFor: package].! !

!GCRegistry methodsFor: 'commands' stamp: 'TF 5/15/2010 17:59:51.201'!
pull: aPackage
	"This might be removed at some time in the future"
	self run: #pull in: aPackage asString! !

!GCRegistry methodsFor: 'commands' stamp: 'tfel 9/8/2009 20:17'!
push: aPackage
	"This might be removed at some time in the future"
	self run: #push in: aPackage asString! !

!GCRegistry methodsFor: 'commands' stamp: 'tfel 9/8/2009 20:27'!
removeRepositoryFor: aPackage
	"This will not touch the filesystem, only our registry"
	Repositories removeKey: aPackage ifAbsent: []! !


!GCRegistry methodsFor: 'monticello-helpers' stamp: 'tfel 5/19/2011 12:09:40.006'!
commitMessagesFor: aPackage
	"Creates a git-commit-msg from the non-commited Monticello versions"
	| messages ancestors |
	ancestors := ((MCPackage named: aPackage) 
		workingCopy ancestry breadthFirstAncestors 
			copyUpTo: (self at: aPackage) lastCommit).
	(ancestors size > 1 and: [self confirm: 'There are ', ancestors size, ' commits difference between the image and the Git repository. Should I commit all messages as one?'])
		ifTrue: [messages := self commitMessagesForAncestors: ancestors]
		ifFalse: [messages := self commitMessagesForAncestors:
				(ancestors ifEmpty: [{}] ifNotEmpty: [{ancestors at: 1}])].
	(self at: aPackage)
		lastCommit: ((MCPackage named: aPackage) workingCopy ancestry ancestors 
			ifEmpty: [nil]
			ifNotEmpty: [:o | o first]).
	^ self escapeForBash: messages contents
		! !

!GCRegistry methodsFor: 'monticello-helpers' stamp: 'tfel 6/9/2011 14:21:51.239'!
commitMessagesForAncestors: aCollection
	"Creates a git-commit-msg from the non-commited Monticello versions"
	| messages |
	messages := WriteStream on: (String new: 100).
	aCollection do: [:next | messages
								nextPutAll: self message;
								nextPutAll: self summaryHeader;
								cr; cr].
	^ messages contents
! !

!GCRegistry methodsFor: 'monticello-helpers' stamp: 'tfel 9/10/2009 09:41'!
escapeForBash: aString

	^ (((aString 
		replaceAll: Character cr with: Character lf)
		replaceAll: $!! with: $.)
		replaceAll: $" with: $')
		replaceAll: $$ with: $S
		! !

!GCRegistry methodsFor: 'monticello-helpers' stamp: 'TF 5/15/2010 18:01:54.402'!
storeVersion: aWorkingCopy

	| package |
	package := aWorkingCopy package name.
	self 
		pull: package;
		commit: package;
		push: package.
	! !


!GCRegistry methodsFor: 'fileOut' stamp: 'tfel 9/13/2009 11:56'!
createFilesFor: aPackage
	"Create and convert source to Gnu Smalltalk syntax. Als create a package.xml"
	| files |
	files := (GCMapper newFor: aPackage)
		repoDir: (RepositoryRoot directoryNamed: aPackage);
		fileOutPackage;
		files.
	files do: [:file | GCGstConvertCommand convert: file from: 'squeak' to: 'gst'].
	(GCGstPackageWriter newFor: aPackage)
		repoDir: (RepositoryRoot directoryNamed: aPackage);
		fileOutPackageXml! !


!GCRegistry methodsFor: 'initialize-release' stamp: 'tfel 9/7/2009 03:32'!
initialize

	super initialize.
	git := GCGitWrapper new! !


!GCRegistry methodsFor: 'helpers' stamp: 'tfel 9/8/2009 19:57'!
run: aGitCommand in: aPackage
	
	self run: aGitCommand in: aPackage with: (Array new: 0)
		! !

!GCRegistry methodsFor: 'helpers' stamp: 'tfel 9/8/2009 19:57'!
run: aGitCommand in: aPackage with: anArgumentsArray
	"Set the details we need and run"
	git 
		localPath: RepositoryRoot pathName, 
					FileDirectory pathNameDelimiter asString, 
					aPackage;
		perform: aGitCommand withArguments: anArgumentsArray
		! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GCRegistry class
	instanceVariableNames: 'instance'!

!GCRegistry class methodsFor: 'accessing' stamp: 'tfel 9/20/2009 13:20'!
at: aPackage

	^ self repositories at: aPackage! !


!GCRegistry class methodsFor: 'class initialization' stamp: 'tfel 9/7/2009 03:42'!
createDirectoryStructure: aString
	"Create the directory structure beneath the current image"
	| repoDir |
	repoDir := FileDirectory default.
	(aString findBetweenSubStrs: FileDirectory pathNameDelimiter asString)
		do: [:each |
			(repoDir directoryExists: each)
				ifFalse: [repoDir createDirectory: each].
			repoDir := repoDir directoryNamed: each].
	^ repoDir! !

!GCRegistry class methodsFor: 'class initialization' stamp: 'mh 5/10/2010 15:27'!
initialize
	
	super initialize.
	Smalltalk addToStartUpList: self. 
	self startUp.
	self instance: nil.! !

!GCRegistry class methodsFor: 'class initialization' stamp: 'tfel 9/9/2009 13:44'!
new
	"One global Registry is enough"
	^ self instance 
		ifNil: [instance := super new]
		ifNotNil: [instance]! !

!GCRegistry class methodsFor: 'class initialization' stamp: 'mh 5/10/2010 15:28'!
startUp

	self 
		repositoryRoot: 'package-cache', FileDirectory slash, 'git-repositories'.
	(self repositories keys copy do: [:each |
			(self repositoryRoot directoryNames includes: each)
				ifFalse: [Repositories removeKey: each]]).! !


!GCRegistry class methodsFor: 'error handling' stamp: 'tfel 9/9/2009 13:43'!
doesNotUnderstand: aMessage

	(self new respondsTo: aMessage selector)
		ifTrue: [^ self instance 
					perform: aMessage selector 
					withArguments: aMessage arguments].
	^ super doesNotUnderstand: aMessage! !


!GCRegistry class methodsFor: 'class variables' stamp: 'tfel 9/7/2009 03:31'!
instance
	
	^ instance! !

!GCRegistry class methodsFor: 'class variables' stamp: 'tfel 9/7/2009 03:31'!
instance: anObject
	
	instance := anObject! !

!GCRegistry class methodsFor: 'class variables' stamp: 'mh 5/10/2010 15:23'!
repositories

	Repositories ifNil: [Repositories := Dictionary new].
	^ Repositories ! !

!GCRegistry class methodsFor: 'class variables' stamp: 'tfel 9/7/2009 02:39'!
repositories: aDictionary

	Repositories := aDictionary! !

!GCRegistry class methodsFor: 'class variables' stamp: 'tfel 9/7/2009 03:09'!
repositoryRoot
	"Return the FileDirectory"
	^ RepositoryRoot! !

!GCRegistry class methodsFor: 'class variables' stamp: 'tfel 9/7/2009 03:12'!
repositoryRoot: aStringOrDirectory
	"Set the FileDirectory either directly or from String"
	RepositoryRoot := aStringOrDirectory isString 
		ifTrue: [self createDirectoryStructure: aStringOrDirectory]
		ifFalse: [self createDirectoryStructure: aStringOrDirectory pathName]
			! !

!GCRegistry class methodsFor: 'class variables' stamp: 'tfel 9/10/2009 09:27'!
tracksPackage: aPackageNameOrMCPackage

	^ (self repositories keys includes: aPackageNameOrMCPackage)
		or: [self repositories keys includes: aPackageNameOrMCPackage name]! !


GCRegistry initialize!
eOrMCPackage name]! !


GCRegistry initialize!
