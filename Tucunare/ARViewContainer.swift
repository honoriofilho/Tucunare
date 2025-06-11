//
//  ARViewContainer.swift
//  Tucunare
//
//  Created by Yaslly Guimarães Maciel on 11/06/25.
//

import SwiftUI
import ARKit
import SceneKit

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.delegate = context.coordinator
        arView.session.delegate = context.coordinator
        
        arView.autoenablesDefaultLighting = true
        arView.scene = SCNScene()
        
        // Carrega as imagens de referência
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Não encontrou o AR Resources")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1  // Podemos mudar depois se quiser múltiplas imagens
        
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        // Quando detectar a imagem:
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard let imageAnchor = anchor as? ARImageAnchor else { return }
            let referenceImage = imageAnchor.referenceImage

            DispatchQueue.main.async {
                print("Imagem detectada: \(referenceImage.name ?? "sem nome")")
            }

            // Cria um plano para sobrepor à imagem detectada
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                  height: referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor.yellow.withAlphaComponent(0.4)

            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2  // Para deixar deitado

            node.addChildNode(planeNode)

            // Animação de "pulse" com escala e brilho
            let pulseAction = SCNAction.sequence([
                .scale(to: 1.2, duration: 0.3),
                .scale(to: 1.0, duration: 0.3)
            ])
            let pulseForever = SCNAction.repeatForever(pulseAction)
            planeNode.runAction(pulseForever)

            // Adiciona efeito de partículas
            if let particleSystem = SCNParticleSystem(named: "Spark.scnp", inDirectory: nil) {
                let particleNode = SCNNode()
                particleNode.addParticleSystem(particleSystem)
                particleNode.position = SCNVector3(0, 0, 0)  // Em cima da imagem
                node.addChildNode(particleNode)
            }
        }
    }
}
