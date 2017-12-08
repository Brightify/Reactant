# Styling

Reactant also contains some convenience `init`s, helper methods, operator overloads, etc.. Protocol `Stylable` allows you to easily apply style to any `UIView`. It's just syntactic sugar, but allows for cleaner code with less duplicates.

## Usage

The best way to master all these styling methods is to check out the tests in `Tests/Core/Styling` directory or the source code itself. For convenience we decided to list the API below (sorted alphabetically except for `Stylable`) for quick reference.

Note: Inits for all structs like CGRect are created so that any parameter can be omitted (has default value of 0). For example: `CGRect(x: 1)`, `CGRect(origin: origin, width: 1)` and `CGRect(x: 1, size: size)` are all valid and these possibilities are skipped from this documentation.   

### Styleable

`Styleable` allows you to easily separate code defining view appearance from the rest. It is basically syntax sugar for using closures which modify passed object.

```swift
protocol Styleable { }

extension UIView: Styleable { }

typealias Style<T> = (T) -> Void

extension Styleable {

    func apply(style: Style<Self>)

    func apply(styles: Style<Self>...)

    func apply(styles: [Style<Self>])

    func styled(using styles: Style<Self>...) -> Self

    func styled(using styles: [Style<Self>]) -> Self

    func with(_ style: Style<Self>) -> Self
}
```

We recommend storing all of your subclassed `UIView` styles in a `fileprivate` struct `Styles` that is inside an extension for better code readability, it should look something like this:

```swift
class SomeView: UIView {

    private let login = UILabel().styled(using: Styles.textFieldLabel)
    private let password = UILabel().styled(using: Styles.textFieldLabel)
}

extension SomeView {

    fileprivate struct Styles {

        static func textFieldLabel(_ label: UILabel) {
            label.fontColor = UIColor.white
        }

        static func redTextFieldLabel(_ label: UILabel) {
            label.fontColor = UIColor.red
        }
    }
}
```

To change the appearance of the view later rather than on initialization (although you can do both), call `apply(style:)` method on it:

```swift
class SomeView: UIView {

    private let login ...
    private let password ...

    func incorrectPassword() {
        password.apply(style: Styles.redTextFieldLabel)
    }
}
```

It is also possible to use a static variable with closure instead of a function:

```swift
static var style: Style<UILabel> = { view in
    view.backgroundColor = UIColor.blue
}
```

You can also define some base styles globally and then call them from another styles like so:

```swift
struct BaseStyles {

    static func blueBackground(_ view: UIView) {
        view.backgroundColor = UIColor.blue
    }
}

struct LabelStyles {

    static func yellowTintWithBlueBackground(_ label: UILabel) {
        label.apply(style: BaseStyles.blueBackground)

        label.tintColor = UIColor.yellow
    }
}
```

### CGAffineTransform

```swift
func +(lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform

func rotate(_ degrees: CGFloat) -> CGAffineTransform

func translate(x: CGFloat, y: CGFloat) -> CGAffineTransform

func scale(x: CGFloat, y: CGFloat) -> CGAffineTransform
```

Notes: `rotate`, `translate` and `scale` are all global functions. They create corresponding `CGAffineTransform`. All of them have default values (`scale` uses 1 as default values).

### CGPoint

```swift
extension CGPoint {

    init(_ both: CGFloat)

    init(x: CGFloat, y: CGFloat)
}
```

### CGRect

```swift
extension CGRect {

    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)

    init(x: CGFloat, y: CGFloat, size: CGSize)

    init(origin: CGPoint, width: CGFloat, height: CGFloat)
}
```

### CGSize

```swift
extension CGSize {

    init(_ both: CGFloat)

    init(width: CGFloat, height: CGFloat)
}
```

### NSAttributedString

#### `+` operator

```swift
func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString

func + (lhs: String, rhs: NSAttributedString) -> NSAttributedString

func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString
```

#### Attribute

```swift
/// Enum which represents NS attributes for NSAttributedString (like NSStrokeColorAttributeName). Each case has value and assigned name.
enum Attribute {

    ...
    ...
    ...

    var name: String

    var value: AnyObject
}
```

```swift
extension Sequence where Iterator.Element == Attribute {

    /// Creates dictionary from sequence of attributes by merging them together. NSAttributedStringKey is name of case and AnyObject value corresponding to it.
    func toDictionary() -> [NSAttributedStringKey: AnyObject]
}
```

#### String

```swift
extension String {

    func attributed(_ attributes: [Attribute]) -> NSAttributedString

    func attributed(_ attributes: Attribute...) -> NSAttributedString
}
```

### Percent

```swift
/// Returns input / 100.
postfix func %(input: CGFloat) -> CGFloat
```

### UIButton

```swift
extension UIButton {

    init(title: String)

    func setBackgroundColor(_ color: UIColor, forState state: UIControlState)
}
```

### UICollectionView

```swift
extension UICollectionView {

    init(collectionViewLayout layout: UICollectionViewLayout)
}
```

### UIColor

```swift
extension UIColor {

    /// Accepted formats: "#RRGGBB" and "#RRGGBBAA".
    init(hex: String)

    /// Accepted format: 0xRRGGBB.
    init(rgb: UInt)

    /// Accepted format: 0xRRGGBBAA.
    init(rgba: UInt)

    /// Increases color's brightness.
    func lighter(by percent: CGFloat) -> UIColor

    /// Reduces color's brightness.
    func darker(by percent: CGFloat) -> UIColor

    /// Increases color's saturation.
    func saturated(by percent: CGFloat) -> UIColor

    /// Reduces color's saturation.
    func desaturated(by percent: CGFloat) -> UIColor

    /// Increases color's alpha.
    func fadedIn(by percent: CGFloat) -> UIColor

    /// Reduces color's alpha.
    func fadedOut(by percent: CGFloat) -> UIColor
}
```

### UIEdgeInsets

```swift
extension UIEdgeInsets {

    init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)

    init(_ all: CGFloat)

    init(horizontal: CGFloat, vertical: CGFloat)

    init(horizontal: CGFloat, top: CGFloat, bottom: CGFloat)

    init(vertical: CGFloat, left: CGFloat, right: CGFloat)
}
```

### UIFont

```swift
extension UIFont {

    init(_ name: String, _ size: CGFloat)
}
```

### UILabel

```swift
extension UILabel {

    init(text: String)
}
```

### UIOffset

```swift
extension UIOffset {

    init(_ all: CGFloat)

    init(horizontal: CGFloat)

    init(vertical: CGFloat)
}
```

### UITableView

```swift
extension UITableView {

    init(style: UITableViewStyle)
}
```
