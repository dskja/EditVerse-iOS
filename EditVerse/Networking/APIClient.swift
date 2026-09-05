import Foundation

enum APIConfig {
    static var baseURL: URL {
        if let raw = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           let url = URL(string: raw), !raw.isEmpty { return url }
        return URL(string: "http://127.0.0.1:8787")!
    }
}

enum APIError: LocalizedError {
    case invalidURL, http(Int, String?), decoding(Error), empty
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL"
        case .http(_, let message): return message ?? "Request failed"
        case .decoding: return "Unexpected server response"
        case .empty: return "Empty response"
        }
    }
}

actor APIClient {
    static let shared = APIClient()
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private var token: String?

    func setToken(_ token: String?) { self.token = token }

    func request<T: Decodable>(
        _ method: String,
        path: String,
        query: [String: String?] = [:],
        body: [String: Any]? = nil,
        authorized: Bool = false
    ) async throws -> T {
        let root = APIConfig.baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let absolute = root + (path.hasPrefix("/") ? path : "/" + path)
        guard var comps = URLComponents(string: absolute) else { throw APIError.invalidURL }
        let items = query.compactMap { k, v -> URLQueryItem? in
            guard let v, !v.isEmpty else { return nil }
            return URLQueryItem(name: k, value: v)
        }
        if !items.isEmpty { comps.queryItems = items }
        guard let url = comps.url else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        else if authorized { throw APIError.http(401, "authentication_required") }

        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.empty }
        guard (200..<300).contains(http.statusCode) else {
            let message = (try? decoder.decode(ErrorDTO.self, from: data))?.error
            throw APIError.http(http.statusCode, message)
        }
        do { return try decoder.decode(T.self, from: data) }
        catch { throw APIError.decoding(error) }
    }

    func uploadEdit(fileURL: URL, title: String, caption: String, category: String, songTitle: String, durationMs: Int) async throws -> EditPost {
        let root = APIConfig.baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: root + "/api/edits") else { throw APIError.invalidURL }
        guard let token else { throw APIError.http(401, "authentication_required") }
        let boundary = "Boundary-\(UUID().uuidString)"
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        var body = Data()
        func field(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        field("title", title); field("caption", caption); field("category", category)
        field("songTitle", songTitle); field("durationMs", "\(durationMs)")
        let fileData = try Data(contentsOf: fileURL)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = body
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let message = (try? decoder.decode(ErrorDTO.self, from: data))?.error
            throw APIError.http((response as? HTTPURLResponse)?.statusCode ?? 500, message)
        }
        return try decoder.decode(ItemEnvelope<EditPost>.self, from: data).item
    }
}

struct ErrorDTO: Codable { let error: String? }
struct ItemEnvelope<T: Codable>: Codable { let item: T }
struct ItemsEnvelope<T: Codable>: Codable { let items: [T]; let nextCursor: String? }
struct CategoriesEnvelope: Codable { let categories: [String] }
struct AuthEnvelope: Codable { let token: String; let user: UserProfile }
struct UserEnvelope: Codable { let user: UserProfile }
struct LikeEnvelope: Codable { let liked: Bool; let likes: Int }
struct SaveEnvelope: Codable { let saved: Bool }
struct ShareEnvelope: Codable { let shares: Int }
struct FollowEnvelope: Codable { let following: Bool }
