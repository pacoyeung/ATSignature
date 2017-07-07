//
//  ViewController.swift
//  CustomizedSignature
//
//  Created by Pacoyeung on 6/29/17.
//  Copyright © 2017 Pacoyeung. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ATSignatureDelegate {

    var vc:ATSignatureViewController!
    
    
    @IBOutlet weak var targetView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let vc = ATSignatureViewController(signatureDelegate: self, targetView: targetView)
        self.vc = vc
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //optional
    func atSignatureCancel(_: ATSignatureViewController) {
        print("Cancel")
    }
    //optional
    func atSignatureSetSaveDirectory(_: ATSignatureViewController) -> String {
        return ""
    }
    //optional
    func atSignatureSigned(_: ATSignatureViewController, didSign signatureImage : UIImage, signatureSavePath: String) {
        print("Did Signature")
    }
    //optional
    func atSignatureNotSigned(_: ATSignatureViewController) {
        print("Not Signature")
    }
    //optional
    func atSignatureInvalidDirectoryError(_: ATSignatureViewController)
    {
        print("InvalidDirectoryError")
    }
}

