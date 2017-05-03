# Styling

Reactant also contains some convenience inits, helper methods etc. and protocol `Stylable` which allows easy style application to `UIView`. This is just a syntactic sugar, but allows you to have cleaner code.

## Usage

The best way to learn how all of this is used is to look at the tests in `Tests/Core/Styling` directory or directly into the source code. For convenience we decided to list the API below (sorted alphabetically except for Stylable) for quick reference.

Note: Inits for all structs like CGRect are created so that any parameter can be omitted (has default value of 0). For example: `CGRect(x: 1)`, `CGRect(origin: origin, width: 1)` and `CGRect(x: 1, size: size)` are all valid and these possibilities are skipped from this documentation.   

### Styleable

`Styleable` allows you to easily separate code defining view appearance from the rest. It is basically syntax sugar for using closures which modify passed object.

```Swift
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

We recommend to put these styles into struct `Styles` and nest it to extension like this:

```Swift
class SomeView: UIView {

    private let label = UILabel().styled(using: Styles.blueBackground)
}

fileprivate extension SomeView {

    fileprivate struct Styles {

        static func blueBackground(_ view: UILabel) {
            view.backgroundColor = UIColor.blue
        }

        static func whiteBackground(_ view: UILabel) {
            view.backgroundColor = UIColor.whiteBackground
        }
    }
}
```

To later change the appearance of view do:

```Swift
class SomeView: UIView {

    private let label ...

    func changeAppearanceOfLabel() {
        label.apply(style: Styles.whiteBackground)
    }
}
```

It is possible to use static var with closure instead of function like this:

```Swift
static var style: Style<UILabel> = { view in
    view.backgroundColor = UIColor.blue
}
```

Or any other syntax that you are happy with.

You can also define some base styles globally and then call them from another styles like so:

```Swift
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

```Swift
func + (lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform

func rotate(_ degrees: CGFloat) -> CGAffineTransform

func translate(x: CGFloat, y: CGFloat) -> CGAffineTransform

func scale(x: CGFloat, y: CGFloat) -> CGAffineTransform
```

Notes: `rotate`, `translate` and `scale` are all global functions. They create corresponding `CGAffineTransform`. All of them have default values (`scale` has as default values 1).

### CGPoint

```Swift
extension CGPoint {

    init(_ both: CGFloat)

    init(x: CGFloat, y: CGFloat)
}
```

### CGRect

```Swift
extension CGRect {

    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)

    init(x: CGFloat, y: CGFloat, size: CGSize)

    init(origin: CGPoint, width: CGFloat, height: CGFloat)
}
```

### CGSize

```Swift
extension CGSize {

    init(_ both: CGFloat)

    init(width: CGFloat, height: CGFloat)
}
```

### NSAttributedString

#### `+` operator

```Swift
func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString

func + (lhs: String, rhs: NSAttributedString) -> NSAttributedString

func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString
```

#### Attribute

```Swift
/// Enum which represents NS attributes for NSAttributedString (like NSStrokeColorAttributeName). Each case has value and assigned name.
enum Attribute {

    ...
    ...
    ...

    var name: String

    var value: AnyObject
}
```

```Swift
extension Sequence where Iterator.Element == Attribute {

    /// Creates dictionary from sequence of attributes by merging them together. String is name of case and AnyObject value corresponding to it.
    func toDictionary() -> [String: AnyObject]
}
```

#### String

```Swift
extension String {

    func attributed(_ attributes: [Attribute]) -> NSAttributedString

    func attributed(_ attributes: Attribute...) -> NSAttributedString
}
```

### Percent

```Swift
/// Returns input / 100.
postfix func %(input: CGFloat) -> CGFloat
```

### UIButton

```Swift
extension UIButton {

    init(title: String)

    func setBackgroundColor(_ color: UIColor, forState state: UIControlState)
}
```

### UICollectionView

```Swift
extension UICollectionView {

    init(collectionViewLayout layout: UICollectionViewLayout)
}
```

### UIColor

```Swift
extension UIColor {

    /// Accepted formats: "#RRGGBB" and "#RRGGBBAA".
    init(hex: String)

    init(rgb: UInt)

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

```Swift
extension UIEdgeInsets {

    init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)

    init(_ all: CGFloat)

    init(horizontal: CGFloat, vertical: CGFloat)

    init(horizontal: CGFloat, top: CGFloat, bottom: CGFloat)

    init(vertical: CGFloat, left: CGFloat, right: CGFloat)
}
```

### UIFont

```Swift
extension UIFont {

    init(_ name: String, _ size: CGFloat)
}
```

### UILabel

```Swift
extension UILabel {

    init(text: String)
}
```

### UIOffset

```Swift
extension UIOffset {

    init(_ all: CGFloat)

    init(horizontal: CGFloat)

    init(vertical: CGFloat)
}
```

### UITableView

```Swift
extension UITableView {

    init(style: UITableViewStyle)
}
