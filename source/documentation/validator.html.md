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
// withDate joins birthdayYear, birthdayMonth and birthdayDay into single birthday
def createParams = Params(params).withDate("birthday")

def createForm = validation(createParams,
  paramKey("name") is checkAll(minLength(5), maxLength(20)),
  paramKey("birthday") is required & dateFormat,
  paramKey("point") is numeric
)

def createStrongParameters = Seq(
  "name" -> ParamType.String,
  "birthday" -> ParamType.LocalDate,
  "point" -> ParamType.Int
)

def create = {
  if (createForm.validate) {
    val id = Member.createNewModel(createParams.permit(createStrongParameters))
    redirect(s"/members/${id}")
  } else {
    render("/members/new")
  }
  // or using #fold
}
```

[/common/src/main/scala/skinny/ParamType.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/common/src/main/scala/skinny/ParamType.scala)

[/common/src/main/scala/skinny/StrongParameters.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/common/src/main/scala/skinny/StrongParameters.scala)

[/framework/src/main/scala/skinny/controller/feature/ValidationFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/framework/src/main/scala/skinny/controller/feature/ValidationFeature.scala)

[/validator/src/main/scala/skinny/validator/ValidatorLike.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/validator/src/main/scala/skinny/validator/ValidatorLike.scala)

<hr/>
### Creating Custom Validators

Just implement `ValidationRule` trait.

[validator/src/main/scala/skinny/validator/ValidationRule.scala](https://github.com/skinny-framework/skinny-framework/blob/master/validator/src/main/scala/skinny/validator/ValidationRule.scala)

You can find many samples here:

[validator/src/main/scala/skinny/validator/BuiltinValidationRules.scala](https://github.com/skinny-framework/skinny-framework/blob/master/validator/src/main/scala/skinny/validator/BuiltinValidationRules.scala)
