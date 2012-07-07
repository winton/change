require 'yaml'

$:.unshift File.dirname(__FILE__)

class Change

  def initialize(root)
    @root = File.expand_path(root)
  end

  def d?(path)
    changed = @d.values.flatten
    if @session && @last_deps && @last_deps.include?(path)
      @last_deps.any? { |p| changed.include?(p) }
    else
      changed.include?(path)
    end
  end

  def d(reload=false)
    if @d && !reload
      @d
    else
      paths = Dir.chdir(@root) { Dir["**/*"] }
      add = paths - states.keys
      rem = states.keys - paths
      hashes = murmur_hashes(paths)

      mod = paths.inject([]) do |array, path|
        hash = hashes[path]
        size = Dir.chdir(@root) { File.size(path) }
        
        if states[path] && size != states[path][:size]
          array << path
        elsif states[path] && hash != states[path][:hash]
          array << path
        end

        states[path] ||= {}
        states[path][:hash] = hash
        states[path][:size] = size
        
        array
      end

      mod -= add
      rem.each { |path| states.delete(path) }

      write!

      @d = { :add => add, :mod => mod, :rem => rem }
    end
  end

  def d_
    @last_session
  end

  def r(path)
    if @session
      deps[@session].push(path)
      deps[@session].uniq!
      write!
    end
  end

  def s(id)
    d(true)

    if @session && @session != id
      @last_session = sessions[@session] = d
      write!
    end

    @session = id
    @last_deps = @session ? deps[@session] : nil
    deps[@session] = [] if @session
  end

  private

  def data
    @data ||= (YAML.load(File.read("#{@root}/.change.yml")) rescue {})
  end

  def murmur_bin
    @murmur ||= File.expand_path('../../bin/murmur3', __FILE__)
  end

  def murmur_hashes(paths)
    hashes = Dir.chdir(@root) do
      `#{murmur_bin} #{paths.collect { |m| "'#{m}'" }.join(' ')}`
    end
    Hash[paths.zip(hashes.split("\n"))]
  end

  def deps
    data['deps'] ||= {}
  end

  def sessions
    data['sessions'] ||= {}
  end

  def states
    data['states'] ||= {}
  end

  def write!
    File.open("#{@root}/.change.yml", 'w') do |f|
      f.write(YAML.dump(data))
    end
  end
end