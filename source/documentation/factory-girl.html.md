---
title: FactoryGirl - Skinny Framework
---

## FactoryGirl

<hr/>
### Easy-to-use Fixture

Though Skinny's FactoryGirl is not a complete port of [thoughtbot/factory_girl](https://github.com/thoughtbot/factory_girl), this module will be quite useful when testing your apps.

FactoryGirl is a part of Skinny ORM, so you can use FactoryGirl even in your Play2 apps!

Just add skinny-orm to your apps.

```
libraryDependencies += "org.skinny-framewrok" %% "skinny-orm" % "[0.9,)"
```

<hr/>
### Usage

FactoryGirl' usage is very simple.

- Defining `SkinnyCRUDMapper`
- Append definitions to `factories.conf`

Exaple code:

```java
case class Company(id: Long, name: String)
object Company extends SkinnyCRUDMapper[Company] {
  def extract ...
}
case class Member ...
object Member extends SkinnyCRUDMapper[Member] ...
case class Country ...
object Country extends SkinnyCRUDMapper[Country] ...


val company1 = FactoryGirl(Company).create()
val company2 = FactoryGirl(Company).create('name -> "FactoryPal, Inc.")

val country = FactoryGirl(Country, 'countryyy).create()

val memberFactory = FactoryGirl(Member).withValues('countryId -> country.id)
val member = memberFactory.create('companyId -> company1.id, 'createdAt -> DateTime.now)
```

In this example, `src/test/resources/factories.conf` is like this:

```
countryyy {
  name="Japan"
}
member {
  countryId="#{countryId}"
}
company {
  name="FactoryGirl, Inc."
}
name {
  first="Kazuhiro"
  last="Sera"
}
skill {
  name="Scala Programming"
}
```

<hr/>
### More Examples:

You can find more examples here:

[orm/src/test/scala/skinny/orm/SkinnyORMSpec.scala](https://github.com/skinny-framework/skinny-framework/blob/master/orm/src/test/scala/skinny/orm/SkinnyORMSpec.scala)

[example/src/test](https://github.com/skinny-framework/skinny-framework/tree/master/example/src/test)

