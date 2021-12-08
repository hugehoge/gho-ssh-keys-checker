// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "GitHubOrganizationSSHKeysChecker",
  platforms: [
    .macOS(.v12),
  ],
  products: [
      .executable(name: "gho-ssh-keys-checker", targets: ["GitHubOrganizationSSHKeysChecker"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", .exact("1.0.2")),
  ],
  targets: [
    .executableTarget(
      name: "GitHubOrganizationSSHKeysChecker",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]),
  ]
)
