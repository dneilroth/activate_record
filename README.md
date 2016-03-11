# **Activate Record**

Inspired by Rail's Active Record this Object Relation Mapping program leverages Ruby's metaprogramming abilities in order to recreate some of AR's best features.

## Features

* Rspec for testing. Example: `rspec spec/01_sql_object.rb`
* Instance variables
* Model attributes
* Saving and updating of models in SQL database
* SQL database querying using Ruby (AR's 'where', 'find', and 'all' methods)
* Model associations (belongs_to, has_many, has_one_through)

## Checkout Activate Record's Newest Feature, Lockable

* Test with `rspec spec/05_lockable_spec.rb`
* Utilizes `lock_version` attribute and extends `#update` method to prevent concurrency conflict
* Checks for locking capability before updating
