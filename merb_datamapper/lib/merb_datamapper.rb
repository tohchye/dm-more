if defined?(Merb::Plugins)
  require 'rubygems'

  gem 'dm-core', '=0.9.3'
  require 'dm-core'

  if File.file?(Merb.dir_for(:config) / "database.yml")
    require File.join(File.dirname(__FILE__) / "merb" / "orms" / "data_mapper" / "connection")

    Merb::Orms::DataMapper.connect
    Merb::Orms::DataMapper.register_session_type
  else
    Merb.logger.info "No database.yml file found in #{Merb.dir_for(:config)}, assuming database connection(s) established in the environment file in #{Merb.dir_for(:config)}/environments"
  end

  require File.join(File.dirname(__FILE__) / "merb" / "orms" / "data_mapper" / "resource")

  Merb::Plugins.add_rakefiles "merb_datamapper" / "merbtasks"
end
