import Foundation

protocol LocationHistoryRepositoryProtocol {
    func fetchHistory() async throws -> [RandomLocation]
    func saveLocation(_ location: RandomLocation) async throws
    func deleteLocation(id: String) async throws
    func clearHistory() async throws
}
