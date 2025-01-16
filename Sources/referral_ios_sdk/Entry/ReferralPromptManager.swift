

import Foundation

typealias EventSet = Set<String>

final class ReferralPromptManager {
    private var combinations: [Int: EventSet] = [:]
    private var promptCooldownInterval: TimeInterval = 0
    private var promptsEnabled = false
    private var lastPromptShowDate: Date? {
        get {
            userDefaultsManager.fetchRawValue(for: .lastPromptShowDate)
        }
        set {
            userDefaultsManager.save(newValue, for: .lastPromptShowDate)
        }
    }
    private var receivedEvents: EventSet = []
    private var triggeredCombinationsIds: Set<Int> = []
    private lazy var userDefaultsManager = UserDefaultsManager()
    private let queue = DispatchQueue(label: "ReferralPromptManagerQueue")

    func handleEvent(_ eventName: String) {
        queue.async { [self] in
            receivedEvents.insert(eventName)
            
            guard !combinations.isEmpty else { return }
            guard hasPromptCooldownCooldownPassed() else { return }
            
            for (id, events) in combinations {
                if !triggeredCombinationsIds.contains(id),
                   events.contains(eventName),
                   events.isSubset(of: receivedEvents) {
                    triggeredCombinationsIds.insert(id)
                    lastPromptShowDate = Date()
                    showPrompt()
                    break
                }
            }
        }
    }
    
    func setEventCombinations(_ combinations: [EventCombination]) {
        self.combinations = combinations.reduce(into: [Int: EventSet]()) { result, combination in
            result[combination.id] = Set(combination.events.map { $0.name })
        }
    }
    
    func setPromptCooldownInterval(_ interval: TimeInterval) {
        promptCooldownInterval = interval
    }
    
    func enablePrompts() {
        promptsEnabled = true
    }
    
    func disablePrompts() {
        promptsEnabled = false
    }
    
    func resetPromptShowCooldown() {
        userDefaultsManager.delete(.lastPromptShowDate)
    }
}

private extension ReferralPromptManager {
    func showPrompt() {
        DispatchQueue.main.async {
            Advato.shared.showReferralPrompt()
        }
    }
    
    func hasPromptCooldownCooldownPassed() -> Bool {
        guard let lastPromptShowDate else {
            return true
        }
        return Date().timeIntervalSince(lastPromptShowDate) > promptCooldownInterval
    }
}
