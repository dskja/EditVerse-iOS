import Foundation
import Combine

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var user: UserProfile?
    @Published private(set) var token: String?
    @Published var isBootstrapping = true
    @Published var authError: String?

    private let tokenKey = "editverse.jwt"
    var isAuthenticated: Bool { token != nil }

    init() { Task { await bootstrap() } }

    func bootstrap() async {
        isBootstrapping = true
        defer { isBootstrapping = false }
        guard let saved = UserDefaults.standard.string(forKey: tokenKey), !saved.isEmpty else {
            clear(); return
        }
        token = saved
        await APIClient.shared.setToken(saved)
        do {
            let env: UserEnvelope = try await APIClient.shared.request("GET", path: "/api/auth/me", authorized: true)
            user = env.user
        } catch { clear() }
    }

    func register(email: String, username: String, displayName: String, password: String) async {
        authError = nil
        do {
            let env: AuthEnvelope = try await APIClient.shared.request(
                "POST", path: "/api/auth/register",
                body: ["email": email, "username": username, "displayName": displayName, "password": password]
            )
            persist(env)
        } catch { authError = error.localizedDescription }
    }

    func login(login: String, password: String) async {
        authError = nil
        do {
            let env: AuthEnvelope = try await APIClient.shared.request(
                "POST", path: "/api/auth/login",
                body: ["login": login, "password": password]
            )
            persist(env)
        } catch { authError = error.localizedDescription }
    }

    func logout() { clear() }

    private func persist(_ env: AuthEnvelope) {
        token = env.token
        user = env.user
        UserDefaults.standard.set(env.token, forKey: tokenKey)
        Task { await APIClient.shared.setToken(env.token) }
    }

    private func clear() {
        token = nil
        user = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
        Task { await APIClient.shared.setToken(nil) }
    }
}
