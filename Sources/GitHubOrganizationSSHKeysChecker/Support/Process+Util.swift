import Foundation

extension Process {
  convenience init(_ launchPath: String, arguments: [String] = []) {
    self.init()

    self.executableURL = URL(fileURLWithPath: launchPath)
    self.arguments = arguments
  }

  func then(_ rhs: Process) -> Process {
    let pipe = Pipe()

    standardOutput = pipe
    standardError = FileHandle.nullDevice
    rhs.standardInput = pipe

    launch()

    return rhs
  }

  func launchWithStandardOutput() throws -> String {
    let pipe = Pipe()

    standardOutput = pipe
    standardError = FileHandle.nullDevice

    launch()
    waitUntilExit()

    guard terminationStatus == 0 else { throw ToolError.shellExec }
    guard let data = try? pipe.fileHandleForReading.readToEnd(),
          let output = String(data: data, encoding: .utf8) else { throw ToolError.shellExec }

    return output
  }
}
