<!-- URLs -->
[project-url]: https://github.com/MatyasKriz/git-explorer
[reactant-CLI]: https://github.com/Brightify/ReactantCLI
[fetcher]: https://github.com/Brightify/Fetcher
[what-are-dtos]: https://en.wikipedia.org/wiki/Data_transfer_object

<!-- relative paths -->
[table-view]: ../../parts/tableview.md
[troubleshooting]: ../../getting-started/troubleshooting.md

# Tutorial: Random GitHub users explorer
Welcome to our second introductory tutorial to the Reactant architecture.

In this tutorial we'll create an explorer that will find some random GitHub users. If you tap on any of them, their repositories (sorted by most stars) are shown along with number of stars in each one.

The whole project can be found on GitHub [here][project-url].

##### Let's get started.

### Setting Up the Project
Let's create our project using [**Reactant CLI**][reactant-CLI] with `reactant init`.

Click the **RUN** button (![Run Button](../img/Tutorials/RunButton.png)) to check that everything is running smooth. If it doesn't, consider visiting the [Troubleshooting Tips][troubleshooting] section.

After testing the project and seeing that everything works as expected, we need to use an HTTP networking library. Any such library will suffice, though we will be using Fetcher as our choice here. [Fetcher][fetcher] is light-weight and is brought to you by Brightify.

It's pretty straightforward to add a new library to a project using Cocoapods. Open the `Podfile` in the root folder of your project and add these two lines under the default pods:
```ruby
pod 'Fetcher'
pod 'Fetcher/RxFetcher'
```

After this, run this in the terminal:
```
pod install
```

### Communicating with GitHub
GitHub has its own API that we are going to be using in order to communicate with it. The full API can be found [here](https://developer.github.com/v3/). But unless you want to study it thoroughly, you needn't follow the link as we will guide you through the usage.

As stated in the brief description of this project, we have to be able to:
- find random users, for that we will use `GET /users` with query `since=:random_number`;
- look at their repositories, where `GET /users/:username/repos` will help;
- open repositories in Safari, GitHub API is not needed for this, we just need a URL.

We'll also prepare the constants we'll be using for communication with GitHub. These are placed in the `Utils` folder.
```swift
// Constants.swift

import Fetcher

public struct Constants {
  public static let apiUrl = BaseUrl(baseUrl: "https://api.github.com/")
  public static let usersPerPage = 15
  public static let randomNumberLimit = 34340000 as UInt32
}
```

`apiUrl` is a request modifier. Using these modifiers we can easily modify `Fetcher`'s requests and rest assured that `Fetcher` will use them according to their purpose. `BaseUrl` modifier in this case tells `Fetcher` to start every request with the passed URL.

`randomNumberLimit` was tested by trial and error and as of now there are not many more users than that.

### Preparing the Insides
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
  let language: String

  enum CodingKeys: String, CodingKey {
    case id
    case url
    case name
    case stars = "stargazers_count"
    case language
  }
}
```

**NOTE**: Creating a separate file for each model/component promotes better code navigation and readability.

We will also need `User` and `Repository` models. As we can only receive user's general info from the `GET /users` request, this `User.swift` is enough:
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

`GET /users/:username/repos` gives us much more info about each of the repositories, so our `Repository` model will be a bit more complex.
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
    super.init(title: "GitXplorer")
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
<!-- MainRootView.ui.xml -->

<?xml version="1.0" encoding="UTF-8" ?>
<Component
  xmlns="http://schema.reactant.tech/ui"
  xmlns:layout="http://schema.reactant.tech/layout"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://schema.reactant.tech/ui https://schema.reactant.tech/ui.xsd
  http://schema.reactant.tech/layout https://schema.reactant.tech/layout.xsd"
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

With the `ui.xml` of the cell defining its layout and styling:
```xml
<!-- UserCell.ui.xml -->

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

We need to connect this to the `MainWireframe` and pass it the `Dependencies` and `Reactions`.

```swift
// MainWireframe.swift inside MainWireframe class

private func main() -> MainController {
  return create { provider in
    let dependencies = MainController.Dependencies(dataService: module.dataService)
    let reactions = MainController.Reactions(
      userSelected: { user in
        provider.navigation?.push(controller: self.repositories(user: user))
      })

    return MainController(dependencies: dependencies, reactions: reactions)
  }
}
```

Now that the components are complete, you have seen `DataService` in the MainController's `Dependencies`. This service will bring us the models we declared by converting DTO's to models that we'll work with in our application.

