import Foundation
import Combine
import MapKit

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var historyLocations: [RandomLocation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )

    private let fetchHistoryUseCase: FetchLocationHistoryUseCase
    private let deleteHistoryUseCase: DeleteLocationHistoryUseCase
    private weak var coordinator: AppCoordinator?

    init(
        fetchHistoryUseCase: FetchLocationHistoryUseCase,
        deleteHistoryUseCase: DeleteLocationHistoryUseCase,
        coordinator: AppCoordinator
    ) {
        self.fetchHistoryUseCase = fetchHistoryUseCase
        self.deleteHistoryUseCase = deleteHistoryUseCase
        self.coordinator = coordinator
    }

    func loadHistory() async {
        isLoading = true
        errorMessage = nil

        do {
            historyLocations = try await fetchHistoryUseCase.execute()
            updateMapRegion()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteLocation(_ location: RandomLocation) async {
        HapticManager.shared.light()

        do {
            try await deleteHistoryUseCase.execute(id: location.id)
            await loadHistory()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectLocation(_ location: RandomLocation) {
        HapticManager.shared.selection()
        coordinator?.showRandomLocation(location, isFromHistory: true)
    }

    private func updateMapRegion() {
        guard !historyLocations.isEmpty else { return }

        if historyLocations.count == 1 {
            region = MKCoordinateRegion(
                center: historyLocations[0].coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        } else {
            // Calculate bounding box for all locations
            var minLat = historyLocations[0].coordinate.latitude
            var maxLat = historyLocations[0].coordinate.latitude
            var minLon = historyLocations[0].coordinate.longitude
            var maxLon = historyLocations[0].coordinate.longitude

            for location in historyLocations {
                minLat = min(minLat, location.coordinate.latitude)
                maxLat = max(maxLat, location.coordinate.latitude)
                minLon = min(minLon, location.coordinate.longitude)
                maxLon = max(maxLon, location.coordinate.longitude)
            }

            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            )

            let span = MKCoordinateSpan(
                latitudeDelta: (maxLat - minLat) * 1.5,
                longitudeDelta: (maxLon - minLon) * 1.5
            )

            region = MKCoordinateRegion(center: center, span: span)
        }
    }
}
