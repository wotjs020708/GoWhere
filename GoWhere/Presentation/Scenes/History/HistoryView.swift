import SwiftUI
import MapKit

struct HistoryView: View {
    @StateObject var viewModel: HistoryViewModel

    var body: some View {
        ZStack {
            if viewModel.historyLocations.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "map")
                        .font(.system(size: 80))
                        .foregroundColor(.secondary)

                    Text("아직 추첨한 장소가 없어요")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("도시를 선택하고 추첨해보세요!")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 0) {
                    // Map with pins
                    Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.historyLocations) { location in
                        MapAnnotation(coordinate: location.coordinate) {
                            VStack(spacing: 2) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        viewModel.selectLocation(location)
                                    }
                            }
                        }
                    }
                    .frame(height: 300)
                    .cornerRadius(12)
                    .padding()

                    // History list
                    List {
                        ForEach(viewModel.historyLocations) { location in
                            HistoryRow(location: location)
                                .onTapGesture {
                                    viewModel.selectLocation(location)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.deleteLocation(location)
                                        }
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .navigationTitle("추첨 기록")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadHistory()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

struct HistoryRow: View {
    let location: RandomLocation

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(location.locationName)
                    .font(.headline)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(location.generatedAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(location.generatedAt, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
