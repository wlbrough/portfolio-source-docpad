---
layout: "post"
date: 2015-04-23
hasCode: true
title: "TodoMVC in ember-cli"
---

A few weeks ago, I decided to jump into Ember.js and try my hand at building a
fully client-side app. The tutorial on Ember’s site that walks through an
implementation of TodoMVC is well written and has good depth, but it is somewhat
outdated. It includes some depricated elements and does not use ember-cli, which
is the recommended implementation as of the current version.

As a way to teach myself the new framework and to provide others a good basis
for starting out, I decided to rework the existing tutorial to bring it up to
date.

This tutorial borrows heavily from the original work done by [Trek
Glowacki](https://github.com/trek).

Installation directions can be found on the [Ember.js
website](http://guides.emberjs.com/v1.11.0/ember-cli/).

The original tutorial can be found on the [Ember.js
website](http://guides.emberjs.com/v1.10.0/getting-started/planning-the-application/).

The source for this tutorial is available on
[github](https://github.com/wlbrough/ember-cli-todomvc).

### Create the application skeleton

Navigate to the folder that you want to create your project in and execute the
following.

```bash
ember new ember-cli-todomvc
cd ember-cli-todomvc
ember serve
```

This will scaffold out the application structure and give you a starting point
to build on. All bash commands going forward are in the application directory.
When files are referenced throughout this tutorial, they will be provided with
the path assuming that the application directory is the base.

`ember serve` instantates a server that you can access at `localhost:4200`
and will watch for changes in the application directory.

### Install TodoMVC base

The fine folks at [TodoMVC](http://www.todomvc.com/) provide the CSS for the
application, so we don’t have to build it from scratch.

```bash
ember install:bower todomvc-app-css
ember install:bower todomvc-common
```

All dependencies are added to `Brocfile.js` before `module.exports =
app.toTree();`. You can only import assets from the bower_components and vendor
directories.

```javascript
app.import('bower_components/todomvc-common/base.css');
app.import('bower_components/todomvc-app-css/index.css');
```

### Create a static mockup of the app

Before adding any code, create a static mockup of the app to
`app/templates/application.hbs`. There is no need to add links to the CSS
files, as that will be handled by Ember’s built-in dependency management.

```handlebars
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Ember.js • TodoMVC</title>
  </head>
  <body>
    <section class="todoapp">
      <header class="header">
        <h1>todos</h1>
        <input type="text" class="new-todo" placeholder="What needs to be done?" />
      </header>

      <section class="main">
        <ul class="todo-list">
          <li class="completed">
            <input type="checkbox" class="toggle">
            <label>Learn Ember.js</label><button class="destroy"></button>
          </li>
          <li>
            <input type="checkbox" class="toggle">
            <label>...</label><button class="destroy"></button>
          </li>
          <li>
            <input type="checkbox" class="toggle">
            <label>Profit!</label><button class="destroy"></button>
          </li>
        </ul>

        <input type="checkbox" class="toggle-all">
      </section>

      <footer class="footer">
        <span class="todo-count">
          <strong>2</strong> todos left
        </span>
        <ul class="filters">
          <li>
            <a href="all" class="selected">All</a>
          </li>
          <li>
            <a href="active">Active</a>
          </li>
          <li>
            <a href="completed">Completed</a>
          </li>
        </ul>

        <button class="clear-completed">
          Clear completed (1)
        </button>
      </footer>
    </section>

    <footer class="info">
      <p>Double-click to edit a todo</p>
    </footer>
  </body>
</html>
```

This will be modified throughout the tutorial as features are implemented.

### Adding first route and template

ember-cli utilizes generators similar to Rails. Generators are called using
`ember generate` or `ember g` for short. This tutorial will use the short
form.

The `route` generator has two options:

* `type` can be either `route` or `resource`
* `path` which specifies a path other than what can be directly inferred using
the route name

A `resource` does not change the URI, whereas a `route` does.

Use the route generator to create a resource at the URI root.

```bash
ember g route todos --type=resource --path '/'
```

The generator will create three files:

* app/routes/todos.js
* app/templates/todos.hbs
* tests/unit/routes/todos-test.js

The generator also modifies `app/router.js` to reflect the new route/resource.

Copy all HTML between `<body>` and `</body>` to `app/templates/todos.hbs`.
Replace copied HTML in `app/templates/application.hbs` with `{{outlet}}`.

```handlebars
//...
<body>
    {{outlet}}
</body>
//...
```

### Modeling data

Use the model generator to create a new `todo` model.

```bash
ember generate model todo
```

This will create two new files:

* /app/models/todo.js
* tests/unit/models/todo-test.js

Modify `app/models/todo.js` to the following

```javascript
export default DS.Model.extend({
    title: DS.attr('string'),
    isCompleted: DS.attr('boolean')
});
```

### Create mock for fixture data

Previous versions of Ember used fixtures for mock data. While fixtures are still
available, it is now recommended that you use http-mock which creates a simple
Express.js server that will run when you use `ember serve`.

http-mock is very simple to setup and use. The generator does most of the work
for you.

```bash
ember g http-mock todos
```

Add the mock data in JSON format between the `[]` in
`server/mocks/todos.js`.

```json
{
    id: 1,
    title: 'Learn Ember.js',
    isCompleted: true
},
{
    id: 2,
    title: '...',
    isCompleted: false
},
{
    id: 3,
    title: 'Profit!',
    isCompleted: false
}
```

Use the generator to create a new adapter.

```bash
ember g adapter application
```

The adapter will be created at `app/adapters/application.js`. Open this file
and modify it to read as follows.

```javascript
import DS from 'ember-data';

export default DS.RESTAdapter.extend({
    namespace: 'api'
});
```

By default, http-mock serves the data from /api/todos, which necessitates the
namespace.

### Displaying model data

Now that data is available to the application, the code will be modified to
display the dynamic data rather than the static mockup.

To serve the data to the template, we first need to modify
`app/routes/todos.js` so it knows what data to pull. Add the following inside
the `extend` block.

```javascript
model: function() {
    return this.store.find('todo');
}
```

Now `app/templates/todos.hbs` can be modified to replace the static `<li>`
elements with the Handlebars `{{each}}` helper.

```handlebars
//...
<ul class="todo-list">
    {{#each todo in model}}
        <li>
            <input type="checkbox" class="toggle">
            <label>{{todo.title}}</label><button class="destroy"></button>
        </li>
    {{/each}}
</ul>
//...
```

Because no custom behavior is required from the controller at this point, we can
rely on the default controller provided by the framework.

### Displaying a model’s complete state

TodoMVC uses the `completed` class to apply a strikethrough to completed
todos. Modify the `<li>` element in `app/templates/todos.hbs` to apply the
class when a todo’s `isCompleted` property is true.

```handlebars
<li {{bind-attr class="todo.isCompleted:completed"}}>
```

### Creating a new model instance

Now that we can display the data, we can make some changes so we can add items
to the todo list.

First, replace the `input` element in `apps/templates/todos.hbs` with an
`{{input}}` helper.

```handlebars
    <h1>todos</h1>
    {{input type="text" class="new-todo" placeholder="What needs to be done?" value=newTitle action="createTodo"}}
    //...
```

The helper binds the `newTitle` property of the controller to the `value`
attribute of the input.

Next, use the generator to create a `todos` controller to implement custom
logic.

```bash
ember g controller todos
```

In the newly generated `app/controllers/todos.js` change
`Ember.Controller.extend` to `Ember.ArrayController.extend` so it will
handle the array data that we are passing to it.

Add the following to the extend block

```javascript
actions: {
    createTodo: function() {
        var title = this.get('newTitle');
        if (!title.trim()) { return; }

        var todo = this.store.createRecord('todo', {
            title: title,
            isCompleted: false
        });

        this.set('newTitle', '');

        todo.save();
    }
}
```

`createTodo` gets the `newTitle` property and creates a new todo record
using the input as the title and setting `isCompleted` to false. It then
clears the input and saves the record to the store.

### Marking a model as complete or incomplete

Next up, we will add the ability to mark a todo as complete or incomplete and
persist the update.

First, update a`pp/templates/todos.hbs` by adding an `itemController` to the
`{{each}}` helper. Also, convert the static `<input>` element to an
`{{input}}` helper.

```handlebars
{{#each todo in model itemController="todo"}}
    <li {{bind-attr class="todo.model.isCompleted:completed"}}>
        {{input type="checkbox" checked=todo.model.isCompleted class="toggle"}}
        <label >{{todo.model.title}}</label><button class="destroy"></button>
    </li>
{{/each}}
```

Notice that `todo.isCompleted` has been changed to `todo.model.isCompleted`.
This is a result of the way the new todo controller is structured. Ember
recently depricated the `ObjectController` class in favor of the easier to
remember `Controller` class, which is part of the reason for this change.

A new controller needs to be created for working with the individual todos. Use
the generator to create the controller.

```bash
ember g controller todo
```

In the `extend` block of `app/controllers/todo.js` add this code.

```javascript
isCompleted: function(key, value) {
    var model = this.get('model');

    if (value === undefined) {
        return model.get('isCompleted');
    } else {
        model.set('isCompleted', value);
        model.save();
        return value;
    }
}.property('model.isCompleted')
```

The `isCompleted` property of the controller is a computed property whose
value is dependent on the value of the model instance’s `isCompleted`
property.

When called with a value, because the user clicked the checkbox, the controller
will toggle the model instance’s `isCompleted` property and persist the
change. When called without a value, such as on the page load, it will simply
return the value of the model instance’s `isCompleted` property.

### Displaying the number of incomplete todos

Update `app/templates/todos.hbs` as shown below.

```handlebars
<span class="todo-count">
    <strong>{{remaining}}</strong> {{inflection}} left
</span>
```

Implement the `remaining` and `inflection` properties in
`app/controllers/todos.js`.

```javascript
actions: {
    // ...
},
remaining: function() {
    return this.filterBy('isCompleted', false).get('length');
}.property('@each.isCompleted'),
inflection: function() {
    var remaining = this.get('remaining');
    return remaining === 1 ? 'item' : 'items';
}.property('remaining')
```

The `remaining` property returns the number of todos whose `isCompleted`
property is false. Any time the `isCompleted` property of a todo changes, the
`remaining` property will recalculate.

The `inflection` property watches the `remaining` property and will update
whenever `remaining` updates. If `remaining` is 1 the singular will be
returned, otherwise the plural will be returned.

### Toggling between showing and editing states

TodoMVC allows users to double-click on a todo to edit the title. To implement
this functionality we will add an `isEditing` property to the todo controller
which will be used to class the `<li>` element and provide an input for
editing the todo.

Update `app/templates/todos.hbs` as follows.

```handlebars
<ul class="todo-list">
  {{#each todo in model itemController="todo"}}
    <li {{bind-attr class="todo.model.isCompleted:completed todo.model.isEditing:editing"}}>
      {{#if todo.model.isEditing}}
        <input class="edit">
      {{else}}
        {{input type="checkbox" checked=todo.model.isCompleted class="toggle"}}
        <label {{action "editTodo" on="doubleClick"}}>{{todo.model.title}}</label><button class="destroy"></button>
      {{/if}}
    </li>
  {{/each}}
</ul>
```

In `app/controllers/todo.js` add an `editTodo` action and an `isEditing`
property.

```javascript
actions: {
  editTodo: function() {
    this.set('isEditing', true);
  },
  isEditing: false,
  //...
}
```

This provides the `editTodo` method which switches the `isEditing` property
to true. Now when you double-click on a todo, you are provided a blank input.
Not quite what we are looking for.

### Accepting edits

Now that we have an input, we need to make it functional. Now we will add the
logic to focus on the input when it is visible, accept user input, and persist
changes when the user presses `Enter`.

Generate a component which will be a modified implementation of a text field.

```bash
ember g component edit-todo
```

Modify the newly generated `app/components/edit-todo.js` to match the
following.

```javascript
//...
export default Ember.TextField.extend({
  didInsertElement: function() {
    this.$().focus();
  }
});
```

This automatically focuses on the element when it is inserted into the page.

Next, replace the static `input` element with the `{{edit-todo}}` component
in `app/templates/todos.hbs`.

```handlebars
{{#if todo.model.isEditing}}
  {{edit-todo class="edit" value=todo.model.title focus-out="acceptChanges" insert-newline="acceptChanges"}}
{{else}}
```

The method `acceptChanges` will be called if the user presses `Enter` or
otherwise takes focus away from the input. The `value` of the input is bound
to the `title` property of the model instance.

Finally, the `acceptChanges` method needs to be added to
`app/controllers/todo.js`.

```javascript
//...
editTodo: function() {
  this.model.set('isEditing', true);
},
acceptChanges: function() {
  this.model.set('isEditing', false);

  if (Ember.isEmpty(this.model.get('title'))) {
    this.send('removeTodo');
  } else {
    this.get('model').save();
  }
}
//...
```

### Deleting a model

Update the static `<button>` element in `app/templates/todos.hbs` to use an
action called `removeTodo`.

```handlebars
<button {{action "removeTodo"}} class="destroy"></button>
```

Add the `removeTodo` method to `app/controllers/todo.js`.

```javascript
//...
acceptChanges: function() {
  this.model.set('isEditing', false);

  if (Ember.isEmpty(this.model.get('title'))) {
    this.send('removeTodo');
  } else {
    this.get('model').save();
  }
},
removeTodo: function() {
  var todo = this.get('model');
  todo.deleteRecord();
  todo.save();
}
//...
```

### Adding child routes

Adding child routes to the `todos` resource in the router will allow
implementation of the filtered `Active` and `Completed` views that are
linked at the bottom of the list. Use the generator to create a new `index`
route within the `todos` resource.

```bash
ember g route todos/index
```

In addition to the route, the generator also gives us
`app/templates/todos/index.hbs`. Move the entire todo list `<ul>` block to
this file and replace it with `{{outlet}}` in `app/templates/todos.hbs`.

```handlebars
<section class="main">
  {{outlet}}

  <input type="checkbox" class="toggle-all">
</section>
```

Add the following to the `extend` block in `app/routes/todos/index.js`.

```javascript
model: function() {
  return this.modelFor('todos');
}
```

### Transitioning to show only incomplete todos

Create a new `active` route within the `todos` resource using the generator.

```bash
ember g route todos/active
```

This route will use the `todos` model with a filter applied. It will also
render in the `todos/index` template that was created earlier. Add the
following to `app/routes/todos/active.js`.

```javascript
model: function() {
  return this.store.filter('todo', function(todo) {
    return !todo.get('isCompleted');
  });
},
renderTemplate: function(controller) {
  this.render('todos/index', {controller: controller});
}
```

The model function returns todos with the `isCompleted` property equal to
false.

Modify `app/templates/todos.hbs` to replace the `Active` link with a
`{{link-to}}` helper.

```handlebars
<li>
  <a href="all">All</a>
</li>
<li>
  {{#link-to "todos.active" activeClass="selected"}}Active{{/link-to}}
</li>
<li>
  <a href="completed">Completed</a>
</li>
```

### Transitioning to show only completed todos

Create a new `completed` route within the `todos` resource using the
generator.

```bash
ember g route todos/completed
```

Add the following to `app/routes/todos/completed.js`.

```javascript
model: function() {
  return this.store.filter('todo', function(todo) {
    return todo.get('isCompleted');
  });
},
renderTemplate: function(controller) {
  this.render('todos/index', {controller: controller});
}
```

Modify` app/templates/todos.hbs` to replace the `Completed` link with a
`{{link-to}}` helper.

```handlebars
<li>
  <a href="all">All</a>
</li>
<li>
  {{#link-to "todos.active" activeClass="selected"}}Active{{/link-to}}
</li>
<li>
  {{#link-to "todos.completed" activeClass="selected"}}Completed{{/link-to}}
</li>
```

### Transitioning back to show all todos

Modify `app/templates/todos.hbs` to replace the `All` link with a
`{{link-to}}` helper.

```handlebars
<li>
  {{#link-to "todos.index" activeClass="selected"}}All{{/link-to}}
</li>
<li>
  {{#link-to "todos.active" activeClass="selected"}}Active{{/link-to}}
</li>
<li>
  {{#link-to "todos.completed" activeClass="selected"}}Completed{{/link-to}}
</li>
```

### Displaying a button to remove all completed todos

TodoMVC allows users to remove all todos that have been marked as completed with
a button click. In `app/templates/todos.js` update the static `<button>`
element with an `{{action}}`.

```handlebars
{{#if hasCompleted}}
  <button class="clear-completed" {{action "clearCompleted"}}>
    Clear completed ({{completed}})
  </button>
{{/if}}
```

`app/controllers/todos.js` needs to be updated to add the `hasCompleted` and
`completed` properties as well as the `clearCompleted` method.

```javascript
actions: {
  clearCompleted: function() {
    var completed = this.filterBy('isCompleted', true);
    completed.invoke('deleteRecord');
    completed.invoke('save');
  },
  //...
},
hasCompleted: function() {
  return this.get('completed') > 0;
}.property('completed'),
completed: function() {
  return this.filterBy('isCompleted', true).get('length');
}.property('@each.isCompleted'),
//...
```

`filterBy` returns an `EmberArray` object which contains only items that
return true. The invoke method is part of the EmberArray API and executes a
method on each object in the array.

### Indicating when all todos are complete

Update the static checkbox in `app/templates/todos.hbs`. This checkbox will
indicate when all todos are complete.

```handlebars
<section class="main">
  {{outlet}}
  {{input type="checkbox" class="toggle-all" checked=allAreDone}}
</section>
```

This checkbox will be checked when `allAreDone` is true. Implement
`allAreDone` in `app/controllers/todos.js`.

```javascript
allAreDone: function(key, value) {
  return !!this.get('length') && this.isEvery('isCompleted');
}.property('@each.isCompleted')
```

### Toggling all todos between complete and incomplete

The checkbox that was just implemented is useful, but it would be much more
useful if it could toggle all of the todos between complete and incomplete.

To implement this, modify `allAreDone` in `app/controllers/todos.js`.

```javascript
allAreDone: function(key, value) {
  if (value === undefined) {
    return !!this.get('length') && this.isEvery('isCompleted');
  } else {
    this.setEach('isCompleted', value);
    this.invoke('save');
    return value;
  }
}.property('@each.isCompleted')
```

### Replacing HTTP-Mock with localStorage

Adapters are easily swapped without affecting the overall application. Now that
the application is complete, we will add a localStorage adapter, so the
information can be persisted outside the session without a server.

Install the localStorage adapter and create a serializer to manage stringifying
the JSON data for storage.

```bash
ember install:bower ember-localstorage-adapter
ember g serializer application
```

Go to `Brocfile.js` and add the following below the CSS imports which will
include the adapter logic as a dependency.

```javascript
app.import('bower_components/ember-localstorage-adapter/localstorage_adapter.js');
```

Now we need to make the application aware that we are using localStorage rather
than REST.

Open `app/serializers/application.js` and change `RESTSerializer` to
`LSSerializer`.

Open `app/adapters/application.js` and change `RESTAdapter` to
`LSAdapter`.
