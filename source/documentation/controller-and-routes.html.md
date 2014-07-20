---
title: Controller & Routes - Skinny Framework
---

## Controller & Routes
<hr/>

Skinny's routing mechanism and controller layer on MVC architecture can be thought of as a **rich Scalatra**. 

Skinny's extensions provide you with much simpler and richer syntax. Of course, if you need to use Scalatra's API directly, Skinny never bothers you.

![Scalatra](images/scalatra.png)

`SkinnyController` is a trait which extends `ScalatraFilter` and includes various useful components out-of-the-box.

```scala
// src/main/scala/controller/MembersController.scala
class MembersController extends SkinnyController {
  protectFromForgery() // CSRF protection enabled

  def index = {
    // set 'members' in the request scope, then you can use it in views
    set("members" -> Member.findAll())
    render("/members/index")
  }

  def newOne = render("/members/new")

  def createForm = validation(params,
    paramKey("name") is required & minLength(2),
    paramKey("countryId") is numeric
  )

  def createFormParams = params.permit(
    "name" -> ParamType.String, 
    "countryId" -> ParamType.Long)

  def create = if (createForm.validate()) {
    Member.createWithPermittedAttributes(createFormParams)
    redirect("/members")
  } else {
    render("/members/new")
  }

  // searches both query params and path params
  def show = params.getAs[Long]("id").map { id =>
    Member.findById(id).map { member =>
      set("member" -> member)
    }.getOrElse haltWithBody(404)
  }.getOrElse haltWithBody(404)

}

// src/main/scala/controller/Controllers.scala
object Controllers {
  object members extends MembersController with Routes {
    val indexUrl = get("/members/?")(index).as('index)
    val newUrl = get("/members/new")(newOne).as('new)
    val createUrl = post("/members/?")(create).as('create)
    val showUrl = get("/members/:id")(show).as('show)
  }
}

// src/main/scala/ScalatraBootstrap.scala
class ScalatraBootstrap exntends SkinnyLifeCycle {
  override def initSkinnyApp(ctx: ServletContext) {
    // register routes
    Controllers.members.mount(ctx)
  }
}
```

`#render` expects `src/main/webapp/WEB-INF/views/members/index.html.ssp` by default.

```
render("/members/index")
```

```
<!-- src/main/webapp/WEB-INF/views/members/index.html.ssp -->
<%@val members: Seq[Member]%>
<ul>
#for (member <- members)
  <li>${member.name}</li>
#end
<ul>
```

<hr/>
### Reverse Routes
<hr/>

You can use Scalatra's reverse routes.

http://www.scalatra.org/2.2/guides/http/reverse-routes.html

In controllers:

```scala
class MembersController extends SkinnyController {
  def oldPage = redirect(url(Controllers.members.indexUrl))
}

object Controllers {
  object members extends MembersController with Routes {
    val indexUrl = get("/members/?")(index).as('index)
    val showUrl = get("/members/:id")(show).as('show)
  }
}
```

In views:

```
// Jade example
a(href={s.url(Controllers.members.showUrl, "id" -> member.id)}) Show detail

```

FYI: You can see more examples for SkinnyResource by generating scaffold views.


<hr/>
### SkinnyController & SkinnyServlet
<hr/>

There are the two controller base traits. SkinnyController is a ScalatraFilter. SkinnyServlet is a ScalatraServlet.

- [org.scalatra.ScalatraFilter]((http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraFilter))
- [org.scalatra.ScalatraServlet]((http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraServlet))

In general SkinnyController is more suitable for Skinny framework based applications.

However, if you really need to use a ScalatraServlet instead of a filter, use SkinnyServlet.

<hr/>
### SkinnyResource
<hr/>

SkinnyResource is a useful base trait for RESTful web services. SkinnyResource is very similar to Rails ActiveResource.

