import Foundation
import CoreLocation

struct City: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let region: CLLocationCoordinate2D
    let radius: Double // in meters
    let isNationwide: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, region, radius, isNationwide
    }

    init(id: String = UUID().uuidString, name: String, latitude: Double, longitude: Double, radius: Double = 10000, isNationwide: Bool = false) {
        self.id = id
        self.name = name
        self.region = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.radius = radius
        self.isNationwide = isNationwide
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        region = try container.decode(CLLocationCoordinate2D.self, forKey: .region)
        radius = try container.decode(Double.self, forKey: .radius)
        isNationwide = try container.decode(Bool.self, forKey: .isNationwide)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(region, forKey: .region)
        try container.encode(radius, forKey: .radius)
        try container.encode(isNationwide, forKey: .isNationwide)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id
    }
}

extension City {
    static let nationwide = City(
        name: "전국",
        latitude: 36.5, // Center of Korea
        longitude: 127.5,
        radius: 500000, // Large radius for nationwide
        isNationwide: true
    )

    static let cities: [City] = [
        // 전국
        nationwide,

        // 서울
        City(name: "서울", latitude: 37.5665, longitude: 126.9780, radius: 15000),

        // 경기도
        City(name: "수원", latitude: 37.2636, longitude: 127.0286, radius: 10000),
        City(name: "성남", latitude: 37.4201, longitude: 127.1262, radius: 10000),
        City(name: "고양", latitude: 37.6584, longitude: 126.8320, radius: 10000),
        City(name: "용인", latitude: 37.2410, longitude: 127.1776, radius: 10000),

        // 인천
        City(name: "인천", latitude: 37.4563, longitude: 126.7052, radius: 12000),

        // 대전
        City(name: "대전", latitude: 36.3504, longitude: 127.3845, radius: 10000),

        // 대구
        City(name: "대구", latitude: 35.8714, longitude: 128.6014, radius: 10000),

        // 부산
        City(name: "부산", latitude: 35.1796, longitude: 129.0756, radius: 12000),

        // 광주
        City(name: "광주", latitude: 35.1595, longitude: 126.8526, radius: 10000),

        // 울산
        City(name: "울산", latitude: 35.5384, longitude: 129.3114, radius: 10000),

        // 강원도
        City(name: "춘천", latitude: 37.8813, longitude: 127.7300, radius: 8000),
        City(name: "강릉", latitude: 37.7519, longitude: 128.8761, radius: 8000),

        // 충청도
        City(name: "청주", latitude: 36.6424, longitude: 127.4890, radius: 9000),
        City(name: "천안", latitude: 36.8151, longitude: 127.1139, radius: 9000),

        // 전라도
        City(name: "전주", latitude: 35.8242, longitude: 127.1480, radius: 8000),
        City(name: "여수", latitude: 34.7604, longitude: 127.6622, radius: 8000),

        // 경상도
        City(name: "포항", latitude: 36.0190, longitude: 129.3435, radius: 9000),
        City(name: "창원", latitude: 35.2272, longitude: 128.6811, radius: 9000),

        // 제주도
        City(name: "제주", latitude: 33.4996, longitude: 126.5312, radius: 12000)
    ]
}
