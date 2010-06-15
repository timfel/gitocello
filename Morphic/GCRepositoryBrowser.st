SystemWindow subclass: GCRepositoryBrowser [
    | repositoryIndex selectedClassIndex classList selectedClasses classListMorph packageListMorph |
    
    <comment: nil>
    <category: 'Gitocello-Morphic'>

    GCRepositoryBrowser class >> open [
	<category: 'instance creation'>
	(self new)
	    createWindow;
	    openInWorld
    ]

    classListMorph [
	<category: 'user interface'>
	^classListMorph ifNil: 
		[classListMorph := (PluggableListMorphOfMany 
			    on: self
			    list: #availableClasses
			    primarySelection: #selectedClassIndex
			    changePrimarySelection: #selectedClassIndex:
			    listSelection: #selectedClassesAt:
			    changeListSelection: #selectedClassesAt:put:
			    menu: nil)
			    color: self defaultBackgroundColor;
			    yourself]
    ]

    createWindow [
	<category: 'user interface'>
	self
	    addMorph: self repositoryUrlField frame: (0 @ 0.01 corner: 0.8 @ 0.1);
	    addMorph: self syncButton frame: (0.8 @ 0.01 corner: 1.0 @ 0.1);
	    addMorph: self packageListMorph frame: (0 @ 0.1 corner: 0.5 @ 1.0);
	    addMorph: self classListMorph frame: (0.5 @ 0.1 corner: 1.0 @ 1.0);
	    setLabel: 'Package Git Repository Mirrors'
    ]

    packageListMorph [
	<category: 'user interface'>
	^packageListMorph ifNil: 
		[packageListMorph := (PluggableListMorph 
			    on: self
			    list: #repositoryList
			    selected: #selectedRepositoryIndex
			    changeSelected: #selectedRepositoryIndex:)
			    color: self defaultBackgroundColor;
			    yourself]
    ]

    repositoryUrlField [
	<category: 'user interface'>
	^(PluggableTextMorph 
	    on: self
	    text: #repositoryRootPath
	    accept: #repositoryRootPath:)
	    hideScrollBarsIndefinitely;
	    color: self defaultBackgroundColor;
	    yourself
    ]

    syncButton [
	<category: 'user interface'>
	^PluggableButtonMorph 
	    on: self
	    getState: #syncButtonOn
	    action: #syncButtonAction
	    label: #syncButtonString
    ]

    repositoryList [
	<category: 'accessing'>
	^GCRegistry repositories keys asOrderedCollection
    ]

    selectedRepository [
	<category: 'accessing'>
	^self repositoryList at: self selectedRepositoryIndex
    ]

    selectedRepositoryIndex [
	"Answer the value of repositoryIndex"

	<category: 'accessing'>
	^repositoryIndex
    ]

    selectedRepositoryIndex: anObject [
	"Set the value of repositoryIndex"

	<category: 'accessing'>
	repositoryIndex := anObject.
	classList := nil.
	self
	    selectedClassIndex: 1;
	    selectedClasses: self currentlySelectedClasses;
	    changed: #selectedRepositoryIndex;
	    changed: #selectedClassesAt:;
	    changed: #availableClasses
    ]

    updatePackageClasses [
	<category: 'accessing'>
	(GCRegistry at: self selectedRepository) 
	    packageClasses: (self availableClasses 
		    select: [:class | self selectedClasses at: (self availableClasses indexOf: class)])
    ]

    repositoryRootPath [
	<category: 'accessing-registry-configuration'>
	^GCRegistry repositoryRoot name
    ]

    repositoryRootPath: aString [
	<category: 'accessing-registry-configuration'>
	^GCRegistry repositoryRoot: aString
    ]

    syncButtonAction [
	<category: 'accessing-buttons'>
	GCRegistry createFilesFor: self selectedRepository
    ]

    syncButtonOn [
	<category: 'accessing-buttons'>
	^GCRegistry repositories isEmpty not
    ]

    syncButtonString [
	<category: 'accessing-buttons'>
	^'Sync repository'
    ]

    availableClasses [
	<category: 'accessing-package-configuration'>
	classList ifNil: 
		[classList := GCRegistry repositories ifEmpty: [#()]
			    ifNotEmpty: [(GCRegistry at: self selectedRepository) classes]].
	^classList
    ]

    currentlySelectedClasses [
	<category: 'accessing-package-configuration'>
	^self availableClasses collect: [:cls | self packageClasses includes: cls]
    ]

    packageClasses [
	<category: 'accessing-package-configuration'>
	^GCRegistry repositories ifEmpty: [#()]
	    ifNotEmpty: [(GCRegistry at: self selectedRepository) packageClasses]
    ]

    selectedClassIndex [
	"Answer the value of selectedClassIndex"

	<category: 'accessing-package-configuration'>
	^selectedClassIndex
    ]

    selectedClassIndex: anObject [
	"Set the value of selectedClassIndex"

	<category: 'accessing-package-configuration'>
	selectedClassIndex := anObject.
	self changed: #selectedClassIndex
    ]

    selectedClasses [
	"Answer the value of selectedClasses"

	<category: 'accessing-package-configuration'>
	^selectedClasses
    ]

    selectedClasses: anObject [
	"Set the value of selectedClasses"

	<category: 'accessing-package-configuration'>
	selectedClasses := anObject
    ]

    selectedClassesAt: anIndex [
	<category: 'accessing-package-configuration'>
	^selectedClasses at: anIndex
    ]

    selectedClassesAt: anIndex put: aValue [
	<category: 'accessing-package-configuration'>
	selectedClasses at: anIndex put: aValue = true.
	self
	    changed: #selectedClassIndex;
	    changed: #availableClasses;
	    updatePackageClasses
    ]

    initialize [
	<category: 'initialization'>
	self
	    selectedRepositoryIndex: 1;
	    selectedClassIndex: 1;
	    selectedClasses: self currentlySelectedClasses.
	super initialize
    ]
]

