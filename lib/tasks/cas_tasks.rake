desc "Generate sites based on the yml file"
namespace :cas do
  task generate_sites: :environment do
    Cas::Installation.generate_sites
  end
end
