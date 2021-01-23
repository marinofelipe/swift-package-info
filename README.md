[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.3-orange.svg?style=flat" alt="Swift" /></a>
[![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)
[![Twitter](https://img.shields.io/badge/twitter-@_marinofelipe-blue.svg?style=flat)](https://twitter.com/_marinofelipe)

# Swift Package Info
CLI tool that provides information about a *given Swift Package product*, such as a *measurament of its binary size impact*.
It's built on top of [Swift Argument Parser](https://github.com/apple/swift-argument-parser).

## Usage
```
OVERVIEW: Get all provided information about a Swift Package

Runs all available providers (each one available via a subcommand, e.g. BinarySize),
and generates a full report of a given Swift Package product for a specific version.

USAGE: swift-package-info full-analyzes --repository-url <repository-url> --package-version <package-version> --product <product> [--verbose]

OPTIONS:
  --repository-url, --for, --package, --repo-url, --url <repository-url>
                          URL containing the Swift Package / `Package.swift` that contains the product you want to run analyzes for. 
  -v, --package-version <package-version>
                          Semantic version of the Swift Package. 
  --product, --product-named, --product-name <product>
                          Name of the product to be checked. 
  --verbose               Increase verbosity of informational output 
  --version               Show the version.
  -h, --help              Show help information.
```

### Example
> Command
```
swift run swift-package-info --for https://github.com/ReactiveX/RxSwift -v 6.0.0 --product RxSwift
```
> Report
```
+-----------------------------------------------+
|              Swift Package Info               |
|                                               |
|                RxSwift, 6.0.0                 |
+-------------+---------------------------------+
| Provider    | Results                         |
+-------------+---------------------------------+
| Binary Size | Binary size increased by 963 KB |
+-------------+---------------------------------+
> Total of 1 provider used.
```

## Installation
* Install [mint](https://github.com/yonaskolb/Mint).
* Run: `mint install marinofelipe/swift-package-info`

## Building
Build from Swift Package Manager

* `swift build` in the top level directory 
* The built utility can be found in `.build/debug/swift-package-info`
* Run with `swift run`

## Running tests
Run from Xcode

* Add the project path to `swift-package-info` scheme customWorkingDirectory.
* Run the tests

Run from command line

* `swift test --build-path PROJECT_DIR`

## Dependencies
* [CombineHTTPClient from HTTPClient](https://github.com/marinofelipe/http_client/blob/main/Package.swift)
* [Swift Argument Parser](https://github.com/apple/swift-argument-parser)
* [swift-tools-support-core from SwiftToolsSupport-auto](https://github.com/apple/swift-tools-support-core/blob/main/Package.swift)
* [XcodeProj](https://github.com/tuist/XcodeProj.git)

## Binary size report
Its methodology is inspired by [cocoapods-size](https://github.com/google/cocoapods-size), and thus works by comparing archives with no bitcode and ARM64 arch.
Such strategy has proven to be consistent with the size added to iOS apps downloaded and installed via TestFlight.

## v1 TODO
* [ ] Add other providers using in-memory package content. E.g. The direct dependencies of a Swift Package product, to help on taking better decisions when adopting a Swift Package
* [ ] Allow passing only `--repository-url` by defaulting product and version, to first and later respectively.
* [ ] First release

## Thanks
Special thanks to [@unnamedd](https://github.com/unnamedd) for sharing his experience with [swift-tools-support-core](https://github.com/apple/swift-tools-support-core) and on how to build a pretty 👌 report.

## Contributions
*Swift Package Info* is fully open and your contributions are more than welcome.