import Alamofire
import Foundation

/// Centralized HTTP client. Configure once via `ApiConfiguration` and inject as singleton.
public final class ApiClient {
    public let configuration: ApiConfiguration
    let session: Session

    public init(configuration: ApiConfiguration) {
        self.configuration = configuration

        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.timeoutIntervalForRequest = configuration.timeout

        #if DEBUG
        session = Session(configuration: urlSessionConfiguration, eventMonitors: [NetworkLogger()])
        #else
        session = Session(configuration: urlSessionConfiguration)
        #endif
    }

    /// Relative endpoint — scheme, host and base path come from `ApiConfiguration`.
    public func request<Response: Decodable, Parameters: Encodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        parameters: Parameters? = nil
    ) async -> Result<Response, Error> {
        guard let url = makeURL(for: endpoint) else { return .failure(NetworkError.invalidURL) }
        return await performRequest(url: url, method: method, parameters: parameters)
    }

    /// Full URL override — use for third-party APIs with a different host.
    public func request<Response: Decodable, Parameters: Encodable>(
        url: URL,
        method: HTTPMethod,
        parameters: Parameters? = nil
    ) async -> Result<Response, Error> {
        await performRequest(url: url, method: method, parameters: parameters, includeDefaultHeaders: false)
    }

    public func request<Response: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod
    ) async -> Result<Response, Error> {
        await request(endpoint: endpoint, method: method, parameters: Optional<String>.none)
    }

    public func request<Response: Decodable>(
        url: URL,
        method: HTTPMethod
    ) async -> Result<Response, Error> {
        await request(url: url, method: method, parameters: Optional<String>.none)
    }

    // MARK: - Internal

    func makeURL(for endpoint: Endpoint) -> URL? {
        var components = URLComponents()
        components.scheme = configuration.scheme
        components.host = configuration.host
        components.path = configuration.basePath + endpoint.path
        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems
        return components.url
    }

    // MARK: - Private

    private func performRequest<Response: Decodable, Parameters: Encodable>(
        url: URL,
        method: HTTPMethod,
        parameters: Parameters?,
        includeDefaultHeaders: Bool = true
    ) async -> Result<Response, Error> {
        let encoder: ParameterEncoder = (method == .get)
            ? URLEncodedFormParameterEncoder.default
            : JSONParameterEncoder.default
        let headers = includeDefaultHeaders ? HTTPHeaders(configuration.defaultHeaders) : nil

        let response = await session.request(
            url,
            method: Alamofire.HTTPMethod(rawValue: method.rawValue),
            parameters: parameters,
            encoder: encoder,
            headers: headers
        )
        .serializingData()
        .response

        guard let data = response.data else {
            return .failure(NetworkError.transport(
                response.error ?? AFError.responseValidationFailed(reason: .dataFileNil)
            ))
        }

        let statusCode = response.response?.statusCode ?? 0

        guard (200...299).contains(statusCode) else {
            let apiError = try? JSONDecoder().decode(ApiErrorResponse.self, from: data)
            return .failure(NetworkError.server(
                status: statusCode,
                message: apiError?.detail,
                code: apiError?.code
            ))
        }

        do {
            return .success(try JSONDecoder().decode(Response.self, from: data))
        } catch {
            return .failure(NetworkError.decoding(error))
        }
    }
}
