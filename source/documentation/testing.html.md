---
title: Testing - Skinny Framework
---

## Testing

<hr/>
### Testability is very important
<hr/>

You can use Scalatra's great test support with Skinny. Some optional features are provided by the skinny-test library.

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
### How to run tests

Simply use skinny command or sbt directly.

```
./skinny test
./skinny test-only models.MemberSpec
```

If you need a code coverage report, use `scoverage:test` instead. 

https://github.com/scoverage/sbt-scoverage

```
./skinny scoverage:test
```

WARNING: There is a known issue that scoverage doesn't work perfectly with Skinny ORM.


<hr/>
You can see some examples here:

[example/src/test/scala](https://github.com/skinny-framework/skinny-framework/tree/master/example/src/test/scala)

See also: [FactoryGirl](factory-girl.html)
