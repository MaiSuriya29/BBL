//
//  UnauthenticatedView.swift
//  BBLTest
//
//  Created by Suriya on 2/8/2565 BE.
//

import SwiftUI


struct UnauthenticatedView: View {
    @ObservedObject private var model: UnauthenticatedViewModel
    init(model: UnauthenticatedViewModel) {
        self.model = model
    }
    var body: some View {
        
        let isEnabled = true
        return VStack {
            
            if self.model.error != nil {
                ErrorView(model: ErrorViewModel(error: self.model.error!))
            }
       
            Spacer()
            Button(action: self.model.startLogin) {
                ZStack {
                    Text("Start Authentication")
                        .padding()
                        .font(.subheadline)
                        .foregroundColor(.white)
                }.background(Color.gray.cornerRadius(8))
                    
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .disabled(!isEnabled)
            
            Spacer()
        }

    }
}

//struct UnauthenticatedView_Previews: PreviewProvider {
//    static var previews: some View {
//        UnauthenticatedView()
//    }
//}
