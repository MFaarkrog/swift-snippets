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
  static let fileManager = FileManager.default
  
  static let currentPath = fileManager.currentDirectoryPath
  static let snippetsPath = fileManager.currentDirectoryPath.appending("/snippets")
  static let codePath = fileManager.currentDirectoryPath.appending("/code")
  
  static var libraryUrl = fileManager.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
  
  static let xcodeSnippetsUrl = libraryUrl?.appendingPathComponent("Developer/Xcode/UserData/CodeSnippets")
  static let xcodeSnippetsPath = xcodeSnippetsUrl?.path
}


// MARK: - Global

class Global {
  
  // Returns the URLs for all codesnippets at a given path
  class func getSnippetURLs(forPath path: String) -> [URL]? {
    do {
      let documentsUrl = NSURL(fileURLWithPath: path)
      let urls = try Constants.fileManager.contentsOfDirectory(
        at: documentsUrl as URL,
        includingPropertiesForKeys: nil,
        options: FileManager.DirectoryEnumerationOptions())
      
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
    let showFolder = Process()
    showFolder.launchPath = "/usr/bin/open"
    showFolder.arguments = [path]
    showFolder.launch()
  }
  
}


// MARK: - SnippetsInstaller

class SnippetInstaller {
  
  // Creates the CodeSnippets Xcode directory
  private func createCodeSnippetsDirectory() {
    guard let directoryUrl = Constants.xcodeSnippetsUrl else { return }
    do {
      try Constants.fileManager.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
      print("> CodeSnippets directory.")
    } catch let error as NSError {
      print(error.localizedDescription)
    }
  }
  
  // Installs all snippets from the repo in Xcode's snippet directory
  func install() {
    print("> Installing all snippets.")
    print("-------------------------")
    
    guard let destinationPath = Constants.xcodeSnippetsPath else { return }
    
    // Check of the CodeSnippets directory currently exist, else create it
    if !Constants.fileManager.fileExists(atPath: destinationPath) {
      createCodeSnippetsDirectory()
    }
    
    guard let snippetUrls = Global.getSnippetURLs(forPath: Constants.snippetsPath) else { return }
    for url in snippetUrls {
      let fileName = url.lastPathComponent
      guard // Get dictionary to copy, filename of snippet, and create final path
        let snippetDictionary = NSDictionary(contentsOf: url as URL),
        let path = Constants.xcodeSnippetsPath?.appending("/\(fileName)") else { return }
      snippetDictionary.write(toFile: path, atomically: true)
      print("> Copying `\(fileName)` to Xcode's CodeSnippets.")
    }
    
    if let path = Constants.xcodeSnippetsPath {
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
      try content.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
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
    guard let snippetUrls = Global.getSnippetURLs(forPath: Constants.snippetsPath) else { return }
    // Loop through every codesnippet url
    for url in snippetUrls {
      // Get contents of codesnippet (plist)
      let content = NSDictionary(contentsOf: url as URL)
      // Get data for file
      if let prefix = content?.object(forKey: "IDECodeSnippetCompletionPrefix"),
        let code = content?.object(forKey: "IDECodeSnippetContents") as? String {
        
        let filePath = Constants.codePath.appending("/\(prefix).swift")
        FileIO.saveFile(atPath: filePath, withContent: code)
      }
    }
  }
  
  func convert() {
    print("Converting snippets to Swift files.")
    print("-------------------------")
    
    createSwiftFilesForSnippets()
    Global.openDirectory(atPath: Constants.codePath)
    
    print("-------------------------")
    print("All snippets converted to code.")
  }
  
}


// MARK: - SnippetsMerger

class SnippetMerger {
  
  // Opens the snippets directory
  private func openSnippetDirectory() {
    let showFolder = Process()
    showFolder.launchPath = "/usr/bin/open"
    showFolder.arguments = [Constants.snippetsPath]
    showFolder.launch()
  }
  
  // Merges all Xcode snippets into the snippets directory
  func merge() {
    print("> Merging all Xcode snippets with snippets directory.")
    print("-------------------------")
    
    guard
      let sourcePath = Constants.xcodeSnippetsPath,
      let snippetUrls = Global.getSnippetURLs(forPath: sourcePath) else { return }
    for url in snippetUrls {
      guard // Get dictionary to copy and filename of new snippet
        let snippetDictionary = NSDictionary(contentsOf: url as URL),
        let name = snippetDictionary["IDECodeSnippetCompletionPrefix"] else { return }
      // Final path for file
      let filePath = Constants.snippetsPath.appending("/\(name).codesnippet")
      snippetDictionary.write(toFile: filePath, atomically: true)
      print("> Merged snippet `\(name)` to snippets directory.")
    }
    
    Global.openDirectory(atPath: Constants.snippetsPath)
    
    print("-------------------------")
    print("> All snippets merged.")
  }
  
}


// MARK: - Main

func printHelp() {
  print("Use `-i` or `--install` to install code snippets in Xcode.")
  print("Use `-c` or `--convert` to convert code snippets into Swift files.")
  print("Use `-m` or `--merge` to merge code snippets from Xcode's snippet directory into this repo.")
}

func main(arguments args: [String]) {
  guard args.count > 1 else {
    print("No arguement applied to call.")
    printHelp()
    return
  }
  
  for (index, arg) in args.enumerated() {
    if index > 0 { // Throw away first argument (name of script)
      switch arg {
      case "-i", "--install":
        SnippetInstaller().install()
      case "-c", "--convert":
        SnippetConverter().convert()
      case "-m", "--merge":
        SnippetMerger().merge()
      default:
        print("Invalid argumenet.")
        printHelp()
      }
    }
  }
}

// Starts the script
main(arguments: CommandLine.arguments)
