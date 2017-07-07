//
//  ATSignatureViewController.swift
//  CustomizedSignature
//
//  Created by Pacoyeung on 6/29/17.
//  Copyright © 2017 Pacoyeung. All rights reserved.
//

import UIKit

    // MARK: - Delegate Protocol
@objc public protocol ATSignatureDelegate {
    @objc optional func atSignatureCancel(_: ATSignatureViewController)
    @objc optional func atSignatureNotSigned(_: ATSignatureViewController)
    @objc optional func atSignatureSetSaveDirectory(_: ATSignatureViewController) -> String
    @objc optional func atSignatureSigned(_: ATSignatureViewController, didSign signatureImage : UIImage, signatureSavePath: String)
    @objc optional func atSignatureInvalidDirectoryError(_: ATSignatureViewController)
}

open class ATSignatureViewController: UIViewController {

    // MARK: - Public IBOutlets
    
    @IBOutlet open weak var cancelButton: UIButton!
    @IBOutlet open weak var confirmButton: UIButton!
    @IBOutlet weak var clickToStartButton: UIButton!
    
    // MARK: - Private IBOutlets
    
    @IBOutlet weak var signatureView: SignatureView!
    @IBOutlet weak var signatureImgView: UIImageView!
    
    // MARK: - Public Vars
    
    
    
    // MARK: - Private Vars
    
    private var targetView: UIView!
    private var layer:CAShapeLayer!
    private var showModal:Int!
    private var borderModal: Int!
    private var display:[String]!
    open weak var signatureDelegate: ATSignatureDelegate?
    
    enum ATSignatureError: Error {
        case emptyDirectory
    }
    
    // MARK: - Public Function
    
    public func changeButtonsColor(color: UIColor) {
        self.cancelButton.setTitleColor(color, for: .normal)
        self.confirmButton.setTitleColor(color, for: .normal)
        self.clickToStartButton.setTitleColor(color, for: .normal)
        let lightColor = self.clickToStartButton.titleColor(for: .normal)?.withAlphaComponent(0.5)
        self.clickToStartButton.setTitleColor(lightColor, for: .normal)
    }
    public func changeButtonDisplay(display: [String])
    {
        self.clickToStartButton.titleLabel?.text = display[0]
        self.cancelButton.titleLabel?.text = display[1]
        self.confirmButton.titleLabel?.text = display[2]
    }
    
    // MARK: - Initializers
    
    public convenience init(signatureDelegate: ATSignatureDelegate, targetView: UIView)
    {
        let bundle = Bundle(for: ATSignatureViewController.self)
        self.init(nibName: "ATSignatureViewController", bundle: bundle, signatureDelegate: signatureDelegate, targetView: targetView)
    }
    
    public convenience init(nibName: String?, bundle: Bundle?, signatureDelegate: ATSignatureDelegate, targetView: UIView) {
        self.init(nibName: nibName, bundle: bundle, signatureDelegate: signatureDelegate, targetView: targetView, showModal: 2, borderModal: 2, display: ["點擊簽署","取消","完成"])
    }
    
