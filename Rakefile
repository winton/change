require 'bundler/gem_tasks'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

task :default do
  Dir.chdir("ext/change") do
    system("make && make install")
  end
  Rake::Task['spec'].execute
end