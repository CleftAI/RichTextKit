//
//  RichTextViewComponent+Attributes.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-05-29.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//

import Foundation

public extension RichTextViewComponent {

    /// Get all current rich text attributes.
    var richTextAttributes: RichTextAttributes {
        if hasSelectedRange {
            return richTextAttributes(at: selectedRange)
        }

        #if macOS
        let range = NSRange(location: selectedRange.location - 1, length: 1)
        let safeRange = safeRange(for: range)
        return richTextAttributes(at: safeRange)
        #else
        return typingAttributes
        #endif
    }

    /// Get a current rich text attribute.
    func richTextAttribute<Value>(
        _ attribute: RichTextAttribute
    ) -> Value? {
        richTextAttributes[attribute] as? Value
    }

    /// Set a current rich text attribute.
    func setRichTextAttribute(
        _ attribute: RichTextAttribute,
        to value: Any
    ) {
        #if macOS
        setRichTextAttribute(attribute, to: value, at: selectedRange)
        typingAttributes[attribute] = value
        #else
        if hasSelectedRange {
            setRichTextAttribute(attribute, to: value, at: selectedRange)
        } else {
            typingAttributes[attribute] = value
        }
        #endif
    }

    /// Set some current rich text attributes.
    func setRichTextAttributes(_ attributes: RichTextAttributes) {
        attributes.forEach { attribute, value in
            setRichTextAttribute(attribute, to: value)
        }
    }
}
