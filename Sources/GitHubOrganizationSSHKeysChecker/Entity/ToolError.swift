import Foundation

enum ToolError: Error {
case apiCall
case shellExec
}

extension ToolError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .apiCall:
      return "GitHub API call failed."

    case .shellExec:
      return "Shell execution failed."
    }
  }
}
