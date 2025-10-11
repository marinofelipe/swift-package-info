# Contributing

When you're contributing to this repository, you're encouraged to discuss the change you'd like to make via an issue before submitting it. 
However, I'm not strict about it; for minor changes or if you have context and are comfortable, feel free to open a pull request directly.

## Local development
To run it locally during development:

### CLI
For building, running, or testing, rely on `swift <command>`, such as 
```sh
swift build
```
Built artifacts can be found in `.build/debug`

### Xcode
Use it to attach the debugger.
<br>
Prefer the shared [swift-package-info xcscheme](.swiftpm/xcode/xcshareddata/xcschemes/swift-package-info.xcscheme), which has run arguments configured for the binary-size check.

#### Run
- Update the [swift-package-info xcscheme](.swiftpm/xcode/xcshareddata/xcschemes/swift-package-info.xcscheme) arguments with the path to the Package.swift under analysis
- For local packages, either use an Absolute path or change the working directory
- **Do not commit** such changes

## Pull Request Process

- Aim to keep pull requests scoped to one feature to ease review
- Add tests to verify that the changes work (if possible)
- Include or update documentation for new or changed features
