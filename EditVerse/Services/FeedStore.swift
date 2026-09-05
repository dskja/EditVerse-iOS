import Foundation
import Combine

@MainActor
final class FeedStore: ObservableObject {
    @Published var posts: [EditPost] = []
    @Published var selectedCategory: String?
    @Published var categories: [String] = EditCategory.allCases.map(\.rawValue)
    @Published var activeTab = 0
    @Published var isMuted = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var nextCursor: String?

    var isFeedVisible: Bool { activeTab == 0 }

    func bootstrap() async {
        await loadCategories()
        await refreshFeed()
    }

    func loadCategories() async {
        do {
            let env: CategoriesEnvelope = try await APIClient.shared.request("GET", path: "/api/feed/categories")
            if !env.categories.isEmpty { categories = env.categories }
        } catch {}
    }

    func refreshFeed() async {
        isRefreshing = true
        errorMessage = nil
        defer { isRefreshing = false }
        do {
            let env: ItemsEnvelope<EditPost> = try await APIClient.shared.request(
                "GET", path: "/api/feed",
                query: ["category": selectedCategory, "limit": "30"]
            )
            posts = env.items
            nextCursor = env.nextCursor
        } catch {
            errorMessage = error.localizedDescription
            posts = []
        }
    }

    func selectCategory(_ category: String?) async {
        selectedCategory = category
        await refreshFeed()
    }

    func search(_ query: String) async -> [EditPost] {
        do {
            let env: ItemsEnvelope<EditPost> = try await APIClient.shared.request(
                "GET", path: "/api/feed",
                query: ["q": query, "limit": "40"]
            )
            return env.items
        } catch { return [] }
    }

    func toggleLike(_ id: String) async {
        guard let i = posts.firstIndex(where: { $0.id == id }) else { return }
        let was = posts[i].isLiked
        posts[i].isLiked.toggle()
        posts[i].likes = max(0, posts[i].likes + (posts[i].isLiked ? 1 : -1))
        do {
            let env: LikeEnvelope = try await APIClient.shared.request(
                was ? "DELETE" : "POST", path: "/api/feed/\(id)/like", authorized: true
            )
            posts[i].isLiked = env.liked
            posts[i].likes = env.likes
        } catch {
            posts[i].isLiked = was
            posts[i].likes = max(0, posts[i].likes + (was ? 1 : -1))
        }
    }

    func toggleSave(_ id: String) async {
        guard let i = posts.firstIndex(where: { $0.id == id }) else { return }
        let was = posts[i].isSaved
        posts[i].isSaved.toggle()
        do {
            let env: SaveEnvelope = try await APIClient.shared.request(
                was ? "DELETE" : "POST", path: "/api/feed/\(id)/save", authorized: true
            )
            posts[i].isSaved = env.saved
        } catch { posts[i].isSaved = was }
    }

    func toggleFollow(username: String, editId: String) async {
        guard let i = posts.firstIndex(where: { $0.id == editId }) else { return }
        let was = posts[i].isFollowingAuthor
        posts[i].isFollowingAuthor.toggle()
        do {
            let _: FollowEnvelope = try await APIClient.shared.request(
                was ? "DELETE" : "POST", path: "/api/users/\(username)/follow", authorized: true
            )
        } catch { posts[i].isFollowingAuthor = was }
    }

    func shareBump(_ id: String) async {
        guard let i = posts.firstIndex(where: { $0.id == id }) else { return }
        do {
            let env: ShareEnvelope = try await APIClient.shared.request("POST", path: "/api/feed/\(id)/share")
            posts[i].shares = env.shares
        } catch { posts[i].shares += 1 }
    }

    func prepend(_ post: EditPost) { posts.insert(post, at: 0) }
}
