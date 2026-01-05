import Foundation
import CoreLocation

final class GenerateRandomLocationUseCase {
    // Predefined city coordinates for nationwide selection
    private let majorCities: [City] = City.cities.filter { !$0.isNationwide }

    func execute(for city: City) -> RandomLocation {
        let maxAttempts = 100 // Prevent infinite loop
        var attempts = 0

        if city.isNationwide {
            // For nationwide, pick a random city first, then generate coordinate
            while attempts < maxAttempts {
                let randomCity = majorCities.randomElement() ?? city
                let randomCoordinate = generateRandomCoordinate(in: randomCity)
                let location = RandomLocation(city: randomCity, coordinate: randomCoordinate)

                // Check if district-level address was resolved
                if location.district != nil {
                    return location
                }
                attempts += 1
            }

            // Fallback: return last attempt even without district
            let randomCity = majorCities.randomElement() ?? city
            let randomCoordinate = generateRandomCoordinate(in: randomCity)
            return RandomLocation(city: randomCity, coordinate: randomCoordinate)
        } else {
            while attempts < maxAttempts {
                let randomCoordinate = generateRandomCoordinate(in: city)
                let location = RandomLocation(city: city, coordinate: randomCoordinate)

                // Check if district-level address was resolved
                if location.district != nil {
                    return location
                }
                attempts += 1
            }

            // Fallback: return last attempt even without district
            let randomCoordinate = generateRandomCoordinate(in: city)
            return RandomLocation(city: city, coordinate: randomCoordinate)
        }
    }

    private func generateRandomCoordinate(in city: City) -> CLLocationCoordinate2D {
        // Generate random point within circular radius
        let radiusInDegrees = city.radius / 111000.0 // rough conversion to degrees

        let u = Double.random(in: 0...1)
        let v = Double.random(in: 0...1)

        let w = radiusInDegrees * sqrt(u)
        let t = 2 * .pi * v

        let x = w * cos(t)
        let y = w * sin(t)

        let newLat = city.region.latitude + y
        let newLon = city.region.longitude + x / cos(city.region.latitude * .pi / 180)

        return CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
    }
}
