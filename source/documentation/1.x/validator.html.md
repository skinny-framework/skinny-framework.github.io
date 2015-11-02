---
title: Validator - Skinny Framework
---

## Validator

<hr/>
### Readable and Customizable DSL
<hr/>

skinny-validator is portable, so you can use skinny-validator with Play2, Scalatra (without Skinny) and any other web app frameworks. Furthermore, you can use it in not only web apps but also any other applications (batch operation, cli and so on).

You can see simple usage of skinny-validator here:

[validator/src/test/scala/UsageSpec.scala](https://github.com/skinny-framework/skinny-framework/blob/master/validator/src/test/scala/UsageSpec.scala)

<hr/>
### Creating New Validation Rule
<hr/>

The way to create new validation rule is pretty simple:

- extend `skinny.validator.ValidationRule` trait
- implement `def name: String` and `def isValid(Any): Boolean`

That's all.

The following is an example from the built-in validations.

```scala
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

```scala
val validator = Validator(
  param("name" -> null) is required
)
validator.hasErrors // true

val errorsForName: Seq[Error] = validator.errors.get("name")
val error: Error = errorsForName.head
error.name // -> "required"
error.messageParams // -> List("name")
```

A validation rule which accepts value when using such as `minLength(6)` is like this:

```scala
case class minLength(min: Int) extends ValidationRule {
  def name = "minLength"
  override def messageParams = Seq(min.toString)

  def isValid(v: Any) = isEmpty(v) || {
    toHasSize(v).map(_.size >= min).getOrElse(v.toString.length >= min)
  }
}

val validator = Validator(
  param("name" -> "xxxx") is checkAll(required, minLength(6)),
  param("password" -> "xxxx") is required & minLength(6)
)
```

Basic usage involves combining validation rules with `&`. If a failure is found, by default the rest of the validation rules will be skipped. `checkAll` executes all the validations even if some of them already failed.

<hr/>
### Built-in Validation Rules
<hr/>

The built-in validators are good enough to cover most common cases.

[validator/src/main/scala/skinny/validator/BuiltinValidationRules.scala](https://github.com/skinny-framework/skinny-framework/blob/master/validator/src/main/scala/skinny/validator/BuiltinValidationRules.scala)

[validator/src/test/scala/skinny/validator](https://github.com/skinny-framework/skinny-framework/tree/master/validator/src/test/scala/skinny/validator)


<hr/>
### Validator & MapValidator
<hr/>

skinny-validator provides `Validator` and `MapValidator`. You already see `Validator` in above code. This one accepts parameters when defining validation rules.

`MapValidator` is another one which accepts `Map[String, Any]` object as parameters. Usually `MapValidator` is more useful in web applications.

```scala
val params = Map("name" -> "Alice", "age" -> 20)

val validator = MapValidator(params)(
  paramKey("name") is required,
  paramKey("age") is required & numeric
)
```

<hr/>
### Error Messages
<hr/>

skinny-validator's `Error` looks like this:

```scala
val error = validator.errors.head
error.name // -> required
error.messageParams // -> List("name")
```

`skinny.validator.Messages` loads error messages from *.conf or *.properties.

This is `src/main/resources/messages.conf` example:

```
error {
  required="{0} is required"
  minLength="{0} length must be greater than or equal to {1}"
}
```

Now `Messages` can load error messages for validation errors named "required" or "minLength". The name comes from `ValidationRule#name`.

```scala
val messages = Messages.loadFromConfig()
// val messages = Messages.loadFromConfig("messages2") // loads messages2.conf
// val messages = Messages.loadFromProperties() // loads messages.properties
// val messages_ja = Messages.loadFromConfig(locale = Option(locale)) // loads messages_ja.conf

messages.get("required", Seq("name")) 
// -> Some("name is required")

messages.get("minLength", Seq("password", 6)) 
// -> Some("password length must be greater than or equal to 6")
```

<hr/>
### How It Works in Skinny apps
<hr/>

You can easily understand how skinny-validator works in Skinny apps.

[framework/src/main/scala/skinny/controller/feature/ValidationFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/master/framework/src/main/scala/skinny/controller/feature/ValidationFeature.scala)

The following is an example with Skinny Framework:

```scala
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
    // error messages is set as "errorMessages" and "keyAndErrorMessages"
    render("/members/new")
  }
  // or using #fold
}
```

See also:

[common/src/main/scala/skinny/ParamType.scala](https://github.com/skinny-framework/skinny-framework/blob/master/common/src/main/scala/skinny/ParamType.scala)

[common/src/main/scala/skinny/StrongParameters.scala](https://github.com/skinny-framework/skinny-framework/blob/master/common/src/main/scala/skinny/StrongParameters.scala)


