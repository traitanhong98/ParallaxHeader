//
//  CustomViewController.swift
//  ScrollViewTest
//
//  Created by ECO0542-HoangNM on 05/12/2022.
//

import UIKit

class CustomViewController: UIViewController {

    @IBOutlet weak var loadingIcon: UIImageView!
    @IBOutlet var header: UIView!
    @IBOutlet weak var headerContainer: HParallaxHeaderContainer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        headerContainer.headerContainerView.headerHeight = 100
        headerContainer.isEnablePullToRefresh = true
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func fillAction(_ sender: Any) {
        headerContainer.headerContainerView.mode = .fill
    }
    
    @IBAction func topFillAction(_ sender: Any) {
        headerContainer.headerContainerView.mode = .topFill
    }
    
    @IBAction func topAction(_ sender: Any) {
        headerContainer.headerContainerView.mode = .top
    }
    
    @IBAction func centerAction(_ sender: Any) {
        headerContainer.headerContainerView.mode = .center
    }
    
    @IBAction func bottomAction(_ sender: Any) {
        headerContainer.headerContainerView.mode = .bottom
    }
}

extension CustomViewController: HParallaxHeaderContainerDelegate {
    func hParallaxContainer(_ view: HParallaxHeaderContainer, didChangePullToRefreshViewHeight height: CGFloat, maximumAvailableHeight: CGFloat) {
        print("Header \(height)")
        loadingIcon.transform = CGAffineTransform(rotationAngle:  (height / maximumAvailableHeight) * CGFloat.pi)
    }
    
    func hParallaxContainer(_ view: HParallaxHeaderContainer, didChangeHeaderViewHeight height: CGFloat, maximumAvailableHeight: CGFloat) {
        print("Header \(height)")
    }
    
    func hParallaxContainerDidPullToRefresh(_ view: HParallaxHeaderContainer) {
        print("Hello")
    }
}
