//  Copyright (c) 2022 Felipe Marino
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
