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
- [ ] Cleanup temporary derived data
- [ ] Reset MeasurementApp to initial state - remove added dependency
- [ ] Prettify report
- [ ] Handle verbose and non-verbose modes. Use [TSCUtility.ProgressAnimation](https://github.com/apple/swift-tools-support-core/blob/fcaa2ce5a852b5355aed5808a6610dc8b6dcf27e/Sources/TSCUtility/ProgressAnimation.swift) for non-verbose mode.
- [ ] Validate repositoryURL argument
- [ ] Validate packageVersion argument - Would be nice to make use of a type safe "SemanticVersion" type - maybe https://github.com/SwiftPackageIndex/SemanticVersion?
- [ ] 💅
- [ ] More tests
- [ ] Finalize README
- [ ] Tiny CI?

* v2
- [ ] Provide more information - E.g. The direct dependencies of a Swift Package product, to help on taking better decisions when adopting a Swift Package.


## License
`SwiftPackageInfo` is released under the MIT license. [See LICENSE](/LICENSE) for details.

Felipe Marino: [felipemarino91@gmail.com](mailto:felipemarino91@gmail.com), [@_marinofelipe](https://twitter.com/_marinofelipe)