//
//  BinarySizeProviderErrorTests.swift
//
//
//  Created by Marino Felipe on 31.01.20.
//

import XCTest

@testable import App
@testable import Core

final class DependenciesProviderTests: XCTestCase {
    /// Test behavior when a product external dependency is declared by name, without matching any declared
    /// dependency name.
    ///
    /// - note: Is expected to return that there are no dependencies available, since unfortunately there's no way
    /// to define a Target dependency when it's name doesn't match with any of available Package dependencies names.
    func testProvidedInfoWhenHasExternalDependencyDeclaredByNameThatDoesNotMatch() throws {
        let result = DependenciesProvider.fetchInformation(
            for: SwiftPackage(
                repositoryURL: URL(string: "https://www.apple.com")!,
                version: "1.0.0",
                product: "Some"
            ),
            packageContent: PackageContent(
                name: "Package",
                platforms: [],
                products: [
                    .init(
                        name: "Some",
                        targets: [
                            "Target1"
                        ],
                        kind: .library(.automatic)
                    )
                ],
                dependencies: [
                    .init(
                        name: "dependency-1",
                        urlString: "https://www.some.com",
                        requirement: .init(
                            range: [
                                .init(
                                    lowerBound: "1.0.0",
                                    upperBound: "1.1.0"
                                )
                            ],
                            revision: [],
                            branch: []
                        )
                    ),
                    .init(
                        name: "dependency-2",
                        urlString: "https://www.some2.com",
                        requirement: .init(
                            range: [
                                .init(
                                    lowerBound: "1.0.0",
                                    upperBound: "1.1.0"
                                )
                            ],
                            revision: [],
                            branch: []
                        )
                    )
                ],
                targets: [
                    .init(
                        name: "Target1",
                        dependencies: [
                            .byName(
                                [
                                    .name("Dependency1"),
                                    .name("Target2")
                                ]
                            )
                        ],
                        kind: .regular
                    ),
                    .init(
                        name: "Target2",
                        dependencies: [
                            .byName(
                                [
                                    .name("Dependency1")
                                ]
                            )
                        ],
                        kind: .regular
                    )
                ],
                swiftLanguageVersions: []
            ),
            verbose: true
        )

        let providedInfo = try result.get()
        XCTAssertEqual(
            providedInfo,
            .init(
                providerName: "Dependencies",
                messages: [
                    .init(
                        text: "No third-party dependencies :)",
                        hasLineBreakAfter: false
                    )
                ]
            )
        )
    }

    func testProvidedInfo() throws {
        let result = DependenciesProvider.fetchInformation(
            for: SwiftPackage(
                repositoryURL: URL(string: "https://www.apple.com")!,
                version: "1.0.0",
                product: "Some"
            ),
            packageContent: PackageContent(
                name: "Package",
                platforms: [],
                products: [
                    .init(
                        name: "Some",
                        targets: [
                            "Target1"
                        ],
                        kind: .library(.automatic)
                    )
                ],
                dependencies: [
                    .init(
                        name: "dependency-1",
                        urlString: "https://www.some.com",
                        requirement: .init(
                            range: [
                                .init(
                                    lowerBound: "1.0.0",
                                    upperBound: "1.1.0"
                                )
                            ],
                            revision: [],
                            branch: []
                        )
                    ),
                    .init(
                        name: "dependency-2",
                        urlString: "https://www.some2.com",
                        requirement: .init(
                            range: [
                                .init(
                                    lowerBound: "1.0.0",
                                    upperBound: "1.1.0"
                                )
                            ],
                            revision: [],
                            branch: []
                        )
                    ),
                    .init(
                        name: "dependency-3",
                        urlString: "https://www.some3.com",
                        requirement: .init(
                            range: [
                                .init(
                                    lowerBound: "1.0.0",
                                    upperBound: "1.1.0"
                                )
                            ],
                            revision: [],
                            branch: []
                        )
                    )
                ],
                targets: [
                    .init(
                        name: "Target1",
                        dependencies: [
                            .byName(
                                [
                                    .name("dependency-1")
                                ]
                            ),
                            .byName(
                                [
                                    .name("Target2")
                                ]
                            )
                        ],
                        kind: .regular
                    ),
                    .init(
                        name: "Target2",
                        dependencies: [
                            .byName(
                                [
                                    .name("dependency-2")
                                ]
                            )
                        ],
                        kind: .regular
                    ),
                    .init(
                        name: "Target3",
                        dependencies: [
                            .byName(
                                [
                                    .name("dependency-1")
                                ]
                            ),
                            .byName(
                                [
                                    .name("dependency-3")
                                ]
                            )
                        ],
                        kind: .regular
                    )
                ],
                swiftLanguageVersions: []
            ),
            verbose: true
        )

        let providedInfo = try result.get()
        XCTAssertEqual(
            providedInfo,
            .init(
                providerName: "Dependencies",
                messages: [
                    .init(
                        text: "dependency-1",
                        hasLineBreakAfter: false
                    ),
                    .init(
                        text: " v. 1.0.0",
                        hasLineBreakAfter: false
                    ),
                    .init(
                        text: " | ",
                        hasLineBreakAfter: false
                    ),
                    .init(
                        text: "dependency-2",
                        hasLineBreakAfter: false
                    ),
                    .init(
                        text: " v. 1.0.0",
                        hasLineBreakAfter: false
                    )
                ]
            )
        )
    }

