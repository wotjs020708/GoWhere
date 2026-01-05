import SwiftUI

protocol Coordinator: AnyObject {
    associatedtype ContentView: View
    var navigationPath: NavigationPath { get set }
    func start() -> ContentView
}
