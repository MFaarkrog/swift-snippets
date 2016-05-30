# swift-snippets
A collection of Swift snippets for Xcode.

## Installation
### Install by script :]
To add the snippets to Xcode, navigate to the directory with `scripts.swift` in the Terminal and type in `./scripts.swift --install`.

*Please note that this will override any existing snippets with the same name. E.g. `ss-mark-header`.*

Restart Xcode and everything should be working :]

### Install manually :[
Navigate to `~/Library/Developer/Xcode/UserData/CodeSnippets/` and copy-paste the snippets from the snippets directory into the directory. If the `CodeSnippets` directory doesn't already exist, simply create it.

Restart Xcode and everything should be working :]

## Usage
All snippets start with `ss` (for swift snippets) followed by their name. Typing `ss` will show you all available snippets for your current scope.

### Current Snippets
- ss-animation-spring
- ss-comment-function
- ss-ibaction-touch
- ss-ibdesignable-nib
- ss-ibinspectable
- ss-iboutlet
- ss-mark-header
- ss-mark-subheader
- ss-uiviewcontroller-comments
- ss-uiviewcontroller-tableview
- ss-uiviewcontroller

## Adding New Snippets
If you create your own snippets or find improvements to the existing ones, feel free to create a Pull Request.

To merge Xcode snippets with your local version of this repo, navigate to the directory with `scripts.swift` in the Terminal and type in `./scripts.swift --merge`.

Before making a Pull Request, please also run the `./scripts.swift --convert` script to make sure the Swift files corresponding to the snippets are up-to-date.

## Script Commands
- `./scripts.swift -i` or `./scripts.swift --install` to install the snippets in Xcode
- `./scripts.swift -c` or `./scripts.swift --convert` to convert snippets into Swift files
- `./scripts.swift -m` or `./scripts.swift --merge` to merge Xcode snippets with the ones in this repo

*Note:* You can chain the commands together. For example, if you want to do a merge followed by a convert, simply type in `./scripts.swift -m -c`

## Todo
- [ ] Add a GIF for usage.
- [ ] Add a section on how to create snippets in Xcode.
- [ ] Make the `--convert` script automatically update the `README.md` file with new scripts.