```swift
// DataService.swift

import Fetcher
import class RxSwift.Observable

private struct Endpoints: EndpointProvider {
  static func users(position: Int, perPage: Int) -> GET<Void, Data> {
    return create("users?since=\(position)&per_page=\(perPage)", modifiers: Constants.apiUrl)
  }

  static func avatar(url: URL) -> GET<Void, Data> {
    return create(url.absoluteString)
  }
}
```

Endpoints are used by **Fetcher** to make requests to the desired URL. Request type is determined by the return value of each function where the first generic parameter is the data sent to the server and the second generic parameter is the type you want to receive. We only want to receive `Data` here, because we will do the deserializing ourselves.

To see all of Fetcher's qualities, head over to [its GitHub page][fetcher].

Add the service itself under the endpoints.

```swift
// DataService.swift under Endpoints struct

final class DataService {
  private let fetcher: Fetcher
  private let decoder: JSONDecoder

  init(fetcher: Fetcher, decoder: JSONDecoder) {
    self.fetcher = fetcher
    self.decoder = decoder
  }

  func users(perPage: Int = Constants.usersPerPage) -> Observable<[User]> {
    let randomPosition = Int(arc4random_uniform(Constants.randomNumberLimit))
    return fetcher.rx.request(Endpoints.users(position: randomPosition, perPage: perPage))
      .map { [decoder] response -> [UserDTO] in
        guard let data = response.rawData else { return [] }
        return (try? decoder.decode([UserDTO].self, from: data)) ?? []
      }
      .flatMapLatest { [unowned self] userDTOs -> Observable<[User]> in
        return Observable.from(
          userDTOs.map { userDTO in
            return self.avatar(url: userDTO.avatarUrl).map { User(avatar: $0, login: userDTO.login, accountUrl: userDTO.accountUrl) }
          }).merge().toArray()
      }
  }

  private func avatar(url: URL) -> Observable<UIImage?> {
    return fetcher.rx.request(Endpoints.avatar(url: url))
      .map { response in
        guard let data = response.rawData else { return nil }
        return UIImage(data: data)
      }
  }
}
```

Some parts may be a little hard to understand at first. Let's step through the `users(perPage:)` method. After generating a random number we make the request by calling `fetcher.rx.request(endpoint:)`, this returns `Observable<Data>` which means we need to deserialize the `Data` using `JSONDecoder`. If the deserializing fails, we want to return only an empty array. After this we make a request for the avatar image for every user in the array through the `avatar(url:)` method which gives us back the `Observable<UIImage?>` which we're using to construct a `User` model. As this is done for every user in the array, `merge()` makes all the request at once (for smaller servers you might use `concat()` which makes requests one by one) and `toArray()` makes sure that we will return an array of users.

Having said that, this notation using `Observables` is very well suited for callbacks and HTTP requests are a good example of that. Everything is handled in this service and the controller that subscribes to get a specific model doesn't need to do any more work.

Having created the service that brings us the much needed data. We can move on to the `DependencyModule` protocol and `ApplicationModule` conforming to it.

```swift
// DependencyModule.swift

protocol DependencyModule {
  var dataService: DataService { get }
}
```

```swift
// ApplicationModule.swift

import Fetcher

final class ApplicationModule: DependencyModule {
  let fetcher: Fetcher
  let dataService: DataService

  init() {
    fetcher = Fetcher(requestPerformer: AlamofireRequestPerformer())
    dataService = DataService(fetcher: fetcher)
  }
}
```

The `AlamofireRequestPerformer` is already in `Fetcher` and doesn't need to be included.

After doing all this, the result should be of similar image, of course the users are random, so the chance that you'll see the exact same developers is really slim.

![Users](../img/Tutorials/GitExplorer/Users.png)

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
      if let language = repositories.map({ $0.language }).filter({ $0 != "None" }).mostFrequentElement {
        favoriteLanguage.text = "❤️ \(language)"
      } else {
        favoriteLanguage.text = nil
      }
    } else {
      totalStars.text = nil
      totalRepositories.text = nil
      favoriteLanguage.text = nil
    }
  }
}
```

`UserAccount` is not defined yet, but we will define it in `RepositoryRootView.swift` later.

Its `.ui.xml` counterpart like this:
```xml
<!-- UserDetailsView.ui.xml -->

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

The variable `mostFrequentElement` is not in Swift by default, so we'll define it in the `Utils` folder.
```swift
// Array+mostFrequentElement.swift

import Foundation

extension Array {
  var mostFrequentElement: Element? {
    let countedSet = NSCountedSet(array: self)
    guard let mostFrequent = (countedSet.max { countedSet.count(for: $0) < countedSet.count(for: $1) } as? Element) else { return nil }
    return mostFrequent
  }
}
```

