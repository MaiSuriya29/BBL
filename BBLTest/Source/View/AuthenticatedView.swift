//
//  AuthenticatedView.swift
//  BBLTest
//
//  Created by Suriya on 2/8/2565 BE.
//

import SwiftUI
import SwiftJWT

struct AuthenticatedView: View {
    @ObservedObject private var model: AuthenticatedViewModel

    init(model: AuthenticatedViewModel) {
        self.model = model
    }
    var body: some View {
    
//        let deviceWidth = UIScreen.main.bounds.size.width
//        let refreshEnabled = self.model.hasRefreshToken
//        let signOutEnabled = self.model.hasIdToken

        return VStack {
            
            if self.model.error != nil {
                ErrorView(model: ErrorViewModel(error: self.model.error!))
                    .foregroundColor(.red)
            }
           
          
                
        
            if let name = model.userData?.name {
                Text(name)
                    .font(.headline)
            }
          
            if let url = model.userData?.picture {
                AsyncImage(url: URL(string: url))
                    .frame(width: 100, height: 100, alignment: .center)
                    .cornerRadius(10)
            }
            if let nickname = model.userData?.nickname{
                Text(nickname)
                    .font(.body)
            }
                
            

   
        
            
            Spacer()
        }
        .onAppear(perform: self.onViewCreated)
    }
    
    func onViewCreated() {
        self.model.processTokens()
        
    }
        
    func getViewController() -> UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
}

//struct AuthenticatedView_Previews: PreviewProvider {
//    static var previews: some View {
//        AuthenticatedView()
//    }
//}
