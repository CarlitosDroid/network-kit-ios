import Alamofire
import Foundation
import OSLog

#if DEBUG
final class NetworkLogger: EventMonitor {
    private let logger = Logger(subsystem: "NetworkKit", category: "HTTP")

    func requestDidFinish(_ request: Request) {
        guard let urlRequest = request.request else { return }

        let method = urlRequest.httpMethod ?? "?"
        let url = urlRequest.url?.absoluteString ?? "?"
        let headers = urlRequest.allHTTPHeaderFields ?? [:]

        var bodyString = "-"
        if let body = urlRequest.httpBody, let string = String(data: body, encoding: .utf8) {
            bodyString = string
        }

        logger.debug("""
        ⬆️ REQUEST
        \(method) \(url)
        Headers: \(headers)
        Body: \(bodyString)
        """)
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        let url = request.request?.url?.absoluteString ?? "?"
        let statusCode = response.response?.statusCode ?? 0

        var bodyString = "-"
        if let data = response.data, let string = String(data: data, encoding: .utf8) {
            bodyString = string
        }

        let icon = (200...299).contains(statusCode) ? "⬇️✅" : "⬇️❌"
        logger.debug("""
        \(icon) RESPONSE
        \(url)
        Status: \(statusCode)
        Body: \(bodyString)
        """)
    }
}
#endif
