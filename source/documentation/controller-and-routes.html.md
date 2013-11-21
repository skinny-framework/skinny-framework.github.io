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
  protectFromForgery()

  beforeAction(only = Seq('index, 'new)) { set("countries", Country.findAll()) }

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
}

// src/main/scala/controller/Controllers.scala
object Controllers {
  val members = new MembersController with Routes {
    get("/members/?")(index).as('index)
    get("/members/new")(newOne).as('new)
    post("/members/?")(create).as('create)
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
### SkinnyController & SkinnyServlet

TODO documentation

<hr/>
### SkinnyResource

TODO documentation

<hr/>
### Skinny elements

TODO

- Params
- Flash
- Error Messages
- i18n
- CSRF token
- context path
- request path

https://github.com/skinny-framework/skinny-framework/blob/develop/framework/src/main/scala/skinny/controller/feature/RequestScopeFeature.scala

<hr/>
### Scalatra APIs

TODO link to documents

TODO Servlet APIs

<hr/>
### Examples

TODO Scalatra Examples

