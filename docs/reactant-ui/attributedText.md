# Attributed Text

Attributed strings are very useful for text with multiple modifications where it would be unnecessarily complex to use more than one label/button.

Both ReactantUI and ReactantLiveUI support attributed strings for even faster prototyping of your application. The attributed texts form a hiearchy where all children inherit the style from their ancestor. However, children can still override the inherited attributes leading to clean and straightforward API.

## AttributedStyle
Defining attributed text style is not much different from creating view styles. Let's take a look:
```xml
<styles name="ReactantStyles">
  <attributedTextStyle name="header">
    <titleText font=":light@50" foregroundColor="#f5f5f5" />
    <b font=":bold@14" />
    <u underlineStyle="styleSingle" underlineColor="gray" />
    <normal font=":medium@20" foregroundColor="#dddddd" />
  </attributedTextStyle>
</styles>
```

## Label
Labels are not containers for other `View`s, creating `attributedText` inside it however allows us to define an attributed string and use various attributes within it. We can even nest them if we desire to do so.

```xml
<Label
  layout:top="safeAreaLayoutGuide inset(10)"
  layout:fillHorizontally="super inset(20)">
  <attributedText
    style="header">
    <titleText>Welcome!</titleText>
    <b>You are currently in <u>New York City</u>.</b>
    Would you like to travel elsewhere?
  </attributedText>
</Label>
```

## Button
Buttons can find themselves in one of the predefined control states, these namely `normal`, `highlighted`, `disabled`, `selected`, `focused`. Their meanings are equal to UIKit's `UIControl.State` cases.

ReactantUI also allows defining an attributed string for more than one control state at once using bars. Here's an example defining an attributed title for `normal` control state (no state is `normal` by default). The second `attributedTitle` element sets both font and foreground color (along with the text content) to both `selected` and `highlighted` states.

We are adding the attributes directly to the `attributedTitle` element's properties. All of the attributes defined at this level are passed on to the text and attributes used within it. The priority of attributes defined in ancestors is lower than priority of attributes defined in children which allows for overriding.

```xml
<Button
  layout:fillHorizontally="super inset(10)"
  layout:height="60">
  <attributedTitle
    style="header">
    <normal>Travel!</normal>
  </attributedTitle>
  <attributedTitle
    state="selected | highlighted"
    style="header"
    font=":bold@21"
    foregroundColor="#f5f5f5">
    Travel!
  </attributedTitle>
</Button>
```

## Extending Styles
ReactantUI supports extending other styles to inherit their properties. Referencing other

## Global Styles
To use globally defined styles, we can use the dot notation to access the stylegroup namespace.

```xml
<!-- CommonStyles.styles.xml -->
<styleGroup name="common">
  <attributedTextStyle name="title">
    <b font=":bold@21" />
    <i font=":light@20" />
    <base font=":bold@30" foregroundColor="white" backgroundColor="black" />
  </attributedTextStyle>
</styleGroup>
```

```xml
<!-- Inside Component in Component.ui.xml -->
<styles name="GeneralStyles">
  <attributedTextStyle name="bandaska" extend="common.title">
    <i font=":bold@20" />
    <base foregroundColor="white" />
  </attributedTextStyle>
</styles>
```

<br>

## Templates
We can create a [template](templates.md) for an Attributed Text.

Template for Attributed Text can be created in the following way:

```xml
<templates name="ReactantTemplates">
    <attributedText style="welcomeStyle" name="welcome">
        <b>Hello {{name}} {{surname}}!<b>
    </attributedText>
</templates>
```

This template can then be used in code:

```swift
label.attributedText = ReactantTemplates.welcome(name: "John", surname: "Appleseed")
```

