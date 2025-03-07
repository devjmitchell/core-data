//
//  CameraViewController.swift
//  Moody
//
//  Created by Florian on 18/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit


protocol CameraViewControllerDelegate: class {
    func didCapture(_ image: UIImage)
}


class CameraViewController: UIViewController {

    @IBOutlet weak var cameraView: CameraView?
    weak var delegate: CameraViewControllerDelegate!
    var locationIsAuthorized: Bool = false {
        didSet { updateAuthorizationStatus() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        session = CaptureSession(delegate: self)
        #if !IOS_SIMULATOR
            cameraView?.setup(for: session.createPreviewLayer())
        #endif
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(snap))
        cameraView?.addGestureRecognizer(recognizer)
        updateAuthorizationStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.start()
    }

    override func viewDidDisappear(_ animated: Bool) {
        session.stop()
        super.viewDidDisappear(animated)
    }

    @IBAction func snap(_ recognizer: UITapGestureRecognizer) {
        #if IOS_SIMULATOR
            self.showImagePicker()
        #else
            session.captureImage()
        #endif
    }


    // MARK: Private

    fileprivate var session: CaptureSession!
    fileprivate var imagePicker: UIImagePickerController?

    fileprivate var readyToSnap: Bool {
        return session.isAuthorized && locationIsAuthorized
    }

    fileprivate func showImagePicker() {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        present(imagePicker!, animated: true, completion: nil)
    }

    fileprivate func updateAuthorizationStatus() {
        cameraView?.authorized = readyToSnap
    }

}


extension CameraViewController: CaptureSessionDelegate {

    func captureSessionDidCapture(_ image: UIImage?) {
        guard let image = image else { return }
        self.delegate.didCapture(image)
    }


    func captureSessionDidChangeAuthorizationStatus(authorized: Bool) {
        updateAuthorizationStatus()
    }

}


extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            delegate.didCapture(image)
        }
        dismiss(animated: true, completion: nil)
        imagePicker = nil
    }

}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
