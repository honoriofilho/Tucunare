//
//  ARViewContainer.swift
//  Tucunare
//
//  Created by honorio on 13/06/25.
//

import Foundation
import RealityKitContent
import RealityKit
import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    
    let arView = ARView(frame: .zero)

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ARView {
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }

        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        
        arView.session.delegate = context.coordinator
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
