---
id: troubleshooting
title: Troubleshooting Tips
sidebar_label: Troubleshooting
---
As we all know, not always everything goes according to plan in IT. That's why we created this section with solutions to problems you are most likely to encounter.

**NOTE**: Always clean the build after trying any of the provided solutions. Some things may depend on it. The shortcut in Xcode is `Cmd+Shift+K`.

## General
- try `pod repo update` to update your Cocoapods repository
- try `pod install` to update the Pods and reopen the `.xcworkspace` (this is important otherwise the changes might not take effect).

## Reactant

## ReactantUI
**I get a compiler error saying that generated things do not exist.**

Make sure that in `Build Phases`->`Compile Sources` the `GeneratedUI.swift` file is the topmost one.

---

**I get an error ".../Application/Sources/Generated/GeneratedUI.swift no such file or directory".**

You need to create the `Generated/` folder yourself. If you're in the root folder of your project, you can use this command: `mkdir ./Application/Generated/`.

---

## ReactantCLI
**I created a new project with `reactant init` command and it doesn't run.**

It's possible that something went wrong during the project creation. Make sure you have [Cocoapods][cocoapods] installed and afterwards try to call `pod repo update` and afterwards `pod install`. If it still doesn't work, consider creating a new project.

<!-- URLs -->

[cocoapods]: http://cocoapods.org
