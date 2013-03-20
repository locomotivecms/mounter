module SpecHelpers
  def delete_current_site
    Locomotive::Mounter::EngineApi.set_token credentials
    Locomotive::Mounter::EngineApi.delete('/current_site.json')
  end
  
  def site_path
    File.join(File.dirname(__FILE__), '..', 'fixtures', 'default')
  end
  
  def credentials
    { uri: 'sample.example.com:3000/locomotive/api', email: 'admin@locomotivecms.com', password: 'locomotive' }
  end
end

RSpec.configure do |c|
  c.include SpecHelpers
end