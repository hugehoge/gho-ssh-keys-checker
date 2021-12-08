import Foundation

import ArgumentParser

struct CommandOptions: ParsableArguments {
  @Argument(help: "Target GitHub orgnization name.")
  var organization: String

  @Flag(name: .long, help: "Suppress summary results.")
  var suppressSummary = false
  
  @Flag(name: .long, help: "Show TSV format results.")
  var tsv = false
}

@main
struct Main {
  static func main() async {
    do {
      let options = CommandOptions.parseOrExit()
      
      "Please enter your GitHub personal access token:\n"
        .data(using: .utf8)
        .map(FileHandle.standardError.write)
      let personalAccessToken = String(cString: getpass(""))
            
      let checker = GitHubOrganizationSSHKeysChecker(organization: options.organization,
                                                     personalAccessToken: personalAccessToken)
      
      try await checker.check(withTSVOutput: options.tsv, withSummaryOutput: !options.suppressSummary)
    } catch {
      error.localizedDescription
        .appending("\n")
        .data(using: .utf8)
        .map(FileHandle.standardError.write)
      exit(EXIT_FAILURE)
    }
  }
}
