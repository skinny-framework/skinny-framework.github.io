---
title: Packaging - Skinny Framework
---

## Packaging

<hr/>
### As you know, it's a servlet application
<hr/>

Skinny applications run on any Serlvet container. 

So you just need to build a war file and deploy it to your production servers.

<hr/>
### Packaging war file
<hr/>

It's very simple to do that. Just 

```
./skinny package
```

You will see the created war file under `build/target/scala_2.10`.

If you want to deploy the war file to a Maven repository (e.g. Artifactory), just run `./skinny publish` after customizing the build settings file.

<hr/>
### Creating stand alone app
<hr/>

What's more, you can easily create a stand alone jar file by just running the following command: 

```
./skinny package:standalone
```

After a while, you will get a standalone jar file. 

```
java -jar standalone-build/target/scala-2.10/skinny-standalone-app-assembly-0.1.0-SNAPSHOT.jar
```

You can pass configuration via system properties. Otherwise, it's also possible to use environment variables.

```
java -jar -Dskinny.port=9000 -Dskinny.env=production \
  standalone-build/target/scala-2.10/skinny-standalone-app-assembly-0.1.0-SNAPSHOT.jar
```

<hr/>
### Configuration
<hr/>

The following options are available to configure your Skinny applications. You can pass the following values from environment variables or system properties.

<hr/>
#### skinny.env or SKINNY_ENV
<hr/>

Default value is "development". If skinny.env is "production", application load the "production" settings from "src/main/resources/application.conf".

You can access the value via [`skinny.SkinnyEnv`](https://github.com/skinny-framework/skinny-framework/blob/develop/common/src/main/scala/skinny/SkinnyEnv.scala) in application.

<hr/>
#### skinny.port or SKINNY_PORT
<hr/>

This value is only for stand alone apps. Default value is 8080. You can customize the port number on which the stand alone app server listens.

<hr/>
### Deployment on Heroku
<hr/>

Hosting your Skinny app on Heroku is pretty simple.

First, make sure that you have the correct DB driver for the production environment. Since you're using Heroku, most likely you are using PostgreSQL. In that case, you will need to add a dependency that looks like this.

```
"org.postgresql"          % "postgresql"          % "9.3-1100-jdbc41" 
```

<hr/>
#### Setting up a Heroku app
<hr/>

Prerequisites: we assume you have a Heroku account and the Heroku toolbelt is installed. See the [Heroku documentation](https://devcenter.heroku.com/articles/quickstart) for more details on getting started with Heroku.

In the root directory of your Skinny app, run the following command.

```
$ heroku apps:create {app-name}
```

<hr/>
#### Deploying
<hr/>

Just push your app to git, and Heroku will stage and deploy it.

```
$ git init
$ git add . -v
$ git commit
$ git remote add heroku git@heroku.com:{app-name}.git
$ git push heroku master
```
 
Note that this will take a long time, as Heroku has to download the world every time it stages the app.

```
$ git push heroku master
Initializing repository, done.
Counting objects: 80, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (54/54), done.
Writing objects: 100% (80/80), 973.96 KiB | 223.00 KiB/s, done.
Total 80 (delta 1), reused 0 (delta 0)

-----> Scala app detected
-----> Installing OpenJDK 1.7...done
-----> Downloading SBT...done
-----> Running: sbt compile stage
       Getting org.scala-sbt sbt 0.13.0 ...
       downloading http://s3pository.heroku.com/ivy-typesafe-releases/org.scala-sbt/sbt/0.13.0/jars/sbt.jar ...
        [SUCCESSFUL ] org.scala-sbt#sbt;0.13.0!sbt.jar (511ms)

```

When the deployment completes, your app should be available to view in a web browser.

<hr/>
#### Running skinny commands
<hr/>

From the root directory of your Skinny app, execute the `heroku run` command.

```
$ heroku run heroku/skinny [args...]
```

For example, to perform a DB migration, you would run

```
$ heroku run heroku/skinny db:migrate production
```

<hr/>
#### Troubleshooting
<hr/>

If you have a file called `package.json` in the root directory, Heroku will get confused and try to deploy your app as a Node.js server. As a workaround, just delete or rename the `package.json` file.
