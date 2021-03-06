# Dependencies contains all required gems, helpers and core configuration

def app(&block)
  JudgeMe.class_eval(&block)
end

class JudgeMe < Sinatra::Application
  bundler_require_dependencies(RACK_ENV)

  # Required middleware
  use Rack::Session::Cookie
  # use Rack::Flash

  # Requires the initializer modules which configure specific components
  Dir[File.dirname(__FILE__) + '/initializers/*.rb'].each do |file|
    # Each initializer file contains a module called 'XxxxInitializer' (i.e HassleInitializer)
    require file
    file_class = File.basename(file, '.rb').split('_').map { |w| w.capitalize! }.join #.camelize
    register Object.const_defined?("#{file_class}Initializer") ? Object.const_get("#{file_class}Initializer") : Object.const_missing("#{file_class}Initializer") #.constantize
  end

  # Returns the list of load paths for this sinatra application
  def self.file_loading_paths
    ["lib/**/*.rb", "app/helpers/**/*.rb", "app/routes/**/*.rb", "app/models/*.rb", "app/mailers/*.rb"]
  end

  # Require all the folders and files necessary to run the application
  file_loading_paths.each { |load_path| Dir[root_path(load_path)].each { |file| require file } }

  DataMapper.finalize

  # Required helpers
  helpers TagHelpers, AssetTagHelpers, FormatHelpers # MarkupHelpers
  helpers RenderHelpers
  helpers ViewHelpers
end