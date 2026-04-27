import SwiftUI

enum BodyPartType: String, CaseIterable, Identifiable {
    case face, palm, tongue, eye, nails

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .face:   return "Face"
        case .palm:   return "Palm"
        case .tongue: return "Tongue"
        case .eye:    return "Eye"
        case .nails:  return "Nails"
        }
    }

    var subtitle: String {
        switch self {
        case .face:   return "Physiognomy & Structure"
        case .palm:   return "Palmistry & Life Lines"
        case .tongue: return "TCM Tongue Analysis"
        case .eye:    return "Iridology"
        case .nails:  return "Nail Reading"
        }
    }

    var emoji: String {
        switch self {
        case .face:   return "👤"
        case .palm:   return "🖐"
        case .tongue: return "👅"
        case .eye:    return "👁"
        case .nails:  return "💅"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .face:   return [Color(hex: "C9A96E"), Color(hex: "7A5C1E")]
        case .palm:   return [Color(hex: "E8C17A"), Color(hex: "8B4513")]
        case .tongue: return [Color(hex: "E8A0A0"), Color(hex: "A04040")]
        case .eye:    return [Color(hex: "7BAFD4"), Color(hex: "2A5F8F")]
        case .nails:  return [Color(hex: "A8D8A8"), Color(hex: "3A7A3A")]
        }
    }

    var photoInstructions: String {
        switch self {
        case .face:
            return "Take a clear, front-facing photo in natural or even lighting. Remove glasses if worn."
        case .palm:
            return "Open your dominant hand flat, palm facing up. Use bright light so lines are clearly visible."
        case .tongue:
            return "Stick out your tongue fully in natural light. No filters. Avoid eating or drinking 30 min prior."
        case .eye:
            return "Open your eye wide and hold camera close. Use bright light or flash to illuminate the iris."
        case .nails:
            return "Lay your hand flat on a light surface with nails facing up. Use bright, even lighting."
        }
    }

    var systemPrompt: String {
        switch self {
        case .face:
            return facePrompt
        case .palm:
            return palmPrompt
        case .tongue:
            return tonguePrompt
        case .eye:
            return eyePrompt
        case .nails:
            return nailsPrompt
        }
    }
}

// MARK: - Claude prompts (return JSON only)
private let facePrompt = """
You are an expert face reader combining physiognomy, structural analysis, and traditional face-reading traditions (Chinese mien shiang, Western physiognomy). Analyze the face in the photo and return ONLY valid JSON — no markdown, no explanation — in this exact schema:
{
  "title": "Face Reading",
  "overallImpression": "2-3 sentence overall read",
  "keyFeatures": ["feature 1","feature 2","feature 3","feature 4"],
  "sections": [
    {"zone":"Face Shape","icon":"face.smiling","observation":"…","interpretation":"…"},
    {"zone":"Forehead","icon":"brain.head.profile","observation":"…","interpretation":"…"},
    {"zone":"Eyes","icon":"eye","observation":"…","interpretation":"…"},
    {"zone":"Nose","icon":"nosesign","observation":"…","interpretation":"…"},
    {"zone":"Lips","icon":"mouth","observation":"…","interpretation":"…"},
    {"zone":"Jawline & Chin","icon":"person.crop.circle","observation":"…","interpretation":"…"},
    {"zone":"Cheekbones","icon":"sparkles","observation":"…","interpretation":"…"}
  ],
  "summary": ["insight 1","insight 2","insight 3","insight 4","insight 5"],
  "disclaimer": "Face reading is a traditional interpretive practice for self-reflection. It is not a medical diagnosis."
}
"""

private let palmPrompt = """
You are an expert palmist versed in Western palmistry, Vedic Hasta Samudrika Shastra, and Chinese hand-reading. Analyze the palm in the photo and return ONLY valid JSON — no markdown, no explanation — in this exact schema:
{
  "title": "Palm Reading",
  "overallImpression": "2-3 sentence overall read",
  "keyFeatures": ["feature 1","feature 2","feature 3","feature 4"],
  "sections": [
    {"zone":"Heart Line","icon":"heart","observation":"…","interpretation":"…"},
    {"zone":"Head Line","icon":"brain","observation":"…","interpretation":"…"},
    {"zone":"Life Line","icon":"bolt.heart","observation":"…","interpretation":"…"},
    {"zone":"Fate Line","icon":"arrow.up.right","observation":"…","interpretation":"…"},
    {"zone":"Palm Shape","icon":"hand.raised","observation":"…","interpretation":"…"},
    {"zone":"Fingers & Thumb","icon":"hand.point.up","observation":"…","interpretation":"…"},
    {"zone":"Mounts","icon":"mountain.2","observation":"…","interpretation":"…"}
  ],
  "summary": ["insight 1","insight 2","insight 3","insight 4","insight 5"],
  "disclaimer": "Palm reading is a traditional interpretive practice for self-reflection. It is not a medical or psychological diagnosis."
}
"""

