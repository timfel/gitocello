Object subclass: GCGstConvertCommand [
    
    <category: 'Gitocello-GST'>
    <comment: 'I am used for converting a Squeak source file to Gnu Smalltalk syntax using the gst-convert tool with the options found at http://smalltalk.gnu.org/faq/169'>

    GstConvertBinaryPath := nil.
    RunGstConvert := nil.

    GCGstConvertCommand class >> allMethodsIn: aCategory [
	<category: 'private'>
	^((self class methodDictionary asSet 
	    select: [:msg | msg methodCategory asString = aCategory]) 
		collect: [:each | each selector]) asArray
    ]

    GCGstConvertCommand class >> classNames [
	<category: 'bidirectional-rules'>
	^
	{'Float' -> 'FloatD'.
	'BlockContext' -> 'BlockClosure'.
	'MessageSend' -> 'DirectedMessage'.
	'DateAndTime' -> 'DateTime'.
	'UnhandledError' -> 'SystemExceptions.UnhandledException'}
    ]

    GCGstConvertCommand class >> methodNames [
	<category: 'bidirectional-rules'>
	^
	{'Date current' -> 'Date today'.
	'TimeStamp current' -> 'DateTime now'.
	'FileDirectory pathNameDelimiter' -> 'Directory pathSeparator'.
	'FileDirectory default' -> 'Directory working'.
	'(FileDirectory deleteFilePath: ``@arg2)' -> '(File remove: ``@arg2)'.
	'(FileDirectory localNameFor: ``@arg2)' 
	    -> '(FilePath stripPathFrom: ``@arg2)'.
	'(``@object recursiveDelete)' -> '(``@object all remove)'.
	'(``@object pathName)' -> '(``@object name)'.
	'(``@object containingDirectory)' -> '(``@object parent)'.
	'(``@object assureExistence)' -> '(``@object createDirectories)'.
	'(``@object fileExists: ``@arg2)' -> '(``@object / ``@arg2) exists'.
	'(FileDirectory on: ``@arg2)' -> '(``@arg2 asFile)'.
	'(``@object directoryNamed: ``@arg2)' -> '(``@object / ``@arg2)'.
	'(``@object readOnlyFileNamed: ``@arg2)' 
	    -> '(``@object / ``@arg2) readStream'.
	'(``@object forceNewFileNamed: ``@arg2)' 
	    -> '(``@object / ``@arg2) writeStream'.
	'(``@object allSubInstancesDo: ``@arg2)' 
	    -> '(``@object allSubinstancesDo: ``@arg2)'.
	'(``@object newFrom: ``@arg2)' -> '(``@object from: ``@arg2)'.
	'((``@object methodClass organization categoryOfElement: ``@object selector))' 
	    -> '(``@object methodCategory)'}
    ]

    GCGstConvertCommand class >> statements [
	<category: 'bidirectional-rules'>
	^
	{'(``@object ifNil: ``@arg ifNotNil: [ | `@t2 | `@.s2 ])' 
	    -> '(``@object ifNil: ``@arg ifNotNil: [ :foo || `@t2 | `@.s2 ])'.
	'(``@object ifNotNil: [ | `@t2 | `@.s2 ] ifNil: ``@arg)' 
	    -> '(``@object ifNotNil: [ :foo || `@t2 | `@.s2 ] ifNil: ``@arg)'.
	'(``@object ifNotNil: [ | `@t2 | `@.s2 ])' 
	    -> '(``@object ifNotNil: [ :foo || `@t2 | `@.s2 ])'}
    ]

    GCGstConvertCommand class >> writeRules: someRules to: aStream [
	<category: 'command-building'>
	someRules do: 
		[:each | 
		aStream
		    nextPutAll: '-r';
		    nextPut: $';
		    nextPutAll: (each printString copyWithout: $');
		    nextPut: $';
		    nextPut: Character space]
    ]

    GCGstConvertCommand class >> convert: aFilepath from: input to: output [
	<category: 'actions'>
	self runGstConvert 
	    ifTrue: 
		[self 
		    basicConvert: aFilepath
		    from: input
		    to: output]
    ]

    GCGstConvertCommand class >> gstBidirectional [
	"Reverse all bidirectional rules to apply them for squeak -> gst conversion"

	<category: 'gst-to-squeak-rules'>
	^(self allMethodsIn: 'bidirectional-rules') inject: OrderedCollection new
	    into: 
		[:list :method | 
		(list asSet)
		    addAll: ((self perform: method) collect: [:each | each value -> each key]);
		    yourself]
    ]

    GCGstConvertCommand class >> gstNewline [
	<category: 'literals'>
	^'\\n'
    ]

    GCGstConvertCommand class >> squeakNewline [
	<category: 'literals'>
	^'\\r'
    ]

    GCGstConvertCommand class >> squeakBidirectional [
	"Find all bidirectional rules to include them in the conversion"

	<category: 'squeak-to-gst-rules'>
	^(self allMethodsIn: 'bidirectional-rules') inject: OrderedCollection new
	    into: 
		[:list :method | 
		(list asSet)
		    addAll: (self perform: method);
		    yourself]
    ]

    GCGstConvertCommand class >> squeakClassNames [
	<category: 'squeak-to-gst-rules'>
	^
	{'TimeStamp' -> 'DateTime'.
	'ProtoObject' -> 'nil'}
    ]

    GCGstConvertCommand class >> squeakMethodNames [
	<category: 'squeak-to-gst-rules'>
	^
	{'(``@object caseInsensitiveLessOrEqual: ``@arg2)' 
	    -> '(``@object <= ``@arg2)'.
	'(``@object isZero)' -> '(``@object = 0)'.
	'FileDirectory dot' -> '($. printString)'.
	'(``@object directoryExists: ``@arg2)' -> '(File path: ``@arg2) exists'.
	'(``@object union: ``@arg1)' 
	    -> '(``@object asSet addAll: ``@arg1; yourself)'.
	'FileStream st' -> '($s printString, $t printString)'.
	'(``@object beginsWith: ``@arg2)' -> '(``@object startsWith: ``@arg2)'.
	'(``@object ifNil: ``@arg1 ifNotNilDo: ``@arg2)' 
	    -> '(``@object ifNil: ``@arg1 ifNotNil: ``@arg2)'.
	'(``@object ifNotNilDo: ``@arg2 ifNil: ``@arg1)' 
	    -> '(``@object ifNotNil: ``@arg2 ifNil: ``@arg1)'.
	'(``@object ifNotNilDo: ``@arg2)' -> '(``@object ifNotNil: ``@arg2)'.
	'(``@object doIfNotNil: ``@arg2)' -> '(``@object ifNotNil: ``@arg2)'}
    ]

    GCGstConvertCommand class >> squeakStatements [
	<category: 'squeak-to-gst-rules'>
	^
	{'(``@object and: ``@arg1 and: ``@arg2)' 
	    -> '((``@object and: ``@arg1) and: ``@arg2)'}
    ]

    GCGstConvertCommand class >> basicConvert: aFilepath from: input to: output [
	"see http://smalltalk.gnu.org/faq/169 for info on gst-convert command-line"

	<category: 'callouts'>
	| stream filename |
	stream := WriteStream on: (String new: 1000).
	stream nextPutAll: self gstConvertBinaryPath , ' -f ' , input , ' '.	"-F ', output, ' '."
	(self allMethodsIn: input , '-to-' , output , '-rules') 
	    do: [:method | self writeRules: (self perform: method) to: stream].
	stream nextPutAll: ' "' , aFilepath , '" "' , aFilepath , '.converted"'.
	GCCallout callout: stream contents.
	filename := FilePath stripPathFrom: aFilepath.
	File remove: aFilepath.
	(FileDirectory forFileName: aFilepath) rename: filename , '.converted'
	    toBe: filename
    ]

    GCGstConvertCommand class >> flip: aString with: anotherString on: aFilepath [
	<category: 'callouts'>
	| filename |
	(GCCallout 
	    callout: 'tr ' , aString , ' ' , anotherString , ' < "' , aFilepath 
		    , '" > "' , aFilepath 
		    , '.converted"') 
		= 0 
		ifTrue: 
		    [filename := FilePath stripPathFrom: aFilepath.
		    File remove: aFilepath.
		    (FileDirectory forFileName: aFilepath) rename: filename , '.converted'
			toBe: filename]
    ]

    GCGstConvertCommand class >> gstConvertBinaryPath [
	<category: 'preferences'>
	<preference: 'Path to gst-convert binary'
		category: 'Gitocello'
		description: 'The gst-convert tool may be used to convert between Squeak and Gnu Smalltalk'
		type: #String>
	^GstConvertBinaryPath ifNil: [GstConvertBinaryPath := 'gst-convert']
    ]

    GCGstConvertCommand class >> gstConvertBinaryPath: aString [
	<category: 'preferences'>
	GstConvertBinaryPath := aString
    ]

    GCGstConvertCommand class >> runGstConvert [
	<category: 'preferences'>
	<preference: 'Convert to Gnu Smalltalk'
		category: 'Gitocello'
		description: 'Convert  file-out to Gnu Smalltalk syntax using gst-convert'
		type: #Boolean>
	^RunGstConvert ifNil: [RunGstConvert := false]
    ]

    GCGstConvertCommand class >> runGstConvert: aBoolean [
	<category: 'preferences'>
	RunGstConvert := aBoolean
    ]
]

