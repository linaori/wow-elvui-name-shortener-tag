# ElvUI Name Shortener Tag
Provides an extra ElvUI tag with options to shorten names when needed, while also keeping it as readable and elaborate
as possible.

This is the ElvUI tag counterpart for the Plater mod: https://wago.io/name-shortener-for-plater

### Available Tags

#### `[lin:unit-name]`
Unit name which can change based on toys

#### `[lin:unit-name:translit]`
Same as `[lin:unit-name]` while converting cyrillic

#### `[lin:real-unit-name]`
The real unit name, unaffected by toys

#### `[lin:real-unit-name:translit]`
Same as `[lin:real-unit-name]` while converting cyrillic


### Configuration Options
All options as listed can be added in the optional part in tags. If you want to keep the default value, you can omit the
arguments. The options listed between the `{}` work with all 4 tags.

Use the real unit name, translit it, and limit it to 10 characters in length, while keeping all other settings default:
> `[lin:real-unit-name:translit{length=10}]` 

This is what the full config would look like if you were to define all settings with their default values:
> `[lin:real-unit{length=20, hyphenAsSpace=1, keepHyphenInLastName=1, noSplitCutoff=1, abbreviate=1, abbreviateLeftToRight=0, keepRightSide=1}]`

#### Name length (length=20)
> This will change the cutoff length. As soon as the length of the name falls under this number, it will attempt to
> cutoff based on the next settings.

#### Treat hyphens (-) as space (hyphenAsSpace=1)
> Some mobs have long names with hyphens, for example the "Forsworn Squad-Leader". This will become "Forsworn Squad
> Leader".

#### Keep hyphen in the last name (keepHyphenInLastName=1)
> This ensures that hyphens in the last name are kept as is. In "Forsworn Squad-Leader" the "Squad-Leader" is treated
> like a single word, while "Squad-Leader of the Forsworn" is treated as "Squad Leader"

#### Cutoff when no split can be done (noSplitCutoff=1)
> When the smallest possible complete word in the NPC name is still longer than the "Name length" setting, enabling this
> setting will cut off the name to enforce a max length.

#### Abbreviate names (abbreviate=1)
> When names become too long and this setting is off, the last word will be used as the name and the rest will be
> hidden. When this setting is enabled, the words will become abbreviated; For example "W.o. Warcraft". Abbreviation
> will respect the "Name length" setting to only abbreviate what's needed.

#### Abbreviate left to right (abbreviateLeftToRight=0)
> Controls whether the left or right side should be abbreviated first. The last part of the name will always be kept
> intact.
>
> - **Left to Right**: This Very Long Name will be shortened as "T.V. Long Name"
> - **Right to Left**: This Very Long Name will be shortened as "This V.L. Name"

#### Keep right side (keepRightSide=1)
> Determines whether the left or right part of the name is kept intact. Combine this with the above option to make it
> show the way you want
>
> - **Keep right side**: This Very Long Name will be shortened as "T.V. Long Name"
> - **Keep left side**: This Very Long Name will be shortened as "This V.L.N."

## Official Download Locations
You can find this addon on: [CurseForge.com](https://www.curseforge.com/wow/addons/elvui-name-shortener-tag),
[Wago.io](https://addons.wago.io/addons/elvui-name-shortener-tag), and [WowUp.io](https://wowup.io/).
You can find the releases on [GitHub](https://github.com/linaori/wow-elvui-name-shortener-tag/releases).
