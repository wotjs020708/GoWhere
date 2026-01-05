import SwiftUI
import MapKit

struct RandomLocationMapView: View {
    @StateObject var viewModel: RandomLocationMapViewModel
    @StateObject private var locationManager = LocationManager.shared
    @State private var showAnimation = false
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        ZStack {
            // Map with iOS 17+ API
            Map(position: $position) {
                // User location marker (blue dot)
                UserAnnotation()
                
                // Random location marker (red pin)
                Annotation(viewModel.randomLocation.locationName, coordinate: viewModel.randomLocation.coordinate) {
                    VStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                            .scaleEffect(showAnimation && !viewModel.isFromHistory ? 1.2 : 1.0)
                            .animation(
                                viewModel.isFromHistory ? nil : Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                value: showAnimation
                            )
                        
                        Text(viewModel.randomLocation.locationName)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                }
            }
            .mapControls {
                if !viewModel.isFromHistory {
                    MapUserLocationButton()
                }
                MapCompass()
                MapScaleView()
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                // Request location permission and start updating
                locationManager.requestPermission()
                locationManager.startUpdatingLocation()
                
                // Set initial camera position to random location
                position = .region(MKCoordinateRegion(
                    center: viewModel.randomLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))
            }

            // Overlay buttons
            VStack {
                Spacer()

                VStack(spacing: 12) {
                    // Info card
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.randomLocation.locationName)
                                    .font(.headline)
                                if let district = viewModel.randomLocation.district {
                                    Text(district)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                        }

                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.secondary)
                            Text(viewModel.randomLocation.generatedAt, style: .time)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
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
                                Text("위치 권한을 허용해주세요")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 8)

                    // Restaurant search button
                    Button(action: viewModel.searchRestaurants) {
                        HStack {
                            Image(systemName: "fork.knife")
                            Text("주변 맛집 검색")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.green)
                        .cornerRadius(16)
                    }

                    // Try again button (only show when not from history)
                    if !viewModel.isFromHistory {
                        Button(action: viewModel.tryAgain) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("다시 추첨")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .cornerRadius(16)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("추천 장소")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: viewModel.goHome) {
                    Image(systemName: "house.fill")
                }
            }
        }
        .onAppear {
            // Only animate pin for new locations (not from history)
            if !viewModel.isFromHistory {
                showAnimation = true
            }
        }
    }
}
