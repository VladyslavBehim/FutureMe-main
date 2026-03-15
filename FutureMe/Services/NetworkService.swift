import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL provided was invalid."
        case .requestFailed(let error): return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse: return "The server response was invalid."
        case .httpError(let statusCode): return "HTTP Error occurred with status code: \(statusCode)"
        case .decodingFailed(let error): return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    func performRequest<T: Decodable>(url: URL, method: String, headers: [String: String], body: Data?) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("HTTP Error \(httpResponse.statusCode): \(errorString)")
            }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding Failed: \(error)")
            throw NetworkError.decodingFailed(error)
        }
    }
}
