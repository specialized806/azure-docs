---
title: Expressions reference for data flows
description: Reference for the expression language used in data flow and data flow graph transforms in Azure IoT Operations. Covers operators, functions, data types, metadata, and conditionals.
author: sethmanheim
ms.author: sethm
ms.service: azure-iot-operations
ms.subservice: azure-data-flows
ms.topic: reference
ms.date: 03/26/2026
ai-usage: ai-assisted

---

# Expressions reference for data flows

This reference applies to both [data flows](overview-dataflow.md) and [data flow graphs](concept-dataflow-graphs.md). Both use the same expression language for map, filter, and enrichment transforms. Data flow graphs also support branch and window (accumulate) transforms, which are noted where applicable.

## Positional variables

Each rule's `inputs` array determines the variables available in the `expression`. The first input becomes `$1`, the second becomes `$2`, and so on.

| Inputs | Expression | Result |
|--------|-----------|--------|
| `Position`, `Office` | `$1 + ", " + $2` | Concatenates Position and Office with a comma |
| `temperature` | `cToF($1)` | Converts Celsius to Fahrenheit |
| `temperature`, `humidity` | `$1 * $2 < 100000` | Checks a threshold against two fields |

If only one input is specified and no expression is provided, the value at that input is copied directly to the output.

## Operators

Expressions support the following operators, listed from highest to lowest precedence:

| Precedence | Operators | Description |
|------------|-----------|-------------|
| 1 | `!` | Logical NOT (unary) |
| 2 | `^` | Exponentiation |
| 3 | `*`, `/`, `%` | Multiplication, division, modulo |
| 4 | `+`, `-` | Addition / string concatenation, subtraction |
| 5 | `<`, `>`, `<=`, `>=` | Comparison |
| 6 | `==`, `!=` | Equality, inequality |
| 7 | `&&` | Logical AND |
| 8 | `\|\|` | Logical OR |

The `+` operator concatenates strings when at least one operand is a string. Use parentheses to override default precedence.

Examples:

| Expression | Description |
|-----------|-------------|
| `$1 * 2 ^ 3` | Exponentiation first: `$1 * 8` |
| `($1 * 2) ^ 3` | Parentheses override: multiply first |
| `-$1 * 2` | Negation first, then multiply |
| `$1 > 100 && $2 > 200` | Chain conditions with logical AND |

## Built-in functions

### Unit conversion functions

These functions accept a single numeric value and return a float.

| Function | Conversion | Formula |
|----------|-----------|---------|
| `cToF(value)` | Celsius to Fahrenheit | F = (C × 9/5) + 32 |
| `fToC(value)` | Fahrenheit to Celsius | C = (F - 32) × 5/9 |
| `psiToBar(value)` | PSI to bar | bar = PSI × 0.0689476 |
| `barToPsi(value)` | Bar to PSI | PSI = bar / 0.0689476 |
| `inToCm(value)` | Inches to centimeters | cm = in × 2.54 |
| `cmToIn(value)` | Centimeters to inches | in = cm / 2.54 |
| `ftToM(value)` | Feet to meters | m = ft × 0.3048 |
| `mToFt(value)` | Meters to feet | ft = m / 0.3048 |
| `lbToKg(value)` | Pounds to kilograms | kg = lb × 0.453592 |
| `kgToLb(value)` | Kilograms to pounds | lb = kg / 0.453592 |
| `galToL(value)` | US gallons to liters | L = gal × 3.78541 |
| `lToGal(value)` | Liters to US gallons | gal = L / 3.78541 |

### Scaling and rounding functions

| Function | Description |
|----------|-------------|
| `scale(value, srcLo, srcHi, dstLo, dstHi)` | Linearly scales `value` from the source range to the destination range. All five arguments must be numeric. |
| `round_n(value, decimals)` | Rounds a float to the specified number of decimal places (0 to 15). |

### Math functions

These functions come from the built-in math library.