    public init(nibName: String?, bundle: Bundle?, signatureDelegate: ATSignatureDelegate, targetView: UIView, showModal: Int, borderModal: Int, display: [String]) {
        
        //Init Vars
        self.signatureDelegate = signatureDelegate
        self.targetView = targetView
        self.showModal = showModal
        self.borderModal = borderModal
        self.display = display
        super.init(nibName: nibName, bundle: bundle)
        
        // MARK: - Add a customized signature view to a super view
        
        self.targetView.addSubview(self.view)
        
        // MARK: - Set a customozed signature view auto match the size with a super view
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.targetView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self.view]))
        self.targetView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self.view]))
    }
    
    // MARK: - Life Cycle Function
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        //MARK: - Set Views
        
        switch self.showModal {
        case 1:
            self.signatureView.isHidden = false
            self.signatureImgView.isHidden = true
        case 2:
            self.clickToStartButton.isHidden = false
            self.signatureView.isHidden = true
            self.signatureImgView.isHidden = true
        default:
            self.signatureView.isHidden = true
            self.signatureImgView.isHidden = true
        }
        
        //MARK: - Set Border
        
        self.layer = CAShapeLayer(layer: self.targetView.layer)
        
        switch self.borderModal {
        case 1:
            self.layer.frame = self.targetView.bounds
        case 2:
            self.layer.strokeColor = UIColor.init(red: 67/255, green: 37/255, blue: 83/255, alpha: 1).cgColor
            self.layer.fillColor = nil
            self.layer.lineDashPattern = [20,20]
            self.layer.cornerRadius = 5
            self.layer.lineWidth = 5
            self.layer.path = UIBezierPath.init(rect: self.targetView.bounds).cgPath
        default:
            self.layer.frame = self.targetView.bounds
        }
        self.targetView.layer.addSublayer(self.layer)
        
        //MARK: - Set Character
        
        self.changeButtonDisplay(display: self.display)
        
        // MARK: - Set Button Text Color
        
        self.changeButtonsColor(color: UIColor.init(red: 161/255, green: 9/255, blue: 71/255, alpha: 1.0))
        
        // MARK: - Set Button Selector
        
        self.confirmButton.addTarget(self, action: #selector(confirmButtonDidPress(_:)), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(cancelButtonDidPress(_:)), for: .touchUpInside)
        self.clickToStartButton.backgroundColor = UIColor.init(red: 176/255, green: 176/255, blue: 176/255, alpha: 0.6)
        self.clickToStartButton.addTarget(self, action: #selector(clickToStartButtonDidPress(_:)), for: .touchUpInside)
        
    }
    
    
    // MARK: - Button Actions
    
    func clickToStartButtonDidPress(_ sender: UIButton)
    {
        self.clickToStartButton.isHidden = true
        self.signatureView.isHidden = false
    }
    
    func confirmButtonDidPress(_ sender: UIButton) {
        // MARK: Save Signature
        
        if let signedImg = signatureView.getSignatureAsImage() {
            //Signed Handling
            signatureImgView.image = signedImg
            //Update appearing
            self.confirmButton.isEnabled = false
            self.signatureView.clear()
            self.signatureView.isHidden = true
            self.signatureImgView.isHidden = false
            self.signatureImgView.backgroundColor = UIColor.init(red: 176/255, green: 176/255, blue: 176/255, alpha: 0.4)
            //Check whether directory is empty or not
            var directory = ""
            do {
                directory = self.getDirectory()
                guard !(directory.isEmpty) else {
                    throw ATSignatureError.emptyDirectory
                }
                //Save file
                let filePath = (directory as NSString).appendingPathComponent("sig.data")
                self.signatureView.saveSignature(filePath)
                //Call a user's customized action after saving file at the app's local directory
                self.signatureDelegate?.atSignatureSigned?(self, didSign: signedImg, signatureSavePath: filePath)
            } catch ATSignatureError.emptyDirectory {
                //Invalid Directory
                print("ATSignatureViewController.confirmButtonDidPress Invalid or Empty Directory")
                //Call a user's customized action if invalid directory is detected
                self.signatureDelegate?.atSignatureInvalidDirectoryError?(self)
            } catch {
                print("ATSignatureViewController.confirmButtonDidPress Unhandled Exception")
            }
            
        }else{
            //Not Signed Handling
            //Call a user's customized action if not signing
            self.signatureDelegate?.atSignatureNotSigned?(self)
        }
    }
    
    func cancelButtonDidPress(_ sender: UIButton) {
 
        self.signatureView.clear()
        //Update appearing
        self.signatureImgView.image = nil
        self.confirmButton.isEnabled = true
        self.signatureImgView.isHidden = true
        self.signatureView.isHidden = false
        self.signatureImgView.backgroundColor = UIColor.init(white: 255/255, alpha: 0.0)
        //Call a user's customized action after pressing a cancel button
        self.signatureDelegate?.atSignatureCancel?(self)
    }
    
    // MARK: - Private Function
    
    private func getDirectory() -> String{
        var directory = ""
        var doChange:Bool = false
        if let str = self.signatureDelegate?.atSignatureSetSaveDirectory?(self) {
            if str == "" || directory != str {
                doChange = true
            }
            directory = str
        }
        if directory.isEmpty {
            if let str = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                directory = str
                if doChange {
                    print("User's customized directory is invalid and, Api sets the directory as \"\(directory)\" ")
                }
            }
        }
        return directory
    }
    
    // MARK: - Override Function 
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
