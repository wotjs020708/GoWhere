import SwiftUI
import Combine

final class AppCoordinator: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var hasCompletedOnboarding = false
    @Published var selectedTab: MainTab = .citySelection

    private let generateRandomLocationUseCase: GenerateRandomLocationUseCase
    private let saveLocationHistoryUseCase: SaveLocationHistoryUseCase
    private let fetchLocationHistoryUseCase: FetchLocationHistoryUseCase
    private let deleteLocationHistoryUseCase: DeleteLocationHistoryUseCase

    init() {
        let historyRepository = LocationHistoryRepository()
        self.generateRandomLocationUseCase = GenerateRandomLocationUseCase()
        self.saveLocationHistoryUseCase = SaveLocationHistoryUseCase(repository: historyRepository)
        self.fetchLocationHistoryUseCase = FetchLocationHistoryUseCase(repository: historyRepository)
        self.deleteLocationHistoryUseCase = DeleteLocationHistoryUseCase(repository: historyRepository)

        // Check if user has completed onboarding
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    @ViewBuilder
    func build() -> some View {
        if hasCompletedOnboarding {
            NavigationStack(path: Binding(
                get: { self.navigationPath },
                set: { self.navigationPath = $0 }
            )) {
                makeMainTabView()
                    .navigationDestination(for: AppRoute.self) { [weak self] route in
                        guard let self = self else { return AnyView(EmptyView()) }
                        switch route {
                        case .randomLocation(let location, let isFromHistory):
                            return AnyView(self.makeRandomLocationMapView(location: location, isFromHistory: isFromHistory))
                        }
                    }
            }
        } else {
            makeOnboardingView()
        }
    }

    private func makeOnboardingView() -> some View {
        let viewModel = OnboardingViewModel(coordinator: self)
        return OnboardingView(viewModel: viewModel) 
    }

    private func makeMainTabView() -> some View {
        let citySelectionView = makeCitySelectionView()
        let historyView = makeHistoryView()
        return MainTabView(
            citySelectionView: citySelectionView,
            historyView: historyView,
            selectedTab: Binding(
                get: { self.selectedTab },
                set: { self.selectedTab = $0 }
            )
        )
    }

    private func makeCitySelectionView() -> CitySelectionView {
        let viewModel = CitySelectionViewModel(
            generateRandomLocationUseCase: generateRandomLocationUseCase,
            saveLocationHistoryUseCase: saveLocationHistoryUseCase,
            coordinator: self
        )
        return CitySelectionView(viewModel: viewModel)
    }

    private func makeHistoryView() -> HistoryView {
        let viewModel = HistoryViewModel(
            fetchHistoryUseCase: fetchLocationHistoryUseCase,
            deleteHistoryUseCase: deleteLocationHistoryUseCase,
            coordinator: self
        )
        return HistoryView(viewModel: viewModel)
    }

    private func makeRandomLocationMapView(location: RandomLocation, isFromHistory: Bool) -> some View {
        let viewModel = RandomLocationMapViewModel(
            randomLocation: location,
            coordinator: self,
            isFromHistory: isFromHistory
        )
        return RandomLocationMapView(viewModel: viewModel)
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            hasCompletedOnboarding = true
        }
    }

    func showRandomLocation(_ location: RandomLocation, isFromHistory: Bool = false) {
        navigate(to: .randomLocation(location, isFromHistory: isFromHistory))
    }

    func navigate(to route: AppRoute) {
        navigationPath.append(route)
    }

    func pop() {
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = NavigationPath()
    }
    
    func goToCitySelection() {
        popToRoot()
        selectedTab = .citySelection
    }
}

enum AppRoute: Hashable {
    case randomLocation(RandomLocation, isFromHistory: Bool)
}
