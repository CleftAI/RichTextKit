//
//  RichTextViewComponent+HeaderLevel.swift
//
//  Created by Rizwana Desai on 05/11/24.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

extension RichTextViewComponent {

    var richTextHeaderLevel: RichTextHeaderLevel? {
        guard let font = richTextFont else { return nil }
        return RichTextHeaderLevel(font)
    }

    func setHeaderLevel(_ level: RichTextHeaderLevel) {
        registerUndo()
        setRichTextFontSize(level.fontSize)
        // Set line spacing based on header level
        let lineSpacing: CGFloat
        switch level {
        case .heading1:
            lineSpacing = 24  // Larger spacing for H1
        case .heading2:
            lineSpacing = 20  // Medium spacing for H2
        case .heading3:
            lineSpacing = 16  // Smaller spacing for H3
        case .paragraph:
            lineSpacing = 10  // Default paragraph spacing
        }
        // Create paragraph style with the specified line spacing
        let paragraphStyle = NSMutableParagraphStyle(
            from: richTextParagraphStyle,
            lineSpacing: lineSpacing
        )
        setRichTextParagraphStyle(paragraphStyle)
    }
}
