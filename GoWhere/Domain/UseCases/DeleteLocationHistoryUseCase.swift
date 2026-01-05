import Foundation

final class DeleteLocationHistoryUseCase {
    private let repository: LocationHistoryRepositoryProtocol

    init(repository: LocationHistoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String) async throws {
        try await repository.deleteLocation(id: id)
    }
}
