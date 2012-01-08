StringHolder subclass: #GCRepositoryBrowser
	instanceVariableNames: 'repositoryIndex selectedClassIndex classList selectedClasses'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gitocello-Morphic'!

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 1/8/2012 11:21'!
classList

	classList ifNil: [
		classList := GCRegistry repositories
			ifEmpty: [#()]
			ifNotEmpty: [(GCRegistry at: self selectedRepository) classes]].
	^ classList! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 15:02'!
classList: anObject
	"Set the value of classList"

	classList := anObject! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 14:01'!
repositoryIndex
	"Answer the value of repositoryIndex"

	^ repositoryIndex! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 14:45'!
repositoryIndex: anObject
	"Set the value of repositoryIndex"

	repositoryIndex := anObject.
	classList := nil! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 14:03'!
repositoryList

	^ GCRegistry repositories keys asOrderedCollection! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 10/2/2009 21:35'!
repositoryRoot

	^ GCRegistry repositoryRoot pathName! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 1/8/2012 11:20'!
repositoryRoot: aString

	^ [GCRegistry repositoryRoot: aString. true] on: Error do: [false]! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 14:51'!
selectedClassIndex
	"Answer the value of selectedClassIndex"

	^ selectedClassIndex! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 14:51'!
selectedClassIndex: anObject
	"Set the value of selectedClassIndex"

	selectedClassIndex := anObject! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 15:02'!
selectedClasses
	"Answer the value of selectedClasses"

	^ selectedClasses! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 15:02'!
selectedClasses: anObject
	"Set the value of selectedClasses"

	selectedClasses := anObject! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 14:58'!
selectedClassesAt: anIndex

	^ selectedClasses at: anIndex! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 15:16'!
selectedClassesAt: anIndex put: aValue

	selectedClasses at: anIndex put: (aValue = true).
	self 
		changed: #selectedClassIndex;
		updatePackageClasses! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 14:10'!
selectedRepository

	^ self repositoryList at: self repositoryIndex! !



!GCRepositoryBrowser methodsFor: 'toolbuilder' stamp: 'tfel 1/8/2012 11:13'!
buildClassListWith: builder

	^ builder pluggableMultiSelectionListSpec new
		model: self;
		list: #classList; 
		getIndex: #selectedClassIndex; 
		setIndex: #selectedClassIndex:;
		getSelectionList: #selectedClassesAt:;
		setSelectionList: #selectedClassesAt:put:;
		yourself! !

!GCRepositoryBrowser methodsFor: 'toolbuilder' stamp: 'tfel 1/8/2012 11:12'!
buildRepositoryListWith: builder

	^ builder pluggableListSpec new
		model: self;
		list: #repositoryList; 
		getIndex: #repositoryIndex; 
		setIndex: #repositoryIndex:;
		yourself! !

!GCRepositoryBrowser methodsFor: 'toolbuilder' stamp: 'tfel 1/8/2012 11:12'!
buildRepositoryPathButtonWith: builder

	^ builder pluggableButtonSpec new
		model: self;
		label: self fileOutButtonString;
		action: #fileOut;
		yourself
! !

!GCRepositoryBrowser methodsFor: 'toolbuilder' stamp: 'tfel 1/8/2012 11:20'!
buildRepositoryPathPaneWith: builder

	^ builder pluggableInputFieldSpec new
		model: self;
		getText: #repositoryRoot; 
		setText: #repositoryRoot:;
		yourself
! !

!GCRepositoryBrowser methodsFor: 'toolbuilder' stamp: 'tfel 1/8/2012 11:24'!
buildWith: builder
	| windowSpec |
	windowSpec := self buildWindowWith: builder specs: {
		(0@0 corner: 0.8@0.1) -> [self buildRepositoryPathPaneWith: builder].
		(0.8@0 corner: 1@0.1) -> [self buildRepositoryPathButtonWith: builder].
		(0@0.1 corner: 0.5@1) -> [self buildRepositoryListWith: builder].
		(0.5@0.1 corner: 1@1) -> [self buildClassListWith: builder] }.
	windowSpec label: self windowLabel.
	^ builder build: windowSpec
! !


!GCRepositoryBrowser methodsFor: 'initialization' stamp: 'tfel 9/20/2009 15:04'!
classListMap

	^ self classList
		collect: [:class | self packageClasses includes: class]! !

!GCRepositoryBrowser methodsFor: 'initialization' stamp: 'tfel 4/26/2010 22:21'!
initialize

	super initialize.
	self 
		repositoryIndex: 1;
		selectedClassIndex: 1;
		selectedClasses: self classListMap! !

!GCRepositoryBrowser methodsFor: 'initialization' stamp: 'tfel 4/26/2010 22:22'!
packageClasses
	
	^ GCRegistry repositories 
		ifEmpty: [#()]
		ifNotEmpty: [(GCRegistry at: self selectedRepository) packageClasses].! !


!GCRepositoryBrowser methodsFor: 'actions' stamp: 'tfel 6/14/2010 16:08'!
fileOut

	GCRegistry createFilesFor: self selectedRepository.! !

!GCRepositoryBrowser methodsFor: 'actions' stamp: 'tfel 9/20/2009 15:15'!
updatePackageClasses

	(GCRegistry at: self selectedRepository)
		packageClasses: (self classList
			select: [:class |
				self selectedClasses at: (self classList indexOf: class)])! !


!GCRepositoryBrowser methodsFor: 'constants' stamp: 'tfel 6/14/2010 15:58'!
fileOutButtonString

	^ 'Sync repository'! !

!GCRepositoryBrowser methodsFor: 'constants' stamp: 'tfel 1/8/2012 11:24'!
windowLabel

	^ 'Package Git Repository Mirrors'! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GCRepositoryBrowser class
	instanceVariableNames: ''!

!GCRepositoryBrowser class methodsFor: 'instance creation' stamp: 'tfel 1/8/2012 11:16'!
open
	| browser |
	browser := self new.
	(browser buildWith: ToolBuilder default) openInWorld.
	^ browser
! !