[Resource Routing: the Rails Default (Rails Routing from the Outside In — Ruby on Rails Guides)](http://guides.rubyonrails.org/routing.html#resource-routing-the-rails-default)

[https://github.com/rails/activeresource](https://github.com/rails/activeresource)

SkinnyResource is also useful as a controller sample. If you're a Skinny beginner, take a look at its code.

[framework/src/main/scala/skinny/controller/SkinnyResource.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/framework/src/main/scala/skinny/controller/SkinnyResource.scala)

SkinnyResourceActions has action methods for the resource and SkinnyResourceRoutes defines routings for the resource.
If you'd like to customize routings (e.g. use only creation and deletion), just mixin only SkinnyResourceActions and define routings by yourself.

You can see a SkinnyResource example using the scaffolding generator.

```
./skinny g scaffold members member name:String birthday:LocalDate
```

Then you get the following code. If you need to customize, override some parts of SkinnyResource:

[framework/src/main/scala/skinny/controller/SkinnyResource.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/framework/src/main/scala/skinny/controller/SkinnyResource.scala)

```scala
package controller

import skinny._
import skinny.validator._
import model.Member

object MembersController extends SkinnyResource {
  protectFromForgery() // CSRF protection

  override def model = Member // SkinnyModel for this controller
  override def resourcesName = "members"
  override def resourceName = "member"

  // parameters & validations for creation
  override def createParams = Params(params).withDate("birthday")
  override def createForm = validation(createParams,
    paramKey("name") is required & maxLength(512),
    paramKey("birthday") is required & dateFormat
  )
  override def createFormStrongParameters = Seq(
    "name" -> ParamType.String,
    "birthday" -> ParamType.LocalDate
  )

  // parameters & validations for modification
  override def updateParams = Params(params).withDate("birthday")
  override def updateForm = validation(updateParams,
    paramKey("name") is required & maxLength(512),
    paramKey("birthday") is required & dateFormat
  )
  override def updateFormStrongParameters = Seq(
    "name" -> ParamType.String,
    "birthday" -> ParamType.LocalDate
  )

}
```

Required view templates:

```
src/main/webapp/WEB-INF/views/members/
├── _form.html.ssp
├── edit.html.ssp
├── index.html.ssp
├── new.html.ssp
└── show.html.ssp
```

In this case, SkinnyResource provides the following URLs by default.

- GET /members
- GET /members/
- GET /members.xml
- GET /members.json
- GET /members/new
- POST /members
- POST /members.xml
- POST /members.json
- POST /members/
- GET /members/{id}
- GET /members/{id}.xml
- GET /members/{id}.json
- GET /members/{id}/edit
- POST /members/{id}.xml
- POST /members/{id}.json
- POST /members/{id}
- PUT /members/{id}.xml
- PUT /members/{id}.json
- PUT /members/{id}
- PATCH /members/{id}.xml
- PATCH /members/{id}.json
- PATCH /members/{id}
- DELETE /members/{id}.xml
- DELETE /members/{id}.json
- DELETE /members/{id}

<hr/>
### skinny.Skinny
<hr/>

skinny.Skinny provides getters for basic elements in view templates.

```
<%@val s: skinny.Skinny %>
```

[framework/src/main/scala/skinny/Skinny.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/framework/src/main/scala/skinny/Skinny.scala)

- params: Params
- multiParams: MultiParams
- flash: Flash
- errorMessages: Seq[String]
- keyAndErrorMessages: Map[String, Seq[String]]
- contextPath: String
- requestPath: String
- requestPathWithQueryString: String
- csrfKey: String
- csrfToken: String
- csrfMetaTag(s): String
- csrfHiddenInputTag: String
- i18n: I18n

<hr/>
### beforeAction/afterAction Filters
<hr/>

Scalatra has before/after filters by default, but we recommend Skinny users to use Skinny's beforeAction/afterAction filters.

The reason is that Scalatra's filters might affect other controllers that are defined further down in ScalatraBootstrap.scala and it's not easy to figure out where each controller's before/after affects completely.

So if you need filters that are similar to Rails filters, just use Skinny filters.

##### Scalatra's before/after filters

[/api/index.html#org.scalatra.ScalatraBase](http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase)

- before(transformers)(action)
- after(transformers)(action)

##### Skinny's beforeAction/afterAction filters

[/framework/src/main/scala/skinny/controller/feature/BeforeAfterActionFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/framework/src/main/scala/skinny/controller/feature/BeforeAfterActionFeature.scala)

```scala
class MembersController extends SkinnyController with Routes {

  // Scalatra filters
  before() { ... } // might affect other controllers
  after() { ... }

  // Skinny filters
  beforeAction(only = Seq('index, 'new)) {
    println("before")
  }
  afterAction(except = Seq('new)) {
    println("after")
  }

  //actions
  def index = ...
  def newInput = ...
  def edit = ...

  // routes
  get("/members/?")(index).as('index)      // before, after
  get("/members/new")(newInput).as('new)   // before
  get("/members/:id/edit")(edit).as('edit) // after

}
```

<hr/>
### SkinnyFilter
<hr/>

SkinnyFilter is our original filter to enable easily handling before/after/error for each controller. You can apply the same beforeAction/afterAction/error filters to several controllers by just mixing in SkinnyFilter-based traits.

Contrary to your expectations, Scalatra doesn't run all the handlers for after and error. Only the first one would be applied and the others are just ignored. We think it's difficult to be aware of this specification (it's not a bug but by design). So SkinnyFilter's before/after/error handlers are always applied. 

For instance, in skinny-blank-app, ErrrorPageFilter is applied to ApplicationController. 

```scala
trait ApplicationController extends SkinnyController
  with ErrorPageFilter {

}
```

ErrorPageFilter is as follows. It's pretty easy to customize such a filter (e.g. adding error notification) as follows.

```scala
trait ErrorPageFilter extends SkinnyRenderingFilter {
  // appends error filter in order
  addRenderingErrorFilter {
    case e: Throwable =>
      logger.error(e.getMessage, e)
      try {
        status = 500
        render("/error/500")
      } catch {
        case e: Exception => throw e
      }
  }
}
```

It just outputs error logging, set status as 500 and renders "/error/500.html.ssp" or similar templates. `SkinnyRenderingFilter` is a sub-trait of `SkinnyFilter`. `SkinnyFilter`'s response value is always ignored. But `SkinnyRenderingFilter` can return a response body like above.

The second example is `TxPerRequestFilter` which enables you to apply the open-session-in-view pattern to your apps.

```scala
trait TxPerRequestFilter extends SkinnyFilter with Logging {
  def cp: ConnectionPool = ConnectionPool.get()

  def begin = {
    val db = ThreadLocalDB.create(cp.borrow())
    db.begin()
  }

  // will handle exceptions occurred in controllers
  addErrorFilter { case e: Throwable =>
    Option(ThreadLocalDB.load()).foreach { db =>
      if (db != null && !db.isTxNotActive) using(db)(_.rollbackIfActive())
    }
  }

  def commit = {
    val db = ThreadLocalDB.load()
    if (db != null && !db.isTxNotActive) {
      using(db)(_.commit())
    }
  }

  beforeAction()(begin)
  afterAction()(commit)
}
```

<hr/>
### How to Do It? Examples
<hr/>

Basically, you will use Scalatra's DSL.

[http://www.scalatra.org/2.2/guides/](http://www.scalatra.org/2.2/guides/)

[http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase](http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase)

<hr/>
#### (Query/Form/Path) Parameters
<hr/>

#### params

```scala
val name: Option[String] = params.get("id")
val id: Option[Int] = params.getAs[Int]("id")
val id: Long = params.getAsOrElse[Long]("id", -1L)

val ids: Option[Seq[Int]] = multiParams.getAs[Int]("ids")
```

[/api/index.html#org.scalatra.ScalatraParams](http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraParams)

[/api/index.html#org.scalatra.ScalatraParamsImplicits$TypedParams](http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraParamsImplicits$TypedParams)

[/api/index.html#org.scalatra.ScalatraParamsImplicits$TypedMultiParams](http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraParamsImplicits$TypedMultiParams)

<hr/>
#### multiParams("splat")

```scala
get("/say/*/to/*") {
  // Matches "GET /say/hello/to/world"
  multiParams("splat") // == Seq("hello", "world")
}

get("/download/*.*") {
  // Matches "GET /download/path/to/file.xml"
  multiParams("splat") // == Seq("path/to/file", "xml")
}
```

[/api/index.html#org.scalatra.ScalatraBase](http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase)

[/guides/http/routes.html](http://www.scalatra.org/guides/http/routes.html)

<hr/>
#### multiParams("captures")

```scala
get("""^\/f(.*)/b(.*)""".r) {
  // Matches "GET /foo/bar"
  multiParams("captures") // == Seq("oo", "ar")
}
```

[/api/index.html#org.scalatra.ScalatraBase](http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase)

[/guides/http/routes.html](http://www.scalatra.org/guides/http/routes.html)

<hr/>
#### Cookies
<hr/>

```scala
def hello = {
  cookies += "name" -> "value"
  cookies -= "name"
}

def helloWithOptions = {
  implicit val options = CookieOptions(secure = true)
  cookies.set("name" -> "value")
  cookies.set("name" -> "value")(options)
}
```

[/api/index.html#org.scalatra.SweetCookies](http://www.scalatra.org/2.2/api/index.html#org.scalatra.SweetCookies)

[/api/org/scalatra/CookieOptions.html](http://www.scalatra.org/2.2/api/org/scalatra/CookieOptions.html)

<hr/>
#### Request/Response Headers
<hr/>

```scala
val v: Option[String] = request.header(name)
```

[/api/index.html#org.scalatra.servlet.RichRequest](http://www.scalatra.org/2.2/api/index.html#org.scalatra.servlet.RichRequest)

```scala
response.headers += "name" -> "value"
response.headers -= "name"
```

[/api/index.html#org.scalatra.servlet.RichResponse](http://www.scalatra.org/2.2/api/index.html#org.scalatra.servlet.RichResponse)

<hr/>
#### Session
<hr/>

```scala
val v: Any = session("name") // or session('name)
session += "name" -> "value"
session -= "name"
```

[/api/index.html#org.scalatra.servlet.RichSession](http://www.scalatra.org/2.2/api/index.html#org.scalatra.servlet.RichSession)

Even if you don't use sessions in your application code, Scalatra's Flash and CSRF protection features are using servlet sessions.
So your apps are not naturally stateless when using vanilla Scalatra.

We recommend you use SkinnySession to keep your Skinny apps stateless.
When you enable SkinnySession, these features also start using SkinnySession instead of Servlet session attributes.

ScalatraBootstrap.scala:

```scala
import scalikejdbc._
import skinny.session.SkinnySessionInitializer
class ScalatraBootstrap extends SkinnyLifeCycle {
  override def initSkinnyApp(ctx: ServletContext) {
    // Database queries will be increased
    GlobalSettings.loggingSQLAndTime = LoggingSQLAndTimeSettings(
      singleLineMode = true
    )
    ctx.mount(classOf[SkinnySessionInitializer], "/*")

    Controllers.root.mount(ctx)
    AssetsController.mount(ctx)
  }
}
```

controller/RootController.scala:

```scala
class RootController extends ApplicationController with SkinnySessionFilter {

  def index = {
    val v: Option[Any] = skinnySession.getAttribute("name")
    skinnySession.setAttribute("name", "value")
    skinnySession.deleteAttribute("name")
  }
}
```

DB migration file:

```sql
-- H2 Database compatible
create table skinny_sessions (
  id bigserial not null primary key,
  created_at timestamp not null,
  expire_at timestamp not null
);
create table servlet_sessions (
  jsession_id varchar(32) not null primary key,
  skinny_session_id bigint not null,
  created_at timestamp not null,
  foreign key(skinny_session_id) references skinny_sessions(id)
);
create table skinny_session_attributes (
  skinny_session_id bigint not null,
  attribute_name varchar(128) not null,
  attribute_value bytea,
  foreign key(skinny_session_id) references skinny_sessions(id)
);
alter table skinny_session_attributes add constraint
  skinny_session_attributes_unique_idx
  unique(skinny_session_id, attribute_name);
```

<hr/>
#### Flash
<hr/>

Notice: Flash uses servlet sessions by default. Be aware of sticky session mode.

```scala
flash(name) = value
flash += (name -> value)
flash.now += (name -> value)
```

[/guides/http/flash.html](http://www.scalatra.org/guides/http/flash.html)

[/api/index.html#org.scalatra.FlashMap](http://www.scalatra.org/2.2/api/index.html#org.scalatra.FlashMap)

<hr/>
#### Request Body
<hr/>

```scala
val body: String = request.body
val stream: InputStream = request.inputStream // raw HTTP POST data
```

[/api/index.html#org.scalatra.servlet.RichRequest](http://www.scalatra.org/2.2/api/index.html#org.scalatra.servlet.RichRequest)

<hr/>
#### File Upload
<hr/>

<div class="alert alert-warning small">
<b>WARNING:</b> Extend not SkinnyController but SkinnyServlet. You cannot use FileUploadFeature with SkinnyController.
</div>

```scala
import skinny.SkinnyServlet
import skinny.controller.feature.FileUploadFeature

// SkinnySerlvet!!!
class FilesController extends SkinnyServlet with FileUploadFeature {

  def upload = fileParams.get("file") match {
    case Some(file) =>
      Ok(file.get(), Map(
        "Content-Type"        -> (file.contentType.getOrElse("application/octet-stream")),
        "Content-Disposition" -> ("attachment; filename=\"" + file.name + "\"")
      ))
    case None =>
      BadRequest(displayPage(
        <p>
          Hey! You forgot to select a file.
        </p>))
  }
}
```

[/guides/formats/upload.html](http://www.scalatra.org/guides/formats/upload.html)

[/api/index.html#org.scalatra.fileupload.FileUploadSupport](http://www.scalatra.org/2.2/api/index.html#org.scalatra.fileupload.FileUploadSupport)


<hr/>
#### Response handling
<hr/>

```scala
halt(404)
halt(status = 400, headers = Map("foo" -> "bar"), reason = "why")

redirect("/top") // 302
redirect301("/new_url") // 301
redirect302("/somewhere") // 302
redirect303("/complete") // 303
```

[/api/index.html#org.scalatra.ScalatraBase](http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase)

[/index.html#org.scalatra.ActionResult](http://www.scalatra.org/2.2/api/index.html#org.scalatra.ActionResult)

[/framework/src/main/scala/skinny/controller/feature/ExplicitRedirectFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/develop/framework/src/main/scala/skinny/controller/feature/ExplicitRedirectFeature.scala)

[/core/src/main/scala/org/scalatra/ActionResult.scala](https://github.com/scalatra/scalatra/blob/2.2.x_2.10/core/src/main/scala/org/scalatra/ActionResult.scala)

<hr/>
#### CSRF Protection
<hr/>

Notice: Scalatra CSRF protection implementation uses servlet sessions by default. Be aware of sticky session mode.

Define `protectFromForgery` in controller/RootController.scala:

```scala
class RootController extends ApplicationController {
  protectFromForgery()

}
```

Use `Skinny.csrfMetaTags` in /WEB-INF/layouts/default.jade:

```
-@val body: String
-@val s: skinny.Skinny
!!! 5
%html(lang="en")
  %head
    %meta(charset="utf-8")
    != s.csrfMetaTags
  %body
    =unescape(body)
    %script(type="text/javascript" src={uri("/assets/js/skinny.js")})
```

<hr/>
#### Check execution time
<hr/>

```scala
val result = warnElapsedTime(1) {
  Thread.sleep(10)
}
// will output "[SLOW EXECUTION DETECTED] Elapsed time: 10 millis"
```

In controllers, you can add request info:

```scala
val result = warnElapsedTimeWithRequest(1) {
  Thread.sleep(10)
}
```

<hr/>
#### Read your own configuration values
<hr/>

```
development {
  defaultLabel="foo"
  timeout {
    connect=1000
    read=3000
  }
  memcached=["server1:11211", "server2:11211"]
}
```

Read the server names like this:

```scala
val label: Option[String] = SkinnyConfig.stringConfigValue("defaultLabel")
val connectTimeout: Option[Int] = SkinnyConfig.intConfigValue("timeout.connect")
val memcachedServers: Option[Seq[String]] = SkinnyConfig.stringSeqConfigValue("memcached")
```

