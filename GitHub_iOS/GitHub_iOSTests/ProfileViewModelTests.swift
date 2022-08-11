//
//  GitHub_iOSTests.swift
//  GitHub_iOSTests
//
//  Created by 전소영 on 2022/08/05.
//

import XCTest
@testable import GitHub_iOS

class ProfileViewModelTests: XCTestCase {
    let data = """
    [
       {
          "keys_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/keys{/key_id}",
          "statuses_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/statuses/{sha}",
          "issues_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/issues{/number}",
          "license":{
             "node_id":"MDc6TGljZW5zZTEz",
             "key":"mit",
             "spdx_id":"MIT",
             "name":"MIT License",
             "url":"https://api.github.com/licenses/mit"
          },
          "issue_events_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/issues/events{/number}",
          "has_projects":true,
          "id":20682114,
          "allow_forking":true,
          "owner":{
             "id":573856,
             "organizations_url":"https://api.github.com/users/JakeLin/orgs",
             "received_events_url":"https://api.github.com/users/JakeLin/received_events",
             "following_url":"https://api.github.com/users/JakeLin/following{/other_user}",
             "login":"JakeLin",
             "avatar_url":"https://avatars.githubusercontent.com/u/573856?v=4",
             "url":"https://api.github.com/users/JakeLin",
             "node_id":"MDQ6VXNlcjU3Mzg1Ng==",
             "subscriptions_url":"https://api.github.com/users/JakeLin/subscriptions",
             "repos_url":"https://api.github.com/users/JakeLin/repos",
             "type":"User",
             "html_url":"https://github.com/JakeLin",
             "events_url":"https://api.github.com/users/JakeLin/events{/privacy}",
             "site_admin":false,
             "starred_url":"https://api.github.com/users/JakeLin/starred{/owner}{/repo}",
             "gists_url":"https://api.github.com/users/JakeLin/gists{/gist_id}",
             "gravatar_id":"",
             "followers_url":"https://api.github.com/users/JakeLin/followers"
          },
          "visibility":"public",
          "default_branch":"master",
          "events_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/events",
          "subscription_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/subscription",
          "watchers":5197,
          "git_commits_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/git/commits{/sha}",
          "subscribers_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/subscribers",
          "clone_url":"https://github.com/JakeLin/SwiftLanguageWeather.git",
          "has_wiki":true,
          "url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather",
          "pulls_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/pulls{/number}",
          "fork":false,
          "notifications_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/notifications{?since,all,participating}",
          "description":"Swift Language Weather is an iOS weather app developed in Swift 4. ",
          "collaborators_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/collaborators{/collaborator}",
          "deployments_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/deployments",
          "archived":false,
          "topics":[
             "design",
             "interface-builder",
             "ios-weather",
             "swift-language",
             "swift-weather",
             "swift4"
          ],
          "languages_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/languages",
          "has_issues":true,
          "comments_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/comments{/number}",
          "is_template":false,
          "private":false,
          "size":40699,
          "git_tags_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/git/tags{/sha}",
          "updated_at":"2022-08-11T14:01:47Z",
          "ssh_url":"git@github.com:JakeLin/SwiftLanguageWeather.git",
          "name":"SwiftLanguageWeather",
          "web_commit_signoff_required":false,
          "contents_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/contents/{+path}",
          "archive_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/{archive_format}{/ref}",
          "milestones_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/milestones{/number}",
          "blobs_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/git/blobs{/sha}",
          "node_id":"MDEwOlJlcG9zaXRvcnkyMDY4MjExNA==",
          "contributors_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/contributors",
          "open_issues_count":9,
          "permissions":{
             "push":false,
             "admin":false,
             "maintain":false,
             "triage":false,
             "pull":true
          },
          "forks_count":1220,
          "trees_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/git/trees{/sha}",
          "svn_url":"https://github.com/JakeLin/SwiftLanguageWeather",
          "commits_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/commits{/sha}",
          "created_at":"2014-06-10T10:58:37Z",
          "forks_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/forks",
          "has_downloads":true,
          "mirror_url":null,
          "homepage":"",
          "teams_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/teams",
          "branches_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/branches{/branch}",
          "disabled":false,
          "issue_comment_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/issues/comments{/number}",
          "merges_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/merges",
          "git_refs_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/git/refs{/sha}",
          "git_url":"git://github.com/JakeLin/SwiftLanguageWeather.git",
          "forks":1220,
          "open_issues":9,
          "hooks_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/hooks",
          "html_url":"https://github.com/JakeLin/SwiftLanguageWeather",
          "stargazers_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/stargazers",
          "assignees_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/assignees{/user}",
          "compare_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/compare/{base}...{head}",
          "full_name":"JakeLin/SwiftLanguageWeather",
          "tags_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/tags",
          "releases_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/releases{/id}",
          "pushed_at":"2022-06-15T11:39:59Z",
          "labels_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/labels{/name}",
          "downloads_url":"https://api.github.com/repos/JakeLin/SwiftLanguageWeather/downloads",
          "stargazers_count":5197,
          "watchers_count":5197,
          "language":"Swift",
          "has_pages":false
       }
    ]
    """.data(using: .utf8)
    
    let profileViewModel: ProfileViewModel = ProfileViewModel()
    var userRepository: [UserRepository] = []
    
    override func setUpWithError() throws {
        do {
            userRepository = try JSONDecoder().decode([UserRepository].self, from: data!)
        } catch {
            throw error
        }
    }
    
    func test_givenBasicViewModel_WhenPagingProcess_ThenSuccess() throws {
        profileViewModel.process(userRepositories: userRepository)
        
        XCTAssertTrue(profileViewModel.currentPage == 2)
        XCTAssertTrue(profileViewModel.section.count == 1)
        XCTAssertFalse(profileViewModel.isRequestCompleted == true)
        
        profileViewModel.process(userRepositories: [])
        XCTAssertTrue(profileViewModel.isRequestCompleted == true)
    }
}
