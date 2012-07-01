Change
======

What files changed since last time?

With dependency management and super fast hashing ([Murmur3](https://github.com/PeterScott/murmur3)).

Requirements
------------

    gem install change

Changed?
--------

    @change = Change.new("/absolute/path")
    @change.d?("relative/path")

`Change` uses a YAML file stored in the root directory called `.change.yml` to maintain state.

Calling `@change.d?` does the following:

* Check if there is an entry for path in `.change.yml`
  * If yes, read file size and compare with entry
    * If file size matches, compare Murmur hash
  * If no, record file size and Murmur hash
* Look up path in dependency tree
  * If found, also mark all dependency parent paths as changed

Dependencies
------------

Sometimes you want to say "if this file changes, then these other files should change as well".

    @change = Change.new("/absolute/path")
    @change.d(:some_id)         # set id (must be symbol)
    @change.d("relative/path")  # add dependency
    @change.d(null)				# unset id (must run this when finished)

If you use `@change.d?` after an id is set, it will return true if any dependencies from the last execution changed.

Tell `Change` to record which files were modified while an id was set during last execution:

	@change = Change.new("/absolute/path", :record => true)
	@change.d(:some_id)  # set id (must be symbol)
    @change.d			 # modified files from last session (hash)
    @change.d(null)		 # unset id (must run this when finished)