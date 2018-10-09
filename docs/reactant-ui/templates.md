# Templates

Templates are useful for designing of complex structures that can later be used in code. Template can also take multiple arguments, so it is represented with a function in the code.

### Creation

Templates are created within a `templates` xml element. We can also specify templates name (if we don't, then `Templates` is a default name).

```xml
<templates>
    <attributedText style="welcomeStyle" name="welcome">
        <b>Hello {{name}} {{surname}}!<b>
    </attributedText>
</templates>
```

These templates are then called in a code in the following way:

```swift
label.attributedText = Templates.welcome(name: "John", surname: "Appleseed")
```


### Arguments

Argument in a template is an identifier surrounded with two curly braces:

```{{argument}}```

## Types of templates

Currently there are supported templates for [Attributed Text](attributedText.md#templates).