#  AJRInspectors

## Introduction

The AJRInspectors are a class of objects used to enable object inspection in your application. They are set up in a three fold manner, and to use them, you'll take the following steps:

1. Set up an AJRInspectorViewController. This will create a view that holds the inspectors. It also maintains a stack of objects to be inspected, so you'll push and pop object's off its stack to see their inspectors appear.

2. Prepare you views for inspection. You do this my implementing the method `inspectorIdentifiers(forInspectorContent:)`. This method will call `super` to get an array of inspectors, and then add it's own inspectors to the end of the array returned by `super`. The method returns an array of `AJRInspectorIdentifier`. 

    You'll also need to add an entry in your `.ajrplugindata` file that maps the inspector identifier to an XML filename.

3. Finally, you'll need to define XML content, described below, for each of the inspectors.

For all of this to work, you're objects must be subclassed from NSObject, and respond to key/value coding protocols. This is necessary, because while the inspector architecture is written fully in Swift, it's designed to function with Obj-C classes. See later sections for more details.

## XML

The inspectors are defined by writing basic XML files to describe the layout of the inspector. The elements defined here will be linked to your inspected objects using the key/value coding and key/value observing protocols via an `NSController` object.

There are three basic types of XML objects defined: document, groups, and slices. Documents define the top level of the XML, groups define how items in the inspector are grouped and labeled, and finally, the slices define the actual value content.

### Object Attributes

Both groups and slices will define attributes. We'll discuss individual attributes below, but all attributes follow these rules.

An attribute has a “base” name. For example:

```xml
<group title="My Title">
```

Here we see the `title` attribute. In this case, the value of the `title` attribute is defined as `My Title`, and cannot be affected by outside influences. 

Alternatively, we might expressess the above as:

```xml
<group titleKeyPath="translator.My_Title">
```

By appending `KeyPath` to the end of the attribute name, the attribute will now be bound to the model/view controller model. In the above example, we see a special case of this where we've bound to `translator`. Inspectors add a special case to my translation architecture, and will cause the system to first look in a file called `<inspector_file>.strings` prior to using the normal search method for the strings files. This makes translating the inspectors quite easy.

We'll talk more about bindings further on.

### XML Header

Each document must start with an XML header. This will generally be as follows:

```xml
<?xml version="1.0" encoding="utf-8" ?>
```

### Document Objects

There's two basic document level objects: `inspector` and `inspector-include`. The first is the main object you'll use, as it defines the "top level" of your inspected content. The second is used for XML files included from other inspectors. Includes are useful for breaking large inspectors into smaller, more managebale chunks.

The basic structure of a document will look like:

```xml
<?xml version="1.0" encoding="utf-8" ?>
<inspector>
    <group title="Graphic">
        <group title="Position" ... />
        </group>
        <include file="DrawText"/>
        <include file="DrawStroke"/>
        <include file="DrawFill"/>
        <include file="DrawShadow"/>
        <include file="DrawReflection"/>
    </group>
</inspector>
```

The included files above might look something like this:

```xml
<inspector-include>
    <group title="Fill">
        <slice type="boolean" ... />
        <slice type="color" ... />
    </group>
</inspector-include>
```

***NOTE:*** The above files elide important content in the `...` sections, which will be discussed in their appropriate sections below.

Document objects current have no attributes.

### Groups

Groups are basic units of grouping in the inspector. There's only one group object, but it's position is important, as how the group is rendered may change depending on the level at which it is defined.

At the top level, a group will get a title with a special background, as defined by the system appearance, while at lower levels, the title will simply be bolded text, perhaps with a horizontal divider.

#### Group Attributes

|Attribute|Type|Description|
| :-- | :-- | :-- |
| title | String | Determines the title of the section. All sections, no matter level, may have a title. |
| visible | Bool | If `true`, then the section is visible, otherwise the section is collapsed. |
| hidden | Bool | This is the opposite of `visible`. |
| forEach | [Object] | Points to an array of objects, and causes the section to be repeated once for each object. This only really works with the `KeyPath` variant.
| borderMarginTop | Float | Defines the spacing above the group. You usually shouldn't need to set this, as the default will work just fine. |
| borderMarginBottom | Float | Defines the spacing below the group. You usually shouldn't need to set this, as the default will work just fine. |
| borderColorTop | NSColor | The color of the top border. Not all groups will have a border. The default is the named color `inspectorDividerColor`, allowing you to change this globally via your asset catalog. |
| borderColorBottom | NSColor | The color of the bottom border. Not all groups will have a border. The default is the named color `inspectorDividerColor`, allowing you to change this globally via your asset catalog. |

