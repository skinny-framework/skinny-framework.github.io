---
title: DB Migration - Skinny Framework
---

## DB Migration

<hr/>
### Flyway
<hr/>

DB migration is provided by [Flyway](http://flywaydb.org/).

![Flyway Logo](images/flyway.png)

<hr/>
### Simple Usage
<hr/>

Just run the following command.

```
./skinny db:migrate [env] [dbname]
````

This command expects `src/main/resources/db/migration/V***__***.sql` files. 

Note the double underscore in the filename.

When your migration file is invalid and migration failed, you must do `db:repair` before retrying the migration.

```
./skinny db:repair [env] [dbname]
# fix your invalid migration file
./skinny db:migrate [env] [dbname]
```

<hr/>
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

Yet another DB migration example:

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
<hr/>

Scaffolding generates a migration SQL file. Try it with [skinny-blank-app.zip](https://github.com/skinny-framework/skinny-framework/releases)!

```
./skinny g scaffold:jade members member name:String birthday:LocalDate
```

```
./skinny db:migrate
./skinny db:migrate test
````

When your migration failed, Run `db:repair` command and fix migration files.

```
./skinny db:repair

// fix migration files...

// retry!
./skinny db:migrate
```

<hr/>
### FAQ
<hr/>

#### How to access schema_version table?

Flyway creates a table named `"schema_version"` for H2 database. 

```scala
sql"""select "version" from "schema_version" """.map(_.string(1)).list.apply()
```

FYI:

http://stackoverflow.com/questions/13850499/flyway-and-h2-why-are-the-schema-version-table-and-columns-lower-case-and-case



