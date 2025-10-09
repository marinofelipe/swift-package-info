![CI](https://github.com/marinofelipe/swift-package-info/workflows/CI/badge.svg)
![Toolchain](https://img.shields.io/badge/Swift-6.1.2%20%7C%20Xcode%2016.4%2B-orange?logo=swift&logoColor=white)
[![Mint](https://img.shields.io/badge/Mint-marinofelipe%2Fswift--package--info-40c8a7?logo=leaf&logoColor=white)](https://github.com/marinofelipe/swift-package-info#installation)
[![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)
[![Twitter](https://img.shields.io/badge/twitter-@_marinofelipe-blue.svg?style=flat)](https://twitter.com/_marinofelipe)

# Swift Package Info
CLI tool that provides information about a *given Swift Package product*, such as a *measurement of its binary size impact*.
It's built on top of [Swift Argument Parser](https://github.com/apple/swift-argument-parser).

## Usage

### Examples
- Run a full analyzes
```
swift-package-info --for https://github.com/ReactiveX/RxSwift -v 6.0.0 --product RxSwift
```

- Check supported platforms (sub command)
```
swift-package-info platforms --for https://github.com/krzyzanowskim/CryptoSwift -v 1.3.8 --product CryptoSwift
```

- See binary size of a local package (e.g. under development framework)
```
swift-package-info binary-size --path ../project/my-framework
```

### Report
```
swift-package-info --for https://github.com/ReactiveX/RxSwift -v 6.0.0 --product RxSwift
```
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

A custom report strategy can be passed via the `report` argument _(check --help for supported values)_
```
swift-package-info --for https://github.com/ReactiveX/RxSwift -v 6.0.0 --product RxSwift --report jsonDump
```
```JSON
{
  "binarySize" : {
    "amount" : 962560,
    "formatted" : "963 KB"
  },
  "dependencies" : [

  ],
  "platforms" : {

  }
}
```

## Requirements
- Swift >= 6.1
- Xcode >= 16.4

## Installation
* Install [mint](https://github.com/yonaskolb/Mint)
* _Optionally_ [add mint to your $PATH](https://github.com/yonaskolb/Mint?tab=readme-ov-file#linking) 
* Run: `mint install marinofelipe/swift-package-info` to install the latest version

## Running it
* `mint run swift-package-info`
* or simply, `swift-package-info` in case it was symlinked

## Building
Build from Swift Package Manager

* `swift build` in the top level directory 
* The built utility can be found in `.build/debug/swift-package-info`
* Run with `swift run`

## Running tests
Run from Xcode

* Add the project directory to `swift-package-info` scheme customWorkingDirectory
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
