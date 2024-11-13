//
//  RichTextHeaderLevel.swift
//  RichTextKit
//
//  Created by Rizwana Desai on 08/11/24.
//

import Foundation
import SwiftUICore

/**
 This enum represents various rich text format style, such as paragraph,
 heading1 and heading2, heading3.
 */

public enum RichTextHeaderLevel: CaseIterable {

    case paragraph
    case heading1
    case heading2
    case heading3

    public init(_ headerlevel: Int) {
        switch headerlevel {
        case 0: self = .paragraph
        case 1: self = .heading1
        case 2: self = .heading2
        case 3: self = .heading3
        default: self = .paragraph
        }
    }

    public init(_ font: FontRepresentable) {
        self = RichTextHeaderLevel.fontMap[font.pointSize] ?? .paragraph
    }

    public var title: String {
        switch self {
        case .paragraph:
            "Paragraph"
        case .heading1:
            "h1"
        case .heading2:
            "h2"
        case .heading3:
            "h3"
        }
    }

    // Using this value to set header level in paragraph style for attributed string
    public var value: Int {
        switch self {
        case .paragraph:
            0
        case .heading1:
            1
        case .heading2:
            2
        case .heading3:
            3
        }
    }

    public var font: FontRepresentable {
        switch self {
        case .heading1:
            return .systemFont(ofSize: self.fontSize, weight: .bold)
        case .heading2:
            return .systemFont(ofSize: self.fontSize, weight: .semibold)
        case .heading3:
            return .systemFont(ofSize: self.fontSize, weight: .medium)
        default:
            return .standardRichTextFont //16
        }
    }

    public var fontSize: CGFloat {
        switch self {
        case .heading1:
            return 24
        case .heading2:
            return 20
        case .heading3:
            return 18
        case .paragraph:
            return .standardRichTextFontSize
        }
    }

    private static let fontMap: [CGFloat: RichTextHeaderLevel] = [
        RichTextHeaderLevel.heading1.fontSize: .heading1,
        RichTextHeaderLevel.heading2.fontSize: .heading2,
        RichTextHeaderLevel.heading3.fontSize: .heading3,
        RichTextHeaderLevel.paragraph.fontSize: .paragraph
    ]

}