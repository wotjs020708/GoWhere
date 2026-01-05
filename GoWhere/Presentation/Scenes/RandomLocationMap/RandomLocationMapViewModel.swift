import Foundation
import MapKit
import Combine

@MainActor
final class RandomLocationMapViewModel: ObservableObject {
    @Published var randomLocation: RandomLocation
    @Published var showingRestaurantSearch = false
    @Published var estimatedTravelTime: TimeInterval?
    @Published var estimatedArrivalTime: Date?
    @Published var isCalculatingRoute = false
    
    let isFromHistory: Bool
    private weak var coordinator: AppCoordinator?
    private let locationManager = LocationManager.shared
    private var cancellables = Set<AnyCancellable>()

    init(randomLocation: RandomLocation, coordinator: AppCoordinator, isFromHistory: Bool = false) {
        self.randomLocation = randomLocation
        self.coordinator = coordinator
        self.isFromHistory = isFromHistory
        
        // Start location updates
        locationManager.requestPermission()
        locationManager.startUpdatingLocation()
        
        // If location is already available, calculate immediately
        if let userLocation = locationManager.userLocation {
            Task { @MainActor in
                await self.calculateTravelTime(from: userLocation)
            }
        } else {
            // Subscribe to user location updates to calculate travel time
            locationManager.$userLocation
                .compactMap { $0 }
                .first()
                .sink { [weak self] userLocation in
                    Task { @MainActor in
                        await self?.calculateTravelTime(from: userLocation)
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func calculateTravelTime(from userLocation: CLLocationCoordinate2D) async {
        isCalculatingRoute = true
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: randomLocation.coordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        do {
            let response = try await directions.calculate()
            if let route = response.routes.first {
                estimatedTravelTime = route.expectedTravelTime
                estimatedArrivalTime = Date().addingTimeInterval(route.expectedTravelTime)
            }
        } catch {
            print("Failed to calculate route: \(error.localizedDescription)")
        }
        
        isCalculatingRoute = false
    }
    
    var formattedTravelTime: String? {
        guard let time = estimatedTravelTime else { return nil }
        
        let hours = Int(time) / 3600
        let minutes = Int(time) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
        }
    }
    
    var formattedArrivalTime: String? {
        guard let arrivalTime = estimatedArrivalTime else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: arrivalTime) + " 도착 예정"
    }

    func searchRestaurants() {
        HapticManager.shared.medium()
        if let url = randomLocation.naverSearchURL {
            UIApplication.shared.open(url)
        }
    }

    func tryAgain() {
        HapticManager.shared.light()
        coordinator?.pop()
    }

    func goHome() {
        HapticManager.shared.light()
        if isFromHistory {
            coordinator?.goToCitySelection()
        } else {
            coordinator?.popToRoot()
        }
    }
}
