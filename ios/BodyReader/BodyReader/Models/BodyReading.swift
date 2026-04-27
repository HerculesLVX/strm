import Foundation

struct BodyReading: Codable, Identifiable {
    let id: UUID
    let title: String
    let overallImpression: String
    let keyFeatures: [String]
    let sections: [ReadingSection]
    let summary: [String]
    let disclaimer: String
    let createdAt: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        title = try container.decode(String.self, forKey: .title)
        overallImpression = try container.decode(String.self, forKey: .overallImpression)
        keyFeatures = try container.decode([String].self, forKey: .keyFeatures)
        sections = try container.decode([ReadingSection].self, forKey: .sections)
        summary = try container.decode([String].self, forKey: .summary)
        disclaimer = try container.decode(String.self, forKey: .disclaimer)
        createdAt = Date()
    }

    init(title: String, overallImpression: String, keyFeatures: [String],
         sections: [ReadingSection], summary: [String], disclaimer: String) {
        id = UUID()
        self.title = title
        self.overallImpression = overallImpression
        self.keyFeatures = keyFeatures
        self.sections = sections
        self.summary = summary
        self.disclaimer = disclaimer
        createdAt = Date()
    }

    enum CodingKeys: String, CodingKey {
        case title, overallImpression, keyFeatures, sections, summary, disclaimer
    }
}

struct ReadingSection: Codable, Identifiable {
    let id: UUID
    let zone: String
    let icon: String
    let observation: String
    let interpretation: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        zone = try container.decode(String.self, forKey: .zone)
        icon = try container.decode(String.self, forKey: .icon)
        observation = try container.decode(String.self, forKey: .observation)
        interpretation = try container.decode(String.self, forKey: .interpretation)
    }

    enum CodingKeys: String, CodingKey {
        case zone, icon, observation, interpretation
    }
}
