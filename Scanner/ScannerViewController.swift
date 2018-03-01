//
//  ViewController.swift
//  Scanner
//
//  Created by Luis Alvarado on 7/27/17.
//  Copyright © 2017 aloysiusan. All rights reserved.
//

import UIKit
import AVFoundation
import ZXingObjC

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    private var captureSession:AVCaptureSession!
    private var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    private var codeFrameView:UIView?
    
    private let keys : [UInt8] = [
        0x27,
        0x30,
        0x04,
        0xA0,
        0x00,
        0x0F,
        0x93,
        0x12,
        0xA0,
        0xD1,
        0x33,
        0xE0,
        0x03,
        0xD0,
        0x00,
        0xDf,
        0x00
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.pdf417]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Initialize  Code Frame to highlight the  code
            codeFrameView = UIView()
            
            if let codeFrameView = codeFrameView {
                codeFrameView.layer.borderColor = UIColor.green.cgColor
                codeFrameView.layer.borderWidth = 2
                view.addSubview(codeFrameView)
                view.bringSubview(toFront: codeFrameView)
            }
            
            // Start video capture.
            captureSession?.startRunning()
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    func found(code: String) {
        
        captureSession.stopRunning()
        let alert = UIAlertController(title: "Found", message: code, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.codeFrameView?.frame = CGRect.zero
            self.captureSession.startRunning()
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            codeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.pdf417 {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            codeFrameView?.frame = barCodeObject!.bounds

            if let descriptor = metadataObj.descriptor {
                let filter = CIFilter(name: "CIBarcodeGenerator", withInputParameters: ["inputBarcodeDescriptor" : descriptor])
                
                let context = CIContext(options: nil)
                
                guard let image = filter?.outputImage, let cgImage = context.createCGImage(image, from: image.extent) else {
                    print("failed to get image")
                    return
                }
                
                let source = ZXCGImageLuminanceSource(cgImage: cgImage)
                let bitmap = ZXBinaryBitmap(binarizer: ZXHybridBinarizer(source: source))
                
                let reader = ZXPDF417Reader()
                
                if let result = try? reader.decode(bitmap) {
                    self.found(code: decode(data: result.text.data(using: .isoLatin1)!).description)
                }
                else {
                    print("Failed to decode")
                }
                
            }
        }
    }
    
    func decode(data : Data) -> Person{
        var d = ""
        var j = 0
        
        for byte in data {
            if (j == 17) {
                j = 0
            }
            
            let c = String(Character(UnicodeScalar(keys[j] ^ byte)))
            
            if c.range(of: "^[a-zA-Z0-9]*$", options: .regularExpression) != nil {
                d.append(c)
            }else{
                d.append(" ")
            }
            
            j += 1
        }
        
        return Person(rawString: d)
    }
}

