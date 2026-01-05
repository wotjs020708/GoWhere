import Foundation

final class SaveLocationHistoryUseCase {
    private let repository: LocationHistoryRepositoryProtocol

    init(repository: LocationHistoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ location: RandomLocation) async throws {
        try await repository.saveLocation(location)
    }
}
