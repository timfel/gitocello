Object subclass: GCCallout [
    | localPath |
    
    <category: 'Gitocello-Core'>
    <comment: nil>

    CalloutDict := nil.
    GitBinaryPath := nil.

    GCCallout class >> apiLinuxLibc5Callout: aCommand [
	<category: 'callout'>
	<cdecl: long 'system' ( char* ) module: 'libc.so.5'>
	^self externalCallFailed
    ]

    GCCallout class >> apiLinuxLibc6Callout: aCommand [
	<category: 'callout'>
	<cdecl: long 'system' ( char* ) module: 'libc.so.6'>
	^self externalCallFailed
    ]

    GCCallout class >> apiMacOSXCallout: aCommand [
	<category: 'callout'>
	| errCode |
	<cdecl: long 'system' (char*) module: 'libSystem.dylib'>
	errCode := ExternalFunction getLastError.
	^errCode = 13 
	    ifTrue: 
		["Unable to find function address. dylibs are not searched"

		self 
		    error: 'Cannot call libSystem.dylib. 
			Please set "SqueakPluginsBuiltInOrLocalOnly" in your VM''s Info.plist to false']
	    ifFalse: [self externalCallFailed]
    ]

    GCCallout class >> apiWindowsCallout: aCommand [
	<category: 'callout'>
	<apicall: long 'system' ( char* ) module: 'msvcrt.dll'>
	^self externalCallFailed
    ]

    GCCallout class >> callout: aCommand [
	<category: 'callout'>
	^(Smalltalk classNamed: 'OSProcess') ifNil: 
		[(self calloutDict at: SmalltalkImage current platformName asLowercase
		    ifAbsent: [[:cmd | self error: 'Callouts not implemented for your platform!']]) 
			value: aCommand]
	    ifNotNil: [:class | class waitForCommand: aCommand]
    ]

    GCCallout class >> calloutDict [
	<category: 'callout'>
	CalloutDict ifNil: 
		[CalloutDict := (Dictionary new)
			    at: 'unix' put: [:cmd | self linuxCallout: cmd];
			    at: 'win32' put: [:cmd | self windowsCallout: cmd];
			    at: 'mac os' put: [:cmd | self apiMacOSXCallout: cmd];
			    yourself].
	^CalloutDict
    ]

    GCCallout class >> linuxCallout: aCommand [
	"Try with new libc6 and older libc5"

	<category: 'callout'>
	[self apiLinuxLibc6Callout: aCommand] on: Error
	    do: [self apiLinuxLibc5Callout: aCommand]
    ]

    GCCallout class >> windowsCallout: aCommand [
	"Escape newlines for Windows CmdLine"

	<category: 'callout'>
	| escapedCommand |
	escapedCommand := (aCommand copyReplaceAll: Character cr asString with: ' ') 
		    copyReplaceAll: Character lf asString
		    with: ' '.
	self apiWindowsCallout: escapedCommand
    ]
]

