#!/usr/bin/swift

import Foundation

let defaultManager = NSFileManager.defaultManager()
let currentPath = defaultManager.currentDirectoryPath

// Returns the URLs for all snippets in the "/snippets" directory
var snippetUrls: [NSURL]? {
  do {
    let documentsUrl = NSURL(fileURLWithPath: currentPath + "/snippets")
    let urls = try defaultManager.contentsOfDirectoryAtURL(
      documentsUrl,
      includingPropertiesForKeys: nil,
      options: NSDirectoryEnumerationOptions())
    
    // Filter urls so only the snippet urls are present
    let snippetUrls = urls.filter({$0.pathExtension == "codesnippet"})
    
    return snippetUrls
  } catch let error as NSError {
    print(error.localizedDescription)
    return nil
  }
}

// Copies all snippets to Xcode's CodeSnippets folder.
// Note: This overwrites any old snippets with the same name.
func copySnippets() {
  // Get URL for Library Directory (~Library)
  guard let libraryUrl = defaultManager.URLsForDirectory(NSSearchPathDirectory.LibraryDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first else { return }
  
  // Append path to CodeSnippets and save in destinationUrl
  let destionationUrl = libraryUrl.URLByAppendingPathComponent("Developer/Xcode/UserData/CodeSnippets")
  print("Copying snippets to \(destionationUrl)")
  print("-------------------------")
  
  // Cast url to path
  guard let destinationPath = destionationUrl.path else { return }
  
  // Create CodeSnippets directory if it doesn't exist
  if !defaultManager.fileExistsAtPath(destinationPath) {
    do {
      try defaultManager.createDirectoryAtURL(destionationUrl, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
      print(error.localizedDescription)
    }
  }
  
  guard let snippetUrls = snippetUrls else { return }
  for url in snippetUrls {
    guard // Get dictionary to copy, filename of snippet, and create final path
      let snippetDictionary = NSDictionary(contentsOfURL: url),
      let fileName = url.lastPathComponent,
      let path = destionationUrl.path?.stringByAppendingString("/\(fileName)") else { return }
    snippetDictionary.writeToFile(path, atomically: true)
    print("Copying `\(fileName)` to Xcode's CodeSnippets.")
  }
  
  print("-------------------------")
  print("All snippets copied.")
}



// Starts the script
copySnippets()