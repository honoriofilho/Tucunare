//
//  ContentView.swift
//  Tucunare
//
//  Created by honorio on 10/06/25.
//

import RealityKitContent
import RealityKit
import SwiftUI
import ARKit

struct ContentView: View {
    var body: some View {
        ZStack {
            ARViewContainer()
        }
        .ignoresSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    let arView = ARView(frame: .zero)

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ARView {
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "Resources", bundle: nil) else {
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
    
    class Coordinator: NSObject, ARSessionDelegate {
        let parent: ARViewContainer

        init(_ parent: ARViewContainer) {
            self.parent = parent
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                guard let imageAnchor = anchor as? ARImageAnchor else { continue }

                Task {
                    do {
                        let entity = try await Entity(named: "Scene", in: realityKitContentBundle)
                        
                        let anchorEntity = await AnchorEntity(anchor: imageAnchor)
                        await anchorEntity.addChild(entity)
                        
                        await parent.arView.scene.addAnchor(anchorEntity)

                    } catch {
                        print("Erro ao carregar entidade RealityKit: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
