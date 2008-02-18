namespace :radiant do
  namespace :extensions do
    namespace :multi_site_hacks do
      
      desc "Runs the migration of the Multi Site Hacks extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          MultiSiteHacksExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          MultiSiteHacksExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Multi Site Hacks to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[MultiSiteHacksExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(MultiSiteHacksExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