The header will look like this:

![UserHeader](../img/Tutorials/GitExplorer/UserHeader.png)

We will integrate it as a header of the `Repositories` screen.

For that `RepositoryCell` component needs to be created.

```swift
// RepositoryCell.swift

import Reactant
import UIKit

final class RepositoryCell: ViewBase<Repository, Void>, Reactant.TableViewCell {
  static let height: CGFloat = 60

  let name = UILabel()
  let starCount = UILabel()
  let language = UILabel()

  override func update() {
    name.text = componentState.name
    starCount.text = "🌟 \(componentState.stars)"
    if let repositoryLanguage = componentState.language {
      language.visibility = .visible
      language.text = "Language: \(repositoryLanguage)"
    } else {
      language.visibility = .collapsed
      language.text = nil
    }
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

extension RepositoryCell.Styles {
  static func normalBackground(_ cell: RepositoryCell) {
    cell.backgroundColor = nil
  }

  static func highlightedBackground(_ cell: RepositoryCell) {
    cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
  }
}
```

Here you can see we used `Reactant`'s `UIView.visibility` in action. Its values are `.visible`, `.collapsed`, and `.hidden`. The difference between `.hidden` and `.collapsed` is that `.hidden` preserves the view's dimensions whereas `.collapsed` uses `UIView.collapseAxis` to determine on which axis (it can even be both) to collapse the view so that the dimension on the chosen axis is equal to zero.

We are using it here because if a particular repository has no language, we don't want to show the language label at all, but as we want the text centered, we need to *collapse* the language label.

This is how it's represented using `ReactantUI`:
```xml
<!-- RepositoryCell.ui.xml -->

<?xml version="1.0" encoding="UTF-8" ?>
<Component
  xmlns="http://schema.reactant.tech/ui"
  xmlns:layout="http://schema.reactant.tech/layout"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://schema.reactant.tech/ui https://schema.reactant.tech/ui.xsd
  http://schema.reactant.tech/layout https://schema.reactant.tech/layout.xsd">

  <Container
    layout:id="text"
    layout:leading="super inset(8)"
    layout:top="super inset(8)"
    layout:bottom="super inset(8)"
    layout:centerY="super" >

    <Label
      field="name"
      font=":bold@20"
      numberOfLines="1"
      layout:leading="super"
      layout:trailing="super"
      layout:top="super" />

    <Label
      field="language"
      font="14"
      numberOfLines="1"
      layout:leading="super"
      layout:trailing="super"
      layout:below="name offset(8)"
      layout:bottom="super" />
  </Container>

  <Label
    field="starCount"
    font="14"
    numberOfLines="1"
    layout:after=":gt id:text offset(10)"
    layout:trailing="super inset(10)"
    layout:centerY="super" />
</Component>
```

Putting this all together in `RepositoryRootView.swift` will look like this:
```swift
// RepositoryRootView.swift

import Reactant
import RxSwift

typealias UserAccount = (user: User, repositories: [Repository]?)

final class RepositoriesRootView: ViewBase<UserAccount, PlainTableViewAction<RepositoryCell>> {
  let repositoryTableView = PlainTableView<RepositoryCell>(reloadable: false)
  let activityIndicator = UIActivityIndicatorView()
  private let userDetails = UserDetailsView()

  override var actions: [Observable<PlainTableViewAction<RepositoryCell>>] {
    return [
      repositoryTableView.action
    ]
  }

  override func update() {
    if let repositories = componentState.repositories {
      activityIndicator.stopAnimating()
      repositoryTableView.componentState = repositories.isEmpty ? .empty(message: "No repositories found.") : .items(repositories)
    } else {
      activityIndicator.startAnimating()
      repositoryTableView.componentState = .loading
    }
    userDetails.componentState = componentState
  }

  override func loadView() {
    activityIndicator.activityIndicatorViewStyle = .gray

    repositoryTableView.headerView = userDetails
    repositoryTableView.footerView = UIView()
    repositoryTableView.rowHeight = RepositoryCell.height
    repositoryTableView.separatorStyle = .singleLine
    repositoryTableView.tableView.contentInset.bottom = 0
  }
}
```

The `ui.xml` side looks like this:
```xml
<!-- RepositoryRootView.ui.xml -->

<?xml version="1.0" encoding="UTF-8" ?>
<Component
  xmlns="http://schema.reactant.tech/ui"
  xmlns:layout="http://schema.reactant.tech/layout"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://schema.reactant.tech/ui http://schema.reactant.tech/ui.xsd
  http://schema.reactant.tech/layout http://schema.reactant.tech/layout.xsd"
  rootView="true">

  <View
    field="repositoryTableView"
    layout:edges="super" />

  <View
    field="activityIndicator"
    layout:center="super" />
</Component>
```

