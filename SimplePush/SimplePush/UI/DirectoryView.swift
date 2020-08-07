/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The main view of the app that lists other connected users.
*/

import Foundation
import SwiftUI
import Combine
import SimplePushKit

struct DirectoryView: View {
    @EnvironmentObject var rootViewCoordinator: RootViewCoordinator
    @StateObject private var viewModel = DirectoryViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                List(viewModel.users) { user in
                    Button {
                        rootViewCoordinator.presentedView = .user(user, nil)
                    } label: {
                        HStack {
                            Text(user.deviceName)
                                .font(.headline)
                                .fontWeight(.regular)
                                .foregroundColor(Color("Colors/PrimaryText"))
                            Spacer()
                            Circle()
                                .fill(fillForCallIndicator(user: user))
                                .frame(width: 10.0)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .environment(\.defaultMinListRowHeight, 50.0)
                
                VStack {
                    if viewModel.state != .connected {
                        placeholderView(state: viewModel.state)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .edgesIgnoringSafeArea(.all)
                            .background(viewModel.state == .connected ? Color.clear : Color("Colors/GroupedListBackground"))
                            .transition(transition)
                    }
                }
            }
            .navigationBarTitle("Contacts", displayMode: .large)
            .navigationBarItems(leading: Button {
                rootViewCoordinator.presentedView = .settings
            } label: {
                Text("Settings")
                    .fontWeight(.medium)
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder func placeholderView(state: DirectoryViewModel.State) -> some View {
        VStack(spacing: 30) {
            image(for: state)
                .font(.system(size: 60, weight: .light))
                .foregroundColor(Color("Colors/PrimaryText"))
            Text(viewModel.stateHumanReadable)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(Color("Colors/PrimaryText"))
        }
    }
    
    @ViewBuilder func image(for state: DirectoryViewModel.State) -> some View {
        switch state {
        case .configurationNeeded:
            Image(systemName: "wrench")
        case .waitingForActivePushManager:
            Image(systemName: "wifi.exclamationmark")
        case .waitingForUsers:
            Image(systemName: "person.crop.circle.badge.xmark")
        case .connecting, .connected:
            Image(systemName: "bolt")
        }
    }
    
    func fillForCallIndicator(user: User) -> Color {
        guard let connectedUser = viewModel.connectedUser,
            connectedUser.uuid == user.uuid else {
                return .clear
        }
        return .blue
    }
   
    var transition: AnyTransition {
        let duration = 0.5
        
        return AnyTransition
            .opacity
            .animation(.easeInOut(duration: duration))
    }
}
