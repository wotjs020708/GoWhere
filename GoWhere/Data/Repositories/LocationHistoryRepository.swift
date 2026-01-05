import Foundation

final class LocationHistoryRepository: LocationHistoryRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let historyKey = "location_history"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func fetchHistory() async throws -> [RandomLocation] {
        guard let data = userDefaults.data(forKey: historyKey) else {
            return []
        }
        let decoder = JSONDecoder()
        return try decoder.decode([RandomLocation].self, from: data)
    }

    func saveLocation(_ location: RandomLocation) async throws {
        var history = try await fetchHistory()

        // Add to beginning (most recent first)
        history.insert(location, at: 0)

        // Limit to 100 items
        if history.count > 100 {
            history = Array(history.prefix(100))
        }

        let encoder = JSONEncoder()
        let data = try encoder.encode(history)
        userDefaults.set(data, forKey: historyKey)
    }

    func deleteLocation(id: String) async throws {
        var history = try await fetchHistory()
        history.removeAll { $0.id == id }

        let encoder = JSONEncoder()
        let data = try encoder.encode(history)
        userDefaults.set(data, forKey: historyKey)
    }

    func clearHistory() async throws {
        userDefaults.removeObject(forKey: historyKey)
    }
}
