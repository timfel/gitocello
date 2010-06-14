
!MCWorkingCopyBrowser methodsFor: '*gitocello-actions-override' stamp: 'TF 5/15/2010 18:00:57.1'!
saveVersion
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
		(GCRegistry tracksPackage: workingCopy package)
			ifTrue: [GCRegistry storeVersion: workingCopy].
		].! !

!MCWorkingCopyBrowser methodsFor: '*gitocello' stamp: 'tfel 9/10/2009 09:20'!
trackWithGit

	GCRegistry createRepositoryFor: workingCopy package name! !

!MCWorkingCopyBrowser methodsFor: '*gitocello' stamp: 'tfel 9/10/2009 09:24'!
untrackWithGit

	GCRegistry removeRepositoryFor: workingCopy package name! !

!MCWorkingCopyBrowser methodsFor: '*gitocello-morphic ui-override' stamp: 'tfel 9/10/2009 09:27'!
workingCopyListMenu: aMenu
	workingCopy ifNil: [^ aMenu].
	self fillMenu: aMenu fromSpecs:
		#(('add required package' #addRequiredPackage)
			('clear required packages' #clearRequiredPackages)
			('browse package' #browseWorkingCopy)
			('view changes' #viewChanges)
			('view history' #viewHistory)
			('recompile package' #recompilePackage)
			('revert package...' #revertPackage)
			('unload package' #unloadPackage)
			('delete working copy' #deleteWorkingCopy)).
	(Smalltalk includesKey: #SARMCPackageDumper) ifTrue: [
		aMenu add: 'make SAR' target: self selector: #fileOutAsSAR
	].
	(GCRegistry tracksPackage: workingCopy package)
		ifFalse: [aMenu add: 'track with Git' target: self selector: #trackWithGit]
		ifTrue: [aMenu add: 'untrack with Git' target: self selector: #untrackWithGit].
	^aMenu! !
