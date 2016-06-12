//
//  ViewController.swift
//  CYMenu
//
//  Created by Cairo on 16/6/6.
//  Copyright © 2016年 Cairo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var moreButton: UIButton!
    var menu : CYMenu?
    var dimView : UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dimView = UIView(frame: self.view.bounds)
        self.dimView!.backgroundColor = UIColor.blackColor()
        self.dimView!.hidden = true
        self.dimView?.alpha = 0
        self.view.addSubview(self.dimView!)
        self.menu = CYMenu(NumberOfItems: 3, ItemSize: 50, ItemSpace: 15, OriginPoint: CGPointMake(moreButton.center.x , moreButton.center.y + 10 ) ,ShowDirection: .Down)
        self.menu!.hideOriginView = true
        self.menu?.titlePosition = .Left
        self.menu?.titleColor = UIColor.whiteColor()
        self.menu?.menuColor = UIColor.whiteColor()
        self.menu?.menuTitles = ["Like" , "Share" , "Save"]
        self.menu?.menuIcons = ["Like" , "Share" , "Save"]
        self.menu?.callBackWithIndex = {index in
            UIView.animateWithDuration(0.1, animations: {
                self.dimView?.alpha = 0
            }) { (finish) in
                self.dimView?.hidden = true
            }
            print(index)
        }
        self.view.addSubview(self.menu!)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func moreButtonHandle(sender: AnyObject) {
        self.dimView?.hidden = false
        UIView.animateWithDuration(0.02, animations: {
            self.dimView?.alpha = 0.7
            }) { (finish) in
        }
        self.menu?.didTapOriginView()
    }
    

}

