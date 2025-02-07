import Combine
import SwiftUI
import PlaygroundSupport
import UIKit

struct Post: Codable, Identifiable {
    let id: Int
    let title: String
}

class ApiService: ObservableObject {
    @Published var posts = [Post]()
    var cancellable = Set<AnyCancellable>()
    
    func fetchPosts() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { $0.data }
            .decode(type: [Post].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { status in
                switch status {
                    
                case .finished:
                    print("Finished")
                    break
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] posts in
                self?.posts = posts
            }
            .store(in: &cancellable)
    }
}

struct PostListingView: View {
    @StateObject private var apiService = ApiService()
    
    var body: some View {
        List(apiService.posts) { post in
            Text(post.title)
        }
        .onAppear {
            apiService.fetchPosts()
        }
    }
    
}

PlaygroundPage.current.setLiveView(PostListingView())
