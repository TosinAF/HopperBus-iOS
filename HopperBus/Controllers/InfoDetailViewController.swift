//
//  InfoDetailViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 26/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import UIKit

class InfoDetailViewController: UIViewController {

    // MARK: - Properties

    let type: InfoSection
    var textStorage: SyntaxHighlightTextStorage!

    lazy var infoText: String = {
        let path = NSBundle.mainBundle().pathForResource(self.type.filename, ofType: "txt")!
        let s = String(contentsOfFile:path, encoding: NSUTF8StringEncoding, error: nil)!
        return s.replace("*", withString: "\u{2022}")
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "HOPPER BUS - \(self.type.title)"
        label.font = UIFont(name: "Montserrat", size: 18)
        label.textColor = UIColor.HopperBusBrandColor()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("\u{274C}", forState: .Normal)
        button.setTitleColor(UIColor.HopperBusBrandColor(), forState: .Normal)
        button.titleLabel?.font = UIFont(name: "Entypo", size: 50.0)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "onDismissButtonTap", forControlEvents: .TouchUpInside)
        return button
    }()

    lazy var textView: UITextView = {
        let textView = self.createTextView()
        return textView
    }()

    // MARK: - Initalizers

    init(type: InfoSection) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()

        view.addSubview(titleLabel)
        view.addSubview(dismissButton)
        view.addSubview(textView)

        layoutViews()
    }

    // MARK: Layout

    func layoutViews() {

        let views = [
            "titleLabel": titleLabel,
            "dismissButton": dismissButton,
            "textView": textView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-15-[titleLabel]-20-[dismissButton(30)]-10-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[dismissButton(30)]", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[titleLabel]-20-[textView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-10-[textView]-10-|", options: nil, metrics: nil, views: views))
    }

    // MARK: - Actions

    func onDismissButtonTap() {
        dismissViewControllerAnimated(true, completion: nil);
    }

    // MARK: - Utility Methods

    func createTextView() -> UITextView {

        let attrs = [
            NSFontAttributeName : UIFont(name: "Avenir-Medium", size: 14)!
        ]

        let attrString = NSAttributedString(string: infoText, attributes: attrs)

        textStorage = SyntaxHighlightTextStorage()
        textStorage.appendAttributedString(attrString)

        let layoutManager = NSLayoutManager()

        let containerSize = CGSize(width: view.frame.size.width - 20, height: CGFloat.max)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true
        layoutManager.addTextContainer(container)
        textStorage.addLayoutManager(layoutManager)

        textView = UITextView(frame: CGRectZero, textContainer: container)
        textView.textAlignment = .Justified
        textView.textContainerInset = UIEdgeInsetsMake(0, 0, 30, 0)
        textView.setTranslatesAutoresizingMaskIntoConstraints(false)

        textView.layoutManager.delegate = self

        return textView
    }
}

extension InfoDetailViewController: NSLayoutManagerDelegate {

    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
}


