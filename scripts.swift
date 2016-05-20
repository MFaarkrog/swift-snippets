#!/usr/bin/swift

/**
 * scripts.swift
 *
 * Created by Morten Faarkrog on 20/05/16.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation


// MARK: - Constants

struct Constants {
  static let FileManager = NSFileManager.defaultManager()
  
  static let CurrentPath = FileManager.currentDirectoryPath
  static let SnippetsPath = FileManager.currentDirectoryPath.stringByAppendingString("/snippets")
  static let CodePath = FileManager.currentDirectoryPath.stringByAppendingString("/code")
  
  static let LibraryUrl = FileManager.URLsForDirectory(NSSearchPathDirectory.LibraryDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first
  
  static let XcodeSnippetsUrl = LibraryUrl?.URLByAppendingPathComponent("Developer/Xcode/UserData/CodeSnippets")
  static let XcodeSnippetsPath = XcodeSnippetsUrl?.path
}


// MARK: - Global

class Global {
  
  // Returns the URLs for all codesnippets at a given path
  class func getSnippetURLs(forPath path: String) -> [NSURL]? {
    do {
      let documentsUrl = NSURL(fileURLWithPath: path)
      let urls = try Constants.FileManager.contentsOfDirectoryAtURL(
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
  
  // Opens the code directory
  class func openDirectory(atPath path: String) {
    let showFolder = NSTask()
    showFolder.launchPath = "/usr/bin/open"
    showFolder.arguments = [path]
    showFolder.launch()
  }
  
}


// MARK: - SnippetsInstaller

class SnippetInstaller {
  
  // Creates the CodeSnippets Xcode directory
  private func createCodeSnippetsDirectory() {
    guard let directoryUrl = Constants.XcodeSnippetsUrl else { return }
    do {
      try Constants.FileManager.createDirectoryAtURL(directoryUrl, withIntermediateDirectories: true, attributes: nil)
      print("> CodeSnippets directory.")
    } catch let error as NSError {
      print(error.localizedDescription)
    }
  }
  
  // Installs all snippets from the repo in Xcode's snippet directory
  func install() {
    print("> Installing all snippets.")
    print("-------------------------")
    
    guard let destinationPath = Constants.XcodeSnippetsPath else { return }
    
    // Check of the CodeSnippets directory currently exist, else create it
    if !Constants.FileManager.fileExistsAtPath(destinationPath) {
      createCodeSnippetsDirectory()
    }
    
    guard let snippetUrls = Global.getSnippetURLs(forPath: Constants.SnippetsPath) else { return }
    for url in snippetUrls {
      guard // Get dictionary to copy, filename of snippet, and create final path
        let snippetDictionary = NSDictionary(contentsOfURL: url),
        let fileName = url.lastPathComponent,
        let path = Constants.XcodeSnippetsPath?.stringByAppendingString("/\(fileName)") else { return }
      snippetDictionary.writeToFile(path, atomically: true)
      print("> Copying `\(fileName)` to Xcode's CodeSnippets.")
    }
    
    if let path = Constants.XcodeSnippetsPath {
      Global.openDirectory(atPath: path)
    }
    
    print("-------------------------")
    print("> All snippets installed.")
    print("> Be sure to restart Xcode before trying them out.")
  }
  
}


// MARK: - FileIO

class FileIO {
  
  // Saves content at a given filepath
  class func saveFile(atPath path: String, withContent content: String) {
    do {
      try content.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
      print("> Saved file at \(path)")
    } catch let error as NSError {
      print(error.localizedDescription)
    }
  }
  
}


// MARK: - SnippetConverter

class SnippetConverter {
  
  // Creates swift files for all .codesnippet files in the /snippets directory
  func createSwiftFilesForSnippets() {
    // Get Urls for all code snippets
    guard let snippetUrls = Global.getSnippetURLs(forPath: Constants.SnippetsPath) else { return }
    // Loop through every codesnippet url
    for url in snippetUrls {
      // Get contents of codesnippet (plist)
      let content = NSDictionary(contentsOfURL: url)
      // Get data for file
      if let prefix = content?.objectForKey("IDECodeSnippetCompletionPrefix"),
        let code = content?.objectForKey("IDECodeSnippetContents") as? String {
        
        let filePath = Constants.CodePath.stringByAppendingString("/\(prefix).swift")
        FileIO.saveFile(atPath: filePath, withContent: code)
      }
    }
  }
  
  func convert() {
    print("Converting snippets to Swift files.")
    print("-------------------------")
    
    createSwiftFilesForSnippets()
    Global.openDirectory(atPath: Constants.CodePath)
    
    print("-------------------------")
    print("All snippets converted to code.")
  }
  
}


// MARK: - SnippetsMerger

class SnippetMerger {
  
  // Opens the snippets directory
  private func openSnippetDirectory() {
    let showFolder = NSTask()
    showFolder.launchPath = "/usr/bin/open"
    showFolder.arguments = [Constants.SnippetsPath]
    showFolder.launch()
  }
  
  // Merges all Xcode snippets into the snippets directory
  func merge() {
    print("> Merging all Xcode snippets with snippets directory.")
    print("-------------------------")
    
    guard
      let sourcePath = Constants.XcodeSnippetsPath,
      let snippetUrls = Global.getSnippetURLs(forPath: sourcePath) else { return }
    for url in snippetUrls {
      guard // Get dictionary to copy and filename of new snippet
        let snippetDictionary = NSDictionary(contentsOfURL: url),
        let name = snippetDictionary["IDECodeSnippetCompletionPrefix"] else { return }
      // Final path for file
      let filePath = Constants.SnippetsPath.stringByAppendingString("/\(name).codesnippet")
      snippetDictionary.writeToFile(filePath, atomically: true)
      print("> Merged snippet `\(name)` to snippets directory.")
    }
    
    Global.openDirectory(atPath: Constants.SnippetsPath)
    
    print("-------------------------")
    print("> All snippets merged.")
  }
  
}


// MARK: - Main

func printHelp() {
  print("Use `-i` or `-install` to install code snippets in Xcode.")
  print("Use `-c` or `-convert` to convert code snippets into Swift files.")
  print("Use `-m` or `-merge` to merge code snippets from Xcode's snippet directory into this repo.")
}

func main(arguements args: [String]) {
  guard args.count > 1 else {
    print("No arguement applied to call.")
    printHelp()
    return
  }
  
  switch args[1] {
  case "-i", "-install":
    SnippetInstaller().install()
  case "-c", "-convert":
    SnippetConverter().convert()
  case "-m", "-merge":
    SnippetMerger().merge()
  default:
    print("Invalid argumenet.")
    printHelp()
  }
}

// Starts the script
main(arguements: Process.arguments)
