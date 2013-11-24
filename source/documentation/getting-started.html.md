---
title: Getting Started - Skinny Framework
---

## Getting Started

<hr/>
### Downloading skinny-blank-app.zip

We highly recommend using skinny-blank-app for your first Skinny app.

[github.com/skinny-framework/skinny-framework/releases](https://github.com/skinny-framework/skinny-framework/releases)

Download latest `skinny-blank-app.zip` and unzip it, then just run ./skinny command on your terminal. That's all!

If you're a Windows user, don't worry. Use skinny.bat on cmd.exe instead.

```sh
./skinny run
```

And then, access `http://localhost:8080/` and app should return 200 OK.

<hr/>
### Using generator

Let's create your first Skinny app by using scaffold generator.

```sh
./skinny g scaffold members member name:String activated:Boolean luckyNumber:Option[Long] birthday:Option[LocalDate]
./skinny db:migrate
./skinny run
```

And then, access `http://localhost:8080/members`.

You can run generated tests.

```
./skinny db:migrate test
./skinny test
```

If you just need a controller, run generator like this:

```sh
./skinny g controller help
```

And then, access `http://localhost:8080/help`.

Finally, let's create war file to deploy.

```sh
./skinny package
```

<hr/>
### Yeoman generator

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

The following tree is directories and files in skinny-blank-app project. Basically using this style is preferred.

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
│   │       │   │   │   └── echo.coffee # converted JS at localhost:8080/assets/echo.js
│   │       │   │   └── less
│   │       │   │       └── box.less    # converted CSS at localhost:8080/assets/box.css
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
│   │               ├── jquery-2.0.3.min.js
│   │               └── jquery-2.0.3.min.map
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

