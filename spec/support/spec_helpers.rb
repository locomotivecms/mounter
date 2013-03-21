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
  
  def reader
    Locomotive::Mounter::Reader::FileSystem.instance
  end
  
  def writer
    Locomotive::Mounter::Writer::Api.instance
  end
  
  def mounting_point
    reader.run!(path: site_path)
  end
  
  def teardown
    Locomotive::Mounter::Writer::Api.teardown
    Locomotive::Mounter::Reader::Api.teardown
    Locomotive::Mounter::EngineApi.teardown
  end
  
  def setup(cassette_name)
    VCR.use_cassette cassette_name do
      teardown
      delete_current_site
      writer.run!({ mounting_point: mounting_point, console: false, data: true, force: true }.merge(credentials))
    end
  end
end

RSpec.configure do |c|
  c.include SpecHelpers
end