The controller that controls it looks like this:
```swift
// RepositoryController.swift

import Reactant

final class RepositoriesController: ControllerBase<Void, RepositoriesRootView> {
  struct Dependencies {
    let dataService: DataService
  }
  struct Properties {
    let user: User
  }
  struct Reactions {
    let repositorySelected: (URL) -> Void
  }

  private let dependencies: Dependencies
  private let properties: Properties
  private let reactions: Reactions

  init(dependencies: Dependencies, properties: Properties, reactions: Reactions) {
    self.dependencies = dependencies
    self.properties = properties
    self.reactions = reactions
    super.init(title: "Repositories")
  }

  override func afterInit() {
    self.rootView.componentState = (self.properties.user, nil)
    dependencies.dataService.repositories(login: properties.user.login)
      .subscribe(onNext: { [unowned self] repositories in
        self.rootView.componentState = (self.properties.user, repositories.sorted(by: { $0.stars > $1.stars }))
      })
      .disposed(by: lifetimeDisposeBag)
  }

  override func act(on action: PlainTableViewAction<RepositoryCell>) {
    switch action {
    case .selected(let repository):
      reactions.repositorySelected(repository.url)
    case .refresh, .rowAction(_, _):
      break
    }
  }
}
```

We also need to add a new endpoint and a method to the `DataService.swift` file.

```swift
// DataService inside Endpoints struct

static func repositories(userLogin: String) -> GET<Void, Data> {
  return create("users/\(userLogin)/repos", modifiers: Constants.apiUrl)
}
```

```swift
// DataService inside DataService class

func repositories(login: String) -> Observable<[Repository]> {
  return fetcher.rx.request(Endpoints.repositories(userLogin: login))
    .map { [decoder] response in
      guard let data = response.rawData else { return [] }
      return ((try? decoder.decode([RepositoryDTO].self, from: data)) ?? [])
        .map { repositoryDTO in
          return Repository(name: repositoryDTO.name, stars: repositoryDTO.stars, language: repositoryDTO.language, url: repositoryDTO.url)
        }
    }
}
```

When debugging HTTP requests/responses with **Fetcher**, it's very easy to have it print out everything that is happening by registering a logger request enhancer.
```swift
fetcher.register(requestEnhancers: RequestLogger(defaultOptions: .all))
```

Now the only thing left to do is to connect the new controller into the `Wireframe` and add a navigation controller so that the user can easily return back from viewing repositories.

```swift
// MainWireframe.swift inside MainWireframe class

private func repositories(user: User) -> RepositoriesController {
  return create { provider in
    let dependencies = RepositoriesController.Dependencies(dataService: module.dataService)
    let properties = RepositoriesController.Properties(user: user)
    let reactions = RepositoriesController.Reactions(
      repositorySelected: { url in
        if #available(iOS 10.0, *) {
          UIApplication.shared.open(url)
        } else {
          UIApplication.shared.openURL(url)
        }
      })

    return RepositoriesController(dependencies: dependencies, properties: properties, reactions: reactions)
  }
}
```

`provider` is used in reactions when you need to either interact with the navigation controller or when you need a reference to the controller that will be initialized at the end of `create(factory:)` method.

We also need to add a navigation controller to let the user easily return back to the main screen. This is done in the `entrypoint()` method of `MainWireframe`.

```swift
// MainWireframe.swift inside MainWireframe class

func entrypoint() -> UIViewController {
  let mainController = main()
  return UINavigationController(rootViewController: mainController)
}
```

User's repository screen now looks like this:

<br>

![UserHeader](../img/Tutorials/GitExplorer/Repositories.png)

## Wrap Up
That concludes the functionality we set out to implement! To hone your Reactant skills further, try implementing the proposed `UPGRADES` below. As always you can find the whole project [here][project-url].

**UPGRADE**: Right now we are ignoring request failures, but adding a feature that opens the user's profile when a repository list request fails is a good alternative to showing `No Repositories Found!` after the request limit is reached.

**UPGRADE**: Try adding a `Search` button to the Navigation Bar that lets you search for users. GitHub's search API doesn't count towards the requests we are making now, so it's really going to improve our application.

**UPGRADE**: You might have noticed during testing our explorer application that after a while you get `No users found!` even though you have perfectly fine internet connection. This is because you have reached GitHub's request limit. If you're interested in expanding it, consider adding a `Log In` possibility to the application.
