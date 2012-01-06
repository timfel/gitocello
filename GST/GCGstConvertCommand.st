Object subclass: #GCGstConvertCommand
	instanceVariableNames: ''
	classVariableNames: 'GstConvertBinaryPath RunGstConvert'
	poolDictionaries: ''
	category: 'Gitocello-GST'!
!GCGstConvertCommand commentStamp: 'tfel 9/10/2009 11:48' prior: 0!
I am used for converting a Squeak source file to Gnu Smalltalk syntax using the gst-convert tool with the options found at http://smalltalk.gnu.org/faq/169!


"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GCGstConvertCommand class
	instanceVariableNames: ''!

!GCGstConvertCommand class methodsFor: 'private' stamp: 'tfel 9/14/2009 01:01'!
allMethodsIn: aCategory

	^ ((self class methodDictionary asSet select: [:msg |
		(msg methodClass organization categoryOfElement: msg selector) asString = aCategory])
			collect: [:each | each selector]) asArray! !


!GCGstConvertCommand class methodsFor: 'callouts' stamp: 'tfel 6/14/2010 17:36'!
basicConvert: aFilepath from: input to: output
	"see http://smalltalk.gnu.org/faq/169 for info on gst-convert command-line"
	| stream filename |
	stream := WriteStream on: (String new: 1000).
	stream nextPutAll: self gstConvertBinaryPath, ' -f ', input, ' '."-F ', output, ' '."
	(self allMethodsIn: input, '-to-', output, '-rules')
			do: [:method | self writeRules: (self perform: method) to: stream].
	stream nextPutAll: ' "', aFilepath, '" "', aFilepath, '.converted"'.
	GCCallout callout: stream contents.
	filename := FileDirectory localNameFor: aFilepath.
			FileDirectory deleteFilePath: aFilepath.
			(FileDirectory forFileName: aFilepath)
				rename: filename, '.converted' toBe: filename.! !

!GCGstConvertCommand class methodsFor: 'callouts' stamp: 'tfel 6/14/2010 17:18'!
flip: aString with: anotherString on: aFilepath

	| filename |
	(GCCallout callout: 'tr ', aString, ' ', anotherString, ' < "', aFilepath,
		'" > "', aFilepath, '.converted"') = 0 ifTrue: [
			filename := FileDirectory localNameFor: aFilepath.
			FileDirectory deleteFilePath: aFilepath.
			(FileDirectory forFileName: aFilepath)
				rename: filename, '.converted' toBe: filename].! !


!GCGstConvertCommand class methodsFor: 'bidirectional-rules' stamp: 'tfel 9/14/2009 01:10'!
classNames

	^ {	'Float' -> 'FloatD' .
		'BlockContext' -> 'BlockClosure' .
		'MessageSend' -> 'DirectedMessage' .
		'DateAndTime' -> 'DateTime' .
		'UnhandledError' -> 'SystemExceptions.UnhandledException' .
	    }! !

!GCGstConvertCommand class methodsFor: 'bidirectional-rules' stamp: 'tfel 9/14/2009 01:13'!
methodNames

	^ {	'Date current' -> 'Date today' .
		'TimeStamp current' -> 'DateTime now' .
		'FileDirectory pathNameDelimiter' -> 'Directory pathSeparator' .
		'FileDirectory default' -> 'Directory working' .
		'(FileDirectory deleteFilePath: ``@arg2)' -> '(File remove: ``@arg2)' .
		'(FileDirectory localNameFor: ``@arg2)' -> '(FilePath stripPathFrom: ``@arg2)' .
		'(``@object recursiveDelete)' -> '(``@object all remove)' .
		'(``@object pathName)' -> '(``@object name)' .
		'(``@object containingDirectory)' -> '(``@object parent)' .
		'(``@object assureExistence)' -> '(``@object createDirectories)' .
		'(``@object fileExists: ``@arg2)' -> '(``@object / ``@arg2) exists' .
		'(FileDirectory on: ``@arg2)' -> '(``@arg2 asFile)' .
		'(``@object directoryNamed: ``@arg2)' -> '(``@object / ``@arg2)' .
		'(``@object readOnlyFileNamed: ``@arg2)' -> '(``@object / ``@arg2) readStream' .
		'(``@object forceNewFileNamed: ``@arg2)' -> '(``@object / ``@arg2) writeStream' .
		'(``@object allSubInstancesDo: ``@arg2)' -> '(``@object allSubinstancesDo: ``@arg2)' .
		'(``@object newFrom: ``@arg2)' -> '(``@object from: ``@arg2)' .
		'((``@object methodClass organization categoryOfElement: ``@object selector))' -> '(``@object methodCategory)'
	    }! !

!GCGstConvertCommand class methodsFor: 'bidirectional-rules' stamp: 'tfel 9/13/2009 13:04'!
statements

	^ {	'(``@object ifNil: ``@arg ifNotNil: [ | `@t2 | `@.s2 ])' -> '(``@object ifNil: ``@arg ifNotNil: [ :foo || `@t2 | `@.s2 ])' .
		'(``@object ifNotNil: [ | `@t2 | `@.s2 ] ifNil: ``@arg)' -> '(``@object ifNotNil: [ :foo || `@t2 | `@.s2 ] ifNil: ``@arg)' .
		'(``@object ifNotNil: [ | `@t2 | `@.s2 ])' -> '(``@object ifNotNil: [ :foo || `@t2 | `@.s2 ])' .
	    }! !


