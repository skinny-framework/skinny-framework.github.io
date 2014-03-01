---
title: Getting Started - Skinny Framework
---

## Getting Started

<hr/>
### Downloading skinny-blank-app.zip
<hr/>

We highly recommend using skinny-blank-app for your first Skinny app.

[github.com/skinny-framework/skinny-framework/releases](https://github.com/skinny-framework/skinny-framework/releases)

Download latest `skinny-blank-app.zip` and unzip it, then just run ./skinny command on your terminal. That's all!

If you're a Windows user, don't worry. Use skinny.bat on cmd.exe instead.

```sh
./skinny run
```

And then, access `http://localhost:8080/` and the app should return 200 OK.

<hr/>
### Using generator
<hr/>

Let's create our first Skinny app by using the scaffold generator.

```sh
./skinny g scaffold members member name:String activated:Boolean luckyNumber:Option[Long] birthday:Option[LocalDate]
./skinny db:migrate
./skinny run
```

FYI: It's also possible to specify the column data type for each field. However you will need to add the length validation code to MembersController yourself.

```sh
./skinny g scaffold members member "name:String:varchar(128)"
```

And then, access `http://localhost:8080/members`.

See in detail here: [Scaffolding](/documentation/scaffolding.html)

You can also run the generated tests.

```
./skinny db:migrate test
./skinny test
```

If you just need a controller, run the generator like this:

```sh
./skinny g controller help
```

And then, access `http://localhost:8080/help`.

Finally, let's create a war file to deploy.

```sh
./skinny package
```

<hr/>
### Yeoman generator
<hr/>

![Yeoman](images/yeoman.png)

If you're familiar with [Yeoman](http://yeoman.io), a generator for [Skinny framework](https://github.com/skinny-framework/skinny-framework) is available.

```sh
# brew instsall node
npm install -g yo
npm install -g generator-skinny
mkdir skinny-app
cd skinny-app
yo skinny
./skinny run
```

<hr/>
### Project Structure
<hr/>

The following tree shows the directories and files in skinny-blank-app project. Using this directory layout is recommended.

```sh
.
├── README.md
├── bin
│   └── sbt-launch.jar # global sbt script in PATH is given priority over this
├── build              # packaging war file uses this directory
├── build.sbt
├── project
│   ├── Build.scala
│   ├── build.properties
│   └── plugins.sbt
├── sbt        # global sbt script in PATH is given priority over this
├── sbt.bat    # global sbt script in PATH is given priority over this
├── skinny     # skinny command for Mac/Linux users
├── skinny.bat # skinny command for Windows users
├── src
│   ├── main
│   │   ├── resources
│   │   │   ├── application.conf # app configuration
│   │   │   ├── logback.xml      # logging configuration
│   │   │   └── messages.conf    # error messages, i18n
│   │   ├── scala
│   │   │   ├── ScalatraBootstrap.scala   # should be here and should be this name for Scalatra
│   │   │   ├── controller                # this package can be changed
│   │   │   │   ├── ApplicationController.scala
│   │   │   │   ├── Controllers.scala     # a preferred way to collect controllers with routes
│   │   │   │   └── RootController.scala
│   │   │   ├── lib   # same as Rails's lib directory
│   │   │   ├── model # Skinny ORM models or other models
│   │   │   └── templates
│   │   │       └── ScalatePackage.scala # should be here and should this name for Scalate
│   │   └── webapp
│   │       ├── WEB-INF
│   │       │   ├── assets
│   │       │   │   ├── coffee
│   │       │   │   jsx
│   │       │   │   less
│   │       │   │   scss
│   │       │   ├── layouts
│   │       │   │   └── default.jade # layout file (ssp, scaml and mustache are also OK)
│   │       │   ├── views
│   │       │   │   ├── error
│   │       │   │   │   ├── 403.html.jade
│   │       │   │   │   ├── 403.html.scaml
│   │       │   │   │   ├── 403.html.ssp
│   │       │   │   │   ├── 404.html.jade
│   │       │   │   │   ├── 404.html.scaml
│   │       │   │   │   ├── 404.html.ssp
│   │       │   │   │   ├── 406.html.jade
│   │       │   │   │   ├── 406.html.scaml
│   │       │   │   │   ├── 406.html.ssp
│   │       │   │   │   ├── 500.html.jade
│   │       │   │   │   ├── 500.html.scaml
│   │       │   │   │   ├── 500.html.ssp
│   │       │   │   │   ├── 503.html.jade
│   │       │   │   │   ├── 503.html.scaml
│   │       │   │   │   └── 503.html.ssp
│   │       │   │   └── root
│   │       │   │       └── index.html.ssp # render("/root/index") expects this file
│   │       │   └── web.xml
│   │       └── assets
│   │           └── js
│   └── test
│       ├── resources
│       │   ├── factories.conf # FactoryGirl's configuration
│       │   └── logback.xml    # logging in Test
│       └── scala
│           └── controller
│               └── RootControllerSpec.scala
└── task
    └── src
        └── main
            └── scala
                └── TaskRunner.scala # if you add new tasks, modify this 
```

<hr/>
### Tips for Developers

<hr/>
#### Avoiding sbt's frequent OOMError 

Skinny Framework uses xsbt-web-plugin. `skinny run` with sbt plugin invokes Jetty and detects source code changes and re-compiles and restarts Jetty server. Eventually, you will see OutOfMemoryError (PermGen) after refreshing several times. To reduce this pain, specify sbt options like this:

```
SBT_OPTS="-XX:+CMSClassUnloadingEnabled -Xmx2048M -XX:MaxPermSize=512M"
```

