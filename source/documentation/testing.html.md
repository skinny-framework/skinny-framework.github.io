---
title: Testing - Skinny Framework
---

## Testing

<hr/>
### Testability is very important
<hr/>

Skinny Framework puts emphasis on testable application development and provides toolkit for testing.

<hr/>
### How to run tests
<hr/>

Simply use skinny command or sbt directly.

```
# run all the tests
./skinny test

# run single test
./skinny testOnly model.MemberSpec

# run only failed tests
./skinny testQuick

# run multiple tests under controller package when changes are detected
./skinny ~testOnly controller.*Spec
```

<hr/>
### ORM Tests
<hr/>

Here is some examples:

https://github.com/skinny-framework/skinny-framework/tree/develop/orm/src/test/scala/blog

```scala
package model

import org.joda.time._
import org.scalatest._
import org.scalatest.fixture.FunSpec
import skinny._
import skinny.test._
import scalikejdbc._
import scalikejdbc.scalatest._

class MemberSpec extends FunSpec with AutoRollback with Matchers with DBSettings {

  override def fixture(implicit session: DBSession) {
    // do fixtures stuff
  }

  describe("Member") {
    it("should find all entities") { implicit session =>
      Member.findAll().size should be >(0)
    }
  }
}
```

NOTICE: `AllRollback` feature is supported by ScalikeJDBC. And this trait is incompatible with ScalaTest 2.x. Furthermore, Scalatra 2.2.x is also incompatible with ScalaTest 2.x. If you'd like to use ScalaTest 2.x, use Scalatra 2.3.0.RC1 and ScalikeJDBC 2.0.0-SNAPSHOT for now (This situation will be fixed in Skinny 1.1).

<hr/>
### Mocked Controller Tests
<hr/>

Skinny provides `MockController` trait for light-weight controller tests.

```scala
package controller

class RootController extends ApplicationController {
  def index = render("/root/index")
}

import org.scalatest._
import skinny.DBSettings
import skinny.test.MockController

class RootControllerSpec extends FunSpec with Matchers with DBSettings {

  describe("RootController") {
    it("shows top page") {
      val controller = new RootController with MockController
      controller.index
      controller.contentType should equal("text/html; charset=utf-8")
      controller.renderCall.map(_.path) should equal(Some("/root/index"))
    }
  }

}
```

Be aware of following points when you use `MockController`:

<hr/>
#### MockController cannot handle org.scalatra.HaltException

HaltExcpetion is very exceptional operation by Scalatra. HaltException is not an Exception but a Throwable. Furthermore, it mutes all the stack traces.

When you call `halt` method or `redirect` method, HaltException will be thrown.

We recommend you using `redirect302` instead because it is excellent with `MockController` testing.

<hr/>
### Integration Tests
<hr/>

Scalatra provides a great test toolkit with embedded Jetty server and easy-to-use DSL. Of course, you can use them without any problem.

Below is an integration test example with scalatra-test.

```scala
package integrationtest

import org.scalatra.test.scalatest._
import skinny.DBSettings 
import skinny.test.SkinnyTestSupport
import _root_.controller.Controllers
import org.scalatest._

class IntegrationTestSpec extends ScalatraFlatSpec with Matchers with SkinnyTestSupport with  DBSettings {
  addFilter(Controllers.members, "/*")

  it should "show index page" in {
    withSession("userId" -> "Alice") {
      get("/members") { 
        status should equal(200) 
        body should contain("something")
      }
    }
  }
}
```

<hr/>
### Coverage Report
<hr/>

<p class="alert alert-warning">
<b>WARNING:</b> There is a known issue that scoverage doesn't work perfectly with Skinny ORM.
Now we're working on this issue with Scoverage team.
<br/>
<a href="https://github.com/skinny-framework/skinny-framework/issues/97">
https://github.com/skinny-framework/skinny-framework/issues/97
</a>
</p>

If you need a code coverage report, use `scoverage:test` instead. 

https://github.com/scoverage/sbt-scoverage

```
./skinny test:coverage
```

<hr/>
### More Examples
<hr/>

It's the fastest way to learn is seeing generated tests by scaffold command.

And also some examples here may be helpful for you:

[example/src/test/scala](https://github.com/skinny-framework/skinny-framework/tree/develop/example/src/test/scala)

See also: [FactoryGirl](factory-girl.html)
