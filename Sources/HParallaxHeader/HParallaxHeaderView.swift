//
//  HParallaxHeader.swift
//  Pmobile3
//
//  Created by ECO0542-HoangNM on 05/12/2022.
//

import UIKit

open class HParallaxHeaderView: UIView {
    public enum HeaderMode {
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
    @IBOutlet public var contentContainerView: UIView! {
        didSet {
            updateConstraints()
        }
    }
    // MARK: - LifeCycle
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateConstraints()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        updateConstraints()
    }
    
    public init(contentView: UIView) {
        super.init(frame: .zero)
        self.contentContainerView = contentView
        updateConstraints()
    }
    
    public override func updateConstraints() {
        contentContainerView.removeFromSuperview()
        addSubview(contentContainerView)
        if let viewHeightConstraint = viewHeightConstraint {
            contentContainerView.removeConstraint(viewHeightConstraint)
            self.viewHeightConstraint = nil
        }
     
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        
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
        contentContainerView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentContainerView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentContainerView?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        viewHeightConstraint =  contentContainerView?.heightAnchor.constraint(equalToConstant: headerHeight)
        viewHeightConstraint?.isActive = true
    }
    
    func setFillModeConstraints() {
        contentContainerView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentContainerView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentContainerView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentContainerView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        viewHeightConstraint?.isActive = false
    }
    
    func setTopFillModeConstraints() {
        contentContainerView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentContainerView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentContainerView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        viewHeightConstraint = contentContainerView?.heightAnchor.constraint(greaterThanOrEqualToConstant: headerHeight)
        viewHeightConstraint?.isActive = true
        
        let constraint = contentContainerView?.bottomAnchor.constraint(equalTo: bottomAnchor)
        constraint?.priority = .defaultHigh
        constraint?.isActive = true
    }

    func setTopModeConstraints() {
        contentContainerView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentContainerView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentContainerView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        viewHeightConstraint = contentContainerView?.heightAnchor.constraint(equalToConstant: headerHeight)
        viewHeightConstraint?.isActive = true
    }
    
    func setBottomModeConstraints() {
        contentContainerView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentContainerView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentContainerView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        viewHeightConstraint = contentContainerView?.heightAnchor.constraint(equalToConstant: headerHeight)
        viewHeightConstraint?.isActive = true
    }
}
