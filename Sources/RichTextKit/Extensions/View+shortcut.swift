
import SwiftUI


public extension View {

    /// Apply keyboard shortcuts for a ``RichTextAlignment``
    /// to the view.
    @ViewBuilder
    func keyboardShortcut(for alignment: RichTextAlignment) -> some View {
        #if iOS || macOS || os(visionOS)
        switch alignment {
        case .left: self.keyboardShortcut("l", modifiers: [.command, .shift])
        case .center: self.keyboardShortcut("e", modifiers: [.command, .shift])
        case .right: self.keyboardShortcut("r", modifiers: [.command, .shift])
        case .justified: self.keyboardShortcut("j", modifiers: [.command, .shift])
        }
        #else
        self
        #endif
    }
}
