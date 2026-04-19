import Foundation

struct Logger {
    func info(_ message: String) {
        fputs("[INFO] \(message)\n", stderr)
    }

    func error(_ message: String) {
        fputs("[ERROR] \(message)\n", stderr)
    }
}
