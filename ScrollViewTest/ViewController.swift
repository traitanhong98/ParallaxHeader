//
//  ViewController.swift
//  ScrollViewTest
//
//  Created by ECO0542-HoangNM on 05/12/2022.
//

import UIKit

class ViewController: UIViewController {
    static var context = "HeaderContex"
    @IBOutlet weak var heightOfHeader: NSLayoutConstraint!
    private let maximumHeightOfHeader: CGFloat = 250
    private let minimumHeightOfHeader: CGFloat = 50
    private var observingViews: [UIView] = []
    private var isObserving: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }

    deinit {
        observingViews.forEach { view in
            view.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: &ViewController.context)
        }
    }
    
    func setupView() {
        let gesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGesture(_:))
        )
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &ViewController.context,
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
        print(diff)
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

    func scrollView(_ scrollView: UIScrollView, setContentOffset offset: CGPoint) {
        isObserving = false
        scrollView.contentOffset = offset
        isObserving = true
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        let velocity = gestureRecognizer.velocity(in: self.view)
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
            otherView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset),  options: [.old, .new], context: &ViewController.context)
            observingViews.append(otherView)
        }
        return true
    }
}