| Function | Description |
|----------|-------------|
| `floor(value)` | Largest integer less than or equal to a number |
| `round(value)` | Nearest integer, rounding half-way cases away from 0.0 |
| `ceil(value)` | Smallest integer greater than or equal to a number |
| `math::abs(value)` | Absolute value |
| `math::sqrt(value)` | Square root (returns NaN for negative numbers) |
| `math::cbrt(value)` | Cube root |
| `math::ln(value)` | Natural logarithm |
| `math::log2(value)` | Base-2 logarithm |
| `math::log10(value)` | Base-10 logarithm |
| `math::log(value, base)` | Logarithm with arbitrary base |
| `math::exp(value)` | e raised to the power of value |
| `math::exp2(value)` | 2 raised to the power of value |
| `math::pow(base, exp)` | Raises base to the power of exp |
| `math::cos(value)` | Cosine (radians) |
| `math::sin(value)` | Sine (radians) |
| `math::tan(value)` | Tangent (radians) |
| `math::acos(value)` | Arccosine (returns radians) |
| `math::asin(value)` | Arcsine (returns radians) |
| `math::atan(value)` | Arctangent (returns radians) |
| `math::atan2(y, x)` | Four-quadrant arctangent (returns radians) |
| `math::hypot(a, b)` | Length of the hypotenuse from sides a and b |

### String functions

| Function | Description |
|----------|-------------|
| `len(string)` | Character length of a string, or element count of a tuple |
| `str::to_lowercase(string)` | Converts to lowercase |
| `str::to_uppercase(string)` | Converts to uppercase |
| `str::trim(string)` | Removes leading and trailing whitespace |
| `str::from(value)` | Converts a value to its string representation |
| `str::substring(string, start, end)` | Extracts a substring by character index |
| `str::regex_matches(string, pattern)` | Returns true if the string matches the regex pattern. Available in data flow graphs only. |
| `str::regex_replace(string, pattern, replacement)` | Replaces all regex matches with the replacement string. Available in data flow graphs only. |

### Conditional and collection functions

| Function | Description |
|----------|-------------|
| `if(condition, trueVal, falseVal)` | Returns `trueVal` when condition is true, otherwise `falseVal` |
| `min(values)` | Minimum of one or more numeric values or an array |
| `max(values)` | Maximum of one or more numeric values or an array |
| `contains(tuple, value)` | Returns true if the tuple contains the value |
| `contains_any(tuple, candidates)` | Returns true if the tuple contains any value from the candidates tuple |
| `typeof(value)` | Returns the type as a string: `"string"`, `"float"`, `"int"`, `"boolean"`, `"tuple"`, or `"empty"` |

### Aggregation functions (window transforms only)

These functions are available only in accumulation rules within window transforms. Each takes a single positional variable.

| Function | Returns | Empty window behavior |
|----------|---------|-----------------------|
| `average($n)` | Mean of numeric values | Error |
| `sum($n)` | Sum of numeric values | 0.0 |
| `min($n)` | Minimum numeric value | Error |
| `max($n)` | Maximum numeric value | Error |
| `count($n)` | Count of messages where the field exists | 0 |
| `first($n)` | First value in the window | Error |
| `last($n)` | Last value in the window | Error |

For details on using aggregation functions, see [Aggregate data over time](howto-dataflow-graphs-window.md).

## Conditional logic

Use the `if` function to branch logic within an expression:

| Expression | Description |
|-----------|-------------|
| `if($1 > 100, "high", "normal")` | Returns "high" when temperature exceeds 100 |
| `if($2 == (), $1, $1 * $2)` | Falls back to $1 when $2 is missing |
| `if($1 > 5, true, false)` | Returns a boolean based on a threshold |

Use `()` (the empty value) in comparisons to detect missing fields.

