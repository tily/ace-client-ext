require "bundler/gem_tasks"

desc 'vup'
task :vup do
        version = ENV['VERSION']
        File.write('VERSION', "#{version}\n")
        system "git add VERSION"
        system "git commit -m 'version up to #{version}'"
        system "git tag v#{version} -m v#{version}"
        system "git push origin master"
        system "git push --tags"
        system "rake build"
        system "gem push pkg/ace-client-ext-#{version}.gem"
end

