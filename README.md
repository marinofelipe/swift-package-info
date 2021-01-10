<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.3-orange.svg?style=flat" alt="Swift" /></a>
[![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)
[![Twitter](https://img.shields.io/badge/twitter-@_marinofelipe-blue.svg?style=flat)](https://twitter.com/_marinofelipe)

# Swift Package Info
Swift CLI tool, built on top of [Swift Argument Parser](https://github.com/apple/swift-argument-parser), that helps with *measuring the binary size impact* of a *given Swift Package product*.

## Usage
```
OVERVIEW: Check the estimated size of a Swift Package.

Measures the estimated binary size impact of a Swift Package product,
such as "ArgumentParser" declared on `swift-argument-parser`.

* Note: When adding a Swift Package dependency to your project, its final contributed binary size varies depending on
the platform, user devices, etc. The app binary goes through optimization processes, such as app thinning,
which decrease the final binary size.

The reported size here though can give you a good general idea of the binary impact, and it can help you on making
a decision to adopt or not such dependency. Be careful and mindful of your decision! *

USAGE: swift-package-info --repository-url <repository-url> --package-version <package-version> --product <product> [--verbose]

OPTIONS:
  --repository-url, --for, --package, --repo-url, --url <repository-url>
                          URL containing the Swift Package / `Package.swift` that contains the product you want to run analyzes for. 
  -v, --package-version <package-version>
                          Semantic version of the Swift Package. 
  --product, --product-named, --product-name <product>
                          Name of the product to be checked. 
  --verbose               Output all steps of a running analyzes 
  --version               Show the version.
  -h, --help              Show help information.
```

### Example
> Command
```
swift run SwiftPackageInfo --for https://github.com/marinofelipe/http_client -v 0.0.4 --product HTTPClient
```
> Report

```
+ -----------------------------------------------------------
|  Empty app size: 164 KB
|
|  App size with HTTPClient: 1 MB
|
|  Binary size increased by: 864 KB
|
|  * Note: When adding a Swift Package dependency to your project, its final contributed binary size varies depending on
|  the platform, user devices, etc. The app binary goes through optimization processes, such as app thinning,
|  which decrease the final binary size.
|
|  The reported size here though can give you a good general idea of the binary impact, and it can help you on making
|  a decision to adopt or not such dependency. Be careful and mindful of your decision! *
+ ----------------------------------------------------------
```

## Dependencies
- [Swift Argument Parser](https://github.com/apple/swift-argument-parser)
- [XcodeProj](https://github.com/tuist/XcodeProj.git)
- [swift-tools-support-core / SwiftToolsSupport-auto](https://github.com/apple/swift-tools-support-core/blob/main/Package.swift)

## TODO
* v1
- [ ] 💅
- [ ] Make Report scalable. Prepare to support different modes of output (e.g. JSON).
- [ ] `Much` more tests
- [ ] Finalize README
- [ ] Tiny CI?
- [ ] Add other providers using in-memory package content. E.g. The direct dependencies of a Swift Package product, to help on taking better decisions when adopting a Swift Package.


## License
`SwiftPackageInfo` is released under the MIT license. [See LICENSE](/LICENSE) for details.

Felipe Marino: [felipemarino91@gmail.com](mailto:felipemarino91@gmail.com), [@_marinofelipe](https://twitter.com/_marinofelipe)