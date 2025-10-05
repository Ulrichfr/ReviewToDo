//
//  QuickActionService.swift
//  ReviewToDoAPp
//
//  Created by Ulrich Rozier on 05/10/2025.
//

import SwiftUI
import Combine

class QuickActionService: ObservableObject {
    static let shared = QuickActionService()

    @Published var shouldShowAddSheet = false

    private init() {}
}
