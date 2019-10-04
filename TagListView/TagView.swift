//
//  TagView.swift
//  TagListViewDemo
//
//  Created by Dongyuan Liu on 2015-05-09.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit

@IBDesignable
open class TagView: UIButton {

  @IBInspectable open var cornerRadiusForTag: CGFloat = 0 {
    didSet {
      layer.cornerRadius = cornerRadiusForTag
      layer.masksToBounds = cornerRadiusForTag > 0
    }
  }
  @IBInspectable open var borderWidthForTag: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidthForTag
    }
  }

  @IBInspectable open var borderColorForTag: UIColor? {
    didSet {
      reloadStyles()
    }
  }

  @IBInspectable open var textColor: UIColor = UIColor.white {
    didSet {
      reloadStyles()
    }
  }
  @IBInspectable open var selectedTextColor: UIColor = UIColor.white {
    didSet {
      reloadStyles()
    }
  }
  @IBInspectable open var titleLineBreakMode: NSLineBreakMode = .byTruncatingMiddle {
    didSet {
      titleLabel?.lineBreakMode = titleLineBreakMode
    }
  }
  @IBInspectable open var paddingY: CGFloat = 2 {
    didSet {
      titleEdgeInsets.top = paddingY
      titleEdgeInsets.bottom = paddingY
    }
  }
  @IBInspectable open var paddingX: CGFloat = 5 {
    didSet {
      titleEdgeInsets.left = paddingX
      updateRightInsets()
    }
  }

  @IBInspectable open var tagBackgroundColor: UIColor = UIColor.gray {
    didSet {
      reloadStyles()
    }
  }

  @IBInspectable open var highlightedBackgroundColor: UIColor? {
    didSet {
      reloadStyles()
    }
  }

  @IBInspectable open var selectedBorderColor: UIColor? {
    didSet {
      reloadStyles()
    }
  }

  @IBInspectable open var selectedBackgroundColor: UIColor? {
    didSet {
      reloadStyles()
    }
  }

  open var gradientSelectedColor: Bool = false {
    didSet {
      reloadStyles()
    }
  }

  @IBInspectable open var textFont: UIFont = .systemFont(ofSize: 12) {
    didSet {
      titleLabel?.font = textFont
    }
  }

  private func reloadStyles() {

    if isHighlighted {
      if let highlightedBackgroundColor = highlightedBackgroundColor {
        // For highlighted, if it's nil, we should not fallback to backgroundColor.
        // Instead, we keep the current color.
        backgroundColor = highlightedBackgroundColor
      }
    }
    else if isSelected {
      backgroundColor = selectedBackgroundColor ?? tagBackgroundColor
      if gradientSelectedColor {
        backgroundColor = .clear
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [selectedBackgroundColor!.cgColor, selectedBackgroundColor?.withAlphaComponent(0.65).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
        layer.insertSublayer(gradient, at: 0)
      }
      layer.borderColor = selectedBorderColor?.cgColor ?? borderColorForTag?.cgColor
      setTitleColor(selectedTextColor, for: UIControl.State())
    }
    else {
      if gradientSelectedColor {
        if let gradient = layer.sublayers?[0] as? CAGradientLayer {
          gradient.removeFromSuperlayer()
        }
      }
      backgroundColor = tagBackgroundColor
      layer.borderColor = borderColorForTag?.cgColor
      setTitleColor(textColor, for: UIControl.State())
    }
  }

  override open var isHighlighted: Bool {
    didSet {
      reloadStyles()
    }
  }

  override open var isSelected: Bool {
    didSet {
      reloadStyles()
    }
  }

  // MARK: remove button

  let removeButton = CloseButton()

  @IBInspectable open var enableRemoveButton: Bool = false {
    didSet {
      removeButton.isHidden = !enableRemoveButton
      updateRightInsets()
    }
  }

  @IBInspectable open var removeButtonIconSize: CGFloat = 12 {
    didSet {
      removeButton.iconSize = removeButtonIconSize
      updateRightInsets()
    }
  }

  @IBInspectable open var removeIconLineWidth: CGFloat = 3 {
    didSet {
      removeButton.lineWidth = removeIconLineWidth
    }
  }
  @IBInspectable open var removeIconLineColor: UIColor = UIColor.white.withAlphaComponent(0.54) {
    didSet {
      removeButton.lineColor = removeIconLineColor
    }
  }

  /// Handles Tap (TouchUpInside)
  open var onTap: ((TagView) -> Void)?
  open var onLongPress: ((TagView) -> Void)?

  // MARK: - init

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    setupView()
  }

  public init(title: String) {
    super.init(frame: CGRect.zero)
    setTitle(title, for: UIControl.State())

    setupView()
  }

  private func setupView() {
    titleLabel?.lineBreakMode = titleLineBreakMode

    frame.size = intrinsicContentSize
    addSubview(removeButton)
    removeButton.tagView = self

    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
    self.addGestureRecognizer(longPress)
  }

  @objc func longPress() {
    onLongPress?(self)
  }

  // MARK: - layout

  override open var intrinsicContentSize: CGSize {
    var size = super.intrinsicContentSize
    size.height = textFont.pointSize + paddingY * 2
    size.width += paddingX * 2
    if size.width < size.height {
      size.width = size.height
    }
    if enableRemoveButton {
      size.width += removeButtonIconSize + paddingX
    }
    return size
  }

  private func updateRightInsets() {
    if enableRemoveButton {
      titleEdgeInsets.right = paddingX + removeButtonIconSize + paddingX
    }
    else {
      titleEdgeInsets.right = paddingX
    }
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    if enableRemoveButton {
      removeButton.frame.size.width = paddingX + removeButtonIconSize + paddingX
      removeButton.frame.origin.x = self.frame.width - removeButton.frame.width
      removeButton.frame.size.height = self.frame.height
      removeButton.frame.origin.y = 0
    }
  }
}

/// Swift < 4.2 support
#if !(swift(>=4.2))
  private extension NSAttributedString {
    typealias Key = NSAttributedStringKey
  }
  private extension UIControl {
    typealias State = UIControlState
  }
#endif
