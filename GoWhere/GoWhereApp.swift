//
//  GoWhereApp.swift
//  GoWhere
//
//  Created by 어재선 on 1/5/26.
//

import SwiftUI

@main
struct GoWhereApp: App {
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            coordinator.build()
        }
    }
}
