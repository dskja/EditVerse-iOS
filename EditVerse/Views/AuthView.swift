import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var mode = 0
    @State private var email = ""
    @State private var username = ""
    @State private var displayName = ""
    @State private var password = ""
    @State private var login = ""
    @State private var busy = false

    var body: some View {
        NavigationStack {
            ZStack {
                EVTheme.stageGradient.ignoresSafeArea()
                VStack(spacing: 22) {
                    Text("EDITVERSE")
                        .font(EVTheme.brandFont)
                        .tracking(6)
                        .foregroundStyle(EVTheme.tungsten)
                        .padding(.top, 12)
                    Text(mode == 0 ? "Return to the reel." : "Claim your editor mark.")
                        .font(EVTheme.bodyFont)
                        .foregroundStyle(EVTheme.fog)

                    Picker("", selection: $mode) {
                        Text("Login").tag(0)
                        Text("Register").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        if mode == 0 {
                            field("Email or username", text: $login)
                            secure("Password", text: $password)
                        } else {
                            field("Email", text: $email)
                            field("Username", text: $username)
                            field("Display name", text: $displayName)
                            secure("Password (8+)", text: $password)
                        }
                    }
                    .padding(.horizontal, 24)

                    if let authError = session.authError {
                        Text(authError).font(EVTheme.captionFont).foregroundStyle(EVTheme.ember)
                    }

                    Button(action: submit) {
                        Group {
                            if busy { ProgressView().tint(EVTheme.void) }
                            else {
                                Text(mode == 0 ? "Enter" : "Create account")
                                    .font(EVTheme.captionFont)
                                    .tracking(1.4)
                            }
                        }
                        .foregroundStyle(EVTheme.void)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(EVTheme.tungsten)
                    }
                    .disabled(busy)
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.foregroundStyle(EVTheme.steel)
                }
            }
            .toolbarBackground(EVTheme.void, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onChange(of: session.isAuthenticated) { _, ok in
            if ok { dismiss() }
        }
    }

    private func field(_ title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(12)
            .background(EVTheme.stage)
            .foregroundStyle(EVTheme.ivory)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func secure(_ title: String, text: Binding<String>) -> some View {
        SecureField(title, text: text)
            .padding(12)
            .background(EVTheme.stage)
            .foregroundStyle(EVTheme.ivory)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func submit() {
        busy = true
        Task {
            if mode == 0 {
                await session.login(login: login, password: password)
            } else {
                await session.register(
                    email: email,
                    username: username,
                    displayName: displayName.isEmpty ? username : displayName,
                    password: password
                )
            }
            busy = false
        }
    }
}
