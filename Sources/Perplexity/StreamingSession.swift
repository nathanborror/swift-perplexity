import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class StreamingSession<ResultType: Codable>: NSObject, Identifiable, URLSessionDelegate, URLSessionDataDelegate {
    
    enum StreamingError: Error {
        case unknownContent
        case emptyContent
    }
    
    var onReceiveContent: ((StreamingSession, ResultType) -> Void)?
    var onProcessingError: ((StreamingSession, Error) -> Void)?
    var onComplete: ((StreamingSession, Error?) -> Void)?

    private let session: URLSession
    private let request: URLRequest
    private let decoder: JSONDecoder

    private var streamingBuffer = ""
    private let streamingCompletionMarker = "[DONE]"

    init(session: URLSession, request: URLRequest) {
        self.session = session
        self.request = request
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateInt = try container.decode(Int.self)
            return Date(timeIntervalSince1970: TimeInterval(dateInt))
        }
    }
    
    func perform() {
        session
            .dataTask(with: request)
            .resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        onComplete?(self, error)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let stringContent = String(data: data, encoding: .utf8) else {
            onProcessingError?(self, StreamingError.unknownContent)
            return
        }
        
        var jsonObjects = [String]()
        let lines = "\(streamingBuffer)\(stringContent)".components(separatedBy: .newlines)
        for line in lines {
            if line.hasPrefix("data:") {
                let obj = line.trimmingPrefix("data:").trimmingCharacters(in: .whitespacesAndNewlines)
                jsonObjects.append(obj)
            } else if line.hasPrefix("event:") { // ignore events
                continue
            }
        }
        
        streamingBuffer = ""
        
        guard jsonObjects.isEmpty == false else {
            return
        }
        jsonObjects.enumerated().forEach { (index, jsonContent)  in
            guard jsonContent != streamingCompletionMarker else {
                return
            }
            guard let jsonData = jsonContent.data(using: .utf8) else {
                onProcessingError?(self, StreamingError.unknownContent)
                return
            }
            do {
                let object = try decoder.decode(ResultType.self, from: jsonData)
                onReceiveContent?(self, object)
            } catch {
                if index == jsonObjects.count - 1 {
                    streamingBuffer = "data: \(jsonContent)" // Chunk ends in a partial JSON
                } else {
                    onProcessingError?(self, error)
                }
            }
        }
    }
}
