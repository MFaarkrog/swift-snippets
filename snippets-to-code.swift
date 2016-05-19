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

// Saves content at a given filepath
func saveFile(atPath path: String, withContent content: String) {
  do {
    try content.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
  } catch let error as NSError {
    print(error.localizedDescription)
  }
}

// Creates swift files for all .codesnippet files in the /snippets directory
func createSwiftFilesForSnippets() {
  print("Converting snippets to Swift files.")
  print("-------------------------")
  
  guard let snippetUrls = snippetUrls else { return }
  
  for url in snippetUrls {
    // Get contents of codesnippet (plist) file
    let snippetDictionary = NSDictionary(contentsOfURL: url)
    // Get code snippet
    if let prefix = snippetDictionary?.objectForKey("IDECodeSnippetCompletionPrefix"),
      let code = snippetDictionary?.objectForKey("IDECodeSnippetContents") as? String {
      
      let filePath = currentPath.stringByAppendingString("/code/\(prefix).swift")
      print("Saving `\(prefix).swift`")
      saveFile(atPath: filePath, withContent: code)
    }
  }
  
  print("-------------------------")
  print("All snippets converted to code.")
}


// Start the script
createSwiftFilesForSnippets()