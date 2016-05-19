# swift-snippets
A collection of Swift snippets for Xcode.

## Installation
### Install by script :]
To add the snippets to Xcode, navigate to the `copy-snippets.swift` script in the Terminal and type in `./copy-snippets.swift`.

*Please note that this will override any existing snippets with the same name. I.e. `mf-mark-header`.*

Restart Xcode and everything should be working :]

### Install manually :[
Navigate to `~/Library/Developer/Xcode/UserData/CodeSnippets/` and copy-paste the snippets from the snippets directory into the directory. If the `CodeSnippets` directory doesn't already exist, simply create it.

Restart Xcode and everything should be working :]

## Usage
All snippets start with `mf-` followed by their name. Typing `mf-` will show you all available snippets for your current scope.

### Current Snippets
- mf-animation-spring
- mf-ibdesignable-nib
- mf-mark-header
- mf-mark-subheader
- mf-uiviewcontroller-tableview
- mf-uiviewcontroller

## Adding New Snippets
If you create your own snippets or find improvements to the existing ones, feel free to create a Pull Request.

Before making a Pull Request, please run the `snippet-to-code.swift` script to make sure the Swift files corresponding to the snippets are up-to-date.

To run the script, navigate to the file in the Terminal and run `./snippet-to-code.swift`.

## Todo
- [ ] Create a script for copying and renaming new snippets created in Xcode (located in the `CodeSnippets` directory). Use the value from the `IDECodeSnippetCompletionPrefix` key as the snippet's name.
- [ ] Add a GIF for usage
- [ ] Add a section on how to create snippets in Xcode
