import XCTest
@testable import NetworkKit

final class NetworkKitTests: XCTestCase {

    func testApiConfigurationDefaults() {
        let sut = ApiConfiguration(host: "api.example.com")

        XCTAssertEqual(sut.scheme, "https")
        XCTAssertEqual(sut.host, "api.example.com")
        XCTAssertEqual(sut.basePath, "")
        XCTAssertTrue(sut.defaultHeaders.isEmpty)
        XCTAssertEqual(sut.timeout, 30)
    }

    func testEndpointKeepsPathAndQueryItems() {
        let item = URLQueryItem(name: "q", value: "1")
        let sut = Endpoint("/v1/items", queryItems: [item])

        XCTAssertEqual(sut.path, "/v1/items")
        XCTAssertEqual(sut.queryItems, [item])
    }

    func testMakeURLComposesSchemeHostBasePathAndPath() {
        let client = ApiClient(configuration: ApiConfiguration(host: "api.example.com", basePath: "/api"))

        let url = client.makeURL(for: Endpoint("/v1/login"))

        XCTAssertEqual(url?.absoluteString, "https://api.example.com/api/v1/login")
    }

    func testMakeURLIncludesQueryItems() {
        let client = ApiClient(configuration: ApiConfiguration(host: "api.example.com"))

        let url = client.makeURL(for: Endpoint("/search", queryItems: [URLQueryItem(name: "q", value: "abc")]))

        XCTAssertEqual(url?.absoluteString, "https://api.example.com/search?q=abc")
    }

    func testRequestWithInvalidHostReturnsInvalidURL() async {
        let client = ApiClient(configuration: ApiConfiguration(host: "bad host"))

        let result: Result<String, Error> = await client.request(endpoint: Endpoint("/x"), method: .get)

        guard case .failure(let error) = result, case NetworkError.invalidURL = error else {
            return XCTFail("Expected NetworkError.invalidURL, got \(result)")
        }
    }

    func testServerErrorDescriptionUsesMessageOrFallback() {
        XCTAssertEqual(NetworkError.server(status: 400, message: "Bad", code: nil).errorDescription, "Bad")
        XCTAssertEqual(
            NetworkError.server(status: 500, message: nil, code: nil).errorDescription,
            "Error inesperado del servidor"
        )
    }
}
