import Foundation

struct GitHubAPIClient {
  let personalAccessToken: String?

  func fetchUserNames(organization: String) async throws -> [String] {
    var userNames: [String] = []

    var loadMore = true
    var page = 1
    while loadMore {
      let request = makeMembersRequest(organization: organization, page: page, perPage: 100)

      guard let (data, _) = try? await URLSession.shared.data(for: request),
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let members = json as? [[String: Any]] else {
              throw ToolError.apiCall
            }

      userNames += members.compactMap { $0["login"] as? String }

      loadMore = members.count == 100
      page += 1
    }

    return userNames
  }

  func fetchUserKeys(userName: String) async throws -> [String] {
    var userKeys: [String] = []

    var loadMore = true
    var page = 1
    while loadMore {
      let request = makeKeysRequest(userName: userName, page: page, perPage: 100)

      guard let (data, _) = try? await URLSession.shared.data(for: request),
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let keys = json as? [[String: Any]] else {
              throw ToolError.apiCall
            }

      userKeys += keys.compactMap { $0["key"] as? String }

      loadMore = keys.count == 100
      page += 1
    }

    return userKeys
  }

  func makeMembersRequest(organization: String, page: Int, perPage: Int) -> URLRequest {
    var urlComponents = URLComponents(string: "https://api.github.com/orgs/\(organization)/members")!
    urlComponents.queryItems = [
      URLQueryItem(name: "per_page", value: String(perPage)),
      URLQueryItem(name: "page", value: String(page)),
    ]

    var urlRequest = URLRequest(url: urlComponents.url!)
    if let token = personalAccessToken {
      urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
    }

    return urlRequest
  }

  func makeKeysRequest(userName: String, page: Int, perPage: Int) -> URLRequest {
    var urlComponents = URLComponents(string: "https://api.github.com/users/\(userName)/keys")!
    urlComponents.queryItems = [
      URLQueryItem(name: "per_page", value: String(perPage)),
      URLQueryItem(name: "page", value: String(page)),
    ]

    var urlRequest = URLRequest(url: urlComponents.url!)
    if let token = personalAccessToken {
      urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
    }

    return urlRequest
  }
}
