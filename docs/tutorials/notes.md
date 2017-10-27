# ($NAME)
Welcome to our first tutorial that will help you get your feet wet with Reactant architecture!

First and foremost, you will need:
- an **Xcode** (AppCode might work as well, but it's not tested),
- a **Terminal**,
- a [Cocoapods](http://cocoapods.org) dependency manager,
- an internet connection.

That's right, with just these few things you, too, can become fluent in Reactant! We won't touch the Terminal much, so if you're not used to hacking out command after command, it's okay, you can always come back and use this tutorial as a reference guide.

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

```

#### RootView
Let's head over to a file called **MainRootView**. We can see `Reactant CLI` generated a class for us that we will use as our `RootView`. However, I don't think we want our notes to be lying all over the place, a table (not the four-legs type) is more appropriate. We'll transform our **MainRootView** into a simple `TableView` by changing what we're subclassing like so:
```swift
final class MainRootView: PlainTableView<NoteCell> {
  // we'll fill this up in no time
}
```

**NOTE**: For more `TableView` variations see [Reactant's TableView classes](https://docs.reactant.tech/parts/tableview.html).

Now we have a `TableView`, but compiler has no idea what `NoteCell` means. We need to create one.

### Part 3: layouting
As you may or may not know, on iOS `AutoLayout` is the reigning king of taking care of your layout on any kind of device. Be it phone or tablet. We sure want to get in on the fun using it.

**ReactantUI** uses what `AutoLayout` offers in an easy-to-understand way. You can either use anonymous components or connect your UI to your code giving you even more control over the component.

Open a file called **MainRootView.ui.xml**. First thing you'll notice is that there's some gibberish in the header. That's actually defining the `RootView` component you're creating right now, that's why the file ends with `</Component>` and every `ui.xml` file has to have this structure (except for the `rootView="true"` if you don't want the view to be a `RootView`).

We're not gonna need the Label, so we can get rid of it.



















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
