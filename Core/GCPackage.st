Object subclass: GCPackage [
    | packageName packageClasses lastCommit |
    
    <category: 'Gitocello-Core'>
    <comment: nil>

    GCPackage class >> newFor: aPackage [
	<category: 'instance creation'>
	^(self new)
	    packageName: aPackage;
	    yourself
    ]

    classes [
	"This converts, then sorts the class names, then finds the classes. Expensive, but run basically
	 only on intialization of the package and for the browser, which is slow anyway"

	<category: 'accessing'>
	| packageInfo |
	packageInfo := PackageInfo named: self packageName.
	^(((packageInfo classes asSet)
	    addAll: packageInfo extensionClasses;
	    yourself) collect: [:class | class name asString]) 
	    asSortedCollection collect: [:className | Smalltalk classNamed: className]
    ]

    lastCommit [
	"Answer the value of lastCommit"

	<category: 'accessing'>
	^lastCommit
    ]

    lastCommit: anObject [
	"Set the value of lastCommit"

	<category: 'accessing'>
	lastCommit := anObject
    ]

    packageClasses [
	"Answer the value of packageClasses"

	<category: 'accessing'>
	packageClasses ifNil: [packageClasses := self classes].
	^packageClasses
    ]

    packageClasses: anObject [
	"Set the value of packageClasses"

	<category: 'accessing'>
	packageClasses := anObject
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
]

