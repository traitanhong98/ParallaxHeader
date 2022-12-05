//
//  HParallaxHeader.swift
//  Pmobile3
//
//  Created by ECO0542-HoangNM on 05/12/2022.
//

import UIKit

class HParallaxHeader: UIView {
    
    enum HeaderMode {
        /**
         The option to scale the content to fill the size of the header. Some portion of the content may be clipped to fill the header’s bounds.
         */
        case fill
        /**
         The option to scale the content to fill the size of the header and aligned at the top in the header's bounds.
         */
        case topFill
        /**
         The option to center the content aligned at the top in the header's bounds.
         */
        case top
        /**
         The option to center the content in the header’s bounds, keeping the proportions the same.
         */
        case center
        /**
         The option to center the content aligned at the bottom in the header’s bounds.
         */
        case bottom
    }

    var header: HParallaxHeader!
    public var mode: HeaderMode = .fill {
        didSet {
            if (mode != oldValue) {
                updateConstraints()
            }
        }
    }
    
    @IBInspectable public var height: CGFloat = 0 {
        didSet {
            if (height != oldValue) {
                heightConstraint?.constant = height
            }
        }
    }
    
    private var heightConstraint: NSLayoutConstraint?
    @IBOutlet var content: UIView!
    // MARK: - LifeCycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateConstraints()
    }
    
    init(contentView: UIView) {
        super.init(frame: .zero)
        self.content = contentView
        updateConstraints()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        content.removeFromSuperview()
        addSubview(content)
        if let heightConstraint = heightConstraint {
            content.removeConstraint(heightConstraint)
            self.heightConstraint = nil
        }
     
        content.translatesAutoresizingMaskIntoConstraints = false
        
        switch self.mode {
        case .fill:
            setFillModeConstraints()
        case .topFill:
            setTopFillModeConstraints()
        case .top:
            setTopModeConstraints()
        case .bottom:
            setBottomModeConstraints()
        case .center:
            setCenterModeConstraints()
        }
    }

    func setCenterModeConstraints() {
        content?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        content?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        content?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        heightConstraint =  content?.heightAnchor.constraint(equalToConstant: height)
        heightConstraint?.isActive = true
    }
    
    func setFillModeConstraints() {
        content?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        content?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        content?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        content?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        heightConstraint?.isActive = false
    }
    
    func setTopFillModeConstraints() {
        content?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        content?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        content?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        heightConstraint = content?.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
        heightConstraint?.isActive = true
        
        let constraint = content?.bottomAnchor.constraint(equalTo: bottomAnchor)
        constraint?.priority = .defaultLow
        constraint?.isActive = true
    }

    func setTopModeConstraints() {
        content?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        content?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        content?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        heightConstraint = content?.heightAnchor.constraint(equalToConstant: height)
        heightConstraint?.isActive = true
    }
    
    func setBottomModeConstraints() {
        content?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        content?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        content?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        heightConstraint = content?.heightAnchor.constraint(equalToConstant: height)
        heightConstraint?.isActive = true
    }
}