!GCGstConvertCommand class methodsFor: 'actions' stamp: 'tfel 6/14/2010 17:32'!
convert: aFilepath from: input to: output

	self runGstConvert ifTrue: [
		self basicConvert: aFilepath from: input to: output].! !


!GCGstConvertCommand class methodsFor: 'gst-to-squeak-rules' stamp: 'tfel 9/14/2009 00:52'!
gstBidirectional
	"Reverse all bidirectional rules to apply them for squeak -> gst conversion"
	^ (self allMethodsIn: 'bidirectional-rules')
		inject: OrderedCollection new
		into: [:list :method |
			list union: ((self perform: method)
						collect: [:each | each value -> each key])]! !


!GCGstConvertCommand class methodsFor: 'preferences' stamp: 'tfel 6/14/2010 15:45'!
gstConvertBinaryPath

	<preference: 'Path to gst-convert binary'
		category: 'Gitocello'
		description: 'The gst-convert tool may be used to convert between Squeak and Gnu Smalltalk'
		type: #String>
	^ GstConvertBinaryPath ifNil: [GstConvertBinaryPath := 'gst-convert']
! !

!GCGstConvertCommand class methodsFor: 'preferences' stamp: 'tfel 6/14/2010 15:49'!
gstConvertBinaryPath: aString

	GstConvertBinaryPath := aString.
! !

!GCGstConvertCommand class methodsFor: 'preferences' stamp: 'tfel 6/14/2010 15:47'!
runGstConvert

	<preference: 'Convert to Gnu Smalltalk'
		category: 'Gitocello'
		description: 'Convert  file-out to Gnu Smalltalk syntax using gst-convert'
		type: #Boolean>
	^ RunGstConvert ifNil: [RunGstConvert := false]
! !

!GCGstConvertCommand class methodsFor: 'preferences' stamp: 'tfel 6/14/2010 15:47'!
runGstConvert: aBoolean

	RunGstConvert := aBoolean.
! !


!GCGstConvertCommand class methodsFor: 'literals' stamp: 'tfel 9/13/2009 11:42'!
gstNewline

	^ '\\n'! !

!GCGstConvertCommand class methodsFor: 'literals' stamp: 'tfel 9/13/2009 11:42'!
squeakNewline

	^ '\\r'! !


!GCGstConvertCommand class methodsFor: 'squeak-to-gst-rules' stamp: 'tfel 9/14/2009 00:52'!
squeakBidirectional
	"Find all bidirectional rules to include them in the conversion"
	^ (self allMethodsIn: 'bidirectional-rules')
		inject: OrderedCollection new
		into: [:list :method | list union: (self perform: method)]! !

!GCGstConvertCommand class methodsFor: 'squeak-to-gst-rules' stamp: 'tfel 9/13/2009 10:36'!
squeakClassNames

	^ {	'TimeStamp' -> 'DateTime' .
		'ProtoObject' -> 'nil' .
	    }! !

!GCGstConvertCommand class methodsFor: 'squeak-to-gst-rules' stamp: 'tfel 9/14/2009 01:24'!
squeakMethodNames

	^ {	'(``@object caseInsensitiveLessOrEqual: ``@arg2)' -> '(``@object <= ``@arg2)' .
		'(``@object isZero)' -> '(``@object = 0)' .
		'FileDirectory dot' -> '($. printString)' .
		'(``@object directoryExists: ``@arg2)' -> '(File path: ``@arg2) exists' .
		'(``@object union: ``@arg1)' -> '(``@object asSet addAll: ``@arg1; yourself)' .
		'FileStream st' -> '($s printString, $t printString)' .
		'(``@object beginsWith: ``@arg2)' -> '(``@object startsWith: ``@arg2)' .
		'(``@object ifNil: ``@arg1 ifNotNilDo: ``@arg2)' -> '(``@object ifNil: ``@arg1 ifNotNil: ``@arg2)' .
		'(``@object ifNotNilDo: ``@arg2 ifNil: ``@arg1)' -> '(``@object ifNotNil: ``@arg2 ifNil: ``@arg1)' .
		'(``@object ifNotNilDo: ``@arg2)' -> '(``@object ifNotNil: ``@arg2)' .
		'(``@object doIfNotNil: ``@arg2)' -> '(``@object ifNotNil: ``@arg2)' .
	    }! !

!GCGstConvertCommand class methodsFor: 'squeak-to-gst-rules' stamp: 'tfel 9/13/2009 13:13'!
squeakStatements

	^ {	'(``@object and: ``@arg1 and: ``@arg2)' -> '((``@object and: ``@arg1) and: ``@arg2)' .
	    }! !


!GCGstConvertCommand class methodsFor: 'command-building' stamp: 'tfel 9/13/2009 19:59'!
writeRules: someRules to: aStream

	someRules do: [:each |
		aStream
			nextPutAll: '-r';
			nextPut: $';
			nextPutAll: (each printString copyWithout: $');
			nextPut: $';
			nextPut: Character space]! !
