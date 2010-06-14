SystemWindow subclass: GCRepositoryBrowser [
    | repositoryIndex selectedClassIndex classList selectedClasses |
    
    <comment: nil>
    <category: 'Gitocello-Morphic'>

    GCRepositoryBrowser class >> open [
	(self new)
	    createWindow;
	    openInWorld
    ]

    classList [
	classList ifNil: 
		[classList := GCRegistry repositories ifEmpty: [#()]
			    ifNotEmpty: [(GCRegistry at: self selectedRepository) classes]].
	^classList
    ]

    classListMap [
	^self classList collect: [:class | self packageClasses includes: class]
    ]

    contents [
	^self selectedRepository
    ]

    createWindow [
	| packageList classList repositoryUrlEntry fileOutCommand |
	fileOutCommand := PluggableButtonMorph 
		    on: self
		    getState: nil
		    action: #fileOut
		    label: #fileOutButtonString.
	repositoryUrlEntry := (PluggableTextMorph 
		    on: self
		    text: #repositoryRoot
		    accept: #repositoryRoot:
		    readSelection: nil
		    menu: #annotationPaneMenu:shifted:)
		    hideScrollBarsIndefinitely;
		    yourself.
	(packageList := PluggableListMorph new) 
	    on: self
	    list: #repositoryList
	    selected: #repositoryIndex
	    changeSelected: #repositoryIndex:
	    menu: #memberMenu:shifted:
	    keystroke: nil.
	(classList := PluggableListMorphOfMany new) 
	    on: self
	    list: #classList
	    primarySelection: #selectedClassIndex
	    changePrimarySelection: #selectedClassIndex:
	    listSelection: #selectedClassesAt:
	    changeListSelection: #selectedClassesAt:put:
	    menu: #classMenu
	    keystroke: nil.
	repositoryUrlEntry color: self defaultBackgroundColor.
	classList color: self defaultBackgroundColor.
	packageList color: self defaultBackgroundColor.
	self addMorph: repositoryUrlEntry frame: (0 @ 0.01 corner: 0.8 @ 0.1).
	self addMorph: fileOutCommand frame: (0.8 @ 0.01 corner: 1.0 @ 0.1).
	self addMorph: packageList frame: (0 @ 0.1 corner: 0.5 @ 1.0).
	self addMorph: classList frame: (0.5 @ 0.1 corner: 1.0 @ 1.0).
	self setLabel: 'Package Git Repository Mirrors'
    ]

    fileOut [
	GCRegistry createFilesFor: self selectedRepository
    ]

    initialize [
	super initialize.
	self
	    repositoryIndex: 1;
	    selectedClassIndex: 1;
	    selectedClasses: self classListMap
    ]

    repositoryList [
	^GCRegistry repositories keys asOrderedCollection
    ]

    selectedClassesAt: anIndex [
	^selectedClasses at: anIndex
    ]

    selectedClassesAt: anIndex put: aValue [
	selectedClasses at: anIndex put: aValue = true.
	self
	    changed: #selectedClassIndex;
	    updatePackageClasses
    ]

    selectedRepository [
	^self repositoryList at: self repositoryIndex
    ]

    classList: anObject [
	"Set the value of classList"

	<category: 'accessing'>
	classList := anObject
    ]

    fileOutButtonString [
	<category: 'accessing'>
	^'Sync repository'
    ]

    packageClasses [
	<category: 'accessing'>
	^GCRegistry repositories ifEmpty: [#()]
	    ifNotEmpty: [(GCRegistry at: self selectedRepository) packageClasses]
    ]

    repositoryIndex [
	"Answer the value of repositoryIndex"

	<category: 'accessing'>
	^repositoryIndex
    ]

    repositoryIndex: anObject [
	"Set the value of repositoryIndex"

	<category: 'accessing'>
	repositoryIndex := anObject.
	classList := nil
    ]

    repositoryRoot [
	<category: 'accessing'>
	^GCRegistry repositoryRoot name
    ]

    repositoryRoot: aString [
	<category: 'accessing'>
	^GCRegistry repositoryRoot: aString
    ]

    selectedClassIndex [
	"Answer the value of selectedClassIndex"

	<category: 'accessing'>
	^selectedClassIndex
    ]

    selectedClassIndex: anObject [
	"Set the value of selectedClassIndex"

	<category: 'accessing'>
	selectedClassIndex := anObject
    ]

    selectedClasses [
	"Answer the value of selectedClasses"

	<category: 'accessing'>
	^selectedClasses
    ]

    selectedClasses: anObject [
	"Set the value of selectedClasses"

	<category: 'accessing'>
	selectedClasses := anObject
    ]

    updatePackageClasses [
	<category: 'accessing'>
	(GCRegistry at: self selectedRepository) packageClasses: (self classList 
		    select: [:class | self selectedClasses at: (self classList indexOf: class)])
    ]
]

