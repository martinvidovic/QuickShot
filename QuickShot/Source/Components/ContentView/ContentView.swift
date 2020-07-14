//
//  ContentView.swift
//  QuickShot
//
//  Created by Martin Vidovic on 14/07/2020.
//  Copyright © 2020 Martin Vidovic. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(self.viewModel.images.chunked(into: 3), id: \.self) { chunk in
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(chunk, id: \.self) { image in
                                Image(nsImage: NSImage(byReferencing: image))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width/3,
                                           height: geometry.size.height/2)
                                    .border(Color.black, width: 1)
                            }
                        }
                    }
                }
            }.background(Color.gray)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init())
    }
}

