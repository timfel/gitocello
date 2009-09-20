Object subclass: GCPackage [
    | packageClasses lastCommit |
    
    <category: 'Gitocello-Core'>
    <comment: nil>

    GCPackage class >> newFor: aPackage [
	<category: 'instance creation'>
	| packageInfo |
	packageInfo := PackageInfo named: aPackage.
	^(self new)
	    lastCommit: nil;
	    packageClasses: ((packageInfo classes asSet)
			addAll: packageInfo extensionClasses;
			yourself)
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
	^packageClasses
    ]

    packageClasses: anObject [
	"Set the value of packageClasses"

	<category: 'accessing'>
	packageClasses := anObject
    ]
]

