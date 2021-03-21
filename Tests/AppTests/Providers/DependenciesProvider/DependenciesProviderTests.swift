//
//  BinarySizeProviderErrorTests.swift
//
//
//  Created by Marino Felipe on 31.01.20.
//

import XCTest
import CoreTestSupport

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
            for: Fixture.makeSwiftPackage(),
            packageContent: Fixture.makePackageContent(
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
                ]
            ),
            verbose: true
        )

        let providedInfo = try result.get()
        XCTAssertEqual(
            providedInfo.providerName,
            "Dependencies"
        )

        XCTAssertEqual(
            providedInfo.messages,
            [
                .init(
                    text: "No third-party dependencies :)",
                    hasLineBreakAfter: false
                )
            ]
        )

        let encodedProvidedInfo = try JSONEncoder().encode(providedInfo)
        let encodedProvidedInfoString = String(
            data: encodedProvidedInfo,
            encoding: .utf8
        )

        XCTAssertEqual(
            encodedProvidedInfoString,
            "[]"
        )
    }

    func testProvidedInfo() throws {
        let result = DependenciesProvider.fetchInformation(
            for: Fixture.makeSwiftPackage(),
            packageContent: Fixture.makePackageContent(
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
                ]
            ),
            verbose: true
        )

        let providedInfo = try result.get()
        XCTAssertEqual(
            providedInfo.providerName,
            "Dependencies"
        )

        XCTAssertEqual(
            providedInfo.messages,
            [
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

        let encodedProvidedInfo = try JSONEncoder().encode(providedInfo)
        let encodedProvidedInfoString = String(
            data: encodedProvidedInfo,
            encoding: .utf8
        )

        XCTAssertEqual(
            encodedProvidedInfoString,
            #"[{"name":"dependency-1","version":"1.0.0"},{"name":"dependency-2","version":"1.0.0"}]"#
        )
    }

    func testProvidedInfoWithManyNestedAndIndirectDependencies() throws {
        let result = DependenciesProvider.fetchInformation(
            for: Fixture.makeSwiftPackage(),
            packageContent: Fixture.makePackageContent(
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
                ]
            ),
            verbose: true
        )

        let providedInfo = try result.get()
        XCTAssertEqual(
            providedInfo.providerName,
            "Dependencies"
        )
        XCTAssertEqual(
            providedInfo.providerKind,
            .dependencies
        )

        XCTAssertEqual(
            providedInfo.messages,
            [
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

        let encodedProvidedInfo = try JSONEncoder().encode(providedInfo)
        let encodedProvidedInfoString = String(
            data: encodedProvidedInfo,
            encoding: .utf8
        )

        XCTAssertEqual(
            encodedProvidedInfoString,
            #"[{"name":"dependency-1","version":"1.0.0"},{"name":"dependency-2","version":"1.0.0"},{"name":"dependency-3","version":"1.0.0"}]"#
        )
    }
}
