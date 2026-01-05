import Foundation
import Combine
import MapKit
import SwiftUI

@MainActor
final class CitySelectionViewModel: ObservableObject {
    @Published var cities: [City] = City.cities
    @Published var selectedCity: City?
    @Published var selectedCategory: String?
    @Published var isGenerating = false
    @Published var generatedLocation: RandomLocation?
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.5, longitude: 127.5), // Korea center
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    
    // Travel time properties
    @Published var estimatedTravelTime: TimeInterval?
    @Published var estimatedArrivalTime: Date?
    @Published var isCalculatingRoute = false

    private let generateRandomLocationUseCase: GenerateRandomLocationUseCase
    private let saveLocationHistoryUseCase: SaveLocationHistoryUseCase
    private weak var coordinator: AppCoordinator?
    private let locationManager = LocationManager.shared

    // Category mapping
    let cityCategories = ["수도권", "충청권", "전라권", "경상권", "강원권", "제주"]

    private let categoryMap: [String: [String]] = [
        "수도권": ["서울", "인천", "수원", "성남", "고양", "용인", "부천"],
        "충청권": ["대전", "청주", "천안", "충주"],
        "전라권": ["광주", "전주", "목포", "여수"],
        "경상권": ["부산", "대구", "울산", "창원", "포항", "김해"],
        "강원권": ["춘천", "강릉", "원주"],
        "제주": ["제주"]
    ]

    var citiesForSelectedCategory: [City] {
        guard let category = selectedCategory,
              let cityNames = categoryMap[category] else {
            return []
        }
        return cities.filter { city in
            !city.isNationwide && cityNames.contains(city.name)
        }
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

    init(
        generateRandomLocationUseCase: GenerateRandomLocationUseCase,
        saveLocationHistoryUseCase: SaveLocationHistoryUseCase,
        coordinator: AppCoordinator
    ) {
        self.generateRandomLocationUseCase = generateRandomLocationUseCase
        self.saveLocationHistoryUseCase = saveLocationHistoryUseCase
        self.coordinator = coordinator
    }
    
    func calculateTravelTime() async {
        guard let destination = generatedLocation,
              let userLocation = locationManager.userLocation else { return }
        
        isCalculatingRoute = true
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
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

    func selectCategory(_ category: String) {
        HapticManager.shared.selection()
        selectedCategory = category
        selectedCity = nil

        // Zoom to category region
        if let cityNames = categoryMap[category],
           let firstCityName = cityNames.first,
           let firstCity = cities.first(where: { $0.name == firstCityName }) {
            withAnimation(.easeInOut(duration: 0.5)) {
                mapRegion = MKCoordinateRegion(
                    center: firstCity.region,
                    span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
                )
            }
        }
    }

    func selectNationwide() {
        HapticManager.shared.selection()
        selectedCategory = nil
        selectedCity = City.nationwide

        // Zoom out to show entire Korea
        withAnimation(.easeInOut(duration: 0.5)) {
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 36.5, longitude: 127.5),
                span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
            )
        }
    }

    func selectCity(_ city: City) {
        HapticManager.shared.selection()
        selectedCity = city

        // Zoom to selected city
        withAnimation(.easeInOut(duration: 0.5)) {
            mapRegion = MKCoordinateRegion(
                center: city.region,
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
    }

    func generateRandomLocation() {
        guard let city = selectedCity else { return }

        isGenerating = true

        // Step 1: Zoom out animation
        withAnimation(.easeInOut(duration: 0.4)) {
            if city.isNationwide {
                mapRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 36.5, longitude: 127.5),
                    span: MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15)
                )
            } else {
                mapRegion = MKCoordinateRegion(
                    center: city.region,
                    span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
                )
            }
        }

        // Step 2: Generate location with haptic effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            HapticManager.shared.randomizingEffect { [weak self] in
                guard let self = self else { return }

                let randomLocation = self.generateRandomLocationUseCase.execute(for: city)
                self.generatedLocation = randomLocation

                // Step 3: Zoom in to the random location
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.mapRegion = MKCoordinateRegion(
                        center: randomLocation.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }

                // Save to history
                Task {
                    try? await self.saveLocationHistoryUseCase.execute(randomLocation)
                    // Calculate travel time after location is generated
                    await self.calculateTravelTime()
                }

                // Complete animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.isGenerating = false
                }
            }
        }
    }

    func openNaverSearch() {
        guard let location = generatedLocation else { return }

        // Try to open Naver Map app first
        if let appURL = location.naverMapAppURL,
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        }
        // Fallback to web search
        else if let webURL = location.naverSearchURL {
            UIApplication.shared.open(webURL)
        }
    }

    func resetSelection() {
        // Step 1: Zoom out animation
        if let city = selectedCity, !city.isNationwide {
            withAnimation(.easeInOut(duration: 0.4)) {
                mapRegion = MKCoordinateRegion(
                    center: city.region,
                    span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
                )
            }
        }

        // Step 2: Reset location and zoom to city view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            self.generatedLocation = nil
            self.estimatedTravelTime = nil
            self.estimatedArrivalTime = nil

            if let city = self.selectedCity, !city.isNationwide {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.mapRegion = MKCoordinateRegion(
                        center: city.region,
                        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    )
                }
            }
        }
    }
}
