//
//  ToolBox.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/10/01.
//

import Foundation
import SwiftUI
import FilePicker
import ActivityIndicatorView

struct ToolBox: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
                List {
                    Group {
                        Section(header: Label(MILocalizedString("Action"), systemImage: "gear")) {
                            Button(MILocalizedString("Apply All")){
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                ViewMemory.shared.AppLoading = true
                                DispatchQueue.global().async { // バックグラウンドスレッドで実行する
                                    ApplyAll(Keep: false)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        ViewMemory.shared.AppLoading = false
                                    }
                                }
                            }
                            Button(MILocalizedString("Restore All")) {
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                ViewMemory.shared.AppLoading = true
                                DispatchQueue.global().async { // バックグラウンドスレッドで実行する
                                    RestoreAll()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        ViewMemory.shared.AppLoading = false
                                    }
                                }
                            }
                            Button(MILocalizedString("Clear UIKeyboardCache")) {
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                _UIKeyboardCache.purge()
                                UIApplication.shared.alert(title: MILocalizedString("Succeed"), body: MILocalizedString("All Caches are deleted"), count: 0)
                            }
                            Button(MILocalizedString("Clear IconCache")) {
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                RemoveIconCache(alert: true)
                            }
                            Button(MILocalizedString("Clear AppCache")){
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                RemoveAppCache(alert: true)
                            }
                        }
                        .foregroundColor(.primary)
                        
                        Section(header: Label(MILocalizedString("Customization"), systemImage: "paintbrush")) {
                            NavigationLink(destination: FontCustomizationView()) {
                                Label(MILocalizedString("Font Customization"), systemImage: "textformat")
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    .listRowBackground((colorScheme == .dark ? Color.gray.opacity(0.1) : Color.gray.opacity(0.1)))
                }
                .navigationTitle("ToolBox")
            } 
        }
        .navigationViewStyle(.stack)
        .overlay(
            AppLoadingView()
        )
    }
}



struct AppLoadingView: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @ObservedObject var ViewMemorySingleton = ViewMemory.shared
    
    var body: some View {
        Group {
            if ViewMemorySingleton.AppLoading {
                VStack {
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ActivityIndicatorView(isVisible: $ViewMemorySingleton.AppLoading, type: .growingArc(.red, lineWidth: 4))
                                    .frame(width: 50.0, height: 50.0)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
                .background(Color.black.opacity(0.1))
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct FontCustomizationView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showRespringAlert = false
    
    var body: some View {
        List {
            Section(header: Text("Available Fonts"), footer: Text("Changes the system font (SFUI.ttf). A respring is required to apply the change.")) {
                ForEach(KRWKFSManager.availableFonts, id: \.name) { font in
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        applyFont(font)
                    }) {
                        HStack {
                            Text(font.name)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                }
            }
        }
        .navigationTitle(MILocalizedString("Font Customization"))
        .alert(isPresented: $showRespringAlert) {
            Alert(
                title: Text("Font Applied"),
                message: Text("The system font has been overwritten. Do you want to respring now to see the changes?"),
                primaryButton: .default(Text("Respring")) {
                    Memory.shared.RespringConfirm = true
                },
                secondaryButton: .cancel(Text("Later"))
            )
        }
    }
    
    private func applyFont(_ font: (name: String, file: String)) {
        let success = KRWKFSManager.shared.overwriteFile(target: KRWKFSManager.targetFontPath, withBundledFont: font.file)
        if success {
            showRespringAlert = true
        } else {
            UIApplication.shared.alert(title: "Error", body: "Failed to overwrite the system font. Make sure the exploit is active.", count: 0)
        }
    }
}
