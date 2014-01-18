---
title: Contribution - Skinny Framework
---

## Contribution

<hr/>
### Website
<hr/>

#### fork skinny-framework.github.io project

Fork [https://github.com/skinny-framework/skinny-framework.github.io](https://github.com/skinny-framework/skinny-framework.github.io).

<hr/>
#### change under the website directory

How to debug:

```
git clone [your forked repository].
cd skinny-framework.github.io
gem install bundler
bundle install
bundle exec middleman server
```

Access `http://localhost:4567` from your browser.

<hr/>
#### make a pull request

Create a branch to request, and send your pull request to `develop` branch (not `master` branch).


<hr/>
### Libraries
<hr/>

#### fork skinny-framework project

Fork [https://github.com/skinny-framework/skinny-framework](https://github.com/skinny-framework/skinny-framework).

```
git clone [your forked repository].
```

<hr/>
#### modify and write tests

Modify code & write test.

<hr/>
#### run all the existing tests

Run all the tests at least with H2 database.


```sh
rm -rf db/example-test*
./skinny db:migrate test
sbt test
```

<hr/>
#### make a pull request

Create a branch to request, and send your pull request to `develop` branch (not `master` branch).

