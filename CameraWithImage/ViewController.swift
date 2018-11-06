//
//  ViewController.swift
//  CameraWithImage
//
//  Created by MINA FUJISAWA on 2018/10/10.
//  Copyright © 2018 MINA FUJISAWA. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet fileprivate var captureButton: UIButton!
    @IBOutlet fileprivate var capturePreviewView: UIView!
//    @IBOutlet fileprivate var toggleCameraButton: UIButton!
//    @IBOutlet fileprivate var toggleFlashButton: UIButton!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var capturePreviewViewHeightConstraint: NSLayoutConstraint!
    
    var camera: Camera!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCameraController()
        view.backgroundColor = .black
    }

    func configureCameraController() {
        camera.prepare { (error) in
            if let error = error {
                print(error)
            }

            try? self.camera.displayPreview(on: self.capturePreviewView)
        }
    }

    func setupUI() {
        captureButton.setTitle("", for: .normal)
        captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        captureButton.backgroundColor = .white
        
        guard let image = UIImage(named: "sample") else {
            print("failed to get image")
            return
        }
        filterImageView.image = UIImage(named: "sample")
        filterImageView.alpha = 0.5
        filterImageView.contentMode = .scaleAspectFit
        
        let height = image.size.height * view.frame.width / image.size.width
        capturePreviewViewHeightConstraint.constant = height
        view.layoutIfNeeded()
        camera = Camera(previewHeight: height)
    }
}

extension UIImage {
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

