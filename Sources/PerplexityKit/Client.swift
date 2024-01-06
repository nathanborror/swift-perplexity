import Foundation

public final class PerplexityClient {
    
    let host: URL
    let token: String
    
    public init(token: String) {
        self.host = URL(string: "https://api.perplexity.ai")!
        self.token = token
    }
    
    // Chats
    
    public func chat(_ payload: ChatRequest) async throws -> ChatResponse {
        var body = payload
        body.stream = nil
        
        var req = makeRequest(path: "chat/completions", method: "POST")
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(ChatResponse.self, from: data)
    }
    
    public func chatStream(_ payload: ChatRequest) -> AsyncThrowingStream<ChatStreamResponse, Error> {
        var body = payload
        body.stream = true
        return makeAsyncRequest(path: "chat/completions", method: "POST", body: body)
    }
    
    // Models
    
    public func models() async throws -> ModelListResponse {
        .init(
            models: [
                "pplx-7b-chat",
                "pplx-70b-chat",
                "pplx-7b-online",
                "pplx-70b-online",
                "llama-2-70b-chat",
                "codellama-34b-instruct",
                "mistral-7b-instruct",
                "mixtral-8x7b-instruct",
            ]
        )
    }
    
    // Private
    
    private func makeRequest(path: String, method: String) -> URLRequest {
        var req = URLRequest(url: host.appending(path: path))
        req.httpMethod = method
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return req
    }
    
    private func makeAsyncRequest<Body: Codable, Response: Codable>(path: String, method: String, body: Body) -> AsyncThrowingStream<Response, Error> {
        var request = makeRequest(path: path, method: method)
        request.httpBody = try? JSONEncoder().encode(body)
        
        return AsyncThrowingStream { continuation in
            let session = StreamingSession<Response>(urlRequest: request)
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
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateInt = try container.decode(Int.self)
            return Date(timeIntervalSince1970: TimeInterval(dateInt))
        }
        return decoder
    }
}
