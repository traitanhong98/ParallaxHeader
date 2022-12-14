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
    
    public var mode: HeaderMode = .fill {
        didSet {
            if (mode != oldValue) {
                updateConstraints()
            }
        }
    }
    
    @IBInspectable public var headerHeight: CGFloat = 0 {
        didSet {
            if (headerHeight != oldValue) {
                viewHeightConstraint?.constant = headerHeight
            }
        }
    }
    
    private var viewHeightConstraint: NSLayoutConstraint?
    @IBOutlet var content: UIView! {
        didSet {
            updateConstraints()
        }
    }
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
        content.removeFromSuperview()
        addSubview(content)
        if let viewHeightConstraint = viewHeightConstraint {
            content.removeConstraint(viewHeightConstraint)
            self.viewHeightConstraint = nil
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
        super.updateConstraints()
    }

    func setCenterModeConstraints() {
        content?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        content?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        content?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        viewHeightConstraint =  content?.heightAnchor.constraint(equalToConstant: headerHeight)
        viewHeightConstraint?.isActive = true
    }
    
    func setFillModeConstraints() {
        content?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        content?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        content?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        content?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        viewHeightConstraint?.isActive = false
    }
    
    func setTopFillModeConstraints() {
        content?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        content?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        content?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        viewHeightConstraint = content?.heightAnchor.constraint(greaterThanOrEqualToConstant: headerHeight)
        viewHeightConstraint?.isActive = true
        
        let constraint = content?.bottomAnchor.constraint(equalTo: bottomAnchor)
        constraint?.priority = .defaultHigh
        constraint?.isActive = true
    }

    func setTopModeConstraints() {
        content?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        content?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        content?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        viewHeightConstraint = content?.heightAnchor.constraint(equalToConstant: headerHeight)
        viewHeightConstraint?.isActive = true
    }
    
    func setBottomModeConstraints() {
        content?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        content?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        content?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        viewHeightConstraint = content?.heightAnchor.constraint(equalToConstant: headerHeight)
        viewHeightConstraint?.isActive = true
    }
}
