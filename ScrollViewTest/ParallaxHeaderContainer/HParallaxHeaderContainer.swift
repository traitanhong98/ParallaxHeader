//
//  ParallaxHeaderContainer.swift
//  Pmobile3
//
//  Created by ECO0542-HoangNM on 05/12/2022.
//

import UIKit

class HParallaxHeaderContainer: UIView {
    static var context = "HParallaxHeaderContainerContext"
    // MARK: - Designable
    @IBInspectable var maximumHeightOfHeader: CGFloat = 250 {
        didSet {
            if heightOfHeader.constant > maximumHeightOfHeader {
                heightOfHeader.constant = maximumHeightOfHeader
            }
        }
    }
    
    @IBInspectable var minimumHeightOfHeader: CGFloat = 50 {
        didSet {
            if heightOfHeader.constant < minimumHeightOfHeader {
                heightOfHeader.constant = minimumHeightOfHeader
            }
        }
    }
    // MARK: - Properties
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var content: UIView!
    
    var headerContainerView: HParallaxHeader!
    private var contentContainerView: UIView!
    var heightOfHeader: NSLayoutConstraint!
    
    private var observingViews: [UIView] = []
    private var isObserving: Bool = true
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
      
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    init(header: UIView, content: UIView) {
        super.init(frame: .zero)
        self.header = header
        self.content = content
        setupView()
        makeUI()
    }
    
    deinit {
        observingViews.forEach { view in
            view.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: &HParallaxHeaderContainer.context)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    func setupView() {
        let gesture = UIPanGestureRecognizer(
            target: self,
            action: nil
        )
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        addGestureRecognizer(gesture)
    }
    
    func makeUI() {
        // Header
        header.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView = HParallaxHeader(contentView: header)
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerContainerView)
        heightOfHeader = headerContainerView.heightAnchor.constraint(equalToConstant: maximumHeightOfHeader)
        heightOfHeader.isActive = true
        
        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        // Content Container
        contentContainerView = UIView()
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentContainerView)
        NSLayoutConstraint.activate([
            contentContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainerView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor)
        ])
        // Content
        content.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            content.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            content.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            content.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &HParallaxHeaderContainer.context,
           keyPath == #keyPath(UIScrollView.contentOffset) else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        guard let scrollView = object as? UIScrollView,
            let new = change?[.newKey] as? CGPoint,
            let old = change?[.oldKey] as? CGPoint else { return }
        let diff = old.y - new.y
        guard diff != 0.0 && isObserving else { return }
        // Up <0 down >0
        let lock = scrollView.contentOffset.y > -scrollView.contentInset.top
        var isMove = false
        if (lock && diff < 0) || (!lock && diff > 0) {
            var height = heightOfHeader.constant + diff
            height = height < minimumHeightOfHeader ? minimumHeightOfHeader : height
            height = height > maximumHeightOfHeader ? maximumHeightOfHeader : height
            heightOfHeader.constant = height
            isMove = minimumHeightOfHeader < height && height < maximumHeightOfHeader
        }
        
        if isMove {
            self.scrollView(scrollView, setContentOffset: old)
        }
    }
    
    private func scrollView(_ scrollView: UIScrollView, setContentOffset offset: CGPoint) {
        isObserving = false
        scrollView.contentOffset = offset
        isObserving = true
    }
    
}
   
extension HParallaxHeaderContainer: UIGestureRecognizerDelegate {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
                return false
            }
            let velocity = gestureRecognizer.velocity(in: self)
            guard abs(velocity.x) <= abs(velocity.y) else {
                return false
            }
            
            guard let otherView = otherGestureRecognizer.view as? UIScrollView else {
                return true
            }
            
            if let uiTableViewContentClass = NSClassFromString("UITableViewCellContentView"),
               (otherView.superview?.isKind(of: uiTableViewContentClass) ?? false) {
                return false
            }
            
            if !observingViews.contains(where: {$0 === otherView}) {
                otherView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset),  options: [.old, .new], context: &HParallaxHeaderContainer.context)
                observingViews.append(otherView)
            }
            return true
        }
    }
