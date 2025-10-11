![CI](https://github.com/marinofelipe/swift-package-info/actions/workflows/ci.yml/badge.svg?branch=main)
![Toolchain](https://img.shields.io/badge/Swift-6.1.2+%20%7C%20Xcode%2016.4%2B-orange?logo=swift&logoColor=white)
[![Mint](https://img.shields.io/badge/Mint-marinofelipe%2Fswift--package--info-40c8a7?logo=leaf&logoColor=white)](https://github.com/marinofelipe/swift-package-info#installation)
[![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)
[![Twitter](https://img.shields.io/badge/twitter-@_marinofelipe-blue.svg?style=flat)](https://twitter.com/_marinofelipe)

# Swift Package Info
CLI tool, built on top of [Swift Argument Parser](https://github.com/apple/swift-argument-parser),  that provides information about a *given Swift Package product*, such as a *measurement of its binary size impact*.
<br>
Binary size calculation is also available _as a library_ via the _`SwiftPackageInfo` package product_.

## Usage

### Examples
- Run a complete analysis
```sh
swift-package-info --for https://github.com/ReactiveX/RxSwift -v 6.0.0 --product RxSwift
```

- Check supported platforms (sub command)
```sh
swift-package-info platforms --for https://github.com/krzyzanowskim/CryptoSwift -v 1.3.8 --product CryptoSwift
```

- See the binary size of a local package (e.g., under development framework)
```sh
swift-package-info binary-size --path ../project/my-framework
```

### Report
```sh
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

A custom report strategy can be passed via the `report` argument _(check `--help` for supported values)_
```sh
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

## Running
* `mint run swift-package-info`
* or simply, `swift-package-info` in case it was symlinked

## Binary size report
Its methodology is inspired by [cocoapods-size](https://github.com/google/cocoapods-size), and thus works by comparing archives with no bitcode and ARM64 arch.
Such a strategy has proven consistent with the size of iOS apps downloaded and installed via TestFlight.

## Thanks
Special thanks to [@unnamedd](https://github.com/unnamedd) for sharing his experience with [swift-tools-support-core](https://github.com/apple/swift-tools-support-core) and on how to build a pretty 👌 report.

## Contributing
Check the [CONTRIBUTING.md](./CONTRIBUTING.md) file.
