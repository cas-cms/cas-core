desc "Generate sites based on the YAML config file"
namespace :cas do
  task apply_config: :environment do
    Cas::Installation.new.generate_sites
  end
end
