//
//  ParallaxHeaderContainer.swift
//  Pmobile3
//
//  Created by ECO0542-HoangNM on 05/12/2022.
//

import UIKit

@objc public protocol HParallaxHeaderContainerDelegate: AnyObject {
    @objc optional func hParallaxContainerDidPullToRefresh(_ view: HParallaxHeaderContainer)
    @objc optional func hParallaxContainer(_ view: HParallaxHeaderContainer, didChangePullToRefreshViewHeight height: CGFloat, maximumAvailableHeight: CGFloat)
    @objc optional func hParallaxContainer(_ view: HParallaxHeaderContainer, didChangeHeaderViewHeight height: CGFloat, maximumAvailableHeight: CGFloat)
}

public class HParallaxHeaderContainer: UIView {
    static var context = "HParallaxHeaderContainerContext"
    // MARK: - Designable
    @IBInspectable public var maximumHeightOfHeader: CGFloat = 250 {
        didSet {
            if heightOfHeader.constant > maximumHeightOfHeader {
                heightOfHeader.constant = maximumHeightOfHeader
            }
        }
    }
    
    @IBInspectable public var minimumHeightOfHeader: CGFloat = 50 {
        didSet {
            if heightOfHeader.constant < minimumHeightOfHeader {
                heightOfHeader.constant = minimumHeightOfHeader
            }
        }
    }
    // MARK: - Properties
    @IBOutlet public weak var contentHeaderView: UIView! {
        didSet {
            setupHeaderView()
        }
    }
    
    @IBOutlet public weak var mainContentView: UIView! {
        didSet {
            setupContent()
        }
    }
    
    @IBOutlet public weak var loadingView: UIView?{
        didSet {
            setupLoadingView()
        }
    }
    
    public weak var delegate: HParallaxHeaderContainerDelegate?
    
    
    @IBInspectable public var isEnablePullToRefresh: Bool = false
    public var maximunHeightOfPullToRefresh: CGFloat = 100
    private var isRefreshing: Bool = false
    
    private var loadingViewWorkItem: DispatchWorkItem?
    private var loadingContainerView: UIView!
    public var headerContainerView: HParallaxHeaderView!
    private var contentContainerView: UIView!
    
    private var heightOfLoading: NSLayoutConstraint!
    private var heightOfHeader: NSLayoutConstraint!
    
    private var observingViews: [UIView] = []
    private var isObserving: Bool = true
    
    private var gestureStartLocation: CGPoint = .zero
    private var headerStartHeight: CGFloat = 0
    private var isReceiveTouchFromOtherScrollView: Bool = false
    
    fileprivate var updatedHeaderHeight: CGFloat = -1 {
        willSet {
            if newValue != updatedHeaderHeight {
                delegate?.hParallaxContainer?(self,
                                              didChangeHeaderViewHeight: newValue,
                                              maximumAvailableHeight: maximumHeightOfHeader)
            }
        }
    }
    