### Slices

The main work horse of the XML files are the slices, as these define the actual content, rather than the organization of the XML. All slices have one attribute.

All slices have the following attributes in common:

| Attribute | Type | Description|
| :-- | :-- | :-- |
| type | String | This attribute must appear and the engine will generate an error if it does not. We'll describe all the available types in the following sections. |
| label | String | The label that appears to the left (or right) of the inspector content. This can be omitted if there's no need to label the content. |
| fullWidth | Bool | If `true`, the field will span the entire width of the inspector, including the label area. This is mostly meant for `table` slices, but may be useful for others. |

#### Slice Merging

One other imporant aspect of slices is that some slices can be "merged" with the predecessor. So, for example, say you have to number fields where it would make sense to them to be on the same line. For example, a width and height field. These fields will automatically "merge" if the second field defined doesn't have a `label`. You can prevent the merge by defining the `label` on the second field as “”.

For example:

```xml
<group title="Placement">
    <slice type="float" label="Position" subtitle="X" valueKeyPath="..."\>
    <slice type="float" subtitle="Y" valueKeypath="..."\>
    <slice type="float" label="Size" subtitle="Width" valueKeyPath="..."\>
    <slice type="float" subtitle="Height" valueKeypath="..."\>
</group>
```

This would create a simple inspector for the `x`, `y`, `width`, and `height` properties of an object where `x` and `y` were on one line while `width` and `height` were on their own line.

### Slice Types

As mentioned above, each slice must define a `type` attribute, and this attribute cannot have the `KeyPath` extension. Below we discuss all the various types and their attributes.

#### **attributedString**

Defines a slice to editing an attributed strings. This has similar functionality to a plain string field, by adds additional controls for changing the text's attributes. The bound value should be a attributed string, otherwise and error is generated.

| Attribute | Type | Description |
| :-- | :-- | :-- |
| editable | Bool | Determines if the field can be edited. |
| selectable | Bool | Determines if the field is selectable. A field may be not editable, but no selectable. |
| enabled | Bool | Determines if the field is enabled. A disable field cannot be edited or selected. |
| isContinuous | Bool | If `true`, all edits in the field will cause the bound object to receive the value. |
| emptyIsNull | Bool | If `true`, the empty string is considered the same as `nil`. This is mostly useful to get the nullPlaceholder string to appear. |
| nullPlaceholder | String | A string that will be displayed when the bound value is empty (see above) or `nil`. |
| value | NSAttributedString | An attributed string to display and edit. Note that this currently only has limited functionality (if any) with Swift's `AttributedString` class, and expects an `NSAttributedString`.

#### **boolean**

This generally generates a check box.

| Attribute | Type | Description |
| :-- | :-- | :-- |
| value | Bool | The bound value. |
| enabled | Bool | Whether the control is active. |
| title | String | The title of the control. This is different from the `label` attribute which generally appears to the left of the control, as `title` appears to the right of the control. |
| negate | Bool | If `true`, negate the value with fetching or setting. |

#### **button**

Create a basic Cocoa button. Note that the button cannot currently be styled. The button is also one of the few slices with out any kind of value as input, it simply just sends an action to the provided target when pressed.

| Attribute | Type | Description |
| :-- | :-- | :-- |
| title | String | The button's title. |
| enabled | Bool | If the button is enabled. |
| action | Selector | The action to send on the button being depressed. If this isn't set, the button will do nothing. |
| target | Object | The target of the action. This may be `nil`, in which case the action is sent down the responder chain. |

#### **color**

Presents a color editor. Note that this is a modified color well that presents a menu of color choices when clicked.

| Attribute | Type | Description |
| :-- | :-- | :-- |
| value | NSColor | The bound value. |
| enabled | Bool | Whether the control is active. |

#### **choice**

