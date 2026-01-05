import Foundation
import SwiftUI
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0

    private weak var coordinator: AppCoordinator?

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    func nextPage() {
        HapticManager.shared.light()
        withAnimation {
            currentPage += 1
        }
    }

    func previousPage() {
        HapticManager.shared.light()
        withAnimation {
            currentPage -= 1
        }
    }

    func complete() {
        HapticManager.shared.success()
        coordinator?.completeOnboarding()
    }
}
