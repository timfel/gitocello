Object subclass: #GCGitWrapper
	instanceVariableNames: 'localPath'
	classVariableNames: 'CalloutDict GitBinaryPath'
	poolDictionaries: ''
	category: 'Gitocello-Core'!

!GCGitWrapper methodsFor: 'commands' stamp: 'tfel 9/8/2009 20:00'!
add
	"Just add all"
	self gitCommand: 'add .'! !

!GCGitWrapper methodsFor: 'commands' stamp: 'tfel 9/8/2009 20:00'!
add: matchString
	"Add using matchString"
	self gitCommand: 'add ', matchString! !

!GCGitWrapper methodsFor: 'commands' stamp: 'tfel 9/8/2009 20:00'!
commit: commitMsg
	"Commit changes to the local repository"
	self gitCommand: 'commit -m "',  commitMsg, '"'! !

!GCGitWrapper methodsFor: 'commands' stamp: 'mh 5/12/2010 17:03'!
dirChangeCommand
	^ SmalltalkImage current platformName asLowercase = 'win32'
		ifTrue: ['cd "', self localPath, '" & ', (self localPath copyUpTo: $:) ,': & ']
		ifFalse: ['cd "', self localPath, '";'].
		! !

!GCGitWrapper methodsFor: 'commands' stamp: 'tfel 6/14/2010 15:37'!
gitCommand: aCommandString
	"Enter the local repository and run the 'git' command with the parameters"
	| command |
	command := self dirChangeCommand, ' ', self class gitBinaryPath, ' ', aCommandString.
	GCCallout callout: command.! !

!GCGitWrapper methodsFor: 'commands' stamp: 'tfel 9/7/2009 01:03'!
init

	self gitCommand: 'init'! !

!GCGitWrapper methodsFor: 'commands' stamp: 'tfel 9/7/2009 03:29'!
origin: aRemoteUrl

	self gitCommand: 'remote rm origin'.
	self gitCommand: 'remote add origin ', aRemoteUrl! !

!GCGitWrapper methodsFor: 'commands' stamp: 'TF 5/15/2010 17:59:40.669'!
pull
	"Avoid merging altogether for now"
	self gitCommand: 'pull -s ours origin master'! !

!GCGitWrapper methodsFor: 'commands' stamp: 'tfel 9/6/2009 18:30'!
push

	self gitCommand: 'push origin master'! !


!GCGitWrapper methodsFor: 'accessing' stamp: 'tfel 9/6/2009 23:10'!
localPath
	"Answer the value of localPath"

	^ localPath! !

!GCGitWrapper methodsFor: 'accessing' stamp: 'tfel 9/6/2009 23:10'!
localPath: anObject
	"Set the value of localPath"

	localPath := anObject! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GCGitWrapper class
	instanceVariableNames: ''!

!GCGitWrapper class methodsFor: 'preferences' stamp: 'tfel 5/31/2010 15:38:12.485'!
gitBinaryPath

	<preference: 'Git binary path'
		category: 'Gitocello'
		description: 'Set the path of the git binary to be used for Gitocello'
		type: #String>
	^ GitBinaryPath ifNil: ['git']
! !

!GCGitWrapper class methodsFor: 'preferences' stamp: 'tfel 5/31/2010 15:46:01.724'!
gitBinaryPath: aString

	GitBinaryPath := aString.! !
or: 'preferences' stamp: 'tfel 5/31/2010 15:46:01.724'!
gitBinaryPath: aString

	GitBinaryPath := aString.! !


!GCGitWrapper class methodsFor: 'callout' stamp: 'tfel 5/31/2010 15:42:45.566'!
apiLinuxLibc5Callout: aCommand
	<cdecl: long 'system' ( char* ) module: 'libc.so.5'>
	^ self externalCallFailed ! !

!GCGitWrapper class methodsFor: 'callout' stamp: 'tfel 5/31/2010 15:43:23.198'!
apiLinuxLibc6Callout: aCommand
	<cdecl: long 'system' ( char* ) module: 'libc.so.6'>
	^ self externalCallFailed ! !

!GCGitWrapper class methodsFor: 'callout' stamp: 'tfel 5/31/2010 15:43:35.167'!
apiMacOSXCallout: aCommand
	<cdecl: long 'system' (char*) module: 'libSystem.dylib'>
	| errCode |
	errCode := ExternalFunction getLastError. 
	^ errCode = 13 "Unable to find function address. dylibs are not searched"
		ifTrue: [self error: 'Cannot call libSystem.dylib. 
			Please set "SqueakPluginsBuiltInOrLocalOnly" in your VM''s Info.plist to false']
		ifFalse: [self externalCallFailed]! !

!GCGitWrapper class methodsFor: 'callout' stamp: 'tfel 5/31/2010 15:43:55.31'!
apiWindowsCallout: aCommand
	<apicall: long 'system' ( char* ) module: 'msvcrt.dll'>
	^ self externalCallFailed! !

!GCGitWrapper class methodsFor: 'callout' stamp: 'tfel 5/31/2010 15:44:05.438'!
callout: aCommand

	(self calloutDict 
		at: SmalltalkImage current platformName asLowercase
		ifAbsent: [[:cmd | self error: 'Not implemented for your platform!!']]) 
			value: aCommand.! !

!GCGitWrapper class methodsFor: 'callout' stamp: 'tfel 5/31/2010 15:41:53.537'!
calloutDict

	CalloutDict ifNil: [CalloutDict := Dictionary new
		at: 'unix' put: [:cmd | self linuxCallout: cmd];
		at: 'win32' put: [:cmd | self windowsCallout: cmd];
		at: 'mac os' put: [:cmd | self apiMacOSXCallout: cmd];
		yourself].
	^ CalloutDict! !

!GCGitWrapper class methodsFor: 'callout' stamp: 'tfel 5/31/2010 15:44:11.901'!
linuxCallout: aCommand
	"Try with new libc6 and older libc5"
	[self apiLinuxLibc6Callout: aCommand] 
		on: Error
		do: [self apiLinuxLibc5Callout: aCommand]! !

!GCGitWrapper class methodsFor: 'callout' stamp: 'tfel 5/31/2010 15:44:16.653'!
windowsCallout: aCommand
	"Escape newlines for Windows CmdLine"
	| escapedCommand |
	escapedCommand := ((aCommand 
		copyReplaceAll: Character cr asString with: ' ') 
			copyReplaceAll: Character lf asString with: ' ').
	self apiWindowsCallout: escapedCommand.! !
