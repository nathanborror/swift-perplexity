import Foundation

public struct ChatRequest: Codable {
    public var model: String
    public var messages: [Message]
    public var temperature: Double?
    public var topP: Double?
    public var topK: UInt?
    public var maxTokens: Int?
    public var stream: Bool?
    public var presencePenalty: Double?
    public var frequencyPenalty: Double?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case topP = "top_p"
        case topK = "top_k"
        case maxTokens = "max_tokens"
        case stream
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
    }
    
    public init(model: String, messages: [Message], temperature: Double? = nil, topP: Double? = nil, topK: UInt? = nil,
                maxTokens: Int? = nil, stream: Bool? = nil, presencePenalty: Double? = nil, frequencyPenalty: Double? = nil) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.topP = topP
        self.maxTokens = maxTokens
        self.stream = stream
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
    }
}

public struct ChatResponse: Codable {
    public let id: String
    public let model: String
    public let object: String?
    public let created: Date
    public let choices: [Choice]
    public let usage: Usage?
    
    public struct Choice: Codable {
        public let index: Int
        public let message: Message
        public let finishReason: FinishReason?
        
        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }
}

public struct ChatStreamResponse: Codable {
    public let id: String
    public let object: String?
    public let created: Date?
    public let model: String
    public let choices: [Choice]
    public let usage: Usage?
    
    public struct Choice: Codable {
        public let index: Int
        public let delta: Message
        public let message: Message
        public let finishReason: FinishReason?
        
        enum CodingKeys: String, CodingKey {
            case index
            case delta
            case message
            case finishReason = "finish_reason"
        }
    }
}

public struct Message: Codable {
    public var role: Role
    public var content: String
    
    public enum Role: String, Codable {
        case system, assistant, user
    }
    
    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}

public enum FinishReason: String, Codable {
    case stop, length, model_length
}

public struct Usage: Codable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}
