//
//  FourthViewController.swift
//  SpamShield
//
//  Created by Ethan Mohammed on 4/17/23.
//

import UIKit

class FourthViewController: UIViewController {

    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    @IBOutlet weak var keywordView: UIView!
    @IBOutlet weak var numberView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubviewToFront(keywordView)
    }
    
    @IBAction func segmentSwitch(_ sender: UISegmentedControl) {
        view.endEditing(true)
        switch sender.selectedSegmentIndex {
        case 0:
            self.view.bringSubviewToFront(keywordView)
        case 1:
            self.view.bringSubviewToFront(numberView)
        default:
            break
        }
    }
    


}
