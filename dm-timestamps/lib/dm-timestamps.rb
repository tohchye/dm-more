require 'rubygems'

gem 'dm-core', '=0.9.3'
require 'dm-core'

module DataMapper
  module Timestamp
    TIMESTAMP_PROPERTIES = {
      :updated_at => lambda { |r| r.updated_at = DateTime.now },
      :updated_on => lambda { |r| r.updated_on = Date.today   },
      :created_at => lambda { |r| r.created_at = DateTime.now if r.new_record? },
      :created_on => lambda { |r| r.created_on = Date.today   if r.new_record? },
    }

    def self.included(model)
      model.before :save, :set_timestamp_properties
    end

    private

    def set_timestamp_properties
      self.class.properties.slice(*TIMESTAMP_PROPERTIES.keys).compact.each do |property|
        TIMESTAMP_PROPERTIES[property.name][self]
      end
    end
  end # module Timestamp

  Resource::append_inclusions Timestamp
end
