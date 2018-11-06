//
//  Camera.swift
//  CameraWithImage
//
//  Created by MINA FUJISAWA on 2018/10/30.
//  Copyright © 2018 MINA FUJISAWA. All rights reserved.
//

import UIKit
import AVFoundation

enum CameraControllerError: Swift.Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
}

enum CameraPosition {
    case front
    case rear
}

class Camera {
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var previewHeight: CGFloat = 0

    init(previewHeight: CGFloat) {
        self.previewHeight = previewHeight
    }

    func prepare(completionHandler: @escaping (Error?) -> Void) {
        DispatchQueue(label: "prepare").async { [weak self] in
            do {
                self?.createCaptureSession()
                try self?.configureCaptureDevices()
                try self?.configureDeviceInputs()
                try self?.configurePhotoOutput()
            }

            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }

                return
            }

            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }

    func createCaptureSession() {
        self.captureSession = AVCaptureSession()
    }

    func configureCaptureDevices() throws {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        let cameras = session.devices.compactMap { $0 }

        guard !cameras.isEmpty else {
            throw CameraControllerError.noCamerasAvailable
        }

        for camera in cameras {
            if camera.position == .front {
                self.frontCamera = camera
            }

            if camera.position == .back {
                self.rearCamera = camera

                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
        }
    }

    func configureDeviceInputs() throws {
        guard let captureSession = self.captureSession else {
            throw CameraControllerError.captureSessionIsMissing
        }

        if let rearCamera = self.rearCamera {
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)

            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
            }
            self.currentCameraPosition = .rear

        } else if let frontCamera = self.frontCamera {
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)

            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
            } else {
                throw CameraControllerError.inputsAreInvalid
            }

            self.currentCameraPosition = .front

        } else {
            throw CameraControllerError.noCamerasAvailable
        }
    }

    func configurePhotoOutput() throws {
        guard let captureSession = self.captureSession else {
            throw CameraControllerError.captureSessionIsMissing
        }

        self.photoOutput = AVCapturePhotoOutput()
        self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)

        if captureSession.canAddOutput(self.photoOutput!) {
            captureSession.addOutput(self.photoOutput!)
        }

        captureSession.startRunning()
    }

    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }

        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait

        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: previewHeight)
    }
}


