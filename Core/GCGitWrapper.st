Object subclass: GCGitWrapper [
    | localPath |
    
    <category: 'Gitocello-Core'>
    <comment: nil>

    CalloutDict := nil.
    GitBinaryPath := nil.

    GCGitWrapper class >> gitBinaryPath [
	<category: 'preferences'>
	<preference: 'Git binary path'
		category: 'Gitocello'
		description: 'Set the path of the git binary to be used for Gitocello'
		type: #String>
	^GitBinaryPath ifNil: ['git']
    ]

    GCGitWrapper class >> gitBinaryPath: aString [
	<category: 'preferences'>
	GitBinaryPath := aString
    ]

    add [
	"Just add all"

	<category: 'commands'>
	self gitCommand: 'add .'
    ]

    add: matchString [
	"Add using matchString"

	<category: 'commands'>
	self gitCommand: 'add ' , matchString
    ]

    commit: commitMsg [
	"Commit changes to the local repository"

	<category: 'commands'>
	self gitCommand: 'commit --allow-empty -m "' , commitMsg , '"'
    ]

    dirChangeCommand [
	<category: 'commands'>
	^SmalltalkImage current platformName asLowercase = 'win32' 
	    ifTrue: 
		['cd "' , self localPath , '" & ' , (self localPath copyUpTo: $:) , ': & ']
	    ifFalse: ['cd "' , self localPath , '";']
    ]

    gitCommand: aCommandString [
	"Enter the local repository and run the 'git' command with the parameters"

	<category: 'commands'>
	| command |
	command := self dirChangeCommand , ' ' , self class gitBinaryPath , ' ' 
		    , aCommandString.
	GCCallout callout: command
    ]

    init [
	<category: 'commands'>
	self gitCommand: 'init'
    ]

    origin: aRemoteUrl [
	<category: 'commands'>
	self gitCommand: 'remote rm origin'.
	self gitCommand: 'remote add origin ' , aRemoteUrl
    ]

    pull [
	"Avoid merging altogether for now"

	<category: 'commands'>
	self gitCommand: 'pull -s ours origin master'
    ]

    push [
	<category: 'commands'>
	self gitCommand: 'push origin master'
    ]

    localPath [
	"Answer the value of localPath"

	<category: 'accessing'>
	^localPath
    ]

    localPath: anObject [
	"Set the value of localPath"

	<category: 'accessing'>
	localPath := anObject
    ]
]

