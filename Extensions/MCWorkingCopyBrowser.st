MCWorkingCopyBrowser extend [

    saveVersion [
	<category: '*gitocello'>
	| repo |
	self canSave ifFalse: [^self].
	self checkForNewerVersions ifFalse: [^self].
	repo := self repository.
	workingCopy newVersion ifNotNil: 
		[:v | 
		(MCVersionInspector new version: v) show.
		Cursor wait showWhile: [repo storeVersion: v].
		MCCacheRepository default cacheAllFileNamesDuring: 
			[repo cacheAllFileNamesDuring: 
				[v allAvailableDependenciesDo: 
					[:dep | 
					(repo includesVersionNamed: dep info name) 
					    ifFalse: [repo storeVersion: dep]]]].
		(GCRegistry tracksPackage: workingCopy package name) 
		    ifTrue: [GCRegistry commit: workingCopy package name]]
    ]

    trackWithGit [
	<category: '*gitocello'>
	GCRegistry createRepositoryFor: workingCopy package name
    ]

    untrackWithGit [
	<category: '*gitocello'>
	GCRegistry removeRepositoryFor: workingCopy package name
    ]

    workingCopyListMenu: aMenu [
	<category: '*gitocello'>
	workingCopy ifNil: [^aMenu].
	self fillMenu: aMenu
	    fromSpecs: #(#('add required package' #addRequiredPackage) #('clear required packages' #clearRequiredPackages) #('browse package' #browseWorkingCopy) #('view changes' #viewChanges) #('view history' #viewHistory) #('recompile package' #recompilePackage) #('revert package...' #revertPackage) #('unload package' #unloadPackage) #('delete working copy' #deleteWorkingCopy)).
	(Smalltalk includesKey: #SARMCPackageDumper) 
	    ifTrue: 
		[aMenu 
		    add: 'make SAR'
		    target: self
		    selector: #fileOutAsSAR].
	(GCRegistry tracksPackage: workingCopy package) 
	    ifFalse: 
		[aMenu 
		    add: 'track with Git'
		    target: self
		    selector: #trackWithGit]
	    ifTrue: 
		[aMenu 
		    add: 'untrack with Git'
		    target: self
		    selector: #untrackWithGit].
	^aMenu
    ]

]

