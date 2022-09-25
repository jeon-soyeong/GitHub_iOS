//
//  UserRepository.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/09.
//

import Foundation

// MARK: - UserRepository
struct UserRepository: Codable {
    let keysURL, statusesURL, issuesURL: String
    let license: License?
    let issueEventsURL: String
    let hasProjects: Bool
    let id: Int
    let allowForking: Bool
    let owner: Owner
    let visibility, defaultBranch: String
    let eventsURL, subscriptionURL: String
    let watchers: Int
    let gitCommitsURL: String
    let subscribersURL: String
    let cloneURL: String
    let hasWiki: Bool
    let url: String
    let pullsURL: String
    let fork: Bool
    let notificationsURL, collaboratorsURL: String
    let userRepositoryDescription: String?
    let deploymentsURL: String
    let archived: Bool
    let topics: [String]
    let languagesURL: String
    let hasIssues: Bool
    let commentsURL: String
    let isTemplate, userRepositoryPrivate: Bool
    let size: Int
    let gitTagsURL: String
    let updatedAt: String
    let sshURL, name: String
    let webCommitSignoffRequired: Bool
    let contentsURL, archiveURL, milestonesURL, blobsURL: String
    let nodeID: String
    let contributorsURL: String
    let openIssuesCount: Int
    let permissions: Permissions?
    let forksCount: Int
    let treesURL: String
    let svnURL: String
    let commitsURL: String
    let createdAt: String
    let forksURL: String
    let hasDownloads: Bool
    let homepage: String?
    let teamsURL: String
    let branchesURL: String
    let disabled: Bool
    let issueCommentURL: String
    let mergesURL: String
    let gitRefsURL, gitURL: String
    let forks, openIssues: Int
    let hooksURL, htmlURL, stargazersURL: String
    let assigneesURL, compareURL, fullName: String
    let tagsURL: String
    let releasesURL: String
    let pushedAt: String
    let labelsURL: String
    let downloadsURL: String
    let stargazersCount, watchersCount: Int
    let language: String?
    let hasPages: Bool

    enum CodingKeys: String, CodingKey {
        case keysURL = "keys_url"
        case statusesURL = "statuses_url"
        case issuesURL = "issues_url"
        case license
        case issueEventsURL = "issue_events_url"
        case hasProjects = "has_projects"
        case id
        case allowForking = "allow_forking"
        case owner, visibility
        case defaultBranch = "default_branch"
        case eventsURL = "events_url"
        case subscriptionURL = "subscription_url"
        case watchers
        case gitCommitsURL = "git_commits_url"
        case subscribersURL = "subscribers_url"
        case cloneURL = "clone_url"
        case hasWiki = "has_wiki"
        case url
        case pullsURL = "pulls_url"
        case fork
        case notificationsURL = "notifications_url"
        case userRepositoryDescription = "description"
        case collaboratorsURL = "collaborators_url"
        case deploymentsURL = "deployments_url"
        case archived, topics
        case languagesURL = "languages_url"
        case hasIssues = "has_issues"
        case commentsURL = "comments_url"
        case isTemplate = "is_template"
        case userRepositoryPrivate = "private"
        case size
        case gitTagsURL = "git_tags_url"
        case updatedAt = "updated_at"
        case sshURL = "ssh_url"
        case name
        case webCommitSignoffRequired = "web_commit_signoff_required"
        case contentsURL = "contents_url"
        case archiveURL = "archive_url"
        case milestonesURL = "milestones_url"
        case blobsURL = "blobs_url"
        case nodeID = "node_id"
        case contributorsURL = "contributors_url"
        case openIssuesCount = "open_issues_count"
        case permissions
        case forksCount = "forks_count"
        case treesURL = "trees_url"
        case svnURL = "svn_url"
        case commitsURL = "commits_url"
        case createdAt = "created_at"
        case forksURL = "forks_url"
        case hasDownloads = "has_downloads"
        case homepage
        case teamsURL = "teams_url"
        case branchesURL = "branches_url"
        case disabled
        case issueCommentURL = "issue_comment_url"
        case mergesURL = "merges_url"
        case gitRefsURL = "git_refs_url"
        case gitURL = "git_url"
        case forks
        case openIssues = "open_issues"
        case hooksURL = "hooks_url"
        case htmlURL = "html_url"
        case stargazersURL = "stargazers_url"
        case assigneesURL = "assignees_url"
        case compareURL = "compare_url"
        case fullName = "full_name"
        case tagsURL = "tags_url"
        case releasesURL = "releases_url"
        case pushedAt = "pushed_at"
        case labelsURL = "labels_url"
        case downloadsURL = "downloads_url"
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case language
        case hasPages = "has_pages"
    }
}

// MARK: - License
struct License: Codable {
    let nodeID, key, spdxID, name: String
    let url: String?

    enum CodingKeys: String, CodingKey {
        case nodeID = "node_id"
        case key
        case spdxID = "spdx_id"
        case name, url
    }
}

// MARK: - Owner
struct Owner: Codable {
    let id: Int
    let organizationsURL, receivedEventsURL: String
    let followingURL, login: String
    let avatarURL, url: String
    let nodeID: String
    let subscriptionsURL, reposURL: String
    let type: String
    let htmlURL: String
    let eventsURL: String
    let siteAdmin: Bool
    let starredURL, gistsURL, gravatarID: String
    let followersURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case organizationsURL = "organizations_url"
        case receivedEventsURL = "received_events_url"
        case followingURL = "following_url"
        case login
        case avatarURL = "avatar_url"
        case url
        case nodeID = "node_id"
        case subscriptionsURL = "subscriptions_url"
        case reposURL = "repos_url"
        case type
        case htmlURL = "html_url"
        case eventsURL = "events_url"
        case siteAdmin = "site_admin"
        case starredURL = "starred_url"
        case gistsURL = "gists_url"
        case gravatarID = "gravatar_id"
        case followersURL = "followers_url"
    }
}

// MARK: - Permissions
struct Permissions: Codable {
    let push, admin, maintain, triage: Bool
    let pull: Bool
}
