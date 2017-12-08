<!-- URLs -->
[reactant-explorer]: https://github.com/MatyasKriz/reactant-explorer
[reactant-CLI]: https://github.com/Brightify/ReactantCLI
[fetcher]: https://github.com/Brightify/Fetcher
[what-are-dtos]: https://en.wikipedia.org/wiki/Data_transfer_object

<!-- relative paths -->
[table-view]: ../../parts/tableview.md
[troubleshooting]: ../../getting-started/troubleshooting.md

# ($NAME)
Welcome to our second introductory tutorial to the Reactant architecture.

In this tutorial we'll create an explorer that will find some random GitHub users (sorted by most followers). If you tap on any of them, their repositories are shown along with number of stars in each one.

The whole project can be found on GitHub [here][reactant-explorer].

##### Let's get started.

### Part 1: Setting Up a Project
Let's create our project using [**Reactant CLI**][reactant-CLI] with `reactant init`.

Click the **RUN** button (![-RUN BUTTON-](../RunButton.png)) to check that everything is running smooth. If it doesn't, consider visiting the [Troubleshooting Tips][troubleshooting] section.

After testing the project and seeing that everything works as expected, we need to use an HTTP networking library. Any such library will suffice, though we will be using Fetcher as our choice here. [Fetcher][fetcher] is light-weight and comes from Brightify as well.

It's pretty straightforward to add a new library to a project using Cocoapods. Open the `Podfile` in the root folder of your project and add these two lines under the default pods:
```ruby
pod 'Fetcher'
pod 'Fetcher/RxFetcher'
```

The whole file should look something like this:
```ruby
platform :ios, '9.0'
target 'Reactant Explorer' do
  use_frameworks!
  pod 'Reactant'
  pod 'ReactantUI'
  pod 'ReactantLiveUI', :configuration => 'Debug'
  pod 'Fetcher'
  pod 'Fetcher/RxFetcher'
end
```