    fileprivate var updatedPullToRefreshHeight: CGFloat = -1 {
        willSet {
            if newValue != updatedPullToRefreshHeight {
                delegate?.hParallaxContainer?(self,
                                              didChangePullToRefreshViewHeight: newValue,
                                              maximumAvailableHeight: maximunHeightOfPullToRefresh)
            }
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public init(header: UIView, content: UIView) {
        super.init(frame: .zero)
        self.contentHeaderView = header
        self.mainContentView = content
        setupView()
        makeUI()
    }
    
    deinit {
        observingViews.forEach { view in
            view.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: &HParallaxHeaderContainer.context)
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    func setupView() {
        let gesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGesture(_:))
        )
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        addGestureRecognizer(gesture)
    }
    
    func makeUI() {
        // Loading
        loadingContainerView = UIView()
        loadingContainerView.clipsToBounds = true
        loadingContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingContainerView)
        NSLayoutConstraint.activate([
            loadingContainerView.topAnchor.constraint(equalTo: topAnchor),
            loadingContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingContainerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        heightOfLoading = loadingContainerView.heightAnchor.constraint(equalToConstant: 0)
        heightOfLoading.isActive = true
        setupLoadingView()
        // Header
        contentHeaderView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView = HParallaxHeaderView(contentView: contentHeaderView)
        headerContainerView.clipsToBounds = true
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerContainerView)
        heightOfHeader = headerContainerView.heightAnchor.constraint(equalToConstant: maximumHeightOfHeader)
        heightOfHeader.isActive = true
        
        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: loadingContainerView.bottomAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        // Content Container
        contentContainerView = UIView()
        contentContainerView.clipsToBounds = true
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentContainerView)
        NSLayoutConstraint.activate([
            contentContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainerView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor)
        ])
        setupContent()
    }
    
    func setupLoadingView() {
        guard let loadingContainerView = loadingContainerView else { return }
        loadingContainerView.subviews.forEach({$0.removeFromSuperview()})
        if let loadingView = loadingView {
            loadingView.translatesAutoresizingMaskIntoConstraints = false
            loadingContainerView.addSubview(loadingView)
            NSLayoutConstraint.activate([
                loadingView.topAnchor.constraint(equalTo: loadingContainerView.topAnchor),
                loadingView.trailingAnchor.constraint(equalTo: loadingContainerView.trailingAnchor),
                loadingView.leadingAnchor.constraint(equalTo: loadingContainerView.leadingAnchor),
                loadingView.bottomAnchor.constraint(equalTo: loadingContainerView.bottomAnchor)
            ])
        }
    }
    
    func setupHeaderView() {
        guard let headerContainerView = headerContainerView else { return }
        headerContainerView.contentContainerView = contentHeaderView
    }
    
    func setupContent() {
        guard let contentContainerView = contentContainerView else { return }
        contentContainerView.subviews.forEach({$0.removeFromSuperview()})
        mainContentView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(mainContentView)
        NSLayoutConstraint.activate([
            mainContentView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            mainContentView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            mainContentView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            mainContentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            endEditing(true)
            let location = gesture.location(in: self)
            gestureStartLocation = location
            headerStartHeight = heightOfHeader.constant
        case .changed: ()
            if !isReceiveTouchFromOtherScrollView {
                let currentLocation = gesture.location(in: self)
                let offSetY = gestureStartLocation.y - currentLocation.y
                // Up > 0 , down < 0
                var height = headerStartHeight - offSetY
                height = height < minimumHeightOfHeader ? minimumHeightOfHeader : height
                height = height > maximumHeightOfHeader ? maximumHeightOfHeader : height
                heightOfHeader.constant = height
                updatedHeaderHeight = height
                if isEnablePullToRefresh {
                    let rawHeight = headerStartHeight - offSetY - height
                    var loadingHeight = rawHeight
                    loadingHeight = loadingHeight < 0 ? 0 : loadingHeight
                    loadingHeight = loadingHeight > maximunHeightOfPullToRefresh ? maximunHeightOfPullToRefresh : loadingHeight
                    heightOfLoading.constant = loadingHeight
                    updatedPullToRefreshHeight = loadingHeight
                }
            }
        case .ended:
            headerStartHeight = 0
            isReceiveTouchFromOtherScrollView = false
            performRefreshIfNeeded()
        default: ()
        }
    }
    
    func performRefreshIfNeeded() {
        if isEnablePullToRefresh && heightOfLoading.constant > 0 {
            if heightOfLoading.constant == maximunHeightOfPullToRefresh {
                delegate?.hParallaxContainerDidPullToRefresh?(self)
            }
            UIView.animate(withDuration: 0.2) {
                self.heightOfLoading.constant = 0
                self.layoutIfNeeded()
                self.delegate?.hParallaxContainer?(self,
                                                   didChangePullToRefreshViewHeight: self.heightOfLoading.constant,
                                                   maximumAvailableHeight: self.maximunHeightOfPullToRefresh)
            }
            loadingViewWorkItem?.cancel()
            let workItem = DispatchWorkItem {
                self.performRefreshIfNeeded()
            }
            loadingViewWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2,
                                          execute: workItem)
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
        
        if ((!lock && diff > 0) && heightOfHeader.constant == maximumHeightOfHeader ||
            (lock && diff < 0) && heightOfLoading.constant > 0) && isEnablePullToRefresh {
            var height: CGFloat = heightOfLoading.constant + diff
            height = height < 0 ? 0 : height
            height = height > maximunHeightOfPullToRefresh ? maximunHeightOfPullToRefresh : height
            heightOfLoading.constant = height
            isMove = 0 < height && height < maximunHeightOfPullToRefresh
            if height != updatedPullToRefreshHeight {
                updatedPullToRefreshHeight = height
                delegate?.hParallaxContainer?(self,
                                              didChangePullToRefreshViewHeight: height,
                                              maximumAvailableHeight: maximunHeightOfPullToRefresh)
            }
          
        } else if (lock && diff < 0) || (!lock && diff > 0) {
            var height: CGFloat = heightOfHeader.constant + diff
            height = height < minimumHeightOfHeader ? minimumHeightOfHeader : height
            height = height > maximumHeightOfHeader ? maximumHeightOfHeader : height
            heightOfHeader.constant = height
            isMove = minimumHeightOfHeader < height && height < maximumHeightOfHeader
            updatedHeaderHeight = height
        }
        
        if isMove {
            // Scroll Up
            if (lock && diff < 0) {
                self.scrollView(scrollView, setContentOffset: old)
            } else if (!lock && diff > 0) {
                self.scrollView(scrollView,
                                setContentOffset: .init(x: scrollView.contentOffset.x,
                                                        y: -scrollView.contentInset.top))
            }
        }
    }
    
    private func scrollView(_ scrollView: UIScrollView, setContentOffset offset: CGPoint) {
        isObserving = false
        scrollView.contentOffset = offset
        isObserving = true
    }
}
// MARK: - UIGestureRecognizerDelegate
extension HParallaxHeaderContainer: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        let velocity = gestureRecognizer.velocity(in: self)
        guard abs(velocity.x) <= abs(velocity.y) else {
            return false
        }
        
        guard let otherView = otherGestureRecognizer.view as? UIScrollView else {
            isReceiveTouchFromOtherScrollView = false
            return true
        }
        // Make sure other scrollView is Vertical scrollable
        guard otherView.contentSize.height > otherView.frame.height,
                otherView.isScrollEnabled == true else {
            isReceiveTouchFromOtherScrollView = false
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
      
        isReceiveTouchFromOtherScrollView = true
        return true
    }
}
