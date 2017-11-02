# ($NAME)
Welcome to our first tutorial! My name's Matt and I will help you get your feet wet with the Reactant architecture!

First and foremost, you will need:
- an **Xcode** (AppCode might work as well, but it's not tested),
- a **Terminal**,
- a [Cocoapods](http://cocoapods.org) dependency manager,
- an internet connection.

That's right, with just these few things you, too, can become fluent in Reactant! We won't touch the Terminal much, so if you're not used to hacking out command after command, it's okay, you can always come back and use this tutorial as a reference guide.

The whole project can be found on GitHub [here](https://github.com/MatyasKriz/reactant-notes).

In this particular tutorial we'll create a simple (but useful) application for keeping your precious ideas safe (until you wipe them, that is).

##### Let's get started.

### Part 1: Setting Up a Project
There are many ways to go about creating a new Reactant project. Creating it by hand can be quite overwhelming at first, so let's use [Reactant CLI](https://github.com/Brightify/ReactantCLI) to build it for us this time.

This is the first time we'll need to open up the Terminal.

After following instructions in **Reactant CLI** repo's README you'll be equipped with a very valuable tool for creating new Reactant projects.

How to create a project using **Reactant CLI**:
- select a favorable root folder (project folder will be created automatically in it)
- simply hack

```
reactant init
```

into the Terminal, we're gonna be using this configuration: ![-REACTANT INIT TERMINAL IMAGE-]()
- wait for Cocoapods to do its job bringing in the dependencies

Xcode workspace should open after this if everything went smooth.

Click the **RUN** button ![-RUN BUTTON-]() so that we see what we've got so far. We're doing this step mainly to check if nothing went wrong. You should get **Hello World!** text on white background.

Moving on to actually coding our app, there are two Xcode projects in the left sidebar. The first is our project (($NAME) in this case) and the second is `Pods`, our dependencies lie there, safe under a lock.

Open our new project folder by clicking the arrow to the left of ($NAME). We are going all the way through folders called `Application` > `Sources`. Our project won't be large, so open all the subfolders for better navigation later on.

You may notice that we have some things prepared in advance. We will certainly take advantage of them.

### Part 2: Preparing The Insides
#### Model
`Models` is the folder for our **Models** \*gasp\*. These include `struct`, `enum`, `protocol` or `class` types that we use everywhere else in our program.

($NAME) will probably make use of some complex model we will come up with. We'll create a new file `Note.swift` (by clicking right on the `Models` folder and choosing `New file...` and selecting `Swift file`, we'll only use these from now on) and a `struct` inside it named `Note`, simple and clean.

```swift
struct Note {
  let title: String
  let body: String
}
```

We have the `MODEL`, now onto the `CONTROLLER`.

#### Controller
Moving on to the **MainController** file. `ControllerBase` is what any controller will be subclassing. The first generic parameter (between the `<` and `>`) is for `componentState`, the second for this controller's `RootView`. Please make sure that for this controller the second generic parameter is **MainRootView**.

Passing information to `RootView` is done by setting `RootView`'s `componentState` (yes, every component has a `componentState`). This is usually done in `update()` method, as it's called every time `componentState` changes (and once at the beginning, even if it's `Void`).

We don't have any notes ready, so we need to create some from scratch and pass them to the `RootView`.

```swift
final class MainController: ControllerBase<Void, MainRootView> {
  override func afterInit() {
    let notes = [
      Note(title: "Groceries", body: "Milk, honey, 2 lemons, 3 melons, a cat"),
      Note(title: "TODO", body: "Workout, take Casey on a date, workout some more"),
      Note(title: "Dear Diary", body: "Today I found out that I'm gonna be promoted tomorrow! I'm so excited as I don't know what to expect from the new job position. Looking forward to it though.")
    ]
    rootView.componentState = .items(notes)
  }
}
```

The `.items` TODO.

Doing so we passed the notes we prepared in advance to the `RootView`. Right now Xcode will complain that `[Note]` and `Void` are incompatible. Shall we head over to a file called **MainRootView** and fix it?

#### RootView
If we were to think of the `Controller` as a puppeteer, `RootView` and all its subviews would be the puppets. They show whatever `Controller` asks them to show. They should not know anything about the application logic.

We can see `Reactant CLI` generated a class for us that we will use as our `RootView`.

However, I don't think we want our notes to be lying all over the place; a table (not the four-leg type) is more appropriate. We'll mark our **MainRootView** as `RootView` and transform it into a simple `TableView` by changing what we're subclassing like so:

```swift
final class MainRootView: PlainTableView<NoteCell>, RootView {
  // we'll fill this up in a second
}
```

Having done that, we can customize our `TableView` a bit in `init()`.

```swift
  init() {
    super.init()

    footerView = UIView() // this is so that cell dividers end after the last cell
    rowHeight = NoteCell.height
    separatorStyle = .singleLine
    tableView.contentInset.bottom = 0
  }
```

**NOTE**: For more `TableView` variations see [Reactant's TableView classes](https://docs.reactant.tech/parts/tableview.html).

Now we have a `TableView`, but the compiler has no idea what `NoteCell` means. For us it means that we need to create one.

Creating new file in the `Main` folder and choosing `Swift file`. You can name the file however you want, though it's good practice to always name it after the class that's going to reside in the file.

```swift
final class NoteCell: ViewBase<Note, Void>, Reactant.TableViewCell {
  static let height: CGFloat = 80
}
```

This is the declaration of our cell. It's good practice to explicitly set the height of your table cell. Next we need to add some labels that will tell us what the note is about without us tapping on it.

```swift
final class NoteCell: ViewBase<Note, Void>, Reactant.TableViewCell {
  static let height: CGFloat = 80

  private let title = UILabel()
  private let body = UILabel()

  override func update() {
    title.text = componentState.title
    preview.text = componentState.body
  }

  override func loadView() {
    children(
      title,
      preview
    )
  }
}
```

**NOTE**: I'm using 2-space tabs in these cute short snippets to achieve better readability. Try reading 4-space tab code on a phone! If you want to inspect the code in its full glory, the whole project can be found  [here](https://github.com/MatyasKriz/reactant-notes). Pasting the code to Xcode from the snippets should automatically convert indentation to your preferred size, if it does not, use `Ctrl+I` on selected code to indent it correctly.

Okay, lots of new code, so I owe you an explanation.

The `update()` method gets called every time `componentState` is modified. What is `componentState` you ask? It's the single mutable state of the Component. Ideally there should be no more `var` fields in the component, only the `componentState` should be mutable. The type of `componentState` is defined as the first generic parameter (between the `<` and `>`), you can see it's `Note` here.

Inside `update()` and only there you should read `componentState`. If you try reading from it before anything is set in there, an error is thrown.

As you can see, here we are using `componentState` to update the view based on the `MODEL` we receive. `Note` has `title` and `body` fields and we copy those into the `UILabel` views.

**ADVANCED**: If, for some reason, you don't want the `update()` method called, overriding method `needsUpdate()` gives you that control. Returning `false` from `needsUpdate()` means that `update()` doesn't get called when `componentState` is modified, default is `true`.

Second, the `loadView()` method. In this method you should setup your view and add subviews. It gets called only once after `afterInit()`.

We are using `children(_:)` which also comes from Reactant to conveniently add all the subviews. Keep in mind that views added first will be under the views added last.

**NOTE**: One more thing, even though these methods are overridden, calling super.*method*() is not needed.

### Part 3: Layouting
As you may or may not know, the reigning king of laying out your views on any kind of Apple device is `AutoLayout`. We sure want to get in on the fun using it.

**ReactantUI** uses what `AutoLayout` offers in an easy-to-understand way. You can either use anonymous components or connect your UI to your code giving you even more control over the component.

Rename **MainRootView.ui.xml** to **NoteCell.ui.xml** (`MainRootView` won't need a `ui.xml` because it's a `TableView` and nothing can be changed about that) and open the file afterwards.

First thing you'll notice is that there's a lot of complex text in the header. That's actually defining the `RootView` component you're creating right now, that's why the file ends with `</Component>` and every `ui.xml` file has to have this structure (except for the `rootView="true"` if you don't want the view to be a `RootView`).

We don't want our `NoteCell` to take up the whole screen, so we'll get rid of

```swift
rootView="true"
```

in the header.

Next up, let's define how our cells should look like. You can of course define your cell however you like. Your wildest dreams can become real (as long as they are about layouting).

My `NoteCell` is going to have Title on top and Preview of the note right under it. The Preview is going to be at most 2 lines long, Title only 1.

A good idea is to run what we have so far

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Component
  HEADER-STUFF REDACTED>
  <Label
    field="title"
    layout:leading="super inset(6)"
    layout:trailing="super inset(10)"
    layout:top="super inset(6)" />

  <Label
    field="preview"
    layout:fillHorizontally="super inset(10)"
    layout:top="super inset(6)"
    layout:bottom=":gt super inset(6)" />
</Component>
```

The `layout:` prefix is used for layouting attributes. Others are used to directly change the attributes of the element you are creating.

Saving the file at any time of you changing the values (assuming it is syntactically and semantically correct) will update the screen on your simulator.

### Part 4: Creating New Notes



### Part 5: Finishing Touches

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Component
  HEADER-STUFF REDACTED>
  <Label
    field="title"
    font="16"
    numberOfLines="1"
    lineBreakMode="byTruncatingTail"
    layout:leading="super inset(6)"
    layout:trailing="super inset(10)"
    layout:top="super inset(6)" />

  <Label
    field="preview"
    font="12"
    numberOfLines="2"
    lineBreakMode="byTruncatingTail"
    layout:fillHorizontally="super inset(10)"
    layout:top="super inset(6)"
    layout:bottom=":gt super inset(6)" />
</Component>
```



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

**NOTE**: You may notice that most (if not all classes) we use are marked `final`. If you are sure they won't need to be subclassed in the near future, it's good practice to mark them so, plus it helps the performance a bit.