### Part 2: Communicating with GitHub
GitHub has its own API that we are going to be using in order to communicate with it. The full API can be found [here](https://developer.github.com/v3/). But unless you want to study it thoroughly, you needn't follow the link as we will guide you through the usage.

As stated in the brief description of this project, we have to be able to:
- find random users, for that we will use `GET /users` with query `since=:random_number`;
- look at their repositories, where `GET /users/:username/repos` will help;
- open repositories in Safari, GitHub API is not needed for this, we just need a URL.

### Part 3: Preparing the Insides
#### Model
When working with network, creating [DTO][what-are-dtos]'s is considered best practice. Our DTO's `UserDTO` and `RepositoryDTO` will look like this:
```swift
// UserDTO.swift

import Foundation

struct UserDTO: Codable {
  let id: Int
  let avatarUrl: URL
  let login: String
  let repositoriesUrl: String
  let accountUrl: URL

  enum CodingKeys: String, CodingKey {
    case id
    case avatarUrl = "avatar_url"
    case login
    case repositoriesUrl = "repos_url"
    case accountUrl = "url"
  }
}
```
```swift
// RepositoryDTO.swift

import Foundation

struct RepositoryDTO: Codable {
  let id: Int
  let url: URL
  let name: String
  let stars: Int
  let license: String
  let language: String

  enum CodingKeys: String, CodingKey {
    case id
    case url
    case name
    case stars = "stargazers_count"
    case license
    case language
  }
}
```

**NOTE**: Creating a separate file for each model/component promotes better code navigation and readability.

We will need a `User` and `Repository` models. As we can only receive user's general info from the `GET /users` request, this `User.swift` is enough:
```swift
// User.swift

import Foundation
import UIKit

struct User {
  let avatar: UIImage?
  let login: String
  let accountUrl: URL
}
```

`GET /users/:username/repos` gives us much more info about each of the repositories, so our `Repository` model will be a bit more complex. It could look like this:
```swift
// Repository.swift

import Foundation

struct Repository {
  let name: String
  let stars: Int
  let language: String
  let url: URL
}
```

This marks our model complete. Let's get onto the `Components`.

#### Components
The application will behave this way – user starts it up and first batch of random GitHub users is shown in a `PlainTableView`. If he is interested in any of these, he can see his repositories in another `PlainTableView` by tapping on the user.

Assuming the user has some repositories, tapping on any of them opens it up in the default browser. This allows the user to further interact with the repository he is interested in.

We should have `MainController` readied up from `ReactantCLI` and so we just need to modify it to be able to bring the necessary information and react to the view's actions.

```swift
// MainController.swift

import Reactant

final class MainController: ControllerBase<Void, MainRootView> {
  struct Dependencies {
    let dataService: DataService
  }
  struct Reactions {
    let userSelected: (User) -> Void
  }

  private let dependencies: Dependencies
  private let reactions: Reactions

  init(dependencies: Dependencies, reactions: Reactions) {
    self.dependencies = dependencies
    self.reactions = reactions
    super.init(title: "RExplorer")
  }

  override func afterInit() {
    self.rootView.componentState = nil
    updateUsers()
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain) { [unowned self] in
      self.updateUsers()
    }
  }

  override func act(on action: PlainTableViewAction<UserCell>) {
    switch action {
    case .selected(let user):
      reactions.userSelected(user)
    case .refresh:
      self.updateUsers()
    case .rowAction(_, _):
      break
    }
  }

  private func updateUsers() {
    dependencies.dataService.users()
      .subscribe(onNext: { [unowned self] users in
        self.rootView.componentState = users
      })
      .disposed(by: lifetimeDisposeBag)
  }
}
```

The `Dependencies` struct is the crucial part of this controller and it's what we're going to be focusing on in this tutorial.

We've already seen `Services` in the first tutorial, but here we combine it with HTTP requests to get our data from the internet. Here you can see that if you had a local database, this `Controller` would not change one bit, it would still call `dataService` to get its data. `DataService` is only responsible to gather the data, it needs not state the source.

We'll take a look at the processes that happen inside the `DataService` right after defining `Components` and wiring them up to the `Wireframe`.

`MainRootView` will be of similar structure as in the first tutorial:
```swift
// MainRootView.swift

import Reactant
import RxSwift

final class MainRootView: ViewBase<[User]?, PlainTableViewAction<UserCell>> {
    let userTableView = PlainTableView<UserCell>(reloadable: true)

    override var actions: [Observable<PlainTableViewAction<UserCell>>] {
        return [userTableView.action]
    }

    override func update() {
        if let users = componentState {
            userTableView.componentState = users.isEmpty ? .empty(message: "No users found!") : .items(users)
        } else {
            userTableView.componentState = .loading
        }
    }

    override func loadView() {
        userTableView.footerView = UIView()
        userTableView.rowHeight = UserCell.height
        userTableView.separatorStyle = .singleLine
        userTableView.tableView.contentInset.bottom = 0
    }
}
```

Its `.ui.xml` side:
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Component
  xmlns="http://schema.reactant.tech/ui"
  xmlns:layout="http://schema.reactant.tech/layout"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://schema.reactant.tech/ui http://schema.reactant.tech/ui.xsd
                      http://schema.reactant.tech/layout http://schema.reactant.tech/layout.xsd"
  rootView="true">

  <View
    field="userTableView"
    layout:edges="super" />
</Component>
```

Then we'll create the cells to fill up the table, `UserCell`:
```swift
// UserCell.swift

import Reactant
import UIKit

final class UserCell: ViewBase<User, Void>, Reactant.TableViewCell {
  static let height: CGFloat = 80

  private let avatar = UIImageView()
  private let login = UILabel()

  override func update() {
    login.text = componentState.login
    avatar.image = componentState.avatar
  }

  func setHighlighted(_ highlighted: Bool, animated: Bool) {
    let style = { self.apply(style: highlighted ? Styles.highlightedBackground : Styles.normalBackground) }
    if animated {
      UIView.animate(withDuration: 0.7, animations: style)
    } else {
      style()
    }
  }
}

extension UserCell.Styles {
  static func normalBackground(_ cell: UserCell) {
    cell.backgroundColor = nil
  }

  static func highlightedBackground(_ cell: UserCell) {
    cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
  }
}
```

Here is the `ui.xml` of the cell defining its layout and styling:
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Component
  xmlns="http://schema.reactant.tech/ui"
  xmlns:layout="http://schema.reactant.tech/layout"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://schema.reactant.tech/ui https://schema.reactant.tech/ui.xsd
  http://schema.reactant.tech/layout https://schema.reactant.tech/layout.xsd">

  <Label
    field="login"
    font=":bold@20"
    numberOfLines="1"
    layout:after="avatar offset(16)"
    layout:top="super inset(26)" />

  <View
    backgroundColor="#e6e6e6"
    clipsToBounds="true"
    layer.cornerRadius="16"
    layout:center="avatar"
    layout:width="self.height"
    layout:fillVertically="super inset(8)" />

  <ImageView
    field="avatar"
    layout:leading="super inset(10)"
    clipsToBounds="true"
    layer.cornerRadius="15"
    layout:width="self.height"
    layout:fillVertically="super inset(10)" />
</Component>
```

For viewing developer's repositories we'll use another PlainTableView, but as the user might forget whose repositories he's viewing, a header showing a quick overview will be helpful.

We'll cover the header first, the `.swift` part should look like this:
```swift
// UserDetailsView.swift

import Reactant

final class UserDetailsView: ViewBase<UserAccount, Void> {
  let avatar = UIImageView()
  let login = UILabel()
  let totalStars = UILabel()
  let totalRepositories = UILabel()
  let favoriteLanguage = UILabel()

  override func update() {
    avatar.image = componentState.user.avatar
    login.text = componentState.user.login
    if let repositories = componentState.repositories {
      totalStars.text = "🌟 \(repositories.filter { $0.name != "None" }.reduce(0) { $0 + $1.stars })"
      totalRepositories.text = "📖 \(repositories.count)"
      favoriteLanguage.text = "❤️ \(repositories.map { $0.language }.mostFrequent ?? "None")"
    } else {
      totalStars.text = nil
      totalRepositories.text = nil
      favoriteLanguage.text = nil
    }
  }
}
```

Its `.ui.xml` counterpart like this:
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Component
  xmlns="http://schema.reactant.tech/ui"
  xmlns:layout="http://schema.reactant.tech/layout"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://schema.reactant.tech/ui https://schema.reactant.tech/ui.xsd
  http://schema.reactant.tech/layout https://schema.reactant.tech/layout.xsd">

  <View
    backgroundColor="#e6e6e6"
    clipsToBounds="true"
    layer.cornerRadius="26"
    layout:center="avatar"
    layout:size="104" />

  <ImageView
    field="avatar"
    layout:leading="super inset(16)"
    layout:fillVertically="super inset(16)"
    clipsToBounds="true"
    layer.cornerRadius="25"
    layout:size="100" />

  <Container
    layout:id="infoContainer"
    layout:after="avatar offset(12)"
    layout:trailing="super inset(12)"
    layout:top="avatar">

    <Label
      field="login"
      adjustsFontSizeToFitWidth="true"
      font=":bold@20"
      numberOfLines="1"
      layout:leading="super"
      layout:top="super" />

    <Label
      field="totalStars"
      layout:leading="super"
      layout:below="login offset(5)" />

    <Label
      field="totalRepositories"
      layout:leading="super"
      layout:below="totalStars offset(5)" />

    <Label
      field="favoriteLanguage"
      layout:leading="super"
      layout:below="totalRepositories offset(5)" />
  </Container>

  <View
    backgroundColor="#e6e6e6"
    layout:height="1"
    layout:fillHorizontally="super"
    layout:bottom="super" />
</Component>
```

The header will look like this:

![header image]()

We will integrate it as a header of the `Repositories` screen.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.
