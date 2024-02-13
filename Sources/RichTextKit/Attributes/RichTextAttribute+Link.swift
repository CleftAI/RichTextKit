//
//  RichTextAttribute+Link.swift
//
//
//  Created by Dominik Bucher on 01.12.2023.
//

import Foundation

extension RichTextAttribute {
    /**
     This attribute ensures that we set the link and its color is always the one we choose.
     Together with this, please set `linkTextAttributes = [:]` on UITextView instance. Otherwise
     the tintColor will always override the foregroundColor. Or Follow RichTextView Configuration
     */
    static let richTextLink: NSAttributedString.Key = .init("richTextLink")
}

public struct CustomLinkAttributes {
    init(link: String, color: ColorRepresentable) {
        self.link = link
        self.color = color
    }
    
    let link: String
    let color: ColorRepresentable
}