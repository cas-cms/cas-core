module Cas
  class SectionAssociation
    attr_reader :field_name
    # This comes in a format like
    #
    #   {"teams"=>{"label"=>"Times"}}
    #
    def initialize(yaml_config)
      @field_name = yaml_config.keys.first
      @field_config = yaml_config.values.first
    end

    def label
      @field_config["label"] or @field_name.titleize
    end
  end
end
