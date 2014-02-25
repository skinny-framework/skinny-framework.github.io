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


