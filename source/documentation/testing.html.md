---
title: Testing - Skinny Framework
---

## Testing

<hr/>
### Testability is much important
<hr/>

You can use Scalatra's great test support. Some optional feature is provided by skinny-test library.

```java
class ControllerSpec extends ScalatraFlatSpec with SkinnyTestSupport {
  addFilter(MembersController, "/*")

  it should "show index page" in {
    withSession("userId" -> "Alice") {
      get("/members") { status should equal(200) }
    }
  }
}
```

<hr/>
You can see some examples here:

[example/src/test/scala](https://github.com/skinny-framework/skinny-framework/tree/master/example/src/test/scala)

See also: [FactoryGirl](factory-girl.html)
