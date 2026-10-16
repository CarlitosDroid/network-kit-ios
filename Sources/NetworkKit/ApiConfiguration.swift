import Foundation

/// Injected by the host app; NetworkKit never reads Bundle.main or build settings itself.
public struct ApiConfiguration: Sendable {
    public let scheme: String
    public let host: String
    public let basePath: String
    public let defaultHeaders: [String: String]
    public let timeout: TimeInterval

    public init(
        scheme: String = "https",
        host: String,
        basePath: String = "",
        defaultHeaders: [String: String] = [:],
        timeout: TimeInterval = 30
    ) {
        self.scheme = scheme
        self.host = host
        self.basePath = basePath
        self.defaultHeaders = defaultHeaders
        self.timeout = timeout
    }
}
