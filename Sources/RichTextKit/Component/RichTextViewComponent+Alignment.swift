//
//  RichTextViewComponent+Alignment.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-05-29.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

public extension RichTextViewComponent {

    /// Get the current rich text alignment.
    var richTextAlignment: RichTextAlignment? {
        let attribute: NSMutableParagraphStyle? = richTextAttribute(.paragraphStyle)
        guard let style = attribute else { return nil }
        return RichTextAlignment(style.alignment)
    }

    /// Set the current text alignment.
    func setRichTextAlignment(
        _ alignment: RichTextAlignment
    ) {
        if richTextAlignment == alignment { return }
        if !hasTrimmedText {
            let style = NSMutableParagraphStyle()
            style.alignment = alignment.nativeAlignment
            var attributes = richTextAttributes
            attributes[.paragraphStyle] = style
            typingAttributes = attributes
        } else {
            setRichTextAlignment(alignment, at: selectedRange)
        }
    }
}
