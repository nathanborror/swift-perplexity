import Foundation

public struct Defaults {
    
    public static let apiHost = URL(string: "https://api.perplexity.ai")!
    
    public static let chatModel = "llama-3.1-sonar-large-128k-chat"
    
    public static let models: [String] = [
        "llama-3.1-sonar-small-128k-chat",
        "llama-3.1-sonar-small-128k-online",
        "llama-3.1-sonar-large-128k-chat",
        "llama-3.1-sonar-large-128k-online",
        "llama-3.1-8b-instruct",
        "llama-3.1-70b-instruct",
    ]
}
