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
├── Procfile # for Heroku deployment
├── README.md
├── bin
│   └── sbt-launch.jar # global sbt script in PATH is given priority over this
├── build.sbt
├── heroku # for Heroku deployment
│   ├── common.sh
│   ├── run
│   ├── skinny
│   └── stage
├── project
│   ├── Build.scala
│   ├── build.properties
│   └── plugins.sbt
├── sbt      # Skinny uses this sbt command
├── sbt.bat  # Skinny uses this sbt command
├── skinny     # skinny command for Mac OS X, Linux
├── skinny.bat # skinny command for Windows
├── src
│   ├── main
│   │   ├── resources
│   │   │   ├── application.conf
│   │   │   ├── logback.xml
│   │   │   └── messages.conf
│   │   ├── scala
│   │   │   ├── ScalatraBootstrap.scala # Scalatra convention
│   │   │   ├── controller
│   │   │   │   ├── ApplicationController.scala
│   │   │   │   ├── Controllers.scala
│   │   │   │   └── RootController.scala
│   │   │   ├── lib
│   │   │   ├── model
│   │   │   │   └── package.scala
│   │   │   └── templates
│   │   │       └── ScalatePackage.scala # Scalate convention
│   │   └── webapp
│   │       └── WEB-INF
│   │           ├── assets
│   │           │   ├── build.sbt
│   │           │   ├── coffee # Put coffee scripts here
│   │           │   ├── jsx    # Put React JSX templates here
│   │           │   ├── less   # Put LESS files here
│   │           │   ├── scala  # Put Scala.js code here
│   │           │   └── scss   # Put sass/scss files here
│   │           ├── layouts
│   │           │   └── default.ssp # layout template
│   │           ├── views
│   │           │   ├── error
│   │           │   │   ├── 403.html.jade
│   │           │   │   ├── 403.html.mustache
│   │           │   │   ├── 403.html.scaml
│   │           │   │   ├── 403.html.ssp
│   │           │   │   ├── 404.html.jade
│   │           │   │   ├── 404.html.mustache
│   │           │   │   ├── 404.html.scaml
│   │           │   │   ├── 404.html.ssp
│   │           │   │   ├── 406.html.jade
│   │           │   │   ├── 406.html.mustache
│   │           │   │   ├── 406.html.scaml
│   │           │   │   ├── 406.html.ssp
│   │           │   │   ├── 500.html.jade
│   │           │   │   ├── 500.html.mustache
│   │           │   │   ├── 500.html.scaml
│   │           │   │   ├── 500.html.ssp
│   │           │   │   ├── 503.html.jade
│   │           │   │   ├── 503.html.mustache
│   │           │   │   ├── 503.html.scaml
│   │           │   │   └── 503.html.ssp
│   │           │   └── root
│   │           │       └── index.html.ssp # default top page
│   │           └── web.xml # because this is on the Servlet
│   └── test
│       ├── resources
│       │   ├── factories.conf # for FactoryGirl
│       │   └── logback.xml
│       └── scala
│           ├── controller
│           │   └── RootControllerSpec.scala # testing with MockController
│           └── integrationtest
│               └── RootController_IntegrationTestSpec.scala # testing with embedded Jetty (scalatra-test)
├── system.properties # for Heroku deployment
└── task
    └── src
        └── main
            └── scala
                └── TaskRunner.scala # when you add new tasks, modify this code
```

