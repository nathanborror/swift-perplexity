import Foundation

public struct Defaults {
    
    public static let apiHost = URL(string: "https://api.perplexity.ai")!
    
    public static let chatModel = "llama-3.1-sonar-large-128k-chat"
    
    public static let models: [Model] = [
        
        // Sonar models
        
        .init(
            id: "llama-3.1-sonar-small-128k-online",
            name: "Sonar (8b)",
            owner: "perplexity",
            contextWindow: 127_072
        ),
        .init(
            id: "llama-3.1-sonar-large-128k-online",
            name: "Sonar (70b)",
            owner: "perplexity",
            contextWindow: 127_072
        ),
        .init(
            id: "llama-3.1-sonar-huge-128k-online",
            name: "Sonar (405b)",
            owner: "perplexity",
            contextWindow: 127_072
        ),
        
        // Chat models
        
        .init(
            id: "llama-3.1-sonar-small-128k-chat",
            name: "Sonar Chat (8b)",
            owner: "perplexity",
            contextWindow: 127_072
        ),
        .init(
            id: "llama-3.1-sonar-large-128k-chat",
            name: "Sonar Chat (70b)",
            owner: "perplexity",
            contextWindow: 127_072
        ),
        
        // Open source models
        
        .init(
            id: "llama-3.1-8b-instruct",
            name: "Llama 3.1 (8b)",
            owner: "perplexity",
            contextWindow: 127_072
        ),
        .init(
            id: "llama-3.1-70b-instruct",
            name: "Llama 3.1 (70b)",
            owner: "perplexity",
            contextWindow: 127_072
        ),
    ]
}
