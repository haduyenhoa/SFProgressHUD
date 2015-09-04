//
//  DetailViewController.swift
//  SFProgressDemo
//
//  Created by Edmond on 9/4/15.
//  Copyright © 2015 XueQiu. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var hud : SFProgressHUD?

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem, let label = self.detailDescriptionLabel {
            label.text = detail.description
                
            if label.text == "Simple" {
                hud = SFProgressHUD(view: self.view)
                self.view.addSubview(hud!)
                hud?.show(true)
                hud?.hide(true, afterDelay:3) 
            } else if label.text == "Label" {
                hud = SFProgressHUD(view: self.view)
                self.view.addSubview(hud!)
                hud?.label.text = "Loding"
                hud?.show(true)
                hud?.hide(true, afterDelay:3)
            } else if label.text == "Detail label" {
                hud = SFProgressHUD(view: self.view)
                self.view.addSubview(hud!)
                hud?.label.text = "Loding"
                hud?.detailsLabel.text = "updating data"
                hud?.show(true)
                hud?.hide(true, afterDelay:3)
            } else if label.text == "Detarminate model" {
                hud = SFProgressHUD(view: self.view)
                self.view.addSubview(hud!)
                hud?.mode = .Determinate
                hud?.label.text = "Loding"
                hud?.show(true)
                hud?.hide(true, afterDelay:3)
            } else if label.text == "Annular width detarminate model" {
                hud = SFProgressHUD(view: self.view)
                self.view.addSubview(hud!)
                hud?.mode = .AnnularDeterminate
                hud?.label.text = "Loding"
                hud?.show(true)
                hud?.hide(true, afterDelay:3)
            } else if label.text == "Mode switching" {
// TODO
                
            } else if label.text == "On window" {
                hud = SFProgressHUD(view: self.view)
                self.view.window?.addSubview(hud!)
                hud?.show(true)
                hud?.hide(true, afterDelay:3)
            } else if label.text == "NSNURLConnection" {
                hud = SFProgressHUD(view: self.view)
                self.view.addSubview(hud!)
                hud?.mode = .Text
                hud?.label.text = "Nothing!!!"
                hud?.show(true)
                hud?.hide(true, afterDelay:3)
            } else if label.text == "Dim background" {
                hud = SFProgressHUD(view: self.view)
                self.view.addSubview(hud!)
                hud?.dimBackground = true
                hud?.show(true)
                hud?.hide(true, afterDelay:3)
            } else if label.text == "Text only" {
                hud = SFProgressHUD(view: self.view)
                self.view.addSubview(hud!)
                hud?.mode = .Text
                hud?.show(true)
                hud?.hide(true, afterDelay:3)
            } else if label.text == "Custom View" {
                hud = SFProgressHUD(view: self.view)
                self.view.addSubview(hud!)
                hud?.mode = .CustomView
                hud?.label.text = "Complete"
                hud?.customView = UIImageView(image: UIImage(named:"37x-Checkmark"))
                hud?.show(true)
                hud?.hide(true, afterDelay:3)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

