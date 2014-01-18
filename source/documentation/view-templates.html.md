---
title: View Templates - Skinny Framework
---

## View Templates

<hr/>
## Scalate
<hr/>

Skinny framework basically follows Scalatra's [Scalate](http://scalate.fusesource.org/) Support, but Skinny has an additional convention.

![Scalate Logo](images/scalate.png)

Templates' path should be `{path}.{format}.{extension}`. Expected {format} are `html`, `json`, `js` and `xml`.

For instance, your controller code will be like this:

```java
class MembersController extends SkinnyController {
  def index = {
    set("members", Member.findAll())
    render("/members/index")
  }
}
```

The render method expects that `src/main/webapp/WEB-INF/views/members/index.html.ssp` exists.

```
<%@val members: Seq[model.Member] %>
<h3>Members</h3>
<hr/>
<table class="table table-bordered">
<thead>
  <tr>
    <th>ID</th>
    <th>Name</th>
    <th></th>
  </tr>
</thead>
<tbody>
  #for (member <- members)
  <tr>
    <td>${member.id}</td>
    <td>${member.name}</td>
    <td>
      <!-- Using Scalatra reverse routes is recommended -->
      <a href="${url(MembersController.editUrl, "id" -> member.id.toString)}" 
         class="btn btn-info">Edit</a>
      <a data-method="delete" data-confirm="Are you sure?" 
         href="${url(MembersControlller.deleteUrl, "id" -> member.id.toString)}" 
         class="btn btn-danger">Delete</a>

      <!-- Primitive HTML coding is also possible -->
      <a href="/members/${member.id}/edit" class="btn btn-info">Edit</a>
      <a data-method="delete" data-confirm="Are you sure?"
         href="/members/${member.id}" class="btn btn-danger">Delete</a>
    </td>
  </tr>
  #end
</tbody>
</table>
```

Scalate supports many template engines.

- Mustache
- Scaml
- Jade
- SSP

[http://scalate.fusesource.org/index.html](http://scalate.fusesource.org/index.html)


If you'd like to use other Scalate templates, just override the settings in controllers.

```java
class MembersController extends SkinnyController {
  override val scalateExtension = "jade"
  // ssp(default), scaml, jade ,mustache
}
```

And then, use `src/main/webapp/WEB-INF/views/members/index.html.jade` instead.

Scaffoding will be the easiest way to understand. Try it now!

```sh
./skinny g scaffold members member name:String activated:Boolean birthday:Option[LocalDate]
./skinny g scaffold:scaml companies company name:String 
./skinny g scaffold:jade  countries country name:String code:Int

./skinny db:migrate
./skinny run
```

For instance, if you use jade instead, above code will be simpler like this. Scaml is very similar.

```
-@val members: Seq[model.Member] 
h3 Members
hr
table(class="table table-bordered")
  thead
    tr
      th ID
      th Name
      th
  tbody
  -for (member <- members)
    tr
      td #{member.id}
      td #{member.name}
      td
        a(href={url(MembersController.editUrl, "id" -> member.id.toString)} class="btn btn-info") Edit
        a(data-method="delete" data-confirm="Are you sure?" href={url(MembersControlller.deleteUrl, "id" -> member.id.toString)} class="btn btn-danger") Delete
        a(href={s"/members/${member.id}/edit"} class="btn btn-info") Edit
        a(data-method="delete" data-confirm="Are you sure?" href={s"/members/${member.id}"} class="btn btn-danger") Delete
```


<hr/>
### FreeMarker
<hr/>

If you prefer FreeMarker template engine, you can easily use it with Skinny framework.

[http://freemarker.org/](http://freemarker.org/)

First, add `skinny-freemarker` to your library-dependencies.

```
libraryDependencies += "org.skinny-framewrok" %% "skinny-freemarker" % "[0.9,)"
```

Mixin `FreeMarkerTemplateEngineFeature` to your controllers.

```java
import skinny.controller.feature.FreeMarkerTemplateEngineFeature

class MembersController extends SkinnyController
  with FreeMarkerTemplateEngineFeature {

  def index = {
    set("members", Member.findAll())
    render("/members/index")
  }
}
```

And then, use `src/main/webapp/WEB-INF/views/members/index.html.ftl` instead.

<hr/>
### Thymeleaf
<hr/>

If you prefer Thymeleaf template engine, you can easily use it with Skinny framework.

[http://www.thymeleaf.org/](http://www.thymeleaf.org/)

First, add `skinny-thymeleaf` to your library-dependencies.

```
libraryDependencies += "org.skinny-framewrok" %% "skinny-thymeleaf" % "[0.9,)"
```

Mixin `ThymeleafTemplateEngineFeature` to your controllers.

```java
import skinny.controller.feature.ThymeleafTemplateEngineFeature

class MembersController extends SkinnyController
  with ThymeleafTemplateEngineFeature {

  def index = {
    set("members", Member.findAll())
    render("/members/index")
  }
}
```

And then, use `src/main/webapp/WEB-INF/views/members/index.html` instead.