This is probably the most complicated, but one of the most useful of the slice types. It's complicated, because it can present a number of different appearances, and also because it allows the dynamic presentation of the inspector segments. 

For example, say you have choice of three items, and each item has a different set of properties. With this slice, you can control dynamically show a different section of the inspector depending on the choice selected.

You currently have three basic appearances: Pop Up Menu, Segmented Control, or Combo Box. The first two are probably the most common.

Also, you have two methods for determining the values in the inspectors. The first option is this slice can have children of type `choice`. Each choice defines one value that can appear in the options. The second option is to provide a list of objects via a binding. Both have their uses.

| Attribute | Type | Description | 
| :-- | :-- | :-- |
| style | string | Defines the style. Currently acceptable styles include: `popUp`, `segments`, and `comboBox`. |
| enabled | Bool | If the primary control is active. |
| allowsNil | Bool | If `true`, a placeholder value is created for `nil` and the user can view and set the bound value to `nil`. |
| mergeWithRight | Bool | Normally this slice tries to avoid being merged with other controls, but if your chocies are narrow enough, you might desired this behavior, so set this to `true`. |
| valueType | String | Determines the value type of the bound value. This cannot use the `KeyPath` variant. Currently valid values are: `integer`, `bool`, `float`, `string`, and `object`. If this key is missing or contains an invalid value, an error will be generated. |

When using the `valueType` `integer`, `bool`, `float`, or `string`, you can define the following keys:

| Attribute | Type | Description |
| :-- | :-- | :-- |
| value | &lt;T&gt; | Binds to a value of the typed defined by `valueType`. When present, `values` may not be present. |
| values | [&lt;T&gt;] | Binds to array of values defined by `valueType`. When present, `value` may not be present. |

If you're using the `object` value type, you may also define the following attributes:

| Attribute | Type | Description |
| :-- | :-- | :-- |
| value | Object | The bound value. |
| objects | [Object] | An array of objects to use as choices. |
| choiceTitle | Key&nbsp;Path | This is slightly special in that the key path provided will be sent to the object to determine the title. |
| titleWhenNil | String | The title to display if `value` is `nil`. |

As an alternative to `choiceTitle`, you can also have your objects define the `AJRInspectorChoiceTitleProvider` protocol, which allows them to return either a title string or an image. Note that a `choiceImage` attribute may be added in the future.


##### ***choice***

The `choice` slice may have childre with the element name `choice`. Choices define the following attributes:

| Attribute | Type | Description |
| :-- | :-- | :-- |
| title | String | The title of the option. |
| imageKey | NSImage | An image to display. This can be used with `title`. |
| imageName | String | The name of an image to display. This is useful if the image is stored in an asset catalog. |
| imageBundle | String | When looking for an image via `imageName`, this defines the bundle ID of where the image should be searched. For example, for the AJRInterface framework, the bundle ID would be `com.ajr.framework.AJRInterface`. |
| separator | Bool | If `true`, a separator item will be displayed. This is only useful for styles that could have a separator, like the `popUp` style. |
| value | &lt;T&gt; | The value of the choice. |
| objectPredicate | Expression | This option is only available for value type `object` and must be present. This represents an expression used to determine if the object matches the current choice. |

Remember that choices can have child content. This content will only be displayed when the choice is selected.

#### **date**

A field used for date display and input. It defines the following attribute:

| Attribute | Type | Description |
| :-- | :-- | :-- |
| editable | Bool | Determines if the field can be edited. |
| selectable | Bool | Determines if the field is selectable. A field may be not editable, but no selectable. |
| enabled | Bool | Determines if the field is enabled. A disable field cannot be edited or selected. |
| isContinuous | Bool | If `true`, all edits in the field will cause the bound object to receive the value. |
| emptyIsNull | Bool | If `true`, the empty string is considered the same as `nil`. This is mostly useful to get the nullPlaceholder string to appear. |
| nullPlaceholder | String | A string that will be displayed when the bound value is empty (see above) or `nil`. |
| alignment | NSTextAlignment | Valid values are `left`, `center`, `justified`, `natural`, and `right`. |
| color | NSColor | The color of the text. |
| backgroundColor | NSColor | The background color of the next.|
| value | Date | The bound value. |
| format | String | A valid date format. See Unicode's [documentation](http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns) for details. |