## Attribute List
The full list of attribute follows along with the way to use them:
- **font** - `system:light@30` where 'system' is the typeface (optional), 'light' is the font's weight (optional), and 30 is the size of the font
- **foregroundColor** - color (e.g. `blue`, `#dddddd`, ...)
- **backgroundColor** - color (e.g. `white`, `#f5f5f5`, ...)
- **ligature** - either `0` (no ligatures) or `1` (default ligatures)
- **kern** - decimal (e.g. `1.3`, `2`, ...)
- **underlineStyle** - `styleNone`, `styleSingle`, `styleThick`, `styleDouble`, `patternDot`, `patternDash`, `patternDashDot`, `patternDashDotDot`, `byWord`
- **strikethroughStyle** - same options as **underlineStyle**
- **underlineColor** - color (e.g. `red`, `#ff01ff`, ...)
- **strikethroughColor** - color (e.g. `gray`, `#cccfff`, ...)
- **strokeColor** - color (e.g. `black`, `#001100`, ...)
- **strokeWidth** - decimal (e.g. `0.1`, `1`, ...)
- **attachmentImage** - image name (e.g. `ic_contacts_dark`, `ic_phonebook_light`, ...)
- **link** - URL (e.g. `https://www.apple.com/`)
- **baselineOffset** - decimal (e.g. `42`, `4.2`, ...)
- **obliqueness** - decimal (e.g. `0.9`, `4`, ...)
- **expansion** - decimal (e.g. `0.03`, `23`, ...)
- **writingDirection** - `natural`, `leftToRight` or `rightToLeft`
- **verticalGlyphForm** - either `0` (horizontal text) or `1` (vertical text, unsupported on iOS)

#### Shadow
Shadow is a bit more complex structure to be instantiated in one string and therefore it is set up using the dot notation:

```xml
<styles name="ReactantStyles">
  <attributedTextStyle name="header">
    <shadowed
      shadow.opacity="0.4"
      shadow.color="#dddddd"
      shadow.offset="3,5" />
  </attributedTextStyle>
</styles>
```

It is not required to set all three, missing values will be replaced by default ones.

#### Paragraph Style
Paragraph style needs its own section because of how many settings it has. Setting the `paragraphStyle` attributes uses the dot notation just like the `shadow` one.

```xml
<styles name="ReactantStyles">
  <attributedTextStyle name="header">
    <shadowed
      paragraphStyle.tabStops="15; 50"
      paragraphStyle.defaultTabInterval="15"
      paragraphStyle.firstLineHeadIndent="0"
      paragraphStyle.headIndent="15"
      paragraphStyle.minimumLineHeight="30"
      paragraphStyle.maximumLineHeight="30"
      paragraphStyle.paragraphSpacing="10" />
  </attributedTextStyle>
</styles>
```

`paragraphStyle` has these settings:
- **alignment** - `left`, `right`, `center`, `justified` or `natural`
- **firstLineHeadIndent** - decimal (e.g. `15`, `9.5`, ...)
- **headIndent** - decimal (e.g. `5`, `4.5`, ...)
- **tailIndent** - decimal (e.g. `1`, `0.1`, ...)
- **tabStops** - array of alignment (optional; `left`, `right`, `center`, `justified` or `natural`) and decimal pairs separated by `@` (e.g. `left@15; center@50`, `right@5; 15; 35`, ...) - we are setting the `alignment` (the word) and `location` (the decimal)
- **lineBreakMode** - `byWordWrapping`, `byCharWrapping`, `byClipping`, `byTruncatingHead`, `byTruncatingTail`, `byTruncatingMiddle`
- **maximumLineHeight** - decimal (e.g. `120`, `65.5`, ...)
- **minimumLineHeight** - decimal (e.g. `0`, `0.676767`, ...)
- **lineHeightMultiple** - decimal (e.g. `10`, `3.14`, ...)
- **lineSpacing** - decimal (e.g. `9`, `2.78`, ...)
- **paragraphSpacing** - decimal (e.g. `30`, `3.5`, ...)
- **paragraphSpacingBefore** - decimal (e.g. `30`, `9.5`, ...)
