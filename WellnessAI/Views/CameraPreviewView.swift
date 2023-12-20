//
//  CameraPreviewView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/20/23.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black
        viewController.view.layer.addSublayer(previewLayer)
        previewLayer.frame = viewController.view.bounds
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {

    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: ()) {
        
    }
    
}
