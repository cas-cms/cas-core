desc "Generate sites based on the yml file"
namespace :cas do
  task generate_sites: :environment do
    Cas::Installation.new.generate_sites
  end
end
