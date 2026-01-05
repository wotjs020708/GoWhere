import Foundation

final class FetchLocationHistoryUseCase {
    private let repository: LocationHistoryRepositoryProtocol

    init(repository: LocationHistoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [RandomLocation] {
        try await repository.fetchHistory()
    }
}
