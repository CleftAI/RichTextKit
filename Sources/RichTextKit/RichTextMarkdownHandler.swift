//
// RichTextMarkdownHandler.swift
// RichTextKit
//

import Foundation
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public extension RichTextView {

    func handleMarkdownInput() {
        guard let textStorage = self.textStorage else { return }
        let fullText = textStorage.string
        let selectedRange = self.selectedRange()
        
        // Get the current line range
        let currentLineRange = (fullText as NSString).lineRange(for: selectedRange)
        let currentLineText = (fullText as NSString).substring(with: currentLineRange)

        if let coordinator = self.delegate as? RichTextCoordinator {
            coordinator.context.isApplyingMarkdown = true
            
            // Begin editing session
            textStorage.beginEditing()
            
            // Store the original state
            let originalText = NSAttributedString(attributedString: textStorage)
            let originalRange = selectedRange
            
            // Process markdown for the current line
            let headingRange = handleHeadingMarkdown(fullText: currentLineText, selectedRange: selectedRange, lineOffset: currentLineRange.location)
            let inlineRange = handleInlineMarkdown(fullText: currentLineText, selectedRange: selectedRange, lineOffset: currentLineRange.location)
            
            // End editing session
            textStorage.endEditing()
            
            // Update the selected range based on the changes
            if let newRange = inlineRange ?? headingRange {
                self.selectedRange = newRange
            }
            
            // Register undo for the markdown changes
            undoManager?.registerUndo(withTarget: self) { target in
                if let ts = target.textStorage {
                    ts.beginEditing()
                    ts.setAttributedString(originalText)
                    ts.endEditing()
                    target.selectedRange = originalRange
                }
            }
            
            coordinator.syncContextWithTextView()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                coordinator.context.isApplyingMarkdown = false
                print("Markdown processing ended - setting isApplyingMarkdown to false")
            }
        } else {
            print("Delegate NOT correctly cast to RichTextCoordinator")
        }
    }

    private func handleHeadingMarkdown(fullText: String, selectedRange: NSRange, lineOffset: Int) -> NSRange? {
        // Check for header patterns anywhere in the line
        let headerPatterns = ["### ", "## ", "# "]
        
        for (index, pattern) in headerPatterns.enumerated() {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: fullText, options: [], range: NSRange(location: 0, length: fullText.utf16.count)) {
                let nsRange = match.range(at: 0)
                let adjustedRange = NSRange(location: nsRange.location + lineOffset, length: nsRange.length)
                // Remove the markdown
                textStorage?.replaceCharacters(in: adjustedRange, with: "")
                if let coordinator = self.delegate as? RichTextCoordinator, let textStorage = textStorage {
                    // After removal, recalculate the line range
                    let newLineRange = (textStorage.string as NSString).lineRange(for: NSRange(location: adjustedRange.location, length: 0))
                    let headerLevel = RichTextHeaderLevel(3 - index)
                    coordinator.context.headerLevel = headerLevel
                    // The header should start at the position where the markdown was, and go to the end of the line
                    let headerStart = adjustedRange.location
                    let headerEnd = newLineRange.location + newLineRange.length
                    let headerLength = max(0, headerEnd - headerStart)
                    let safeRange = NSRange(location: headerStart, length: min(headerLength, textStorage.length - headerStart))
                    if safeRange.length > 0 && safeRange.location < textStorage.length {
                        textStorage.addAttribute(.font, value: headerLevel.font, range: safeRange)
                    }
                    setTypingAttributes(forHeadingLevel: 3 - index)
                    coordinator.syncContextWithTextView()
                }
                return NSRange(location: adjustedRange.location, length: 0)
            }
        }
        // Then check for existing heading patterns in the middle of text
        let patterns = ["(?<=^|\\s)(### )", "(?<=^|\\s)(## )", "(?<=^|\\s)(# )"]
        for (index, pattern) in patterns.enumerated() {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines),
                  let match = regex.firstMatch(in: fullText, options: [], range: NSRange(location: 0, length: fullText.utf16.count)) else { continue }
            let nsRange = match.range(at: 0)
            let hashRange = match.range(at: 1)
            // Adjust ranges to account for line offset
            let adjustedNsRange = NSRange(location: nsRange.location + lineOffset, length: nsRange.length)
            let adjustedHashRange = NSRange(location: hashRange.location + lineOffset, length: hashRange.length)
            // Remove the markdown
            textStorage?.replaceCharacters(in: NSRange(location: adjustedHashRange.location, length: adjustedNsRange.length - (adjustedHashRange.location - adjustedNsRange.location)), with: "")
            if let coordinator = self.delegate as? RichTextCoordinator, let textStorage = textStorage {
                // After removal, recalculate the line range
                let newLineRange = (textStorage.string as NSString).lineRange(for: NSRange(location: adjustedHashRange.location, length: 0))
                let headerLevel = RichTextHeaderLevel(3 - index)
                coordinator.context.headerLevel = headerLevel
                // The header should start at the position where the markdown was, and go to the end of the line
                let headerStart = adjustedHashRange.location
                let headerEnd = newLineRange.location + newLineRange.length
                let headerLength = max(0, headerEnd - headerStart)
                let safeRange = NSRange(location: headerStart, length: min(headerLength, textStorage.length - headerStart))
                if safeRange.length > 0 && safeRange.location < textStorage.length {
                    textStorage.addAttribute(.font, value: headerLevel.font, range: safeRange)
                }
                setTypingAttributes(forHeadingLevel: 3 - index)
                coordinator.syncContextWithTextView()
            }
            return NSRange(location: adjustedHashRange.location, length: 0)
        }
        return nil
    }

    private func handleInlineMarkdown(fullText: String, selectedRange: NSRange, lineOffset: Int) -> NSRange? {
        let patterns = ["\\*\\*(.+?)\\*\\*", "(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)", "_(.+?)_"]
        var replacements: [(range: NSRange, content: String, attributes: [NSAttributedString.Key: Any])] = []
        var lastReplacementRange: NSRange?

        for (index, pattern) in patterns.enumerated() {
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            regex?.enumerateMatches(in: fullText, options: [], range: NSRange(location: 0, length: fullText.utf16.count)) { match, _, _ in
                guard let match = match, match.numberOfRanges > 1 else { return }
                let markdownRange = match.range(at: 0)
                let contentRange = match.range(at: 1)
                let content = (fullText as NSString).substring(with: contentRange)

                // Adjust ranges to account for line offset
                let adjustedMarkdownRange = NSRange(location: markdownRange.location + lineOffset, length: markdownRange.length)

                let currentFont = textStorage?.attribute(.font, at: adjustedMarkdownRange.location, effectiveRange: nil) as? NSFont ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)

                var newFont: NSFont = currentFont
                var attributes: [NSAttributedString.Key: Any] = [:]

                switch index {
                case 0:
                    newFont = NSFontManager.shared.convert(currentFont, toHaveTrait: .boldFontMask)
                    attributes[.font] = newFont
                case 1:
                    newFont = NSFontManager.shared.convert(currentFont, toHaveTrait: .italicFontMask)
                    attributes[.font] = newFont
                case 2:
                    attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                default: break
                }

                replacements.append((adjustedMarkdownRange, content, attributes))
                lastReplacementRange = NSRange(location: adjustedMarkdownRange.location, length: content.count)
            }
        }

        // Apply all replacements in reverse order to maintain correct ranges
        for replacement in replacements.reversed() {
            textStorage?.replaceCharacters(in: replacement.range, with: replacement.content)
            textStorage?.addAttributes(replacement.attributes, range: NSRange(location: replacement.range.location, length: replacement.content.count))
        }

        return lastReplacementRange
    }

    private func setTypingAttributes(forHeadingLevel level: Int) {
        let headerLevel = RichTextHeaderLevel(level)
        typingAttributes[.font] = NSFont(name: headerLevel.font.fontName, size: headerLevel.fontSize)
        
        // Store the header level in the typing attributes to ensure it's preserved
        typingAttributes[.headerLevel] = level
    }
}
#endif
