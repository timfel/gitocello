Object subclass: #GCPackage
	instanceVariableNames: 'packageName packageClasses lastCommit'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Gitocello-Core'!

!GCPackage methodsFor: 'accessing' stamp: 'tfel 9/20/2009 14:31'!
classes
	"This converts, then sorts the class names, then finds the classes. Expensive, but run basically 
	only on intialization of the package and for the browser, which is slow anyway"
	| packageInfo |
	packageInfo := (PackageInfo named: self packageName).
	^ ((packageInfo classes union: packageInfo extensionClasses)
		collect: [:class | class name asString]) asSortedCollection
			collect: [:className | Smalltalk classNamed: className]! !

!GCPackage methodsFor: 'accessing' stamp: 'tfel 9/20/2009 13:00'!
lastCommit
	"Answer the value of lastCommit"

	^ lastCommit! !

!GCPackage methodsFor: 'accessing' stamp: 'tfel 9/20/2009 13:00'!
lastCommit: anObject
	"Set the value of lastCommit"

	lastCommit := anObject! !

!GCPackage methodsFor: 'accessing' stamp: 'tfel 9/20/2009 14:25'!
packageClasses
	"Answer the value of packageClasses"

	packageClasses ifNil: [packageClasses := self classes].
	^ packageClasses! !

!GCPackage methodsFor: 'accessing' stamp: 'tfel 9/20/2009 12:50'!
packageClasses: anObject
	"Set the value of packageClasses"

	packageClasses := anObject! !

!GCPackage methodsFor: 'accessing' stamp: 'tfel 9/20/2009 14:23'!
packageName
	"Answer the value of packageName"

	^ packageName! !

!GCPackage methodsFor: 'accessing' stamp: 'tfel 9/20/2009 14:23'!
packageName: anObject
	"Set the value of packageName"

	packageName := anObject! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GCPackage class
	instanceVariableNames: ''!

!GCPackage class methodsFor: 'instance creation' stamp: 'tfel 9/20/2009 14:24'!
newFor: aPackage

	^ self new
		packageName: aPackage;
		yourself
! !
