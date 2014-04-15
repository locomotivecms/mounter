require 'spec_helper'

require 'locomotive/mounter/writer/api/base'

describe Locomotive::Mounter::Writer::Api::Base do

  let(:content_assets_writer) { double }

  let(:writer) { build_base_writer }

  describe '#replace_content_assets!' do

    context 'tinymce markups' do

      let(:content) { %{<img alt="" data-mce-src="/samples/assets/broadcast_screenshot.png" src="/samples/assets/broadcast_screenshot.png">} }

      it 'creates two assets' do
        content_assets_writer.should_receive(:write).with('/samples/assets/broadcast_screenshot.png').twice
        writer.replace_content_assets!(content)
      end

    end

  end

  def build_base_writer
    Locomotive::Mounter::Writer::Api::Base.new(nil, nil).tap do |writer|
      writer.stub(content_assets_writer: content_assets_writer)
    end
  end

end