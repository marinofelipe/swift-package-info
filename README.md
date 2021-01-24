[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.3-orange.svg?style=flat" alt="Swift" /></a>
[![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)
[![Twitter](https://img.shields.io/badge/twitter-@_marinofelipe-blue.svg?style=flat)](https://twitter.com/_marinofelipe)

# Swift Package Info
CLI tool that provides information about a *given Swift Package product*, such as a *measurament of its binary size impact*.
It's built on top of [Swift Argument Parser](https://github.com/apple/swift-argument-parser).

## Usage
```
OVERVIEW: A tool for analyzing Swift Packages

Provides valuable information about a given Swift Package,
that can be used in your favor when deciding whether to
adopt or not a Swift Package as a dependency on your app.

USAGE: swift-package-info <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  binary-size             Estimated binary size of a Swift Package product.
  platforms               Shows platforms supported b a Package product.
  dependencies            List dependencies of a Package product.
  full-analyzes (default) All available information about a Swift Package product.

  See 'swift-package-info help <subcommand>' for detailed help.
```

> swift run swift-package-info help binary-size
```
OVERVIEW: Estimated binary size of a Swift Package product.

Measures the estimated binary size impact of a Swift Package product,
such as "ArgumentParser" declared on `swift-argument-parser`.

* Note: The estimated size doesn't consider optimizations such as app thinning.
Its methodology is inspired by [cocoapods-size](https://github.com/google/cocoapods-size),
and thus works by comparing archives with no bitcode and ARM64 arch.
Such a strategy has proven to be very consistent with the size added to iOS apps downloaded and installed via TestFlight.

USAGE: swift-package-info binary-size --repository-url <repository-url> [--package-version <package-version>] --product <product> [--verbose]

OPTIONS:
  --repository-url, --for, --package, --repo-url, --url <repository-url>
                          URL containing the Swift Package / `Package.swift` that contains the product you want to run analyzes for. 
  -v, --package-version <package-version>
                          Semantic version of the Swift Package. If not passed in the latest release is used. 
  --product, --product-named, --product-name <product>
                          Name of the product to be checked. 
  --verbose               Increase verbosity of informational output 
  --version               Show the version.
  -h, --help              Show help information.
```

### Example
- To run a full analyzes
```
swift run swift-package-info --for https://github.com/ReactiveX/RxSwift -v 6.0.0 --product RxSwift
```
> Report
```
+------------------------------------------------+
|               Swift Package Info               |
|                                                |
|                 RxSwift, 6.0.0                 |
+--------------+---------------------------------+
| Provider     | Results                         |
+--------------+---------------------------------+
| Binary Size  | Binary size increases by 963 KB |
| Platforms    | System default                  |
| Dependencies | No third-party dependencies :)  |
+--------------+---------------------------------+
> Total of 3 providers used.
```

- To check supported platforms (sub command)
```
swift run swift-package-info platforms --for https://github.com/krzyzanowskim/CryptoSwift -v 1.3.8 --product CryptoSwift
```
> Report
```
+----------------------------------------------------------------------+
|                          Swift Package Info                          |
|                                                                      |
|                          CryptoSwift, 1.3.8                          |
+-----------+----------------------------------------------------------+
| Provider  | Results                                                  |
+-----------+----------------------------------------------------------+
| Platforms | macos from v. 10.12 | ios from v. 9.0 | tvos from v. 9.0 |
+-----------+----------------------------------------------------------+
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

## Thanks
Special thanks to [@unnamedd](https://github.com/unnamedd) for sharing his experience with [swift-tools-support-core](https://github.com/apple/swift-tools-support-core) and on how to build a pretty 👌 report.

## Contributions
*Swift Package Info* is fully open and your contributions are more than welcome.