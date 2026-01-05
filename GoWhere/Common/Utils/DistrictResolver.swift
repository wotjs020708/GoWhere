import Foundation
import CoreLocation

final class DistrictResolver {
    static let shared = DistrictResolver()

    private init() {}

    func resolveDistrict(for coordinate: CLLocationCoordinate2D, in cityName: String) -> String? {
        switch cityName {
        case "서울":
            return resolveSeoulDistrict(coordinate)
        case "부산":
            return resolveBusanDistrict(coordinate)
        case "대구":
            return resolveDaeguDistrict(coordinate)
        case "인천":
            return resolveIncheonDistrict(coordinate)
        case "광주":
            return resolveGwangjuDistrict(coordinate)
        case "대전":
            return resolveDaejeonDistrict(coordinate)
        case "울산":
            return resolveUlsanDistrict(coordinate)
        default:
            return nil
        }
    }

    func resolveDong(for coordinate: CLLocationCoordinate2D, in cityName: String, district: String?) -> String? {
        guard let district = district else { return nil }

        // Use reverse geocoding to get dong information
        // For now, return sample dong names based on location within district
        // In production, you would use CLGeocoder or a proper address API

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        // Generate a pseudo-dong based on coordinate hash (for demo purposes)
        // In real app, use CLGeocoder.reverseGeocodeLocation
        return generateDongName(for: coordinate, district: district)
    }

    private func generateDongName(for coordinate: CLLocationCoordinate2D, district: String) -> String {
        // Sample dong generation based on coordinate
        // In production, use actual reverse geocoding
        let latHash = Int((coordinate.latitude * 1000).truncatingRemainder(dividingBy: 10))
        let lonHash = Int((coordinate.longitude * 1000).truncatingRemainder(dividingBy: 10))

        let dongSuffixes = ["1동", "2동", "3동", "본동", "역삼동", "논현동", "청담동", "삼성동", "대치동", "도곡동"]
        let index = (latHash + lonHash) % dongSuffixes.count

        // For common districts, use known dong names
        if district == "강남구" {
            return ["역삼동", "논현동", "청담동", "삼성동", "대치동", "도곡동"][index % 6]
        } else if district == "서초구" {
            return ["서초동", "반포동", "잠원동", "방배동", "양재동"][index % 5]
        } else if district == "송파구" {
            return ["잠실동", "신천동", "풍납동", "송파동", "가락동", "문정동"][index % 6]
        } else {
            return dongSuffixes[index]
        }
    }

