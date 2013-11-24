---
title: Validator - Skinny Framework
---

## Validator

<hr/>
### Built-in Validation Rules

In most of cases, built-in validators are useful.

[validator/src/main/scala/skinny/validator/BuiltinValidationRules.scala](https://github.com/skinny-framework/skinny-framework/blob/master/validator/src/main/scala/skinny/validator/BuiltinValidationRules.scala)

Usage:

[validator/src/test/scala/skinny/validator](https://github.com/skinny-framework/skinny-framework/tree/master/validator/src/test/scala/skinny/validator)

Basic usage is combining validation rules with `&`. If a failure is found, rest of them will be skipped.

`checkAll` executes all the validations even if some of them already failed.

```java
override def createForm = validation(createParams,
  paramKey("name") is checkAll(minLength(5), maxLength(20)),
  paramKey("birthday") is required & dateFormat
)
```

<hr/>
### Creating Custom Validators

Just implement `ValidationRule` trait.

[validator/src/main/scala/skinny/validator/ValidationRule.scala](https://github.com/skinny-framework/skinny-framework/blob/master/validator/src/main/scala/skinny/validator/ValidationRule.scala)

You can find many samples here:

[validator/src/main/scala/skinny/validator/BuiltinValidationRules.scala](https://github.com/skinny-framework/skinny-framework/blob/master/validator/src/main/scala/skinny/validator/BuiltinValidationRules.scala)
