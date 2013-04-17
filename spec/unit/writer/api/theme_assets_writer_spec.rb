require 'spec_helper'

require 'locomotive/mounter/writer/api/base'
require 'locomotive/mounter/writer/api/theme_assets_writer'

describe Locomotive::Mounter::Writer::Api::ThemeAssetsWriter do

  let(:writer) { build_theme_asset_writer }

  describe '#theme_asset_changed?' do

    let(:theme_asset) { build_theme_asset(filepath: filepath ) }

    context 'an image' do

      let(:filepath) { full_asset_path('images/nav_on.png') }
      let(:another_filepath) { full_asset_path('images/photo_frame.png') }

      it 'returns false if same file' do
        writer.send(:theme_asset_changed?, theme_asset, File.open(filepath)).should be_false
      end

      it 'returns true if different file' do
        writer.send(:theme_asset_changed?, theme_asset, File.open(another_filepath)).should be_true
      end

    end

    context 'a non compiled javascript file' do

      let(:filepath) { full_asset_path('javascripts/common.js') }
      let(:another_filepath) { full_asset_path('images/photo_frame.png') }

      it 'returns false if same file' do
        writer.send(:theme_asset_changed?, theme_asset, File.open(filepath)).should be_false
      end

      it 'returns true if different file' do
        writer.send(:theme_asset_changed?, theme_asset, File.open(another_filepath)).should be_true
      end

    end

    context 'a compiled javascript file' do

      let(:filepath) { full_asset_path('javascripts/application.js.coffee') }
      let(:another_filepath) { full_asset_path('javascripts/common.js') }

      it 'returns false if same file' do
        _filepath = File.expand_path('../../../../fixtures/application.js', __FILE__)
        writer.send(:theme_asset_changed?, theme_asset, File.open(_filepath)).should be_false
      end

      it 'returns true if different file' do
        writer.send(:theme_asset_changed?, theme_asset, File.open(another_filepath)).should be_true
      end

    end

    context 'a stylesheet file' do

      let(:filepath) { full_asset_path('stylesheets/application.css') }
      let(:another_filepath) { full_asset_path('stylesheets/reboot.css') }

      it 'returns false if same file' do
        _filepath = File.expand_path('../../../../fixtures/application.css', __FILE__)
        writer.send(:theme_asset_changed?, theme_asset, File.open(_filepath)).should be_false
      end

      it 'returns true if different file' do
        writer.send(:theme_asset_changed?, theme_asset, File.open(another_filepath)).should be_true
      end

    end

  end

  def build_theme_asset_writer
    Locomotive::Mounter::Writer::Api::ThemeAssetsWriter.new(nil, nil)
  end

  def build_theme_asset(attributes = {})
    filepath = attributes.delete(:filepath)
    Locomotive::Mounter::Models::ThemeAsset.new(attributes).tap do |asset|
      asset.filepath = filepath
    end
  end

  def full_asset_path(asset_path)
    File.expand_path(File.join('../../../../fixtures/default/public', asset_path), __FILE__)
  end

end