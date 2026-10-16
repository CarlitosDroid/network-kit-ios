import Foundation

struct ApiErrorResponse: Decodable {
    let detail: String
    let code: String?
    let status: Int
}
