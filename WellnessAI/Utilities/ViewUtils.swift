//
//  ViewUtils.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/20/23.
//

import Foundation
import SwiftUI

extension View {
    
    // Takes a screenshot of any view
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
    
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
            
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
            
        let window = UIWindow(frame: view!.bounds)
        window.addSubview(controller.view)
        window.makeKeyAndVisible()
            
        let renderer = UIGraphicsImageRenderer(bounds: view!.bounds, format: format)
        return renderer.image { rendererContext in
            view?.layer.render(in: rendererContext.cgContext)
        }
    }
    
}
