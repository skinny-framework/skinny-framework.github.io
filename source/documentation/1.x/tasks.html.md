---
title: Tasks - Skinny Framework
---

## Tasks

<hr/>
### Task Launcher
<hr/>

skinny-task is a mechanism to run tasks easily. By default, the following tasks are already registered.

[task/src/main/scala/skinny/task/TaskLauncher.scala](https://github.com/skinny-framework/skinny-framework/blob/master/task/src/main/scala/skinny/task/TaskLauncher.scala)

skinny-blank-app prepares the easy-to-use `TaskRunner`.

[task/src/main/scala/TaskRunner.scala](https://github.com/skinny-framework/skinny-framework/blob/master/yeoman-generator-skinny/app/templates/task/src/main/scala/TaskRunner.scala)


```scala
object TaskRunner extends skinny.task.TaskLauncher {

  // def register(name: String, runner: (List[String]) => Unit)
  register("assets:precompile", (params) => {
    val buildDir = params.headOption.getOrElse("build")
    skinny.task.AssetsPrecompileTask.main(Array(buildDir))
  })
}
```

<hr/>
### Creating Your Own Tasks
<hr/>

Creating tasks is pretty easy. You just need to define a function `(List[String]) => Unit`.

```scala
register("echo", (params) => params foreach println)
```

Run the task:

```
sbt "task/run echo foo bar baz"

[info] Running TaskLauncher echo foo bar baz
foo
bar
baz
```

Improve your development with tasks.

If you have any good ideas for how to use tasks or improve the API, please write a blog post or give us some feedback.
