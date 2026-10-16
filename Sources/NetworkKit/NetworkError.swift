import Foundation

public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case transport(Error)
    case decoding(Error)
    case server(status: Int, message: String?, code: String?)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .transport(let error), .decoding(let error):
            return error.localizedDescription
        case .server(_, let message, _):
            return message ?? "Error inesperado del servidor"
        }
    }
}
