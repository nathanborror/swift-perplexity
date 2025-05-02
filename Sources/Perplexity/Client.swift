import Foundation

public final class Client {

    public static let defaultHost = URL(string: "https://api.perplexity.ai")!

    public let host: URL
    public let apiKey: String

    internal(set) public var session: URLSession

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(session: URLSession = URLSession(configuration: .default), host: URL? = nil, apiKey: String) {
        self.session = session
        self.host = host ?? Self.defaultHost
        self.apiKey = apiKey
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateInt = try container.decode(Int.self)
            return Date(timeIntervalSince1970: TimeInterval(dateInt))
        }
    }

    public enum Error: Swift.Error, CustomStringConvertible {
        case requestError(String)
        case responseError(response: HTTPURLResponse, detail: String)
        case decodingError(response: HTTPURLResponse, detail: String)
        case unexpectedError(String)

        public var description: String {
            switch self {
            case .requestError(let detail):
                return "Request error: \(detail)"
            case .responseError(let response, let detail):
                return "Response error (Status \(response.statusCode)): \(detail)"
            case .decodingError(let response, let detail):
                return "Decoding error (Status \(response.statusCode)): \(detail)"
            case .unexpectedError(let detail):
                return "Unexpected error: \(detail)"
            }
        }
    }

    private enum Method: String {
        case post = "POST"
        case get = "GET"
    }
}

// MARK: - Chats

extension Client {

    public func chat(_ payload: ChatRequest) async throws -> ChatResponse {
        try checkAuthentication()

        var body = payload
        body.stream = nil

        var req = makeRequest(path: "chat/completions", method: "POST")
        req.httpBody = try encoder.encode(body)

        let (data, resp) = try await session.data(for: req)
        if let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(ChatResponse.self, from: data)
    }

    public func chatStream(_ payload: ChatRequest) throws -> AsyncThrowingStream<ChatStreamResponse, Swift.Error> {
        try checkAuthentication()

        var body = payload
        body.stream = true
        return makeAsyncRequest(path: "chat/completions", method: "POST", body: body)
    }
}

// MARK: - Models

extension Client {

    public func models() async throws -> ModelListResponse {
        try checkAuthentication()
        return .init(models: Defaults.models)
    }
}

// MARK: - Private

extension Client {

    private func checkAuthentication() throws {
        if apiKey.isEmpty {
            throw Error.requestError("Missing API key")
        }
    }

    private func makeRequest(path: String, method: String) -> URLRequest {
        var req = URLRequest(url: host.appending(path: path))
        req.httpMethod = method
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return req
    }
    
    private func makeAsyncRequest<Body: Codable, Response: Codable>(path: String, method: String, body: Body) -> AsyncThrowingStream<Response, Swift.Error> {
        var request = makeRequest(path: path, method: method)
        request.httpBody = try? encoder.encode(body)

        return AsyncThrowingStream { continuation in
            let session = StreamingSession<Response>(session: session, request: request)
            session.onReceiveContent = {_, object in
                continuation.yield(object)
            }
            session.onProcessingError = {_, error in
                continuation.finish(throwing: error)
            }
            session.onComplete = { object, error in
                continuation.finish(throwing: error)
            }
            session.perform()
        }
    }
}
