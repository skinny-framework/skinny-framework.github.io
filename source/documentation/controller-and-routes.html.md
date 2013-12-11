---
title: Controller & Routes - Skinny Framework
---

## Controller & Routes

<hr/>
### Routing & Controller

Skinny's routing mechanism and controller layer on MVC architecture is a **rich Scalatra**. 

Skinny's extension provides you much simpler/rich syntax. Of course, if you need to use Scalatra's API directly, Skinny never bothers you.

![Scalatra](images/scalatra.png)

`SkinnyController` is a trait which extends `ScalatraFilter` and out-of-the-box components are integrated.

```java
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

  // whether query param or path param
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
#### Reverse Routes

You can use Scalatra's reverse routes.

http://www.scalatra.org/2.2/guides/http/reverse-routes.html

In controllers:

```java
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
a(href={url(Controllers.members.showUrl, "id" -> member.id.toString)}) Show detail

```

FYI: You can see more examples for SkinnyResource by generating scaffold views.


<hr/>
#### SkinnyController & SkinnyServlet

There are two controller base trait. SkinnyController is a ScalatraFilter. SkinnyServlet is a ScalatraServlet.

- [org.scalatra.ScalatraFilter]((http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraFilter))
- [org.scalatra.ScalatraServlet]((http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraServlet))

Basically SkinnyController is more suitable for Skinny framework based applications.

However, really you need to use ScalatraServlet, use SkinnyServlet instead.

<hr/>
### SkinnyResource

SkinnyResource is a useful base trait for RESTful web services. SkinnyResource is very similar to Rails ActiveResource.

[Resource Routing: the Rails Default (Rails Routing from the Outside In — Ruby on Rails Guides)](http://guides.rubyonrails.org/routing.html#resource-routing-the-rails-default)

[https://github.com/rails/activeresource](https://github.com/rails/activeresource)

SkinnyResource is also useful as a controller sample. If you're a Skinny beginner, take a look at its code.

[framework/src/main/scala/skinny/controller/SkinnyResource.scala](https://github.com/skinny-framework/skinny-framework/blob/master/framework/src/main/scala/skinny/controller/SkinnyResource.scala)

SkinnyResourceActions has action methods for the resource and SkinnyResourceRoutes defines routings for the resource.
If you'd like to customize routings (e.g. use only creation and deletion), just mixin only SkinnyResourceActions and define routings by yourself.

You can get SkinnyResource example by scaffolding.

```
./skinny g scaffold members member name:String birthday:LocalDate
```

Then you get the following code. If you need to customize, override some parts of SkinnyResource:

[framework/src/main/scala/skinny/controller/SkinnyResource.scala](https://github.com/skinny-framework/skinny-framework/blob/master/framework/src/main/scala/skinny/controller/SkinnyResource.scala)

```java
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
  override def createForm = validation(createParams,
    paramKey("name") is required & maxLength(512),
    paramKey("birthday") is required & dateFormat
  )
  override def createParams = Params(params).withDate("birthday")
  override def createFormStrongParameters = Seq(
    "name" -> ParamType.String,
    "birthday" -> ParamType.LocalDate
  )

  // parameters & validations for modification
  override def updateForm = validation(updateParams,
    paramKey("name") is required & maxLength(512),
    paramKey("birthday") is required & dateFormat
  )
  override def updateParams = Params(params).withDate("birthday")
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
- POST /members/
- GET /members/{id}
- GET /members/{id}.xml
- GET /members/{id}.json
- GET /members/{id}/edit
- POST /members/{id}
- PUT /members/{id}
- PATCH /members/{id}
- DELETE /members/{id}

<hr/>
### skinny.Skinny

skinny.Skinny provides getters for basic elements in view templates.

```
<%@val s: skinny.Skinny %>
```

[framework/src/main/scala/skinny/Skinny.scala](https://github.com/skinny-framework/skinny-framework/blob/master/framework/src/main/scala/skinny/Skinny.scala)

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
### How to Do It

Basically, you will use Scalatra's DSL.

[http://www.scalatra.org/2.2/guides/](http://www.scalatra.org/2.2/guides/)

[http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase](http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase)

#### (Query/Form/Path) Parameters

[http://www.scalatra.org/guides/http/routes.html](http://www.scalatra.org/guides/http/routes.html)

- params
- params.get(name)
- multiParams("splat")
- multiParams("captures")

#### Cookies

[http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase](http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase)

- cookies

#### Request/Response Headers

[http://docs.oracle.com/javaee/7/api/javax/servlet/http/HttpServletRequest.html](http://docs.oracle.com/javaee/7/api/javax/servlet/http/HttpServletRequest.html)

[http://docs.oracle.com/javaee/7/api/javax/servlet/http/HttpServletResponse.html](http://docs.oracle.com/javaee/7/api/javax/servlet/http/HttpServletResponse.html)

- request.getHeader(name)
- response.setHeader(name, value)

#### Session

[http://www.scalatra.org/2.2/api/index.html#org.scalatra.SessionSupport](http://www.scalatra.org/2.2/api/index.html#org.scalatra.SessionSupport)

- session
- session(key)

#### Flash

[http://www.scalatra.org/guides/http/flash.html](http://www.scalatra.org/guides/http/flash.html)

- flash(name) = value
- flash += (name -> value)
- flash.now += (name -> value)

#### Response handling

[http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase](http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase)

- halt(status, body, headers, reason)

#### Before/After Filters

Scalatra has filters by default. However, we highly recommend Skinny users to use Skinny's filters.

##### Scalatra filters

[http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase](http://www.scalatra.org/2.2/api/index.html#org.scalatra.ScalatraBase)

- before(transformers)(action)
- after(transformers)(action)

##### Skinny filters

[framework/src/main/scala/skinny/controller/feature/BeforeAfterActionFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/master/framework/src/main/scala/skinny/controller/feature/BeforeAfterActionFeature.scala)

```java
class MembersController extends SkinnyController with Routes {

  // Scalatra filters
  before() { ... } // might affect in other controllers
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

Scalatra's filters might effect other controllers.

If you need filters that are similar to Rails filters, just use Skinny filters.
