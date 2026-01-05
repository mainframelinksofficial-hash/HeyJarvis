//
//  ConversationHistoryView.swift
//  HeyJarvisApp
//
//  View all past JARVIS conversations with search
//

import SwiftUI

struct ConversationHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: AppViewModel
    @State private var searchText = ""
    @State private var showExportSheet = false
    
    var filteredCommands: [Command] {
        if searchText.isEmpty {
            return viewModel.commandHistory
        }
        return viewModel.commandHistory.filter { 
            $0.text.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("primaryDark").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("dimText"))
                        
                        TextField("Search conversations...", text: $searchText)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color("dimText"))
                            }
                        }
                    }
                    .padding()
                    .background(Color("accentDark"))
                    .cornerRadius(12)
                    .padding()
                    
                    if filteredCommands.isEmpty {
                        emptyState
                    } else {
                        // Stats Bar
                        HStack {
                            Label("\(filteredCommands.count) conversations", systemImage: "text.bubble")
                            Spacer()
                            let successCount = filteredCommands.filter { $0.status == .success }.count
                            Text("\(successCount) successful")
                                .foregroundColor(Color("successGreen"))
                        }
                        .font(.system(size: 12))
                        .foregroundColor(Color("dimText"))
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        
                        // Conversation List
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredCommands) { command in
                                    ConversationCard(command: command)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showExportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color("jarvisBlue"))
                    }
                    .disabled(viewModel.commandHistory.isEmpty)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("jarvisBlue"))
                }
            }
            .toolbarBackground(Color("primaryDark"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showExportSheet) {
            ExportView(commands: viewModel.commandHistory)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(Color("dimText").opacity(0.5))
            
            Text(searchText.isEmpty ? "No conversations yet" : "No results found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text(searchText.isEmpty ? "Say \"Hey Jarvis\" to start talking" : "Try a different search term")
                .font(.system(size: 14))
                .foregroundColor(Color("dimText"))
            
            Spacer()
        }
    }
}

// MARK: - Conversation Card
struct ConversationCard: View {
    let command: Command
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: command.type.icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color("jarvisBlue"))
                
                Text(command.type.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("jarvisBlue"))
                
                Spacer()
                
                Text(command.formattedTime)
                    .font(.system(size: 11))
                    .foregroundColor(Color("dimText"))
                
                Image(systemName: command.status == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(command.status == .success ? Color("successGreen") : .red)
            }
            
            // User Query
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color("dimText"))
                    .frame(width: 20)
                
                Text(command.text)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .lineLimit(isExpanded ? nil : 2)
            }
            
            // Expand Button
            if command.text.count > 80 {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Text(isExpanded ? "Show less" : "Show more")
                        .font(.system(size: 12))
                        .foregroundColor(Color("jarvisBlue"))
                }
            }
        }
        .padding()
        .background(Color("accentDark"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(command.status == .success ? Color("successGreen").opacity(0.2) : Color.red.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Export View
struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    let commands: [Command]
    @State private var copied = false
    
    var exportText: String {
        var text = "JARVIS Conversation History\n"
        text += "Exported: \(Date().formatted())\n"
        text += "Total: \(commands.count) conversations\n"
        text += String(repeating: "=", count: 40) + "\n\n"
        
        for command in commands {
            text += "[\(command.formattedTime)] \(command.type.displayName)\n"
            text += "User: \(command.text)\n"
            text += "Status: \(command.status == .success ? "Success" : "Failed")\n\n"
        }
        
        return text
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("primaryDark").ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Export \(commands.count) conversations")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView {
                        Text(exportText)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color("dimText"))
                            .padding()
                    }
                    .background(Color("accentDark"))
                    .cornerRadius(12)
                    
                    Button {
                        UIPasteboard.general.string = exportText
                        copied = true
                        SettingsManager.shared.triggerNotificationHaptic(.success)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copied = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            Text(copied ? "Copied!" : "Copy to Clipboard")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("jarvisBlue"))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("jarvisBlue"))
                }
            }
            .toolbarBackground(Color("primaryDark"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ConversationHistoryView()
        .environmentObject(AppViewModel())
}
