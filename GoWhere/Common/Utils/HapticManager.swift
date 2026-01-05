import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selectionGenerator.prepare()
    }

    func light() {
        impactLight.impactOccurred()
        impactLight.prepare()
    }

    func medium() {
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }

    func heavy() {
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }

    func success() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }

    func warning() {
        notification.notificationOccurred(.warning)
        notification.prepare()
    }

    func error() {
        notification.notificationOccurred(.error)
        notification.prepare()
    }

    func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    // Special effect for location randomizing
    func randomizingEffect(completion: @escaping () -> Void) {
        var count = 0
        let totalSteps = 8

        func triggerNext() {
            guard count < totalSteps else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.success()
                    completion()
                }
                return
            }

            let delay = count < 4 ? 0.15 : 0.25
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if count < totalSteps - 1 {
                    self.light()
                }
                count += 1
                triggerNext()
            }
        }

        triggerNext()
    }
}
