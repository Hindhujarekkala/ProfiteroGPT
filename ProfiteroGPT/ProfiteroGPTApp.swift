//
//  ProfiteroGPTApp.swift
//  Profitero ChatGPT
//
//  Created by Rekkala Hindhuja on 28/06/23.
//

import SwiftUI

@main
struct ProfiteroGPTApp: App {
    @StateObject var vm = ViewModel(api: ChatGPTAPI(apiKey: "apikey"))
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                 ContentView(vm:vm)
                    
                    .toolbar{
                        ToolbarItem{
                            Button("Clear"){
                                vm.clearMessages()
                            }
                            .disabled(vm.isInteractingWithChatGPT)
                        }
                    }
            }
        }
    }
}

