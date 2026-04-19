import Foundation

struct Logger {
    func info(_ message: String) {
        write("[INFO] \(message)")
    }

    func error(_ message: String) {
        write("[ERROR] \(message)")
    }

    private func write(_ line: String) {
        let formattedLine = "\(line)\n"
        fputs(formattedLine, stderr)

        let logURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/JoyConCodexHelper.log")
        guard let data = formattedLine.data(using: .utf8) else {
            return
        }

        if !FileManager.default.fileExists(atPath: logURL.path) {
            FileManager.default.createFile(atPath: logURL.path, contents: nil)
        }

        guard let handle = try? FileHandle(forWritingTo: logURL) else {
            return
        }
        defer { try? handle.close() }

        _ = try? handle.seekToEnd()
        _ = try? handle.write(contentsOf: data)
    }
}
