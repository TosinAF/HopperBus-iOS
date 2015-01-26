//
//  SyntaxHighlightTextStorage.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 26/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import UIKit

class SyntaxHighlightTextStorage: NSTextStorage {
    let backingStore = NSMutableAttributedString()
    var replacements: [String : [NSObject : AnyObject]]!

    override init() {
        super.init()
        createHighlightPatterns()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var string: String {
        return backingStore.string
    }

    override func attributesAtIndex(index: Int, effectiveRange range: NSRangePointer) -> [NSObject : AnyObject] {
        return backingStore.attributesAtIndex(index, effectiveRange: range)
    }

    override func replaceCharactersInRange(range: NSRange, withString str: String) {
        println("replaceCharactersInRange:\(range) withString:\(str)")

        beginEditing()
        backingStore.replaceCharactersInRange(range, withString:str)
        edited(.EditedCharacters | .EditedAttributes, range: range, changeInLength: (str as NSString).length - range.length)
        endEditing()
    }

    override func setAttributes(attrs: [NSObject : AnyObject]!, range: NSRange) {
        println("setAttributes:\(attrs) range:\(range)")

        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.EditedAttributes, range: range, changeInLength: 0)
        endEditing()
    }

    func applyStylesToRange(searchRange: NSRange) {
        let normalAttrs = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]

        // iterate over each replacement
        for (pattern, attributes) in replacements {
            let regex = NSRegularExpression(pattern: pattern, options: nil, error: nil)!
            regex.enumerateMatchesInString(backingStore.string, options: nil, range: searchRange) {
                match, flags, stop in
                // apply the style
                let matchRange = match.rangeAtIndex(1)
                self.addAttributes(attributes, range: matchRange)

                // reset the style to the original
                let maxRange = matchRange.location + matchRange.length
                if maxRange + 1 < self.length {
                    self.addAttributes(normalAttrs, range: NSMakeRange(maxRange, 1))
                }
            }
        }
    }

    func performReplacementsForRange(changedRange: NSRange) {
        var extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRangeForRange(NSMakeRange(changedRange.location, 0)))
        extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRangeForRange(NSMakeRange(NSMaxRange(changedRange), 0)))
        applyStylesToRange(extendedRange)
    }

    override func processEditing() {
        performReplacementsForRange(self.editedRange)
        super.processEditing()
    }

    func createAttributesForFontStyle(style: String, withTrait trait: UIFontDescriptorSymbolicTraits) -> [NSObject : AnyObject] {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
        let descriptorWithTrait = fontDescriptor.fontDescriptorWithSymbolicTraits(trait)
        let font = UIFont(descriptor: descriptorWithTrait, size: 0)
        return [NSFontAttributeName : font]
    }

    func createHighlightPatterns() {
        let boldAttributes = [NSFontAttributeName : UIFont(name: "Avenir-Medium", size: 15)!]
        replacements = [
            "(-([\\s\\w&]+)-)" : boldAttributes
        ]
    }
    
    func update() {
        createHighlightPatterns()
        let bodyFont = [NSFontAttributeName : UIFont(name: "Avenir-Medium", size: 14)! ]
        addAttributes(bodyFont, range: NSMakeRange(0, length))
        applyStylesToRange(NSMakeRange(0, length))
    }
}
