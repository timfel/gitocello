Object subclass: GCGitWrapper [
    | localPath |
    
    <category: 'Gitocello-Core'>
    <comment: nil>

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
	self gitCommand: 'commit -m "' , commitMsg , '"'
    ]

    gitCommand: aCommandString [
	"Enter the local repository and run the 'git' command with the parameters"

	<category: 'commands'>
	OSProcess 
	    waitForCommand: 'cd ' , self localPath , '; git ' , aCommandString
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
	<category: 'commands'>
	self gitCommand: 'pull origin master'
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

