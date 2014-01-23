---
title: Packaging - Skinny Framework
---

## Packaging

<hr/>
### As you know, it's a servlet application
<hr/>

Skinny applications runs on any Serlvet containers. 

So what you need to do is just creating war file and deploying it to your production servers.

<hr/>
### Packaging war file
<hr/>

It's utmost simple to do that. Just 

```
./skinny package
```

You will see created war file under `build/target/scala_2.10`.

If you deploy war file to maven repository (e.g. Artifactory), just `./skinny publish` after configuring build settings (default settings doesn't work for you).

<hr/>
### Creating stand alone app
<hr/>

What's more, you can easily create stand alone jar file by just run the following command: 

```
./skinny package:standalone
```

After a while, you will get standalone jar file. 

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

Options to configure your Skinny applications. You can pass the following values from environment variables or system properties.

<hr/>
#### skinny.env or SKINNY_ENV
<hr/>

Default value is "development". If skinny.env is "production", application load the "production" settings from "src/main/resources/application.conf".

You can access the value via [`skinny.SkinnyEnv`](https://github.com/skinny-framework/skinny-framework/blob/develop/common/src/main/scala/skinny/SkinnyEnv.scala) in application.

<hr/>
#### skinny.port
<hr/>

This value is only for stand alone apps. Default value is 8080. You can customize the port number stand alone app server listens.


