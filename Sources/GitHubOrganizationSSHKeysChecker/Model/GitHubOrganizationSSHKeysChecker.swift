import Foundation

struct GitHubOrganizationSSHKeysChecker {
  let organization: String
  let personalAccessToken: String

  func check(withTSVOutput: Bool = false, withSummaryOutput: Bool = true) async throws {
    let client = GitHubAPIClient(personalAccessToken: personalAccessToken)

    let userNames = try await client.fetchUserNames(organization: organization)
    let userPemKeys: [UserPemKey] =
      try await withThrowingTaskGroup(of: (userName: String, keys: [String]).self) { group in
        for userName in userNames {
          group.addTask {
            try await (userName, client.fetchUserKeys(userName: userName))
          }
        }

      return try await group.reduce(into: [UserPemKey]()) { acc, cur in
        acc += cur.keys.map { UserPemKey(userName: cur.userName, pemKeyString: $0) }
      }
    }

    let userKeys = userPemKeys.map { userPemKey -> UserKey in
      let keyType = try? Process("/bin/echo", arguments: [userPemKey.pemKeyString])
        .then(Process("/usr/bin/ssh-keygen", arguments: ["-lf", "-"]))
        .then(Process("/usr/bin/sed", arguments: ["-E", #"s/^([0-9]+).+\((.+)\)$/\2 \1bit/"#]))
        .launchWithStandardOutput()
        .trimmingCharacters(in: .whitespacesAndNewlines)

      return UserKey(
        userName: userPemKey.userName,
        pemKeyString: userPemKey.pemKeyString,
        keyType: keyType ?? "Unknown"
      )
    }

    if withTSVOutput {
      printTSVOutput(userKeys)
    }
    if withSummaryOutput {
      printSummaryOutput(userKeys)
    }
  }

  private func printTSVOutput(_ userKeys: [UserKey]) {
    for userKey in userKeys {
      "\(userKey.userName)\t\(userKey.keyType)\t\(userKey.pemKeyString)\n"
        .data(using: .utf8)
        .map(FileHandle.standardOutput.write)
    }
  }

  private func printSummaryOutput(_ userKeys: [UserKey]) {
    let keyTypeCount: [String: Int] = userKeys.reduce(into: [:]) { acc, cur in
      let keyType = cur.keyType
      if let count = acc[keyType] {
        acc[keyType] = count + 1
      } else {
        acc[keyType] = 1
      }
    }
    let maxKeyTypeName = userKeys.reduce(0) { max($0, $1.keyType.count) }
    let totalCount = userKeys.count

    for type in keyTypeCount.keys.sorted() {
      let count = keyTypeCount[type] ?? 0
      let ratio = (Float(count) / Float(totalCount)) * 100

      let typeText = type.padding(toLength: maxKeyTypeName, withPad: " ", startingAt: 0)
      let ratioText = String(format: "%.1f%%", ratio)
      "\(typeText): \(count) (\(ratioText))\n"
        .data(using: .utf8)
        .map(FileHandle.standardOutput.write)
    }
    "\nTotal: \(totalCount) keys\n"
      .data(using: .utf8)
      .map(FileHandle.standardOutput.write)
  }
}
