//
//  File.swift
//  RichTextKit
//
//  Created by Rizwana Desai on 13/12/24.
//

import SwiftUI

public extension RichTextContext {

    /// Get a binding for a certain style.
    @preconcurrency @MainActor
    func bindingHeaderLevel() -> Binding<RichTextHeaderLevel> {
        Binding(
            get: { self.headerLevel },
            set: { self.setHeaderLevel($0) }
        )
    }

    /// Set whether or not the context has a certain style.
    func setHeaderLevel(
        _ level: RichTextHeaderLevel) {
        actionPublisher.send(.setHeaderLevel(level))
        setStyleInternal(level)
    }
}

extension RichTextContext {

    func setStyleInternal(
        _ level: RichTextHeaderLevel
    ) {
        headerLevel = level
    }

}
