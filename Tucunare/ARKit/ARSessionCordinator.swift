//
//  Cordinator.swift
//  Tucunare
//
//  Created by honorio on 13/06/25.
//

import Foundation
import RealityKitContent
import RealityKit
import SwiftUI
import ARKit

class Coordinator: NSObject, ARSessionDelegate {
    let parent: ARViewContainer

    init(_ parent: ARViewContainer) {
        self.parent = parent
    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let imageAnchor = anchor as? ARImageAnchor else { continue }
            let referenceImage = imageAnchor.referenceImage
            
            DispatchQueue.main.async {
                print("Imagem detectada: \(referenceImage.name ?? "sem nome")")
            }
            
            let width = Float(referenceImage.physicalSize.width)
            let height = Float(referenceImage.physicalSize.height)

            let planeMesh = MeshResource.generatePlane(width: width, height: height)
            let yellowMaterial = SimpleMaterial(color: .yellow.withAlphaComponent(0.4), isMetallic: false)
            let planeEntity = ModelEntity(mesh: planeMesh, materials: [yellowMaterial])
            planeEntity.transform.rotation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])

            // Animação de “pulso”
            var growing = true
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                let scale: Float = growing ? 1.2 : 1.0
                growing.toggle()
                planeEntity.setScale([scale, 1.0, scale], relativeTo: planeEntity)
            }

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
