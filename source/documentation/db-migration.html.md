---
title: DB Migration - Skinny Framework
---

## DB Migration

<hr/>
### Flyway

DB migration comes with [Flyway](http://flywaydb.org/).

![Flyway Logo](images/flyway.png)

<hr/>
### Simple Usage

Just run the following command.

```
./skinny db:migrate [env] [dbname]
````

This command expects `src/main/resources/db/migration/V***_***.sql` files.

### Customizing Migration

If you need to change the location of SQL files or need to migrate several DBs, modify `{env}.db.{dbname}.migration.locations` in `application.conf`.

In the following example, db:migrate command scans under `src/main/resources/db/migration/development/default`.

```
development {
  db {
    default {
      driver="org.h2.Driver"
      url="jdbc:h2:file:db/example-development"
      user="sa"
      password="sa"
      migration {
        locations: ["development.default"]
      }
    }
  }
}
```

Yet anothe DB's migration example:

```
development {
  db {
    yetanother {
      driver="org.h2.Driver"
      url="jdbc:h2:file:db/yetanother"
      user="sa"
      password="sa"
      migration {
        locations: ["development.yetanother"]
      }
    }
  }
}
```

Command is like this:

```
./skinny db:migrate development yetanother
```

<hr/>
### Try now

Scaffolding generates migration SQL file. Try it with [blank-app](https://github.com/skinny-framework/skinny-framework/releases)!

```
./skinny g scaffold:jade members member name:String birthday:LocalDate
```

```
./skinny db:migrate
./skinny db:migrate test
````
