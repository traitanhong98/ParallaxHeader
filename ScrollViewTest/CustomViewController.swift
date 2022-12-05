//
//  CustomViewController.swift
//  ScrollViewTest
//
//  Created by ECO0542-HoangNM on 05/12/2022.
//

import UIKit

class CustomViewController: UIViewController {

    @IBOutlet weak var headerContainer: HParallaxHeaderContainer!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        headerContainer.headerContainerView.height = 100
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
