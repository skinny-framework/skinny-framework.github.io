---
title: Validator - Skinny Framework
---

## Validator

<hr/>
### Portable Validator

skinny-validator is portable, so you can use skinny-validator with Play2, Scalatra (without Skinny) and any other web app frameworks. Furthermore, you can use it in not only web apps but also any other applications (batch operation, cli and so on).

You can see simple usage of skinny-validator here:

[validator/src/test/scala/UsageSpec.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/validator/src/test/scala/UsageSpec.scala)

<hr/>
### Creating Custom Validators

The way to create new validation rule is pretty simple:

- extend `skinny.validator.ValidationRule` trait
- implement `def name: String` and `def isValid(Any): Boolean`

That's all.

The following is an example from built-in validations.

```java
import skinny.validator._

object required extends required(true)

case class required(trim: Boolean = true) extends ValidationRule {
  def name = "required"
  def isValid(v: Any) = !isEmpty(v) && {
    if (trim) v.toString.trim.length > 0
    else v.toString.length > 0
  }
}
```
Then you can use it like this:

```java
val validator = Validator(
  param("name" -> "Alice") is required,
  param("description" -> "   ") is required(false)
)
validator.hasErrors // false
```

You can see more examples here:

[validator/src/main/scala/skinny/validator/BuiltinValidationRules.scala](https://github.com/skinny-framework/skinny-framework/blob/master/validator/src/main/scala/skinny/validator/BuiltinValidationRules.scala)

<hr/>
### Built-in Validation Rules

In most of cases, built-in validators are useful.

[validator/src/main/scala/skinny/validator/BuiltinValidationRules.scala](https://github.com/skinny-framework/skinny-framework/blob/master/validator/src/main/scala/skinny/validator/BuiltinValidationRules.scala)

Usage:

[validator/src/test/scala/skinny/validator](https://github.com/skinny-framework/skinny-framework/tree/master/validator/src/test/scala/skinny/validator)

Basic usage is combining validation rules with `&`. If a failure is found, rest of them will be skipped.

`checkAll` executes all the validations even if some of them already failed.

The following is an example with Skinny Framework:

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

See also:

[/common/src/main/scala/skinny/ParamType.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/common/src/main/scala/skinny/ParamType.scala)

[/common/src/main/scala/skinny/StrongParameters.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/common/src/main/scala/skinny/StrongParameters.scala)

[/framework/src/main/scala/skinny/controller/feature/ValidationFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/framework/src/main/scala/skinny/controller/feature/ValidationFeature.scala)

[/validator/src/main/scala/skinny/validator/ValidatorLike.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/validator/src/main/scala/skinny/validator/ValidatorLike.scala)


