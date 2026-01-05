import SwiftUI
import MapKit

struct CitySelectionView: View {
    @StateObject var viewModel: CitySelectionViewModel
    @StateObject private var locationManager = LocationManager.shared

    var body: some View {
        ZStack {
            // Background Map
            Map(coordinateRegion: $viewModel.mapRegion, showsUserLocation: true, annotationItems: annotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    ZStack {
                        Circle()
                            .fill(annotation.isGenerated ? Color.red : Color.blue)
                            .frame(width: 30, height: 30)

                        Image(systemName: annotation.isGenerated ? "mappin.circle.fill" : "mappin")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                }
            }
            .ignoresSafeArea()

            // Overlay UI
            VStack(spacing: 0) {
                Spacer()

                // Generated Location Info Card
                if let location = viewModel.generatedLocation {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(location.locationName)
                                    .font(.title2.bold())
                                Text(location.city.name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Button(action: viewModel.resetSelection) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Travel time and arrival time
                        HStack {
                            Image(systemName: "car.fill")
                                .foregroundColor(.orange)
                            
                            if viewModel.isCalculatingRoute {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("경로 계산 중...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else if let travelTime = viewModel.formattedTravelTime {
                                Text("약 \(travelTime)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                if let arrivalTime = viewModel.formattedArrivalTime {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text(arrivalTime)
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .fontWeight(.semibold)
                                }
                            } else {
                                Text("위치 권한을 허용하면 도착 시간을 확인할 수 있어요")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }

                        HStack(spacing: 12) {
                            Button(action: viewModel.openNaverSearch) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                    Text("맛집 검색")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.green)
                                .cornerRadius(12)
                            }

                            Button(action: viewModel.generateRandomLocation) {
                                HStack {
                                    if viewModel.isGenerating {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                    }
                                    Text("다시 추첨")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            .disabled(viewModel.isGenerating)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 10)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Category Picker
                    VStack(spacing: 16) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Nationwide button
                                CategoryButton(
                                    title: "전국",
                                    isSelected: viewModel.selectedCity?.isNationwide == true,
                                    icon: "globe.asia.australia.fill"
                                ) {
                                    viewModel.selectNationwide()
                                }

                                // City buttons grouped by category
                                ForEach(viewModel.cityCategories, id: \.self) { category in
                                    CategoryButton(
                                        title: category,
                                        isSelected: viewModel.selectedCategory == category,
                                        icon: "building.2.fill"
                                    ) {
                                        viewModel.selectCategory(category)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 50)

                        // City selection for selected category
                        if let category = viewModel.selectedCategory {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.citiesForSelectedCategory) { city in
                                        CityChip(
                                            city: city,
                                            isSelected: viewModel.selectedCity?.id == city.id
                                        ) {
                                            viewModel.selectCity(city)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 44)
                        }

                        // Random button
                        Button(action: viewModel.generateRandomLocation) {
                            HStack(spacing: 8) {
                                if viewModel.isGenerating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "shuffle")
                                }

                                Text(viewModel.isGenerating ? "추첨 중..." : "추첨하기")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                viewModel.selectedCity == nil ? Color.gray : Color.blue
                            )
                            .cornerRadius(16)
                        }
                        .disabled(viewModel.selectedCity == nil || viewModel.isGenerating)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 10)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationManager.requestPermission()
        }
    }

    private var annotations: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []

        // Add selected city marker
        if let selectedCity = viewModel.selectedCity, !selectedCity.isNationwide, viewModel.generatedLocation == nil {
            items.append(MapAnnotationItem(coordinate: selectedCity.region, isGenerated: false))
        }

        // Add generated location marker
        if let location = viewModel.generatedLocation {
            items.append(MapAnnotationItem(coordinate: location.coordinate, isGenerated: true))
        }

        return items
    }
}

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let isGenerated: Bool
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color(.systemGray5))
            )
        }
        .buttonStyle(.plain)
    }
}

struct CityChip: View {
    let city: City
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(city.name)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.systemGray6))
                )
        }
        .buttonStyle(.plain)
    }
}
