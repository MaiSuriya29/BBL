//
//  ErrorView.swift
//  BBLTest
//
//  Created by Suriya on 2/8/2565 BE.
//

import SwiftUI

struct ErrorView: View {
    @ObservedObject private var model: ErrorViewModel
    
    init(model: ErrorViewModel) {
        self.model = model
    }
    var body: some View {
    
        return VStack {
            
            Text(self.model.title)
                .padding(.top, 20)
                .padding(.leading, 20)

            Text(self.model.description)
                .padding(.leading, 20)
                .padding(.trailing, 20)
        }
    }

}

//struct ErrorView_Previews: PreviewProvider {
//    static var previews: some View {
//        ErrorView()
//    }
//}
