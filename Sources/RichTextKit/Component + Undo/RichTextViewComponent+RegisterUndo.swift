

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

public extension RichTextViewComponent {

    func registerUndo() {
        let range = selectedRange
        guard range.length > 0 else { return }
        let textView = self as? RichTextView
        #if canImport(UIKit)
        let undoManager = textView?.undoManager
        #elseif canImport(AppKit)
        let undoManager = textView?.undoManager
        #endif
        guard let undoManager = undoManager, let text = mutableRichText, let textView else {
            return
        }
        // Store the previous paragraph style
        let currentAttributes = NSAttributedString(attributedString: text.attributedSubstring(from: range))

        undoManager.registerUndo(withTarget: textView) { target in
            target.mutableRichText?.replaceCharacters(in: range, with: currentAttributes)
        }
        undoManager.setActionName("Change Paragraph Style")


    }
}