    func testProvidedInfoWithManyNestedAndIndirectDependencies() throws {
        let result = DependenciesProvider.fetchInformation(
            for: SwiftPackage(
                repositoryURL: URL(string: "https://www.apple.com")!,
                version: "1.0.0",
                product: "Some"
            ),
            packageContent: PackageContent(
                name: "Package",
                platforms: [],
                products: [
                    .init(
                        name: "Some",
                        targets: [
                            "Target1"
                        ],
                        kind: .library(.automatic)
                    )
                ],
                dependencies: [
                    .init(
                        name: "dependency-1",
                        urlString: "https://www.some.com",
                        requirement: .init(
                            range: [
                                .init(
                                    lowerBound: "1.0.0",
                                    upperBound: "1.1.0"
                                )
                            ],
                            revision: [],
                            branch: []
                        )
                    ),
                    .init(
                        name: "dependency-2",
                        urlString: "https://www.some2.com",
                        requirement: .init(
                            range: [
                                .init(
                                    lowerBound: "1.0.0",
                                    upperBound: "1.1.0"
                                )
                            ],
                            revision: [],
                            branch: []
                        )
                    ),
                    .init(
                        name: "dependency-3",
                        urlString: "https://www.some3.com",
                        requirement: .init(
                            range: [
                                .init(
                                    lowerBound: "1.0.0",
                                    upperBound: "1.1.0"
                                )
                            ],
                            revision: [],
                            branch: []
                        )
                    )
                ],
                targets: [
                    .init(
                        name: "Target1",
                        dependencies: [
                            .byName(
                                [
                                    .name("dependency-1")
                                ]
                            ),
                            .target(
                                [
                                    .name("Target2")
                                ]
                            ),
                            .target(
                                [
                                    .name("Target3")
                                ]
                            )
                        ],
                        kind: .regular
                    ),
                    .init(
                        name: "Target2",
                        dependencies: [
                            .byName(
                                [
                                    .name("dependency-1"),
                                    .name("dependency-1")
                                ]
                            ),
                            .product(
                                [
                                    .name("dependency-2"),
                                    .name("dependency-2"),
                                ]
                            ),
                            .target(
                                [
                                    .name("Target3")
                                ]
                            )
                        ],
                        kind: .regular
                    ),
                    .init(
                        name: "Target3",
                        dependencies: [
                            .byName(
                                [
                                    .name("dependency-1"),
                                    .name("dependency-1")
                                ]
                            ),
                            .product(
                                [
                                    .name("dependency-3"),
                                    .name("dependency-3")
                                ]
                            )
                        ],
                        kind: .regular
                    )
                ],
                swiftLanguageVersions: []
            ),
            verbose: true
        )

        let providedInfo = try result.get()
        XCTAssertEqual(
            providedInfo,
            .init(
                providerName: "Dependencies",
                messages: [
                    .init(
                        text: "dependency-1",
                        hasLineBreakAfter: false
                    ),
                    .init(
                        text: " v. 1.0.0",
                        hasLineBreakAfter: false
                    ),
                    .init(
                        text: " | ",
                        hasLineBreakAfter: false
                    ),
                    .init(
                        text: "dependency-2",
                        hasLineBreakAfter: false
                    ),
                    .init(
                        text: " v. 1.0.0",
                        hasLineBreakAfter: false
                    ),
                    .init(
                        text: " | ",
                        hasLineBreakAfter: false
                    ),
                    .init(
                        text: "dependency-3",
                        hasLineBreakAfter: false
                    ),
                    .init(
                        text: " v. 1.0.0",
                        hasLineBreakAfter: false
                    )
                ]
            )
        )
    }
}
