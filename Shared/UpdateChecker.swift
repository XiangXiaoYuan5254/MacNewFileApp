import Foundation

struct AppRelease {
    let version: String
    let pageURL: URL
}

/// 通过官网上的 latest.json 检查新版本，主 App 和 Finder 扩展共用
final class UpdateChecker {
    static let shared = UpdateChecker()

    // 官网上的版本信息，发布新版本时随官网一起更新
    private static let latestReleaseURL = URL(string: "https://helloxxy.com/works/newfileapp/downloads/latest.json")!
    private static let downloadPageURL = URL(string: "https://helloxxy.com/works/newfileapp/")!
    // 成功后一天再查；失败（比如刚唤醒还没联网）一小时后重试
    private static let checkInterval: TimeInterval = 24 * 60 * 60
    private static let retryInterval: TimeInterval = 60 * 60
    private static let nextCheckDateKey = "UpdateNextCheckDate"
    private static let latestVersionKey = "UpdateLatestVersion"
    private static let latestPageURLKey = "UpdateLatestPageURL"

    let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"

    private let defaults = UserDefaults.standard

    /// 上次检查到的新版本；已经是最新版时为 nil
    var availableUpdate: AppRelease? {
        guard let version = defaults.string(forKey: Self.latestVersionKey),
              let pageURL = defaults.string(forKey: Self.latestPageURLKey).flatMap(URL.init(string:)),
              Self.isVersion(version, newerThan: currentVersion) else {
            return nil
        }

        return AppRelease(version: version, pageURL: pageURL)
    }

    /// 到了检查时间才联网，适合频繁调用
    func checkIfNeeded() {
        if let nextCheckDate = defaults.object(forKey: Self.nextCheckDateKey) as? Date, nextCheckDate > Date() {
            return
        }

        check()
    }

    /// 立即检查，在主线程回调：有新版本时为该版本，已是最新版时为 nil
    func check(completion: ((Result<AppRelease?, Error>) -> Void)? = nil) {
        // 先占住下次检查时间，避免连续右键时重复请求
        defaults.set(Date().addingTimeInterval(Self.retryInterval), forKey: Self.nextCheckDateKey)

        let request = URLRequest(url: Self.latestReleaseURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)

        URLSession.shared.dataTask(with: request) { data, response, error in
            let result = Result { try Self.parseRelease(data: data, response: response, error: error) }

            DispatchQueue.main.async {
                if case .success(let release) = result {
                    self.defaults.set(Date().addingTimeInterval(Self.checkInterval), forKey: Self.nextCheckDateKey)
                    self.defaults.set(release.version, forKey: Self.latestVersionKey)
                    self.defaults.set(release.pageURL.absoluteString, forKey: Self.latestPageURLKey)
                }

                completion?(result.map { release in
                    Self.isVersion(release.version, newerThan: self.currentVersion) ? release : nil
                })
            }
        }.resume()
    }

    static func isVersion(_ version: String, newerThan other: String) -> Bool {
        version.compare(other, options: .numeric) == .orderedDescending
    }

    private struct LatestRelease: Decodable {
        let version: String
    }

    private static func parseRelease(data: Data?, response: URLResponse?, error: Error?) throws -> AppRelease {
        if let error {
            throw error
        }

        guard let data, (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let release = try JSONDecoder().decode(LatestRelease.self, from: data)
        return AppRelease(version: release.version, pageURL: downloadPageURL)
    }
}
