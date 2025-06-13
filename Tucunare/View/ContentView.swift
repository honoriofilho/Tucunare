//
//  ContentView.swift
//  Tucunare
//
//  Created by honorio on 10/06/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Text("Aponte para uma imagem")
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
