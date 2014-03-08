---
title: ORM - Skinny Framework
---

## ORM

<hr/>
### Skinny-ORM
<hr/>

Skinny provides you with Skinny-ORM as the default O/R mapper, which is built with [ScalikeJDBC](https://github.com/scalikejdbc/scalikejdbc). This is a portable library, so you can also use it with Play2, pure Scalatra, Lift and any other frameworks.

![Logo](images/scalikejdbc.png)

A key feature of Skinny-ORM is that it avoids N+1 queries because associations are resolved by join queries. 

`#belongsTo`, `#hasOne` and `#hasMany(Through)` associations are converted into join queries, so you don't need to worry about performance problems caused by N+1 queries. 

Furthermore, the `#byDefault` option allows you to resolve assocations anytime. If you don't always need some association, miss the `#byDefault` and just use `#joins` method such as `Team.joins(Team.members).findById(123)` on demand.

On the other hand, it's impossible to resolve all the nested attributes' relationships by a single join query. If you need to resolve nested relationships, you can retrieve them with eager loading by using `#includes` method.

<hr/>
#### The Best way to learn

The best way to learn is by reading the following examamples. 

Table definitions: https://github.com/skinny-framework/skinny-framework/blob/develop/orm/src/test/scala/skinny/orm/CreateTables.scala

Model examples: https://github.com/skinny-framework/skinny-framework/blob/develop/orm/src/test/scala/skinny/orm/models.scala

Usage: https://github.com/skinny-framework/skinny-framework/blob/develop/orm/src/test/scala/skinny/orm/SkinnyORMSpec.scala

If you have any questions or feedback, feel free to ask the Skinny team or users in the mailing list.

https://groups.google.com/forum/#!forum/skinny-framework


<hr/>
### Your First Mapper

<hr/>
#### Easy to use and powerful

Skinny-ORM is very powerful, so you don't need to write much code. Your first model class and companion are here.

```java
import skinny._
import skinny.orm._
import scalikejdbc._, SQLInterpolation._
import org.joda.time._

case class Member(id: Long, name: String, createdAt: DateTime)

object Member extends SkinnyCRUDMapper[Member] {
  override def defaultAlias = createAlias("m")

  override def extract(rs: WrappedResultSet, n: ResultName[Member]) = new Member(
    id = rs.long(n.id),
    name = rs.string(n.name),
    createdAt = rs.dateTime(n.createdAt)
  )
}
```

That's all! Now you can use the following APIs.

```java
val m = Member.defaultAlias

// ------------
// find by primary key
val member: Option[Member] = Member.findById(123)

val member: Option[Member] = Member.where('id -> 123).apply().headOption

// ------------
// find many
val members: List[Member] = Member.findAll()

// ------------
// in clause
val members: List[Member] = Member.findAllBy(sqls.in(m.id, Seq(123, 234, 345)))

val members: List[Member] = Member.where('id -> Seq(123, 234, 345)).apply()

// will return 345, 234, 123 in order
val m = Member.defaultAlias
val members: List[Member] = 
  Member.where('id -> Seq(123, 234, 345))
    .orderBy(m.id.desc).offset(0).limit(5)
    .apply()

// ------------
// find by condition

val members: List[Member] = Member.findAllBy(
  sqls.eq(m.groupName, "scalajp").and.eq(m.delete, false))

val members: List[Member] = Member.where(
  'groupName -> "scalajp", 'deleted -> false).apply()

// use Pagination instead. Easier to understand than limit/offset
val members = Member.where(sqls.eq(m.groupId, 123))
  .paginate(Pagination.page(1).per(20))
  .orderBy(m.id.desc).apply()

// ------------
// count

Order.count()
Order.countBy(sqls.isNull(m.deletedAt).and.eq(m.shopId, 123))

Order.where('deletedAt -> None, 'shopId -> 123).count()
Order.where(sqls.eq(o.cancelled, false)).distinctCount('customerId)

// ------------
// calcuations
// min, max, average and sum

Order.sum('amount)

Product.min('price)
Product.where(sqls.ge(p.createdAt, startDate)).max('price)
Product.average('price)

Product.calculate(sqls"original_func(${p.userId})")

// ------------
// create with strong parameters

val params = Map("name" -> "Bob")
val id = Member.createWithPermittedAttributes(params.permit("name" -> ParamType.String))

// ------------
// create with unsafe parameters

val m = Member.defaultAlias
val id = Member.createWithNamedValues(m.name -> "Alice")

Member.createWithAttributes(
  'id -> 123,
  'name -> "Chris",
  'createdAt -> DateTime.now
)

// ------------
// update with strong parameters

Member.updateById(123).withPermittedAttributes(params.permit("name" -> ParamType.String))

// ------------
// update with unsafe parameters

Member.updateById(123).withAttributes('name -> "Alice")

// update by condition

Member.updateBy(sqls.eq(m.groupId, 123)).withAttribtues('groupId -> 234)

// ------------
// delete

Member.deleteById(234)
Member.deleteBy(sqls.eq(m.groupId, 123))
```

Source code: 
https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/CRUDFeature.scala

<hr/>
### Associations
<hr/>

If you need to join other tables, just add `belongsTo`, `hasOne` or `hasMany(Through)` to the companion. 

Examples: 
https://github.com/skinny-framework/skinny-framework/blob/develop/orm/src/test/scala/skinny/orm/models.scala

Be aware of Skinny ORM's concept that basically joins tables to resolve associations to reduce N+1 queries. We recommend enabling query logging for development.

http://scalikejdbc.org/documentation/query-inspector.html

Typically defining associations are fundamentally not so simple, so you might be confused when specifying these definitions. Understanding how ScalikeJDBC's join queries and One-to-X APIs work may be useful.

http://scalikejdbc.org/documentation/one-to-x.html

<hr/>
#### BelongsTo

Same as ActiveRecord's `belongs_to` assocation:

http://guides.rubyonrails.org/association_basics.html#the-belongs-to-association

We need to specify some types, so definitions are not as simple as ActiveRecord, but it's easy to understand and simple enough.


```java
case class Company(id: Long, name: String)
class Member(id: Long, name: String,
  mentorId: Long, mentor: Option[Member] = None,
  companyId: Long, company: Option[Company] = None)

object Member extends SkinnyCRUDMapper[Member] {
  // basic settings ...

  // If byDefault is called, this join condition is enabled by default
  belongsTo[Company](Company, (m, c) => m.copy(company = c)).byDefault

  // or more explanatory
  belongsTo[Company](
    // entity mapper on the right side
    // in this case, default alias will be used in join query
    right = Company, 
    // function to merge association to main entity
    merge = (member, company) => member.copy(company = company)
  ).byDefault
 
  // when you cannot use defaultAlias, use this instead
  val mentorAlais = createAlias("mentor")
  val mentor = belongToWithAlias(
    // in this case, "mentor" alias will be used in join query
    right = Member -> mentorAlias,
    merge = (member, mentor) => member.copy(mentor = mentor))
    // mentor will be resolved only when calling #joins 
    /*.byDefault */ 
}

Member.findById(123) // without mentor

Member.joins(Member.mentor).findById(123) // with mentor
```

In this case, following table is expected:

```sql
create table members (
  id bigint auto_increment primary key not null,
  company_id bigint,
  mentor_id bigint
);
create table companies (
  id bigint auto_increment primary key not null,
  name varchar(64) not null
);
```

Find more here: https://github.com/skinny-framework/skinny-framework/blob/develop/orm/src/main/scala/skinny/orm/feature/AssociationsFeature.scala

<hr/>
#### HasOne

Same as ActiveRecord's `has_one` assocation:

http://guides.rubyonrails.org/association_basics.html#the-has-one-association

We need to specify some types, so definitions are not as simple as ActiveRecord, but it's easy to understand and simple enough.

```java
case class Name(first: String, last: String)
case class Member(id: Long, name: Option[Name] = None)

object Member extends SkinnyCRUDMapper[Member] {
  // basic settings ...

  val name = hasOne[Name](
    right = Name, 
    merge = (member, name) => m.copy(name = name)
  ).byDefault
}
```

In this case, following tables are expected:

```sql
create table members (
  id bigint auto_increment primary key not null
);
create table names (
  member_id bigint primary key not null,
  first varchar(64) not null,
  last varchar(64) not null
);
```

<hr/>
#### HasMany

Same as ActiveRecord's `has_many` assocation:

http://guides.rubyonrails.org/association_basics.html#the-has-many-association

We need to specify some types, so definitions are not as simple as ActiveRecord, but it's easy to understand and simple enough.

```java
case class Company(id: Long, name: String, members: Seq[Member] = Nil)
case class Member(id: Long, 
  companyId: Option[Long] = None, company: Option[Company] = None,
  skills: Seq[Skill] = Nil
)
case class Skill(id: Long, name: String)

// -----------------------
// hasMany example
object Company extends SkinnyCRUDMapper[Company] {
  // basic settings ...

  val membersRef = hasMany[Member](
    // association's SkinnyMapper and alias
    many = Member -> Member.membersAlias,
    // defines join condition by using aliases
    on = (c, m) => sqls.eq(c.id, m.companyId),
    // function to merge associations to main entity
    merge = (company, members) => company.copy(members = members)
  )
}
Company.joins(Company.membersRef).findById(123) // with members

// -----------------------
// hasManyThrough example

// join table definition
case class MemberSkill(memberId: Long, skillId: Long)
object MemberSkill extends SkinnyJoinTable[MemberSkill] {
  override val tableName = "members_skills"
  override val defaultAlias = createAlias("ms")
}
// hasManyThrough
object Member extends SkinnyCRUDMapper[Member] {
  // basic settings ...

  val skillsRef = hasManyThrough[Skill](
    through = MemberSkill, 
    many = Skill, 
    merge = (member, skills) => member.copy(skills = skills)
  )
}
Member.joins(Member.skillsRef).findById(234) // with skills
```

In this case, following tables are expected:

```sql
create table companies (
  id bigint auto_increment primary key not null,
  name varchar(255) not null
);
create table members (
  id bigint auto_increment primary key not null,
  company_id bigint
);
create table skills (
  id bigint auto_increment primary key not null,
  name varchar(255) not null
);
create table members_skills (
  member_id bigint not null,
  skill_id bigint not null
);
```

<hr/>
#### What's more

You can find more examples here:

Table definitions:
https://github.com/skinny-framework/skinny-framework/blob/develop/orm/src/test/scala/skinny/orm/CreateTables.scala

Model examples:
https://github.com/skinny-framework/skinny-framework/blob/develop/orm/src/test/scala/skinny/orm/models.scala

Usage:
https://github.com/skinny-framework/skinny-framework/blob/develop/orm/src/test/scala/skinny/orm/SkinnyORMSpec.scala

<hr/>
#### Entity Equality

Basically using case classes for entities is recommended. As you know, Scala (until 2.11) has 22 limitation, so you may need to use normal classes for entities to treat tables that have more than 22 columns.

In this case, entities should be defined like this (Skinny 0.9.21 or ScalikeJDBC 1.7.3 is required):

```java
class LegacyData(val id: Long, val c2: String, val c3: Int, ..., val c23: Int)
  extends scalikejdbc.EntityEquality {
  // override val entityIdentity = id
  override val entityIdentity = s"$id $c2 $c3 ... $c23"
}

object LegacyData extends SkinnyCRUDMapper[LegacyData] {
  ...
}
```

If you don't implement like this, one-to-many relationships won't work as you expect.

See also the detailed explanation here: http://scalikejdbc.org/documentation/one-to-x.html

<hr/>
### Eager Loading
<hr/>

When you enable eager loading using the `includes` API, you need to define both `belongsTo` and `includes`. 

Note: eager loading of nested entities is not supported yet.

Indeed, it's not incredibly simple. But we believe that what it does is so clear that you can easily write the definition.

```java
object Member extends SkinnyCRUDMapper[Member] {

  // Unfortunately the combination of Scala macros and type-dynamic sometimes doesn't work as expected
  // when "val company" is defined in Scala 2.10.x.
  // If you suffer from this issue, use "val companyOpt" "companyRef" and so on instead.
  val companyOpt = {
    // normal belongsTo
    belongsTo[Company](
      right = Company,
      merge = (member, company) => member.copy(company = company))
    // eager loading operation for this one-to-one relation
    .includes[Company](
      merge = (members, companies) => members.map { m =>
        companies.find { c => m.company
          .exists(_.id == c.id))
          .map(v => m.copy(company = Some(v)))
          .getOrElse(m)
      })
  }
}

Member.includes(companyOpt).findAll()
```

Yet another example:

```java
object Member extends SkinnyCRUDMapper[Member] {
  val skills =
    hasManyThrough[Skill](
      MemberSkill, Skill, (m, skills) => m.copy(skills = skills)
    ).includes[Skill]((ms, skills) => ms.map { m =>
      m.copy(kills = skills.filter(_.memberId.exists(_ == m.id)))
    })
}

Member.includes(Member.skills).findById(123) // with skills
```

Note: when your entities have the same associations (e.g. Company has Employee, Country and Employee have Country), avoiding using the default alias for the associations is recommended because that may cause invalid join query generation when you use eager loading. We plan to provide more useful error messages for such cases in version 1.0.0.

Source code: 
https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/IncludesFeature.scala


<hr/>
### Other Configurations
<hr/>

Skinny ORM provides the folllowing settings to overwrite.

```java
object GroupMember extends SkinnyCRUDMapper[Member] {

  // default: 'default
  override def connectionPoolName = 'legacydb
 
  // default: None 
  override def schemaName = Some("public")

  // Basically tableName is loaded from jdbc metadata and cached on the JVM
  // However, if the name of object/class which extends SkinnyMapper is not the camelCase of table name,
  // you need to override tableName by yourself.
  override def tableName = "group_members" // default: group_member 

  // Basically columnNames are loaded from jdbc metadata and cached on the JVM
  override def columnNames = Seq("id", "name", "birthday", "created_at")

  // field name which represents the (single) primary key column
  // default: "id"
  override def primaryKeyFieldName = "uid" 

  // with SkinnyCRUDMapper[GroupMember]
  // createWithAttributes will try to return generated id if true
  // default: true
  override def useAutoIncrementPrimaryKey = false

  // with SkinnyCRUDMapper[GroupMember]
  // default scope for update operations
  // default: None
  override def defaultScopeForUpdateOperations = Some(sqls.isNull(column.deletedAt))

  // with TimestampsFeature[GroupMember]
  // default: "createdAt"
  override def createdAtFieldName = "createdTimestamp"

  // with TimestampsFeature[GroupMember]
  // default: "updatedAt"
  override def updatedAtFieldName = "updatedTimestamp"

  // with OptimisticLockWithTimestampFeature[GroupMember] 
  // default: "lockTimestamp"
  override val lockTimestampFieldName = "lockedAt"

  // with OptimisticLockWithVersionFeature[GroupMember]
  // default: "lockVersion"
  override val lockVersionFieldName = "ver"

  // with SoftDeleteWithBooleanFeature[GroupMember]
  // default: "isDeleted"
  override val isDeletedFieldName = "deleted"

  // with SoftDeleteWithTimestampFeature[GroupMember]
  // default: "deletedAt"
  override val deletedAtFieldName = "deletedTimestamp"

}
```

<hr/>
### Dynamic Table Name
<hr/>

`#withTableName` enables using another table name only for the current query.

```java
object Order extends SkinnyCRUDMapper[Order] {
  override def defaultAlias = createAlias("o")
  override def tableName = "orders"
}

// default: orders
Order.count()

// other table: orders_2012
Order.withTableName("orders_2012").count()
```

Source code: 
https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/DynamicTableNameFeature.scala

<hr/>
### Adding Methods
<hr/>

If you need to add methods, just write methods that use `#findBy`, `#countBy` or ScalikeJDBC's APIs directly.

```java
object Member extends SkinnyCRUDMapper[Member] {
  private[this] val m = defaultAlias

  def findAllByGroupId(groupId: Long)(implicit s: DBSession = autoSession): Seq[Member] = {
    findAllBy(sqls.eq(m.groupId, groupId))
  }
}
```

If you're using Skinny-ORM with Skinny Framework,
[skinny.orm.servlet.TxPerRequestFilter](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/servlet/TxPerRequestFilter.scala) simplifies your applciations.

```java
// src/main/scala/ScalatraBootstrap.scala
class ScalatraBootstrap exntends SkinnyLifeCycle {
  override def initSkinnyApp(ctx: ServletContext) {
    ctx.mount(new TxPerRequestFilter, "/*")
  }
}
```

And then your ORM models can retrieve the current DB session as a thread-local value per request, so you don't need to pass `DBSession` value as an implicit parameter in each method. 

```java
def findAllByGroupId(groupId: Long): List[Member] = findAllBy(sqls.eq(m.groupId, groupId)
```

On the other hand, if you work with multiple threads for single HTTP request, you should be aware that the thread-local DB session won't be shared.


<hr/>
### Using Non-Numerical or Typed Primary Key
<hr/>

SkinnyMapper expects a Long (bigint) value named `id` for primary key column.

If your application uses a non-numerical primary key for some reason, use `****WithId` traits instead. In this case, you must implement `idToRawValue` and `rawValueToId` methods.

If you need to use a complex object (e.g. `MemberId` class) as a primary key, it's also easy to implement.

```java
case class MemberId(value: Long)
case class Member(id: MemberId, name: String)

object Member extends SkinnyCRUDMapperWithId[MemberId, Member] {
  override def defaultAlias = createAlias("m")

  override def idToRawValue(id: MemberId) = id.value
  override def rawValueToId(v: Any) = MemberId(v.toString.toLong)

  def extract(rs: WrappedResultSet, m: ResultName[Member]) = new Member(
    id = rawValueToId(rs.string(m.id)),
    name = rs.string(m.name)
  )
}
```

And your SkinnyResource will be like this:

```java
package controller
import skinny._
import skinny.validator._
import model._

object CompaniesController extends SkinnyResourceWithId[CompanyId] with ApplicationController {
  protectFromForgery()

  implicit override val scalatraParamsIdTypeConverter = new TypeConverter[String, CompanyId] {
    def apply(s: String): Option[CompanyId] = Option(s).map(model.rawValueToId)
  }

  override def model = Company
  override def resourcesName = "companies"
  override def resourceName = "company"

  override def createParams = Params(params).withDateTime("updatedAt")
  override def createForm = validation(createParams,
    paramKey("name") is required & maxLength(64),
    paramKey("url") is maxLength(128)
  )
  override def createFormStrongParameters = Seq(
    "name" -> ParamType.String, "url" -> ParamType.String)

  override def updateParams = Params(params).withDateTime("updatedAt")
  override def updateForm = validation(updateParams,
    paramKey("name") is required & maxLength(64),
    paramKey("url") is maxLength(128)
  )
  override def updateFormStrongParameters = Seq(
    "name" -> ParamType.String, "url" -> ParamType.String)
}
```

If you use an alternative Id generator instead of the RDB's auto-incremental value, set `useExternalIdGenerator` as true and implement the `generateId` method.

```java
case class Member(uuid: UUID, name: String)

object Member extends SkinnyCRUDMapperWithId[UUID, Member] 
  with SoftDeleteWithBooleanFeatureWithId[UUID, Member] {
  override def defaultAlias = createAlias("m")

  override def primaryKeyFieldName = "uuid"

  // use alternative id generator instead of DB's auto-increment
  override def useExternalIdGenerator = true
  override def generateId = UUID.randomUUID

  override def idToRawValue(id: UUID) = id.toString
  override def rawValueToId(value: Any) = UUID.fromString(value.toString)

  def extract(rs: WrappedResultSet, m: ResultName[Member]) = new Member(
    uuid = rawValueToId(rs.string(m.uuid)),
    name = rs.string(m.name)
  )
}

val m: Option[Member] = Memmber.findById(UUID.fromString("....."))
```

Don't worry. Skinny-ORM does well at resolving associations even if you use custom primary keys.

<hr/>
### ActiveRecord-like Timestamps
<hr/>

`timetamps` from ActiveRecord is available as the `TimestampsFeature` trait. 

By default, this trait expects two columns on the table - `created_at timestamp not null` and `updated_at timestamp`. If you need customizing, override *FieldName methods as follows.

```java
class Member(id: Long, name: String, createdAt: DateTime, updatedAt: DateTime)

object Member extends SkinnyCRUDMapper[Member] with TimestampsFeature[Member] {

  // created_timestamp
  override def createdAtFieldName = "createdTimestamp"
  // updated_timestamp
  override def updatedAtFieldName = "updatedTimestamp"
}
```

Source code: 
https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/TimestampsFeature.scala

<hr/>
### Soft Deletion
<hr/>

Soft delete support is also available. 

By default, `deleted_at timestamp` column or `is_deleted boolean not null` is expected.

```java
object Member extends SkinnyCRUDMapper[Member]
  with SoftDeleteWithTimestampFeature[Member] {

  // deleted_timestamp timestamp
  override val deletedAtFieldName = "deletedTimestamp"
}
```

Source code: 
https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/SoftDeleteWithBooleanFeature.scala

Source code: 
https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/SoftDeleteWithTimestampFeature.scala

<hr/>
### Optimistic Lock
<hr/>

Furthermore, optimistic lock is also available. 

By default, `lock_version bigint not null` or `lock_timestamp timestamp` is expected

```java
object Member extends SkinnyCRUDMapper[Member]
  with OptimisticLockWithVersionFeature[Member]
// lock_version bigint
```

Source code: 
https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/OptimisticLockWithVersionFeature.scala

Source code: 
https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/OptimisticLockWithTimestampFeature.scala

<hr/>
### FactoryGirl
<hr/>

An easy-to-use fixture tool named FactoryGirl makes testing easy.

See in detail here: [FactoryGirl](factory-girl.html)

