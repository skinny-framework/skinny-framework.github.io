---
title: Tasks - Skinny Framework
---

## Tasks

<hr/>
### Task Launcher

skinny-task is a mechanism to run tasks easily.

By default, the following tasks are already registered.

[task/src/main/scala/skinny/task/TaskLauncher.scala](https://github.com/skinny-framework/skinny-framework/blob/master/task/src/main/scala/skinny/task/TaskLauncher.scala)

skinny-blank-app prepares easy-to-use TaksRunner.

[task/src/main/scala/TaskRunner.scala](https://github.com/skinny-framework/skinny-framework/blob/master/yeoman-generator-skinny/app/templates/task/src/main/scala/TaskRunner.scala)


```java
object TaskLancher extends skinny.task.TaskLauncher {

  // def register(name: String, runner: (List[String]) => Unit)
  register("assets:precompile", (params) => {
    val buildDir = params.headOption.getOrElse("build")
    skinny.task.AssetsPrecompileTask.main(Array(buildDir))
  })
}
```

<hr/>
### Creating Custom Tasks

Creating tasks is pretty easy. It's just defining a function `(List[String]) => Unit`.

```java
register("echo", (params) => params foreach println)
```

Run the task:

```
sbt "task/run echo foo bar baz"

[info] Running TaskLancher echo foo bar baz
foo
bar
baz
```

Improve your development with tasks.

If you have good idea, please write a blog post or give us some feedback.