> [!TIP]
> If you only need a static fallback for a missing field, the `?? <default>` syntax is simpler. See [Default values](#default-values). Reserve `if` for cases where you need to choose between computed values.

## Metadata fields

Read from and write to message metadata by using the `$metadata.` prefix in the `inputs` or `output` fields of a rule. Metadata references go in the field path, not in the expression itself.

### Metadata properties

* **Topic**: Works for both MQTT and Kafka. It contains the string where the message was published. Example: `$metadata.topic`.
* **User property**: In MQTT, this refers to the free-form key/value pairs an MQTT message can carry. For example, if the MQTT message was published with a user property with key "priority" and value "high", then the `$metadata.user_property.priority` reference holds the value "high". User property keys can be arbitrary strings and may require escaping: `$metadata.user_property."weird key"` uses the key "weird key" (with a space).
* **System property**: This term is used for every property that is not a user property. Currently, only a single system property is supported: `$metadata.system_property.content_type`, which reads the content type property of the MQTT message (if set).
* **Header**: This is the Kafka equivalent of the MQTT user property. Kafka can use any binary value for a key, but data flows support only UTF-8 string keys. Example: `$metadata.header.priority`. This functionality is similar to user properties.

| Field | Description |
|-------|-------------|
| `$metadata.topic` | The MQTT topic of the message |
| `$metadata.user_property.<key>` | A user property on the message, identified by key |
| `$metadata.system_property.content_type` | The content type system property |
| `$metadata.header.<key>` | A Kafka header value, identified by key |

### Read from metadata

To reference the source topic and a user property in an expression, list them as inputs:

| Input | Variable |
|-------|----------|
| `$metadata.topic` | `$1` |
| `$metadata.user_property.device_id` | `$2` |

Expression: `$1 + "/" + $2`

In the following example, the MQTT `topic` property is mapped to the `origin_topic` field in the output:

```yaml
inputs:
  - $metadata.topic
output: origin_topic
```

If the user property `priority` is present in the MQTT message, the following example demonstrates how to map it to an output field:

```yaml
inputs:
  - $metadata.user_property.priority
output: priority
```

### Write to metadata

To set a user property on the output message, use `$metadata.user_property.<key>` as the output field.

Setting a metadata field to an empty value (`()`) removes it. For user properties, duplicate keys are allowed.

You can also map metadata properties to an output header or user property. In the following example, the MQTT `topic` is mapped to the `origin_topic` field in the output's user property:

```yaml
inputs:
  - $metadata.topic
output: $metadata.user_property.origin_topic
```

If the incoming payload contains a `priority` field, the following example demonstrates how to map it to an MQTT user property:

```yaml
inputs:
  - priority
output: $metadata.user_property.priority
```

The same example for Kafka:

```yaml
inputs:
  - priority
output: $metadata.header.priority
```

Metadata fields are supported in map, filter, and branch rules. They aren't available in window (accumulate) rules.

## Last known value

Use the `? $last` suffix on an input to tell the runtime to remember the most recent value for that field. If the field is missing in the current message, the last known value is used instead.

| Input | Behavior |
|-------|----------|
| `temperature ? $last` | Uses the last known temperature if the current message has no `temperature` field |

The `? $last` directive is case-insensitive and supports flexible whitespace.

> [!IMPORTANT]
> Last known values are stored in memory only. They're lost when the pod restarts and aren't shared across replicas.

Last known value is supported in map, filter, and branch rules. It isn't available in window (accumulate) rules.

## Default values

Use the `?? <default>` suffix on an input to provide a fallback value when the field is missing. Supported default types: integer, float, boolean, string, and null.

> [!NOTE]
> The `?? <default>` syntax is available in data flow graphs only. It isn't supported in data flow `builtInTransformation` inputs.

| Input | Fallback |
|-------|----------|
| `temperature ?? 0` | Integer 0 |
| `status ?? "unknown"` | String "unknown" |
| `threshold ?? 98.6` | Float 98.6 |
| `enabled ?? true` | Boolean true |

### Combine last known value and default

You can combine `? $last` and `?? <default>`. The runtime checks the current message first, then the last known value, then the default. If you use `?? <default>` without `? $last`, the runtime checks the current message and then the default directly.

| Input | Evaluation order |
|-------|-----------------|
| `temperature ?? 0` | Current value, then default (0) |
| `temperature ? $last ?? 0` | Current value, then last known, then default (0) |

Default values are supported in map, filter, and branch rules. They aren't available in window (accumulate) rules.

## Data types

| Type | Description | Example |
|------|-------------|---------|
| Int | 64-bit signed integer | `42`, `-7` |
| Float | 64-bit floating point | `3.14`, `-0.5` |
| String | UTF-8 text | `"hello"` |
| Bool | Boolean | `true`, `false` |
| Tuple | Array of primitive values | `(1, 2, 3)` |
| Empty | Missing or null value | `()` |
| JSON | JSON object passed through | (can't be used in expressions) |

JSON objects and arrays are preserved as-is when fields are copied without an expression, but they can't be used as inputs to expression evaluation.

## Feature support by transform type

| Feature | Map | Filter | Branch | Window (accumulate) |
|---------|-----|--------|--------|---------------------|
| Positional variables | Yes | Yes | Yes | Yes |
| Operators | Yes | Yes | Yes | Yes |
| Built-in functions | Yes | Yes | Yes | Yes |
| Aggregation functions | No | No | No | Yes |
| `$metadata` access | Yes | Yes | Yes | No |
| `$context` enrichment | Yes | Yes | Yes | No |
| `? $last` | Yes | Yes | Yes | No |
| `?? <default>` ¹ | Yes | Yes | Yes | No |
| `str::regex_matches` / `str::regex_replace` ¹ | Yes | Yes | Yes | No |
| Wildcards | Yes | No | No | No |

¹ Available in data flow graphs only. Not supported in data flow `builtInTransformation` inputs.

## Dot notation and escaping

Dot notation is widely used to reference nested fields. A standard dot-notation sample looks like this:

```yaml
- inputs:
  - Person.Address.Street.Number
```

In a data flow, a path described by dot notation might include strings and some special characters without needing escaping:

```yaml
- inputs:
  - Person.Date of Birth
```

In other cases, escaping is necessary:

```yaml
- inputs:
  - nsu=http://opcfoundation.org/UA/Plc/Applications;s=RandomSignedInt32
```

The previous example, among other special characters, contains dots within the field name. Without escaping, the field name would serve as a separator in the dot notation itself.

While a data flow parses a path, it treats only two characters as special:

* Dots (`.`) act as field separators.
* Single quotation marks, when placed at the beginning or the end of a segment, start an escaped section where dots aren't treated as field separators.

Any other characters are treated as part of the field name. This flexibility is useful in formats like JSON, where field names can be arbitrary strings.

The path definition must also adhere to the rules of YAML. When a character with special meaning is included in the path, proper quoting is required in the configuration. Consult the YAML documentation for precise rules. Here are some examples that demonstrate the need for careful formatting:

```yaml
- inputs:
  - ':Person:.:name:'   # ':' cannot be used as the first character without single quotation marks
  - '100 celsius.hot'   # numbers followed by text would not be interpreted as a string without single quotation marks
```

### Escaping

The primary function of escaping in a dot-notated path is to accommodate the use of dots that are part of field names rather than separators:

```yaml
- inputs:
  - 'Payload."Tag.10".Value'
```

The outer single quotation marks (`'`) are necessary because of YAML syntax rules, which allow the inclusion of double quotation marks within the string.

In this example, the path consists of three segments: `Payload`, `Tag.10`, and `Value`.

### Escaping rules in dot notation

* **Escape each segment separately:** If multiple segments contain dots, those segments must be enclosed in double quotation marks. Other segments can also be quoted, but it doesn't affect the path interpretation:

  
  ```yaml
  - inputs:
    - 'Payload."Tag.10".Measurements."Vibration.$12".Value'
  ```

    
* **Proper use of double quotation marks:** Double quotation marks must open and close an escaped segment. Any quotation marks in the middle of the segment are considered part of the field name:

  
  ```yaml
  - inputs:
    - 'Payload.He said: "Hello", and waved'
  ```

  This example defines two fields: `Payload` and `He said: "Hello", and waved`. When a dot appears under these circumstances, it continues to serve as a separator:

  
  ```yaml
  - inputs:
    - 'Payload.He said: "No. It is done"'
  ```

  
  In this case, the path is split into the segments `Payload`, `He said: "No`, and `It is done"` (starting with a space).
    
### Segmentation algorithm

* If the first character of a segment is a quotation mark, the parser searches for the next quotation mark. The string enclosed between these quotation marks is considered a single segment.
* If the segment doesn't start with a quotation mark, the parser identifies segments by searching for the next dot or the end of the path.

## Wildcards

In many scenarios, the output record closely resembles the input record, with only minor modifications required. When you deal with records that contain numerous fields, manually specifying mappings for each field can become tedious. Wildcards simplify this process by allowing for generalized mappings that can automatically apply to multiple fields.

Let's consider a basic scenario to understand the use of asterisks in mappings:

```yaml
- inputs:
  - '*'
  output: '*'
```

This configuration shows a basic mapping where every field in the input is directly mapped to the same field in the output without any changes. The asterisk (`*`) serves as a wildcard that matches any field in the input record.

Here's how the asterisk (`*`) operates in this context:

* **Pattern matching**: The asterisk can match a single segment or multiple segments of a path. It serves as a placeholder for any segments in the path.
* **Field matching**: During the mapping process, the algorithm evaluates each field in the input record against the pattern specified in the `inputs`. The asterisk in the previous example matches all possible paths, effectively fitting every individual field in the input.
* **Captured segment**: The portion of the path that the asterisk matches is referred to as the `captured segment`.
* **Output mapping**: In the output configuration, the `captured segment` is placed where the asterisk appears. This means that the structure of the input is preserved in the output, with the `captured segment` filling the placeholder provided by the asterisk.

Another example illustrates how wildcards can be used to match subsections and move them together. This example effectively flattens nested structures within a JSON object.

Original JSON:

```json
{
  "ColorProperties": {
    "Hue": "blue",
    "Saturation": "90%",
    "Brightness": "50%",
    "Opacity": "0.8"
  },
  "TextureProperties": {
    "type": "fabric",
    "SurfaceFeel": "soft",
    "SurfaceAppearance": "matte",
    "Pattern": "knitted"
  }
}
```

Mapping configuration that uses wildcards:

```yaml
- inputs:
  - 'ColorProperties.*'
  output: '*'

- inputs:
  - 'TextureProperties.*'
  output: '*'
```

Resulting JSON:

```json
{
  "Hue": "blue",
  "Saturation": "90%",
  "Brightness": "50%",
  "Opacity": "0.8",
  "type": "fabric",
  "SurfaceFeel": "soft",
  "SurfaceAppearance": "matte",
  "Pattern": "knitted"
}
```

### Wildcard placement

When you place a wildcard, you must follow these rules:

* **Single asterisk per data reference:** Only one asterisk (`*`) is allowed within a single data reference.
* **Full segment matching:** The asterisk must always match an entire segment of the path. It can't be used to match only a part of a segment, such as `path1.partial*.path3`.
* **Positioning:** The asterisk can be positioned in various parts of a data reference:
  * **At the beginning:** `*.path2.path3` - Here, the asterisk matches any segment that leads up to `path2.path3`.
  * **In the middle:** `path1.*.path3` - In this configuration, the asterisk matches any segment between `path1` and `path3`.
  * **At the end:** `path1.path2.*` - The asterisk at the end matches any segment that follows after `path1.path2`.
* The path containing the asterisk must be enclosed in single quotation marks (`'`).

### Multi-input wildcards

Original JSON:

```json
{
  "Saturation": {
    "Max": 0.42,
    "Min": 0.67,
  },
  "Brightness": {
    "Max": 0.78,
    "Min": 0.93,
  },
  "Opacity": {
    "Max": 0.88,
    "Min": 0.91,
  }
}
```

Mapping configuration that uses wildcards:

```yaml
- inputs:
  - '*.Max'   # - $1
  - '*.Min'   # - $2
  output: 'ColorProperties.*'
  expression: ($1 + $2) / 2
```

Resulting JSON:

```json
{
  "ColorProperties" : {
    "Saturation": 0.54,
    "Brightness": 0.85,
    "Opacity": 0.89 
  }    
}
```

If you use multi-input wildcards, the asterisk (`*`) must consistently represent the same `Captured Segment` across every input. For example, when `*` captures `Saturation` in the pattern `*.Max`, the mapping algorithm expects the corresponding `Saturation.Min` to match with the pattern `*.Min`. Here, `*` is substituted by the `Captured Segment` from the first input, guiding the matching for subsequent inputs.

Consider this detailed example:

Original JSON:

```json
{
  "Saturation": {
    "Max": 0.42,
    "Min": 0.67,
    "Mid": {
      "Avg": 0.51,
      "Mean": 0.56
    }
  },
  "Brightness": {
    "Max": 0.78,
    "Min": 0.93,
    "Mid": {
      "Avg": 0.81,
      "Mean": 0.82
    }
  },
  "Opacity": {
    "Max": 0.88,
    "Min": 0.91,
    "Mid": {
      "Avg": 0.89,
      "Mean": 0.89
    }
  }
}
```

Initial mapping configuration that uses wildcards:

```yaml
- inputs:
  - '*.Max'    # - $1
  - '*.Min'    # - $2
  - '*.Avg'    # - $3
  - '*.Mean'   # - $4
  output: 'ColorProperties.*'
  expression: ($1, $2, $3, $4)
```

This initial mapping tries to build an array (for example, for `Opacity`: `[0.88, 0.91, 0.89, 0.89]`). This configuration fails because:

* The first input `*.Max` captures a segment like `Saturation`.
* The mapping expects the subsequent inputs to be present at the same level:
  * `Saturation.Max`
  * `Saturation.Min`
  * `Saturation.Avg`
  * `Saturation.Mean`

Because `Avg` and `Mean` are nested within `Mid`, the asterisk in the initial mapping doesn't correctly capture these paths.

Corrected mapping configuration:

```yaml
- inputs:
  - '*.Max'        # - $1
  - '*.Min'        # - $2
  - '*.Mid.Avg'    # - $3
  - '*.Mid.Mean'   # - $4
  output: 'ColorProperties.*'
  expression: ($1, $2, $3, $4)
```

This revised mapping accurately captures the necessary fields. It correctly specifies the paths to include the nested `Mid` object, which ensures that the asterisks work effectively across different levels of the JSON structure.

### Specialization and second rules

When you use the previous example from multi-input wildcards, consider the following mappings that generate two derived values for each property:

```yaml
- inputs:
  - '*.Max'   # - $1
  - '*.Min'   # - $2
  output: 'ColorProperties.*.Avg'
  expression: ($1 + $2) / 2

- inputs:
  - '*.Max'   # - $1
  - '*.Min'   # - $2
  output: 'ColorProperties.*.Diff'
  expression: $1 - $2
```

This mapping is intended to create two separate calculations (`Avg` and `Diff`) for each property under `ColorProperties`. This example shows the result:

```json
{
  "ColorProperties": {
    "Saturation": {
      "Avg": 0.54,
      "Diff": 0.25
    },
    "Brightness": {
      "Avg": 0.85,
      "Diff": 0.15
    },
    "Opacity": {
      "Avg": 0.89,
      "Diff": 0.03
    }
  }
}
```

Here, the second mapping definition on the same inputs acts as a *second rule* for mapping.

Now, consider a scenario where a specific field needs a different calculation:

```yaml
- inputs:
  - '*.Max'   # - $1
  - '*.Min'   # - $2
  output: 'ColorProperties.*'
  expression: ($1 + $2) / 2

- inputs:
  - Opacity.Max   # - $1
  - Opacity.Min   # - $2
  output: ColorProperties.OpacityAdjusted
  expression: ($1 + $2 + 1.32) / 2  
```

In this case, the `Opacity` field has a unique calculation. Two options to handle this overlapping scenario are:

- Include both mappings for `Opacity`. Because the output fields are different in this example, they wouldn't override each other.
- Use the more specific rule for `Opacity` and remove the more generic one.

Consider a special case for the same fields to help decide the right action:

```yaml
- inputs:
  - '*.Max'   # - $1
  - '*.Min'   # - $2
  output: 'ColorProperties.*'
  expression: ($1 + $2) / 2

- inputs:
  - Opacity.Max
  - Opacity.Min
  output:   
```

An empty `output` field in the second definition implies not writing the fields in the output record (effectively removing `Opacity`). This setup is more of a `Specialization` than a `Second Rule`.

Resolution of overlapping mappings by data flows:

* The evaluation progresses from the top rule in the mapping definition.
* If a new mapping resolves to the same fields as a previous rule, the following conditions apply:
  * A `Rank` is calculated for each resolved input based on the number of segments the wildcard captures. For instance, if the `Captured Segments` are `Properties.Opacity`, the `Rank` is 2. If it's only `Opacity`, the `Rank` is 1. A mapping without wildcards has a `Rank` of 0.
  * If the `Rank` of the latter rule is equal to or higher than the previous rule, a data flow treats it as a `Second Rule`.
  * Otherwise, the data flow treats the configuration as a `Specialization`.

For example, the mapping that directs `Opacity.Max` and `Opacity.Min` to an empty output has a `Rank` of 0. Because the second rule has a lower `Rank` than the previous one, it's considered a specialization and overrides the previous rule, which would calculate a value for `Opacity`.

### Wildcards in contextualization datasets

Contextualization datasets can be used with wildcards. Consider a dataset named `position` that contains the following record:

```json
{
  "Position": "Analyst",
  "BaseSalary": 70000,
  "WorkingHours": "Regular"
}
```

In an earlier example, we used a specific field from this dataset:

```yaml
- inputs:
  - $context(position).BaseSalary
  output: Employment.BaseSalary
```

This mapping copies `BaseSalary` from the context dataset directly into the `Employment` section of the output record. If you want to automate the process and include all fields from the `position` dataset into the `Employment` section, you can use wildcards:

```yaml
- inputs:
  - '$context(position).*'
  output: 'Employment.*'
```

This configuration allows for a dynamic mapping where every field within the `position` dataset is copied into the `Employment` section of the output record:

```json
{
    "Employment": {      
      "Position": "Analyst",
      "BaseSalary": 70000,
      "WorkingHours": "Regular"
    }
}
```

## Contextualization datasets

Contextualization datasets let mappings integrate extra data from external databases. Use the `$context(datasetName)` prefix to reference fields from a dataset. For example, `$context(position).BaseSalary` reads the `BaseSalary` field from a dataset named `position`.

For details on configuring contextualization datasets, see [Enrich data by using data flows](concept-dataflow-enrich.md) and [Enrich with external data in data flow graphs](howto-dataflow-graphs-enrich.md).

## Related content

- [Map data by using data flows](concept-dataflow-mapping.md)
- [Filter data in a data flow](howto-dataflow-filter.md)
- [Transform data with map in data flow graphs](howto-dataflow-graphs-map.md)
- [Filter and route data in data flow graphs](howto-dataflow-graphs-filter-route.md)
- [Aggregate data over time](howto-dataflow-graphs-window.md)
- [Enrich with external data](howto-dataflow-graphs-enrich.md)
