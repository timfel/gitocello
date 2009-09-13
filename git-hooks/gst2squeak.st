Eval [
   PackageLoader fileInPackage: 'Gitocello'.
   stdout nextPutAll: (Gitocello.GCGstConvertCommand commandLineFor: 'source.st' from: 'gst' to: 'squeak').
]
