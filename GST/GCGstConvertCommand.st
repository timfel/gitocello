Object subclass: GCGstConvertCommand [
    
    <category: 'Gitocello-GST'>
    <comment: 'I am used for converting a Squeak source file to Gnu Smalltalk syntax using the gst-convert tool with the options found at http://smalltalk.gnu.org/faq/169'>

    GCGstConvertCommand class >> classNames [
	<category: 'bidirectional-rules'>
	^
	{'Float' -> 'FloatD'.
	'BlockContext' -> 'BlockClosure'.
	'MessageSend' -> 'DirectedMessage'.
	'DateAndTime' -> 'DateTime'.
	'UnhandledError' -> 'SystemExceptions.UnhandledException'.
	'FileDirectory' -> 'File'}
    ]

    GCGstConvertCommand class >> methodNames [
	<category: 'bidirectional-rules'>
	^
	{'Date current' -> 'Date today'.
	'TimeStamp current' -> 'DateTime now'.
	'FileDirectory pathNameDelimiter' -> 'Directory pathSeparator'.
	'FileDirectory default' -> 'Directory working'.
	'(FileDirectory deleteFilePath: ``@arg2)' -> '(File remove: ``@arg2)'.
	'(``@object rename: ``@arg1 toBe: ``@arg2)' 
	    -> '(File rename: ``@object name, Directory pathSeparatorString,``@arg1 to: ``@object name, Directory pathSeparatorString,``@arg2)'.
	'(FileDirectory forFileName: ``@arg2)' 
	    -> '(File path: (FilePath pathFor: ``@arg2))'.
	'(FileDirectory localNameFor: ``@arg2)' 
	    -> '(FilePath stripPathFrom: ``@arg2)'.
	'(``@object directoryExists: ``@arg2)' -> '(File path: ``@arg2) exists'.
	'(``@object createDirectory: ``@arg2)' 
	    -> '(File path: ``@arg2) createDirectory'.
	'(``@object recursiveDelete)' -> '(``@object all remove)'.
	'(``@object pathName)' -> '(``@object name)'.
	'(``@object containingDirectory)' -> '(``@object parent)'.
	'(``@object assureExistence)' -> '(``@object createDirectories)'.
	'(FileDirectory on: ``@arg2)' -> '(``@arg2 asFile)'.
	'(``@object directoryNamed: ``@arg2)' -> '(``@object / ``@arg2)'.
	'(``@object readOnlyFileNamed: ``@arg2)' 
	    -> '(``@object / ``@arg2) readStream'.
	'(``@object forceNewFileNamed: ``@arg2)' 
	    -> '(``@object / ``@arg2) writeStream'.
	'(Dictionary withAll: ``@arg2)' -> '(Dictionary from: ``@arg2)'.
	'(``@object allSubInstancesDo: ``@arg2)' 
	    -> '(``@object allSubinstancesDo: ``@arg2)'.
	'(``@object newFrom: ``@arg2)' -> '(``@object from: ``@arg2)'.
	'(``@object allMethodsInCategory: ``@arg1)' 
	    -> '((``@object class methodDictionary asSet select: [:msg | msg methodCategory = ``@arg1 ]) collect: [:each | each selector] asArray)'}
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

    GCGstConvertCommand class >> gstBidirectional [
	<category: 'gst-to-squeak-rules'>
	^((self class class methodDictionary asSet 
	    select: [:msg | msg methodCategory = 'bidirectional-rules']) 
		collect: [:each | each selector] asArray) inject: OrderedCollection new
		into: 
		    [:list :method | 
		    list 
			union: ((self perform: method) collect: [:each | each value -> each key])]
    ]

    GCGstConvertCommand class >> squeakBidirectional [
	<category: 'squeak-to-gst-rules'>
	^((self class class methodDictionary asSet 
	    select: [:msg | msg methodCategory = 'bidirectional-rules']) 
		collect: [:each | each selector] asArray) inject: OrderedCollection new
		into: [:list :method | list union: (self perform: method)]
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
	{'(``@object fileExists: ``@arg2)' -> '(``@object includes: ``@arg2)'.
	'(``@object caseInsensitiveLessOrEqual: ``@arg2)' 
	    -> '(``@object <= ``@arg2)'.
	'(``@object isZero)' -> '(``@object = 0)'.
	'FileDirectory dot' -> '$. asString'.
	'FileStream st' -> '($s asString, $t asString)'.
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

    GCGstConvertCommand class >> convert: aFilepath from: input to: output [
	<category: 'actions'>
	| filename |
	OSProcess waitForCommand: (self 
		    commandLineFor: aFilepath
		    from: input
		    to: output).
	filename := FilePath stripPathFrom: aFilepath.
	File remove: aFilepath.
	File 
	    rename: (File path: (FilePath pathFor: aFilepath)) name 
		    , Directory pathSeparatorString , (filename , '.converted')
	    to: (File path: (FilePath pathFor: aFilepath)) name 
		    , Directory pathSeparatorString , filename
    ]

    GCGstConvertCommand class >> commandLineFor: aFilepath from: input to: output [
	"see http://smalltalk.gnu.org/faq/169 for info on gst-convert command-line"

	<category: 'command-building'>
	| stream |
	stream := WriteStream on: (String new: 1000).
	stream nextPutAll: 'gst-convert -f ' , input , ' -F ' , output , ' '.
	((self class class methodDictionary asSet 
	    select: [:msg | msg methodCategory = (((input , '-to-') , output) , '-rules')]) 
		collect: [:each | each selector] asArray) 
		do: [:method | self writeRules: (self perform: method) to: stream].
	self 
	    flip: (self perform: (input , 'Newline') asSymbol)
	    with: (self perform: (output , 'Newline') asSymbol)
	    on: aFilepath
	    in: stream.
	^stream contents
    ]

    GCGstConvertCommand class >> flip: aString with: anotherString on: aFilepath in: aStream [
	<category: 'command-building'>
	aStream
	    nextPutAll: '"' , aFilepath , '"';
	    nextPutAll: ' - | tr ' , aString , ' ' , anotherString , ' > ';
	    nextPutAll: '"' , aFilepath , '.converted"'
    ]

    GCGstConvertCommand class >> writeRules: someRules to: aStream [
	<category: 'command-building'>
	someRules do: 
		[:each | 
		aStream
		    nextPutAll: '-r';
		    nextPut: $';
		    nextPutAll: (each asString copyWithout: $');
		    nextPut: $';
		    nextPut: Character space]
    ]

    GCGstConvertCommand class >> gstNewline [
	<category: 'literals'>
	^'\\n'
    ]

    GCGstConvertCommand class >> squeakNewline [
	<category: 'literals'>
	^'\\r'
    ]
]

