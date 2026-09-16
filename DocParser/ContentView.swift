//
//  ContentView.swift
//  DocParser
//
//  Created by Prabhdeep Singh on 15/09/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .task({
            try? await DocParser.parseData()
        })
        .padding()
    }
}

#Preview {
    ContentView()
}
