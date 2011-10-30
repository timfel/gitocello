Object subclass: #GCCallout
	instanceVariableNames: 'localPath'
	classVariableNames: 'CalloutDict GitBinaryPath'
	poolDictionaries: ''
	category: 'Gitocello-Core'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GCCallout class
	instanceVariableNames: ''!

!GCCallout class methodsFor: 'callout' stamp: 'tfel 6/14/2010 15:36'!
apiLinuxLibc5Callout: aCommand
	<cdecl: long 'system' ( char* ) module: 'libc.so.5'>
	^ self externalCallFailed ! !

!GCCallout class methodsFor: 'callout' stamp: 'tfel 6/14/2010 15:36'!
apiLinuxLibc6Callout: aCommand
	<cdecl: long 'system' ( char* ) module: 'libc.so.6'>
	^ self externalCallFailed ! !

!GCCallout class methodsFor: 'callout' stamp: 'tfel 6/14/2010 15:36'!
apiMacOSXCallout: aCommand
	<cdecl: long 'system' (char*) module: 'libSystem.dylib'>
	| errCode |
	errCode := ExternalFunction getLastError.
	^ errCode = 13 "Unable to find function address. dylibs are not searched"
		ifTrue: [self error: 'Cannot call libSystem.dylib.
			Please set "SqueakPluginsBuiltInOrLocalOnly" in your VM''s Info.plist to false']
		ifFalse: [self externalCallFailed]! !

!GCCallout class methodsFor: 'callout' stamp: 'tfel 6/14/2010 15:36'!
apiWindowsCallout: aCommand
	<apicall: long 'system' ( char* ) module: 'msvcrt.dll'>
	^ self externalCallFailed! !

!GCCallout class methodsFor: 'callout' stamp: 'tfel 6/14/2010 16:21'!
callout: aCommand

	^ (Smalltalk classNamed: 'OSProcess')
		ifNil: [(self calloutDict
				at: SmalltalkImage current platformName asLowercase
				ifAbsent: [[:cmd | self error: 'Callouts not implemented for your platform!!']])
					value: aCommand]
		ifNotNilDo: [:class | class waitForCommand: aCommand].! !

!GCCallout class methodsFor: 'callout' stamp: 'tfel 6/14/2010 15:36'!
calloutDict

	CalloutDict ifNil: [CalloutDict := Dictionary new
		at: 'unix' put: [:cmd | self linuxCallout: cmd];
		at: 'win32' put: [:cmd | self windowsCallout: cmd];
		at: 'mac os' put: [:cmd | self apiMacOSXCallout: cmd];
		yourself].
	^ CalloutDict! !

!GCCallout class methodsFor: 'callout' stamp: 'tfel 6/14/2010 15:36'!
linuxCallout: aCommand
	"Try with new libc6 and older libc5"
	[self apiLinuxLibc6Callout: aCommand]
		on: Error
		do: [self apiLinuxLibc5Callout: aCommand]! !

!GCCallout class methodsFor: 'callout' stamp: 'tfel 6/14/2010 15:36'!
windowsCallout: aCommand
	"Escape newlines for Windows CmdLine"
	| escapedCommand |
	escapedCommand := ((aCommand
		copyReplaceAll: Character cr asString with: ' ')
			copyReplaceAll: Character lf asString with: ' ').
	self apiWindowsCallout: escapedCommand.! !
