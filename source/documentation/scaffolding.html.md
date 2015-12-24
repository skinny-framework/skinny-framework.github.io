---
title: Scaffolding - Skinny Framework
---

## Scaffolding

<hr/>
### Scaffold Generator
<hr/>

Skinny has a powerful scaffold generator. Usage is very simple.

```
# If you're a zsh user, try "noglob ./skinny g scaffold ..."
./skinny g scaffold members member name:String "nickname:String:varchar(64)" birthday:Option[LocalDate]
./skinny db:migrate
./skinny run
```

Now you can use CRUD pages for members resource at `http://localhost:8080/members`.

<hr/>
#### Parameters

Scaffold command's parameters are ...

```
./skinny g scaffold:{template} {resources} {resource} "{fieldName:paramType(:columnType)}" ...
```

- {template}: "ssp" / "scaml" / "jade" (Scalate template name)
- {resources}: Resource name in the plural (camelCase)
- {resource}: Resource name (camelCase)
- {fieldName}: Field name in the resource (camelCase)
- {paramType}: `skinny.ParamType`. see also: [skinny/ParamType.scala](https://github.com/skinny-framework/skinny-framework/blob/master/common/src/main/scala/skinny/ParamType.scala)
- {columnType}: (optional) Database column type. This will be embedded into DB migration file.

If an attribute's {paramType} is an entity type (all unexpected types), the attribute will be converted to association definition.

```bash
./skinny g model tweet userId:Long text:String user:Option[User]
```

This command will generate following code:

```scala
package model

import skinny.orm._, feature._
import scalikejdbc._
import org.joda.time._

// If your model has +23 fields, switch this to normal class and mixin scalikejdbc.EntityEquality.
case class Tweet(
  id: Long,
  userId: Long,
  text: String,
  user: Option[User] = None,
  createdAt: DateTime,
  updatedAt: DateTime
)

object Tweet extends SkinnyCRUDMapper[Tweet] with TimestampsFeature[Tweet] {

  override lazy val defaultAlias = createAlias("t")

  lazy val userRef = belongsTo[User](User, (t, u) => t.copy(user = u))

  /*
   * If you're familiar with ScalikeJDBC/Skinny ORM, using #autoConstruct makes your mapper simpler.
   * (e.g.)
   * override def extract(rs: WrappedResultSet, rn: ResultName[Tweet]) = autoConstruct(rs, rn)
   *
   * Be aware of excluding associations like this:
   * (e.g.)
   * case class Member(id: Long, companyId: Long, company: Option[Company] = None)
   * object Member extends SkinnyCRUDMapper[Member] {
   *   override def extract(rs: WrappedResultSet, rn: ResultName[Member]) =
   *     autoConstruct(rs, rn, "company") // "company" will be skipped
   * }
   */
  override def extract(rs: WrappedResultSet, rn: ResultName[Tweet]): Tweet = new Tweet(
    id = rs.get(rn.id),
    userId = rs.get(rn.userId),
    text = rs.get(rn.text),
    createdAt = rs.get(rn.createdAt),
    updatedAt = rs.get(rn.updatedAt)
  )
}
```

Other associations can be generated with the following convention.

- Option[{Entity}]: belongsTo association
- Seq[{Entity}]: hasMany association
- Seq[{Entity1}{Entity2}]: hasManyThrough association

It's also possible to specify namespace for the resource:

```
./skinny g scaffold:{template} {namespace} {resources} {resource} {attributes}...
```

- {namespace}: prefix for the resource (e.g. admin.foo.bar)


<hr/>
#### Example Usage
<hr/>

Let's create CRUD pages to manage project members!

<hr/>

```
$ ./skinny g scaffold:jade projectMembers projectMember name:String "nickname:Option[String]:varchar(32)" joinedAt:DateTime leaveAt:Option[DateTime]

[info] Running TaskRunner generate:scaffold:jade projectMembers projectMember name:String nickname:Option[String]:varchar(32) joinedAt:DateTime leaveAt:Option[DateTime]

 *** Skinny Generator Task ***

  "src/main/scala/controller/ApplicationController.scala" skipped.
  "src/main/scala/controller/ProjectMembersController.scala" created.
  "src/main/scala/controller/Controllers.scala" modified.
  "src/test/scala/controller/ProjectMembersControllerSpec.scala" created.
  "src/test/scala/integrationtest/ProjectMembersController_IntegrationTestSpec.scala" created.
  "src/test/resources/factories.conf" modified.
  "src/main/scala/model/ProjectMember.scala" created.
  "src/test/scala/model/ProjectMemberSpec.scala" created.
  "src/main/webapp/WEB-INF/views/projectMembers/_form.html.jade" created.
  "src/main/webapp/WEB-INF/views/projectMembers/new.html.jade" created.
  "src/main/webapp/WEB-INF/views/projectMembers/edit.html.jade" created.
  "src/main/webapp/WEB-INF/views/projectMembers/index.html.jade" created.
  "src/main/webapp/WEB-INF/views/projectMembers/show.html.jade" created.
  "src/main/resources/messages.conf" modified.
  "src/main/resources/db/migration/V20140324003741__Create_projectMembers_table.sql" created.

[success] Total time: 1 s, completed Mar 2, 2014 12:58:53 AM
```

With namespace:

```
$ ./skinny g scaffold:jade admin.foo members member name:String

[info] Running TaskRunner generate:scaffold:jade admin.foo members member name:String

 *** Skinny Generator Task ***

  "src/main/scala/controller/ApplicationController.scala" skipped.
  "src/main/scala/controller/admin/foo/MembersController.scala" created.
  "src/main/scala/controller/Controllers.scala" modified.
  "src/test/scala/controller/admin/foo/MembersControllerSpec.scala" created.
  "src/test/scala/integrationtest/admin/foo/MembersController_IntegrationTestSpec.scala" created.
  "src/test/resources/factories.conf" modified.
  "src/main/scala/model/admin/foo/Member.scala" created.
  "src/test/scala/model/admin/foo/MemberSpec.scala" created.
  "src/main/webapp/WEB-INF/views/admin/foo/members/_form.html.jade" created.
  "src/main/webapp/WEB-INF/views/admin/foo/members/new.html.jade" created.
  "src/main/webapp/WEB-INF/views/admin/foo/members/edit.html.jade" created.
  "src/main/webapp/WEB-INF/views/admin/foo/members/index.html.jade" created.
  "src/main/webapp/WEB-INF/views/admin/foo/members/show.html.jade" created.
  "src/main/resources/messages.conf" modified.
  "src/main/resources/db/migration/V20140324003819__Create_members_table.sql" created.

[success] Total time: 2 s, completed Mar 7, 2014 12:36:17 AM
```


<hr/>
After that, do DB migration.
<hr/>

```
$ ./skinny db:migrate
```

<hr/>
Run the Skinny app and access `http://localhost:8080/project_members` from your browser.
<hr/>

```
$ ./skinny run
```

<hr/>
#### URL / Parameter Names
<hr/>

The following is an example controller generated by scaffold command.

Be aware of these rules:

- Base URL will be snake_cased. If you'd like to change it, edit `resourcesBasePath`
- Parameter names will be snake_cased. `useSnakeCasedParamKeys` should be true when using `Params#withDateTime`

It'll be the fastest way to understand actual files generated by scaffold generator.

<hr/>

```java
package controller

import skinny._
import skinny.validator._
import model.ProjectMember

object ProjectMembersController extends SkinnyResource with ApplicationController {
  protectFromForgery()

  override def model = ProjectMember
  override def resourcesName = "projectMembers"
  override def resourceName = "projectMember"

  override def resourcesBasePath = s"/${toSnakeCase(resourcesName)}"
  override def useSnakeCasedParamKeys = true

  override def createParams = Params(params).withDateTime("joined_at").withDateTime("leave_at")
  override def createForm = validation(createParams,
    paramKey("name") is required & maxLength(512),
    paramKey("nickname") is maxLength(512),
    paramKey("joined_at") is required & dateTimeFormat,
    paramKey("leave_at") is dateTimeFormat
  )
  override def createFormStrongParameters = Seq(
    "name" -> ParamType.String,
    "nickname" -> ParamType.String,
    "joined_at" -> ParamType.DateTime,
    "leave_at" -> ParamType.DateTime
  )

...
```

<hr/>
#### Using your favorite ORM with SkinnyResource
<hr/>

Skinny ORM'S CRUDMapper implements `skinny.SkinnyModel`'s methods. If you'd like to use other ORM or DB library, you can do that by implementing `SkinnyModel` trait.

https://github.com/skinny-framework/skinny-framework/blob/master/common/src/main/scala/skinny/SkinnyModel.scala

```scala
object MembersController extends SkinnyResource with ApplicationController {
  protectFromForgery()

  override def model = SlickBackendMapper

...
```

<hr/>
#### SkinnyResource's pagination for Oracle, MS SQLServer
<hr/>

Skinny ORM doesn't support Oracle DB or MS SQLServer's pagination. You should override `SkinnyModel#findModels(pageSize: Int, pageNo: Int): List[Model]` method for your RDBMS. 

https://github.com/skinny-framework/skinny-framework/blob/master/common/src/main/scala/skinny/SkinnyModel.scala

<hr/>
### Reverse Scaffold Generator
<hr/>

If you're working with existing database, `reverse-scaffold` command is pretty useful.

When you have `project_members` table in database,

```sql
-- For H2 Database
create table project_members (
  member_id bigserial not null primary key,
  name varchar(512) not null,
  nickname varchar(32),
  joined_at timestamp not null,
  leave_at timestamp
);
```

Run the `reverse-scaffold` command like this.

This command uses DB settings in the `src/main/resources/application.conf`. SkinnyEnv is set as `development`. 

```
$ ./skinny g reverse-scaffold:scaml project_members projectMembers projectMember

[info] Running TaskRunner generate:reverse-scaffold:scaml project_members projectMembers projectMember

 *** Skinny Reverse Engineering Task ***

  Table     : project_members
  ID        : memberId
  Resources : projectMembers
  Resource  : projectMember

  Columns:
   - name:String:varchar(512)
   - nickname:Option[String]:varchar(32)
   - joinedAt:DateTime
   - leaveAt:Option[DateTime]

 *** Skinny Generator Task ***

  "src/main/scala/controller/ApplicationController.scala" skipped.
  "src/main/scala/controller/ProjectMembersController.scala" created.
  "src/main/scala/controller/Controllers.scala" modified.
  "src/test/scala/controller/ProjectMembersControllerSpec.scala" created.
  "src/test/scala/integrationtest/ProjectMembersController_IntegrationTestSpec.scala" created.
  "src/test/resources/factories.conf" modified.
  "src/main/scala/model/ProjectMember.scala" created.
  "src/test/scala/model/ProjectMemberSpec.scala" created.
  "src/main/webapp/WEB-INF/views/projectMembers/_form.html.scaml" created.
  "src/main/webapp/WEB-INF/views/projectMembers/new.html.scaml" created.
  "src/main/webapp/WEB-INF/views/projectMembers/edit.html.scaml" created.
  "src/main/webapp/WEB-INF/views/projectMembers/index.html.scaml" created.
  "src/main/webapp/WEB-INF/views/projectMembers/show.html.scaml" created.
  "src/main/resources/messages.conf" modified.
  "src/main/resources/db/migration/V20140302010916__Create_projectMembers_table.sql" created.

[success] Total time: 1 s, completed Mar 2, 2014 1:09:16 AM
```

The DB migration file generated by this command is commented out by default, so `./skinny db:migrate` will do nothing.

Just run `./skinny run` and access `http://localhost:8080/project_members` from your browser.

<hr/>
#### Parameters

Reverse scaffold command's parameters are ...

```
./skinny g reverse-scaffold:{template} {tableName} {resources} {resource}
```

- {template}: "ssp" / "scaml" / "jade" (Scalate template name)
- {tableName}: Target table name in the existing database
- {resources}: Resource name in the plural (camelCase)
- {resource}: Resource name (camelCase)

```
./skinny g reverse-scaffold:{template} {namespace} {tableName} {resources} {resource}
```

- {namespace}: prefix for the resource (e.g. admin.foo.bar)

<hr/>
#### reverse-*-all commands

`reverse-scaffold-all/reverse-model-all` commands generate all the code from existing database.

```bash
./skinny g reverse-model-all
./skinny g reverse-scaffold-all
```

Here is an example DDL.

```sql
create table user_group (
  id bigserial not null primary key,
  name varchar(100) not null,
  url varchar(512)
);
create table organization (
  id bigserial not null primary key,
  name varchar(100) not null,
  url varchar(512) not null
);
create table developer (
  id bigserial not null primary key,
  name varchar(512) not null,
  nickname varchar(32),
  user_group_id bigint references user_group(id)
);
create table organization_developer (
  organization_id bigint not null references organization(id),
  developer_id bigint not null references developer(id)
);
```

When you run `reverse-scaffold-all` generator for this database schema, skinny command will show you following output.

```
*** Skinny Reverse Engineering Task ***

  Table     : developer
  ID        : id:Long
  Resources : developers
  Resource  : developer

  Columns:
   - name:String:varchar(512)
   - nickname:Option[String]:varchar(32)
   - userGroupId:Option[Long]
   - userGroup:Option[UserGroup]
   - organizationDevelopers:Seq[OrganizationDeveloper]

 *** Skinny Generator Task ***

  "sample/src/main/scala/controller/ApplicationController.scala" skipped.
  "sample/src/main/scala/controller/DevelopersController.scala" created.
  "sample/src/main/scala/controller/Controllers.scala" modified.
  "sample/src/test/scala/controller/DevelopersControllerSpec.scala" created.
  "sample/src/test/scala/integrationtest/DevelopersController_IntegrationTestSpec.scala" created.
  "sample/src/test/resources/factories.conf" modified.
  "sample/src/main/scala/model/Developer.scala" created.
  "sample/src/test/scala/model/DeveloperSpec.scala" created.
  "sample/src/main/webapp/WEB-INF/views/developers/_form.html.ssp" created.
  "sample/src/main/webapp/WEB-INF/views/developers/new.html.ssp" created.
  "sample/src/main/webapp/WEB-INF/views/developers/edit.html.ssp" created.
  "sample/src/main/webapp/WEB-INF/views/developers/index.html.ssp" created.
  "sample/src/main/webapp/WEB-INF/views/developers/show.html.ssp" created.
  "sample/src/main/resources/messages.conf" modified.
  "sample/src/main/resources/db/migration/V20141207024947__Create_developers_table.sql" created.


 *** Skinny Reverse Engineering Task ***

  Table     : organization
  ID        : id:Long
  Resources : organizations
  Resource  : organization

  Columns:
   - name:String:varchar(100)
   - url:String:varchar(512)
   - organizationDevelopers:Seq[OrganizationDeveloper]

 *** Skinny Generator Task ***

  "sample/src/main/scala/controller/ApplicationController.scala" skipped.
  "sample/src/main/scala/controller/OrganizationsController.scala" created.
  "sample/src/main/scala/controller/Controllers.scala" modified.
  "sample/src/test/scala/controller/OrganizationsControllerSpec.scala" created.
  "sample/src/test/scala/integrationtest/OrganizationsController_IntegrationTestSpec.scala" created.
  "sample/src/test/resources/factories.conf" modified.
  "sample/src/main/scala/model/Organization.scala" created.
  "sample/src/test/scala/model/OrganizationSpec.scala" created.
  "sample/src/main/webapp/WEB-INF/views/organizations/_form.html.ssp" created.
  "sample/src/main/webapp/WEB-INF/views/organizations/new.html.ssp" created.
  "sample/src/main/webapp/WEB-INF/views/organizations/edit.html.ssp" created.
  "sample/src/main/webapp/WEB-INF/views/organizations/index.html.ssp" created.
  "sample/src/main/webapp/WEB-INF/views/organizations/show.html.ssp" created.
  "sample/src/main/resources/messages.conf" modified.
  "sample/src/main/resources/db/migration/V20141207024947__Create_organizations_table.sql" created.


Since this table (organization_developer) has no primary key, generator created only NoIdCRUDMapper file and skipped creating controller and view files.

 *** Skinny Reverse Engineering Task ***

  Table  : organization_developer

  Columns:
   - organizationId:Long
   - developerId:Long
   - developer:Option[Developer]
   - organization:Option[Organization]

 *** Skinny Generator Task ***

  "sample/src/main/scala/model/OrganizationDeveloper.scala" created.
  "sample/src/test/scala/model/OrganizationDeveloperSpec.scala" created.
  "sample/src/main/resources/db/migration/V20141207024947__Create_organizationDevelopers_table.sql" created.


 *** Skinny Reverse Engineering Task ***

  Table     : user_group
  ID        : id:Long
  Resources : userGroups
  Resource  : userGroup

  Columns:
   - name:String:varchar(100)
   - url:Option[String]:varchar(512)
   - developers:Seq[Developer]

 *** Skinny Generator Task ***

  "sample/src/main/scala/controller/ApplicationController.scala" skipped.
  "sample/src/main/scala/controller/UserGroupsController.scala" created.
  "sample/src/main/scala/controller/Controllers.scala" modified.
  "sample/src/test/scala/controller/UserGroupsControllerSpec.scala" created.
  "sample/src/test/scala/integrationtest/UserGroupsController_IntegrationTestSpec.scala" created.
  "sample/src/test/resources/factories.conf" modified.
  "sample/src/main/scala/model/UserGroup.scala" created.
  "sample/src/test/scala/model/UserGroupSpec.scala" created.
  "sample/src/main/webapp/WEB-INF/views/userGroups/_form.html.ssp" created.
  "sample/src/main/webapp/WEB-INF/views/userGroups/new.html.ssp" created.
  "sample/src/main/webapp/WEB-INF/views/userGroups/edit.html.ssp" created.
  "sample/src/main/webapp/WEB-INF/views/userGroups/index.html.ssp" created.
  "sample/src/main/webapp/WEB-INF/views/userGroups/show.html.ssp" created.
  "sample/src/main/resources/messages.conf" modified.
  "sample/src/main/resources/db/migration/V20141207024947__Create_userGroups_table.sql" created.

 ```

Generated models include association configurations too (only when tables are referenced with foreign keys).

```scala
package model

import skinny.orm._, feature._
import scalikejdbc._
import org.joda.time._

// If your model has +23 fields, switch this to normal class and mixin scalikejdbc.EntityEquality.
case class Developer(
  id: Long,
  name: String,
  nickname: Option[String] = None,
  userGroupId: Option[Long] = None,
  userGroup: Option[UserGroup] = None,
  organizations: Seq[Organization] = Nil
)

object Developer extends SkinnyCRUDMapper[Developer] {
  override lazy val tableName = "developer"
  override lazy val defaultAlias = createAlias("d")

  lazy val userGroupRef = belongsTo[UserGroup](UserGroup, (d, ug) => d.copy(userGroup = ug))

  lazy val organizationsRef = hasManyThrough[Organization](
    through = OrganizationDeveloper,
    many = Organization,
    merge = (d, os) => d.copy(organizations = os)
  )

  override def extract(rs: WrappedResultSet, rn: ResultName[Developer]): Developer = {
    autoConstruct(rs, rn, "userGroup", "organizations")
  }
}
```

Controllers are created as same as normal scaffold generator.

```scala
package controller

import skinny._
import skinny.validator._
import _root_.controller._
import model.Developer

class DevelopersController extends SkinnyResource with ApplicationController {
  protectFromForgery()

  override def model = Developer
  override def resourcesName = "developers"
  override def resourceName = "developer"

  override def resourcesBasePath = s"/${toSnakeCase(resourcesName)}"
  override def useSnakeCasedParamKeys = true

  override def viewsDirectoryPath = s"/${resourcesName}"

  override def createParams = Params(params)
  override def createForm = validation(createParams,
    paramKey("name") is required & maxLength(512),
    paramKey("nickname") is maxLength(32),
    paramKey("user_group_id") is numeric & longValue
  )
  override def createFormStrongParameters = Seq(
    "name" -> ParamType.String,
    "nickname" -> ParamType.String,
    "user_group_id" -> ParamType.Long
  )

  override def updateParams = Params(params)
  override def updateForm = validation(updateParams,
    paramKey("name") is required & maxLength(512),
    paramKey("nickname") is maxLength(32),
    paramKey("user_group_id") is numeric & longValue
  )
  override def updateFormStrongParameters = Seq(
    "name" -> ParamType.String,
    "nickname" -> ParamType.String,
    "user_group_id" -> ParamType.Long
  )

}
```
