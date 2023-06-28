//
//  ContentView.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @FocusState var isTextFieldFocused: Bool
    @ObservedObject var vm: ViewModel
    var body: some View {
        chatListView
    }
    
    var chatListView: some View {
        ScrollViewReader { proxy in
               
            VStack(spacing: 0) {
                Text("ProfiteroGPT")
                    .font(.largeTitle.weight(.bold))
            ScrollView {
                  LazyVStack(spacing: 0) {
                  ForEach(vm.messages) { message in
                     MessageRowView(message: message) { message in
                          Task { @MainActor in
                                    await vm.retry(message: message)
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                }

                Divider()
                bottomView(image: "profile", proxy: proxy)
                Spacer()
            }
            .onChange(of: vm.messages.last?.responseText) { _ in  scrollToBottom(proxy: proxy)
            }
        }
      .background(colorScheme == .light ? .white : Color(red: 89/255, green: 53/255, blue: 65/255, opacity: 0.5))
    }
    
    func bottomView(image: String, proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .top, spacing: 8) {
            if image.hasPrefix("http"), let url = URL(string: image) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .frame(width: 30, height: 30)
                } placeholder: {
                    ProgressView()
                }

            } else {
                Image(image)
                    .resizable()
                    .frame(width: 30, height: 30)
            }
           
            TextField("Ask me a question...", text: $vm.inputMessage, axis: .vertical)
                .focused($isTextFieldFocused)
                .disabled(vm.isInteractingWithChatGPT)
            
            if vm.isInteractingWithChatGPT {
                DotLoadingView().frame(width: 60, height: 30)
            } else {
                Button {
                    Task { @MainActor in
                        isTextFieldFocused = false
                        scrollToBottom(proxy: proxy)
                        await vm.sendTapped()
                    }
                } label: {
                    Image(systemName: "paperplane")
                        .rotationEffect(.degrees(45))
                        .font(.system(size: 20))
                }
                .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = vm.messages.last?.id else { return }
        proxy.scrollTo(id, anchor: .bottomTrailing)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView(vm: ViewModel(api: ChatGPTAPI(apiKey: "apikey")))
        }
    }
}