private let tonguePrompt = """
You are an expert in Traditional Chinese Medicine (TCM) tongue diagnosis. Analyze the tongue in the photo for body color, coating, shape, moisture, and zone-based organ mapping. Return ONLY valid JSON — no markdown, no explanation — in this exact schema:
{
  "title": "TCM Tongue Analysis",
  "overallImpression": "2-3 sentence overall TCM read",
  "keyFeatures": ["feature 1","feature 2","feature 3","feature 4"],
  "sections": [
    {"zone":"Tip — Heart / Lungs","icon":"heart","observation":"…","interpretation":"…"},
    {"zone":"Center — Spleen / Stomach","icon":"leaf","observation":"…","interpretation":"…"},
    {"zone":"Sides — Liver / Gallbladder","icon":"waveform.path","observation":"…","interpretation":"…"},
    {"zone":"Root — Kidneys / Bladder","icon":"drop","observation":"…","interpretation":"…"},
    {"zone":"Body Color","icon":"paintbrush","observation":"…","interpretation":"…"},
    {"zone":"Coating","icon":"cloud","observation":"…","interpretation":"…"},
    {"zone":"Shape & Moisture","icon":"water.waves","observation":"…","interpretation":"…"}
  ],
  "summary": ["insight 1","insight 2","insight 3","insight 4","insight 5"],
  "disclaimer": "TCM tongue reading is a traditional wellness practice and is not a medical diagnosis."
}
"""

private let eyePrompt = """
You are an expert iridologist and eye reader. Analyze the eye in the photo covering iris color/texture, sclera, pupil, and zone-based iridology mapping. Return ONLY valid JSON — no markdown, no explanation — in this exact schema:
{
  "title": "Eye & Iris Reading",
  "overallImpression": "2-3 sentence overall read",
  "keyFeatures": ["feature 1","feature 2","feature 3","feature 4"],
  "sections": [
    {"zone":"Iris Color & Texture","icon":"eye","observation":"…","interpretation":"…"},
    {"zone":"Pupil","icon":"circle.fill","observation":"…","interpretation":"…"},
    {"zone":"Sclera","icon":"circle","observation":"…","interpretation":"…"},
    {"zone":"Inner Iris Zone","icon":"scope","observation":"…","interpretation":"…"},
    {"zone":"Outer Iris Zone","icon":"circle.dashed","observation":"…","interpretation":"…"},
    {"zone":"Eye Shape","icon":"eye.trianglebadge.exclamationmark","observation":"…","interpretation":"…"},
    {"zone":"Overall Eye Energy","icon":"sparkles","observation":"…","interpretation":"…"}
  ],
  "summary": ["insight 1","insight 2","insight 3","insight 4","insight 5"],
  "disclaimer": "Eye and iris reading is a traditional interpretive practice. It is not a substitute for professional eye care or medical diagnosis."
}
"""

private let nailsPrompt = """
You are an expert in nail analysis combining traditional character reading and hand analysis traditions. Analyze the nails in the photo and return ONLY valid JSON — no markdown, no explanation — in this exact schema:
{
  "title": "Nail Reading",
  "overallImpression": "2-3 sentence overall read",
  "keyFeatures": ["feature 1","feature 2","feature 3","feature 4"],
  "sections": [
    {"zone":"Nail Shape","icon":"rectangle.roundedtop","observation":"…","interpretation":"…"},
    {"zone":"Color & Tone","icon":"paintbrush.pointed","observation":"…","interpretation":"…"},
    {"zone":"Texture & Surface","icon":"square.grid.3x3","observation":"…","interpretation":"…"},
    {"zone":"Lunula (Moon)","icon":"moon","observation":"…","interpretation":"…"},
    {"zone":"Length & Proportion","icon":"ruler","observation":"…","interpretation":"…"},
    {"zone":"Overall Hand","icon":"hand.raised","observation":"…","interpretation":"…"},
    {"zone":"Character Insight","icon":"person.text.rectangle","observation":"…","interpretation":"…"}
  ],
  "summary": ["insight 1","insight 2","insight 3","insight 4","insight 5"],
  "disclaimer": "Nail reading is a traditional interpretive practice for self-reflection. It is not a medical diagnosis."
}
"""
