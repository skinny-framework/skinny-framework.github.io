---
title: ORM - Skinny Framework
---

## ORM

<hr/>
### Skinny-ORM

Skinny provides you Skinny-ORM as the default O/R mapper, which is built with [ScalikeJDBC](https://github.com/scalikejdbc/scalikejdbc). This is a portable library. So you can use it with Play2, pure Scalatra, Lift and any other frameworks.

![Logo](images/scalikejdbc.png)

Skinny-ORM is natually characterized by avoding N+1 queries because associations are resolved by join queries. 

`#belongTo`, `#hasOne` and `#hasMany(Through)` associations are converted into join queries, so you don't need to take care about performance problems caused by so many N+1 queries any more. 

Furthermore, the `#byDefault` option allows you resolving assocations anytime. If you don't always need some association, miss the `#byDefault` and just use `#joins` method such as `Team.joins(Team.members).findById(123)` on demand.

On the other hand, it's impossible to resolve all the nested attributes' relationships by single join query. If you need to resolve nested relationships, you can retrieve them with eagar loading by using `#includes` method.

Examples:

[orm/src/test/scala/skinny/orm/models.scala](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/test/scala/skinny/orm/models.scala)

[orm/src/test/scala/skinny/orm/SkinnyORMSpec.scala](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/test/scala/skinny/orm/SkinnyORMSpec.scala)

<hr/>
### Your First Mapper

<hr/>
#### Easy to use and powerful

Skinny-ORM is much powerful, so you don't need to write much code. Your first model class and companion are here.

```java
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

// ------------
// find by condition
val members: List[Member] = Member.findAllBy(
  sqls.eq(m.groupName, "scalajp").and.eq(m.delete, false))

val members: List[Member] = Member.where(
  'groupName -> "scalajp", 'deleted -> false).apply()

// ------------
// count
val allCount: Long = Member.countAll()

val count = Member.where('deletedAt -> None, 'countryId -> 123).count.apply()

val count = Member.countBy(sqls.isNull(m.deletedAt).and.eq(m.countryId, 123))

// ------------
// create with strong parameters
val params = Map("name" -> "Bob")
val id = Member.createWithPermittedAttributes(params.permit("name" -> ParamType.String))

// ------------
// create with unsafe parameters
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
// delete by condition
Member.deleteBy(sqls.eq(m.groupId, 123))
```

Source code: [skinny.orm.feature.CRUDFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/CRUDFeature.scala)

<hr/>
#### Associations

If you need to join other tables, just add `belongsTo`, `hasOne` or `hasMany(Through)` to the companion.

```java
class Member(id: Long, name: String, companyId: Long,
  company: Option[Company] = None, skills: Seq[Skill] = Nil)

object Member extends SkinnyCRUDMapper[Member] {
  override def defaultAlias = createAlias("m")

  // If byDefault is called, this join condition is enabled by default
  belongsTo[Company](Company, (m, c) => m.copy(company = Some(c))).byDefault

  val skills = hasManyThrough[Skill](
    MemberSkill, Skill, (m, skills) => m.copy(skills = skills))
}

Member.findById(123) // without skills

Member.joins(Member.skills).findById(123) // with skills
```

Source code: [skinny.orm.feature.AssociationsFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/AssociationsFeature.scala)

<hr/>
##### Entity Equality

Basically using case classes for entities is recommended. As you know, Scala (until 2.11) has 22 limitation, so you may need to use normal classes for entities to treat tables that have more than 22 columns.

In this case, entity should be defined like this (Skinny 0.9.21 or ScalikeJDBC 1.7.3 is required):

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

If you missed above implementation, one-to-many relationships doesn't work as you expect.

<hr/>
#### Eager Loading

You can call `includes` for eager loading. But nested entities's eager loading is not supported yet.

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

Source code: [skinny.orm.feature.IncludesFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/IncludesFeature.scala)


<hr/>
#### Other Settings

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
  // createWithAttributes will try returing generated id if true
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
  override val lockTimestampFieldName = "locked_at"

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
#### Dynamic Table Name

`#withTableName` enables using another table name only for current query.

```java
object Order extends SkinnyCRUDMapper[Order] {
  override def defaultAlias = createAlias("o")
  override def tableName = "orders"
}

// default: orders
Order.countAll()

// other table: orders_2012
Order.withTableName("orders_2012").countAll()
```

Source code: [skinny.orm.feature.DynamicTableNameFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/DynamicTableNameFeature.scala)

<hr/>
#### Adding Methods

If you need to add methods, just write methods that use `#findBy`, `#countBy` or ScalikeJDBC' APIs directly.

```java
object Member extends SkinnyCRUDMapper[Member] {
  private[this] val m = defaultAlias

  def findAllByGroupId(groupId: Long)(implicit s: DBSession = autoSession): Seq[Member] = {
    findAllBy(sqls.eq(m.groupId, groupId))
  }
}
```

If you're using ORM with Skinny Framework,
[skinny.orm.servlet.TxPerRequestFilter](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/servlet/TxPerRequestFilter.scala) simplifies your applciations.

```java
// src/main/scala/ScalatraBootstrap.scala
class ScalatraBootstrap exntends SkinnyLifeCycle {
  override def initSkinnyApp(ctx: ServletContext) {
    ctx.mount(new TxPerRequestFilter, "/*")
  }
}
```

And then your ORM models can retrieve current DB session as thread-local value per request, so you don't need to pass `DBSession` value as an implicit parameter in each method. 

```java
def findAllByGroupId(groupId: Long): List[Member] = findAllBy(sqls.eq(m.groupId, groupId)
```

On the other hand, if you work with multiple threads for single HTTP request, you should be aware that the thread-local db session won't be shared.


<hr/>
#### Using Non-numerical Primary Key

SkinnyMapper expects Long (bigint) value named `id` for primary key column.

If your application uses non-numerical primary key for some reasons, use `****WithId` traits instead. In this case, you must implement `idToRawValue`, `rawValueToId` and `generateId` methods.

```java
case class Member(uuid: UUID, name: String)

object Member extends SkinnyCRUDMapperWithId[UUID, Member] 
  with SoftDeleteWithBooleanFeatureWithId[UUID, Member] {
  override def defaultAlias = createAlias("m")

  override def primaryKeyFieldName = "uuid"

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

If you need `MemberId` class for primary key, it's also easy to implement.

```java
case class MemberId(value: Long)
case class Member(id: MemberId, name: String)

object Member extends SkinnyCRUDMapperWithId[MemberId, Member] {
  override def defaultAlias = createAlias("m")

  override def generateId = getNewIdFromExternalSystem()
  override def idToRawValue(id: MemberId) = id.value
  override def rawValueToId(v: Any) = MemberId(v.toString.toLong)

  def extract(rs: WrappedResultSet, m: ResultName[Member]) = new Member(
    id = rawValueToId(rs.string(m.id)),
    name = rs.string(m.name)
  )
}
```

Don't worry. Skinny-ORM does well at resolving associations even if you use custom primary keys.

<hr/>
#### Timestamps

`timetamps` from ActiveRecord is available as the `TimestampsFeature` trait. 

By default, this trait expects two columns on the table - `created_at timestamp not null` and `updated_at timestamp`. If you need customizing, override *FieldName methods as follows.

```java
class Member(id: Long, name: String,
  createdAt: DateTime,
  updatedAt: Option[DateTime] = None)

object Member extends SkinnyCRUDMapper[Member] with TimestampsFeature[Member] {

  // created_timestamp
  override def createdAtFieldName = "createdTimestamp"
  // updated_timestamp
  override def updatedAtFieldName = "updatedTimestamp"
}
```

Source code: [skinny.orm.feature.TimestampsFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/TimestampsFeature.scala)

<hr/>
#### Soft Deletion

Soft delete support is also available. 

By default, `deleted_at timestamp` column or `is_deleted boolean not null` is expected.

```java
object Member extends SkinnyCRUDMapper[Member]
  with SoftDeleteWithTimestampFeature[Member] {

  // deleted_timestamp timestamp
  override val deletedAtFieldName = "deletedTimestamp"
}
```

Source code: [skinny.orm.feature.SoftDeleteWithBooleanFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/SoftDeleteWithBooleanFeature.scala)

Source code: [skinny.orm.feature.SoftDeleteWithTimestampFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/SoftDeleteWithTimestampFeature.scala)

<hr/>
#### Optimistic Lock

Furthermore, optimistic lock is also available. 

By default, `lock_version bigint not null` or `lock_timestamp timestamp` is expected

```java
object Member extends SkinnyCRUDMapper[Member]
  with OptimisticLockWithVersionFeature[Member]
// lock_version bigint
```

Source code: [skinny.orm.feature.OptimisticLockWithVersionFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/OptimisticLockWithVersionFeature.scala)

Source code: [skinny.orm.feature.OptimisticLockWithTimestampFeature.scala](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/main/scala/skinny/orm/feature/OptimisticLockWithTimestampFeature.scala)

<hr/>
#### FactoryGirl

Easy-to-use fixture tool named FactoryGirl makes your testing more comfortable.

See in detail here: [FactoryGirl](factory-girl.html)

