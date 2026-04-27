import UIKit
import Foundation

enum ClaudeError: LocalizedError {
    case noAPIKey
    case imageEncodingFailed
    case networkError(Error)
    case invalidResponse
    case parseError(String)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "API key not configured. See Config.plist."
        case .imageEncodingFailed:
            return "Failed to encode image."
        case .networkError(let e):
            return "Network error: \(e.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server."
        case .parseError(let detail):
            return "Could not parse reading: \(detail)"
        case .apiError(let msg):
            return "API error: \(msg)"
        }
    }
}

actor ClaudeService {
    static let shared = ClaudeService()

    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-sonnet-4-6"

    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["ANTHROPIC_API_KEY"] as? String,
              !key.isEmpty, key != "YOUR_API_KEY_HERE" else {
            return ""
        }
        return key
    }

    func analyze(image: UIImage, bodyPart: BodyPartType) async throws -> BodyReading {
        let key = apiKey
        guard !key.isEmpty else { throw ClaudeError.noAPIKey }

        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
            throw ClaudeError.imageEncodingFailed
        }
        let base64Image = imageData.base64EncodedString()

        let requestBody: [String: Any] = [
            "model": model,
            "max_tokens": 1500,
            "system": bodyPart.systemPrompt,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": "Please analyze this \(bodyPart.displayName.lowercased()) and provide a complete reading."
                        ]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ClaudeError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }

        if http.statusCode != 200 {
            let msg = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["error"] as? [String: Any]
            let errText = msg?["message"] as? String ?? "Status \(http.statusCode)"
            throw ClaudeError.apiError(errText)
        }

        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = json["content"] as? [[String: Any]],
            let firstBlock = content.first,
            let text = firstBlock["text"] as? String
        else {
            throw ClaudeError.invalidResponse
        }

        return try parseReading(from: text)
    }

    private func parseReading(from text: String) throws -> BodyReading {
        // Strip markdown code fences if present
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```json") { cleaned = String(cleaned.dropFirst(7)) }
        if cleaned.hasPrefix("```")     { cleaned = String(cleaned.dropFirst(3)) }
        if cleaned.hasSuffix("```")     { cleaned = String(cleaned.dropLast(3)) }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            throw ClaudeError.parseError("Could not convert response to data")
        }

        do {
            return try JSONDecoder().decode(BodyReading.self, from: data)
        } catch {
            throw ClaudeError.parseError(error.localizedDescription)
        }
    }
}
