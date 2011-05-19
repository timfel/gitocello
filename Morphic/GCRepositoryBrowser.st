SystemWindow subclass: #GCRepositoryBrowser
	instanceVariableNames: 'repositoryIndex selectedClassIndex classList selectedClasses'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gitocello-Morphic'!

!GCRepositoryBrowser methodsFor: 'as yet unclassified' stamp: 'tfel 4/26/2010 22:23'!
classList

	
	classList ifNil: [
		classList := GCRegistry repositories
			ifEmpty: [#()]
			ifNotEmpty: [(GCRegistry at: self selectedRepository) classes]].
	^ classList! !

!GCRepositoryBrowser methodsFor: 'as yet unclassified' stamp: 'tfel 9/20/2009 15:04'!
classListMap

	^ self classList
		collect: [:class | self packageClasses includes: class]! !

!GCRepositoryBrowser methodsFor: 'as yet unclassified' stamp: 'tfel 9/20/2009 14:08'!
contents

	^ self selectedRepository! !

!GCRepositoryBrowser methodsFor: 'as yet unclassified' stamp: 'tfel 6/14/2010 16:03'!
createWindow
	
	| packageList classList repositoryUrlEntry fileOutCommand |
	(fileOutCommand := PluggableButtonMorph
		on: self
		getState: nil
		action: #fileOut
		label: #fileOutButtonString).
	repositoryUrlEntry := (PluggableTextMorph on: self
		text: #repositoryRoot
		accept: #repositoryRoot:
		readSelection: nil
		menu: #annotationPaneMenu:shifted:)
		hideScrollBarsIndefinitely;
		yourself.
	(packageList := PluggableListMorph new)
		on: self list: #repositoryList
		selected: #repositoryIndex changeSelected: #repositoryIndex:
		menu: #memberMenu:shifted: keystroke: nil.
	(classList := PluggableListMorphOfMany new)
		on: self list: #classList 
		primarySelection: #selectedClassIndex changePrimarySelection: #selectedClassIndex:
		listSelection: #selectedClassesAt: changeListSelection: #selectedClassesAt:put: 
		menu: #classMenu keystroke: nil.
	repositoryUrlEntry color: self defaultBackgroundColor.
	classList color: self defaultBackgroundColor.
	packageList color: self defaultBackgroundColor.
	self addMorph: repositoryUrlEntry frame: (0@0.01 corner: 0.8@0.1).
	self addMorph: fileOutCommand frame: (0.8@0.01 corner: 1.0@0.1).
	self addMorph: packageList frame: (0@0.1 corner: 0.5@1.0).
	self addMorph: classList frame: (0.5@0.1 corner: 1.0@1.0).

	self setLabel: 'Package Git Repository Mirrors'! !

!GCRepositoryBrowser methodsFor: 'as yet unclassified' stamp: 'tfel 6/14/2010 16:08'!
fileOut

	GCRegistry createFilesFor: self selectedRepository.! !

!GCRepositoryBrowser methodsFor: 'as yet unclassified' stamp: 'tfel 4/26/2010 22:21'!
initialize

	super initialize.
	self 
		repositoryIndex: 1;
		selectedClassIndex: 1;
		selectedClasses: self classListMap! !

!GCRepositoryBrowser methodsFor: 'as yet unclassified' stamp: 'tfel 9/20/2009 14:03'!
repositoryList

	^ GCRegistry repositories keys asOrderedCollection! !

!GCRepositoryBrowser methodsFor: 'as yet unclassified' stamp: 'tfel 9/20/2009 14:58'!
selectedClassesAt: anIndex

	^ selectedClasses at: anIndex! !

!GCRepositoryBrowser methodsFor: 'as yet unclassified' stamp: 'tfel 9/20/2009 15:16'!
selectedClassesAt: anIndex put: aValue

	selectedClasses at: anIndex put: (aValue = true).
	self 
		changed: #selectedClassIndex;
		updatePackageClasses! !

!GCRepositoryBrowser methodsFor: 'as yet unclassified' stamp: 'tfel 9/20/2009 14:10'!
selectedRepository

	^ self repositoryList at: self repositoryIndex! !


!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 15:02'!
classList: anObject
	"Set the value of classList"

	classList := anObject! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 6/14/2010 15:58'!
fileOutButtonString

	^ 'Sync repository'! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 4/26/2010 22:22'!
packageClasses
	
	^ GCRegistry repositories 
		ifEmpty: [#()]
		ifNotEmpty: [(GCRegistry at: self selectedRepository) packageClasses].! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 14:01'!
repositoryIndex
	"Answer the value of repositoryIndex"

	^ repositoryIndex! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 14:45'!
repositoryIndex: anObject
	"Set the value of repositoryIndex"

	repositoryIndex := anObject.
	classList := nil! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 10/2/2009 21:35'!
repositoryRoot

	^ GCRegistry repositoryRoot pathName! !

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 10/2/2009 21:34'!
repositoryRoot: aString

	^ GCRegistry repositoryRoot: aString! !

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

!GCRepositoryBrowser methodsFor: 'accessing' stamp: 'tfel 9/20/2009 15:15'!
updatePackageClasses

	(GCRegistry at: self selectedRepository)
		packageClasses: (self classList
			select: [:class |
				self selectedClasses at: (self classList indexOf: class)])! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GCRepositoryBrowser class
	instanceVariableNames: ''!

!GCRepositoryBrowser class methodsFor: 'as yet unclassified' stamp: 'tfel 9/20/2009 15:18'!
open

	(self new) 
		createWindow; 
		openInWorld! !
