

import Foundation

struct EventCombination: Codable {
    let id: Int
    let events: [Event]
}

struct Event: Codable {
    let id: Int
    let name: String
}
