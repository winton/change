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
    @change.d        # { :add => [], :mod => [], :rem => [] }
    @change.d(true)  # reload

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

To group dependencies, `Change` uses the concept of a "session":

    @change = Change.new("/absolute/path")
    @change.s(:some_id)         # start session with id
    @change.r("relative/path")  # record dependency
    @change.s(nil)              # stop session

If you use `@change.d?` within a session, it will return true if any dependencies have changed. `Change` recalls the dependencies from the last session to achieve this.

    @change.s(:some_id)
    @change.d?('relative/path')
      # returns true if any dependencies have changed
      # dependencies are recalled from LAST :some_id session

Recall files that were modified during the last execution of this session:

    @change.s(:some_id)
    @change.d_  # returns: { :add => [], :mod => [], :rem => [] }
