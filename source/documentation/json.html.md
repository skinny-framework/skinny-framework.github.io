---
title: Working with JSON - Skinny Framework
---

## Working with JSON

<hr/>
### JSONStringOps

`SkinnyController` provides the following useful methods from `JSONStringOps` trait by default.

- def toJSON(v: Any): JValue
- def toJSONString(v: Any, underscoreKeys: Boolean = true): String 
- def toPrettyJSONString(v: Any, underscoreKeys: Boolean = true): String
- def fromJSONString[A](json: String)(implicit mf: Manifest[A]): Option[A] 

[framework/src/main/scala/skinny/util/JSONStringOps.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/framework/src/main/scala/skinny/util/JSONStringOps.scala)

The following methods come from `JSONFeature` trait.

- def responseAsJSON(entity: Any, charset: Option[String] = Some("utf-8"), prettify: Boolean = false): String

[framework/src/main/scala/skinny/controller/feature/JSONFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/master/framework/src/main/scala/skinny/controller/feature/JSONFeature.scala)


```java
import skinny.util.JSONStringOps._

case class UserResponse(user: User)
case class User(name: String, age: Int, email: String, 
  isAlive: Boolean = false, friend: Option[User] = None)

val jsonString =
  """{
    |  "user": {
    |    "name" : "toto",
    |    "age" : 25,
    |    "email" : "toto@jmail.com",
    |    "isAlive" : true,
    |    "friend" : {
    |      "name" : "tata",
    |      "age" : 20,
    |      "email" : "tata@coldmail.com"
    |    }
    |  }
    |}
  """.stripMargin

val userResponse: Option[UserResponse] = fromJSONString[UserResponse](jsonString)

val jsonString2 = userResponse.map(r => toJSONString(r))
```

If you need more complex operations, use [json4s](https://github.com/json4s/json4s) directly.