    // MARK: - Seoul Districts
    private func resolveSeoulDistrict(_ coord: CLLocationCoordinate2D) -> String {
        let districts: [(String, CLLocationCoordinate2D, Double)] = [
            ("강남구", CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276), 0.05),
            ("강동구", CLLocationCoordinate2D(latitude: 37.5301, longitude: 127.1238), 0.05),
            ("강북구", CLLocationCoordinate2D(latitude: 37.6396, longitude: 127.0257), 0.05),
            ("강서구", CLLocationCoordinate2D(latitude: 37.5509, longitude: 126.8495), 0.05),
            ("관악구", CLLocationCoordinate2D(latitude: 37.4784, longitude: 126.9516), 0.05),
            ("광진구", CLLocationCoordinate2D(latitude: 37.5384, longitude: 127.0822), 0.05),
            ("구로구", CLLocationCoordinate2D(latitude: 37.4955, longitude: 126.8874), 0.05),
            ("금천구", CLLocationCoordinate2D(latitude: 37.4519, longitude: 126.9018), 0.05),
            ("노원구", CLLocationCoordinate2D(latitude: 37.6542, longitude: 127.0568), 0.05),
            ("도봉구", CLLocationCoordinate2D(latitude: 37.6688, longitude: 127.0471), 0.05),
            ("동대문구", CLLocationCoordinate2D(latitude: 37.5744, longitude: 127.0396), 0.05),
            ("동작구", CLLocationCoordinate2D(latitude: 37.5124, longitude: 126.9393), 0.05),
            ("마포구", CLLocationCoordinate2D(latitude: 37.5663, longitude: 126.9019), 0.05),
            ("서대문구", CLLocationCoordinate2D(latitude: 37.5791, longitude: 126.9368), 0.05),
            ("서초구", CLLocationCoordinate2D(latitude: 37.4837, longitude: 127.0324), 0.05),
            ("성동구", CLLocationCoordinate2D(latitude: 37.5634, longitude: 127.0369), 0.05),
            ("성북구", CLLocationCoordinate2D(latitude: 37.5894, longitude: 127.0167), 0.05),
            ("송파구", CLLocationCoordinate2D(latitude: 37.5145, longitude: 127.1059), 0.05),
            ("양천구", CLLocationCoordinate2D(latitude: 37.5170, longitude: 126.8664), 0.05),
            ("영등포구", CLLocationCoordinate2D(latitude: 37.5264, longitude: 126.8962), 0.05),
            ("용산구", CLLocationCoordinate2D(latitude: 37.5384, longitude: 126.9654), 0.05),
            ("은평구", CLLocationCoordinate2D(latitude: 37.6027, longitude: 126.9291), 0.05),
            ("종로구", CLLocationCoordinate2D(latitude: 37.5735, longitude: 126.9788), 0.05),
            ("중구", CLLocationCoordinate2D(latitude: 37.5641, longitude: 126.9979), 0.05),
            ("중랑구", CLLocationCoordinate2D(latitude: 37.6063, longitude: 127.0925), 0.05)
        ]
        return findClosestDistrict(coord, in: districts)
    }

    // MARK: - Busan Districts
    private func resolveBusanDistrict(_ coord: CLLocationCoordinate2D) -> String {
        let districts: [(String, CLLocationCoordinate2D, Double)] = [
            ("중구", CLLocationCoordinate2D(latitude: 35.1063, longitude: 129.0326), 0.05),
            ("서구", CLLocationCoordinate2D(latitude: 35.0979, longitude: 129.0246), 0.05),
            ("동구", CLLocationCoordinate2D(latitude: 35.1295, longitude: 129.0454), 0.05),
            ("영도구", CLLocationCoordinate2D(latitude: 35.0913, longitude: 129.0679), 0.05),
            ("부산진구", CLLocationCoordinate2D(latitude: 35.1628, longitude: 129.0530), 0.05),
            ("동래구", CLLocationCoordinate2D(latitude: 35.2049, longitude: 129.0825), 0.05),
            ("남구", CLLocationCoordinate2D(latitude: 35.1362, longitude: 129.0845), 0.05),
            ("북구", CLLocationCoordinate2D(latitude: 35.1976, longitude: 128.9906), 0.05),
            ("해운대구", CLLocationCoordinate2D(latitude: 35.1631, longitude: 129.1635), 0.05),
            ("사하구", CLLocationCoordinate2D(latitude: 35.1045, longitude: 128.9746), 0.05),
            ("금정구", CLLocationCoordinate2D(latitude: 35.2429, longitude: 129.0929), 0.05),
            ("강서구", CLLocationCoordinate2D(latitude: 35.2120, longitude: 128.9808), 0.05),
            ("연제구", CLLocationCoordinate2D(latitude: 35.1765, longitude: 129.0819), 0.05),
            ("수영구", CLLocationCoordinate2D(latitude: 35.1454, longitude: 129.1134), 0.05),
            ("사상구", CLLocationCoordinate2D(latitude: 35.1528, longitude: 128.9909), 0.05),
            ("기장군", CLLocationCoordinate2D(latitude: 35.2446, longitude: 129.2217), 0.08)
        ]
        return findClosestDistrict(coord, in: districts)
    }

    // MARK: - Daegu Districts
    private func resolveDaeguDistrict(_ coord: CLLocationCoordinate2D) -> String {
        let districts: [(String, CLLocationCoordinate2D, Double)] = [
            ("중구", CLLocationCoordinate2D(latitude: 35.8694, longitude: 128.6067), 0.05),
            ("동구", CLLocationCoordinate2D(latitude: 35.8869, longitude: 128.6350), 0.05),
            ("서구", CLLocationCoordinate2D(latitude: 35.8719, longitude: 128.5592), 0.05),
            ("남구", CLLocationCoordinate2D(latitude: 35.8464, longitude: 128.5975), 0.05),
            ("북구", CLLocationCoordinate2D(latitude: 35.8858, longitude: 128.5829), 0.05),
            ("수성구", CLLocationCoordinate2D(latitude: 35.8581, longitude: 128.6311), 0.05),
            ("달서구", CLLocationCoordinate2D(latitude: 35.8299, longitude: 128.5326), 0.05),
            ("달성군", CLLocationCoordinate2D(latitude: 35.7749, longitude: 128.4314), 0.08)
        ]
        return findClosestDistrict(coord, in: districts)
    }

    // MARK: - Incheon Districts
    private func resolveIncheonDistrict(_ coord: CLLocationCoordinate2D) -> String {
        let districts: [(String, CLLocationCoordinate2D, Double)] = [
            ("중구", CLLocationCoordinate2D(latitude: 37.4738, longitude: 126.6216), 0.05),
            ("동구", CLLocationCoordinate2D(latitude: 37.4739, longitude: 126.6432), 0.05),
            ("미추홀구", CLLocationCoordinate2D(latitude: 37.4635, longitude: 126.6505), 0.05),
            ("연수구", CLLocationCoordinate2D(latitude: 37.4106, longitude: 126.6779), 0.05),
            ("남동구", CLLocationCoordinate2D(latitude: 37.4469, longitude: 126.7314), 0.05),
            ("부평구", CLLocationCoordinate2D(latitude: 37.5069, longitude: 126.7219), 0.05),
            ("계양구", CLLocationCoordinate2D(latitude: 37.5376, longitude: 126.7379), 0.05),
            ("서구", CLLocationCoordinate2D(latitude: 37.5453, longitude: 126.6759), 0.05)
        ]
        return findClosestDistrict(coord, in: districts)
    }

    // MARK: - Gwangju Districts
    private func resolveGwangjuDistrict(_ coord: CLLocationCoordinate2D) -> String {
        let districts: [(String, CLLocationCoordinate2D, Double)] = [
            ("동구", CLLocationCoordinate2D(latitude: 35.1461, longitude: 126.9228), 0.05),
            ("서구", CLLocationCoordinate2D(latitude: 35.1518, longitude: 126.8895), 0.05),
            ("남구", CLLocationCoordinate2D(latitude: 35.1327, longitude: 126.9024), 0.05),
            ("북구", CLLocationCoordinate2D(latitude: 35.1740, longitude: 126.9117), 0.05),
            ("광산구", CLLocationCoordinate2D(latitude: 35.1396, longitude: 126.7935), 0.06)
        ]
        return findClosestDistrict(coord, in: districts)
    }

    // MARK: - Daejeon Districts
    private func resolveDaejeonDistrict(_ coord: CLLocationCoordinate2D) -> String {
        let districts: [(String, CLLocationCoordinate2D, Double)] = [
            ("동구", CLLocationCoordinate2D(latitude: 36.3504, longitude: 127.4548), 0.05),
            ("중구", CLLocationCoordinate2D(latitude: 36.3255, longitude: 127.4211), 0.05),
            ("서구", CLLocationCoordinate2D(latitude: 36.3556, longitude: 127.3835), 0.05),
            ("유성구", CLLocationCoordinate2D(latitude: 36.3624, longitude: 127.3563), 0.06),
            ("대덕구", CLLocationCoordinate2D(latitude: 36.3467, longitude: 127.4169), 0.05)
        ]
        return findClosestDistrict(coord, in: districts)
    }

    // MARK: - Ulsan Districts
    private func resolveUlsanDistrict(_ coord: CLLocationCoordinate2D) -> String {
        let districts: [(String, CLLocationCoordinate2D, Double)] = [
            ("중구", CLLocationCoordinate2D(latitude: 35.5694, longitude: 129.3319), 0.05),
            ("남구", CLLocationCoordinate2D(latitude: 35.5460, longitude: 129.3300), 0.05),
            ("동구", CLLocationCoordinate2D(latitude: 35.5050, longitude: 129.4163), 0.05),
            ("북구", CLLocationCoordinate2D(latitude: 35.5819, longitude: 129.3614), 0.06),
            ("울주군", CLLocationCoordinate2D(latitude: 35.5226, longitude: 129.1536), 0.08)
        ]
        return findClosestDistrict(coord, in: districts)
    }

    // MARK: - Helper
    private func findClosestDistrict(_ coord: CLLocationCoordinate2D, in districts: [(String, CLLocationCoordinate2D, Double)]) -> String {
        var closestDistrict = districts[0].0
        var minDistance = Double.infinity

        for (name, center, radius) in districts {
            let distance = calculateDistance(from: coord, to: center)
            if distance < minDistance && distance <= radius {
                minDistance = distance
                closestDistrict = name
            }
        }

        return closestDistrict
    }

    private func calculateDistance(from coord1: CLLocationCoordinate2D, to coord2: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let location2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        return location1.distance(from: location2) / 111000.0 // Convert meters to degrees
    }
}
