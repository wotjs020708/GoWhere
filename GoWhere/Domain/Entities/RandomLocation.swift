import Foundation
import CoreLocation

struct RandomLocation: Identifiable, Hashable, Codable {
    let id: String
    let city: City
    let coordinate: CLLocationCoordinate2D
    let district: String?
    let dong: String?
    let generatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, city, coordinate, district, dong, generatedAt
    }

    init(city: City, coordinate: CLLocationCoordinate2D) {
        self.id = UUID().uuidString
        self.city = city
        self.coordinate = coordinate
        self.district = DistrictResolver.shared.resolveDistrict(for: coordinate, in: city.name)
        self.dong = DistrictResolver.shared.resolveDong(for: coordinate, in: city.name, district: self.district)
        self.generatedAt = Date()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        city = try container.decode(City.self, forKey: .city)
        coordinate = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinate)
        district = try container.decodeIfPresent(String.self, forKey: .district)
        dong = try container.decodeIfPresent(String.self, forKey: .dong)
        generatedAt = try container.decode(Date.self, forKey: .generatedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(city, forKey: .city)
        try container.encode(coordinate, forKey: .coordinate)
        try container.encodeIfPresent(district, forKey: .district)
        try container.encodeIfPresent(dong, forKey: .dong)
        try container.encode(generatedAt, forKey: .generatedAt)
    }

    var locationName: String {
        var parts: [String] = [city.name]
        if let district = district {
            parts.append(district)
        }
        if let dong = dong {
            parts.append(dong)
        }
        return parts.joined(separator: " ")
    }

    var searchQuery: String {
        if let district = district {
            return "\(city.name) \(district)"
        }
        return city.name
    }

    // Naver Map App URL (if installed)
    var naverMapAppURL: URL? {
        let query = "\(searchQuery) 맛집"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        // nmap://search?query=검색어&lat=위도&lng=경도
        return URL(string: "nmap://search?query=\(encodedQuery)&lat=\(coordinate.latitude)&lng=\(coordinate.longitude)")
    }

    // Naver Web Search URL (fallback)
    var naverSearchURL: URL? {
        let query = "\(searchQuery) 맛집"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://search.naver.com/search.naver?query=\(encodedQuery)&lat=\(coordinate.latitude)&lng=\(coordinate.longitude)")
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: RandomLocation, rhs: RandomLocation) -> Bool {
        lhs.id == rhs.id
    }
}
