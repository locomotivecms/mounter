require 'spec_helper'

describe Locomotive::Mounter::Reader::FileSystem::PagesBuilder do

  before(:each) do
    @builder = Locomotive::Mounter::Reader::FileSystem::PagesBuilder.new(nil)
  end

  describe '#filepath_locale' do

    before(:each) do
      @builder.stubs(:locales).returns(['en', 'fr'])
    end

    it 'returns false if no locale information in the filepath' do
      @builder.send(:filepath_locale, 'app/views/pages/index.liquid.haml').should be_nil
    end

    it 'returns false if the locale in the filepath is not registered' do
      @builder.send(:filepath_locale, 'app/views/pages/index.de.liquid.haml').should be_nil
    end

    context 'the locale in the filepath is registered' do

      it 'returns true' do
        @builder.send(:filepath_locale, 'app/views/pages/index.fr.liquid.haml').should == 'fr'
      end

      it 'returns true even if the filepath contains multiple dots' do
        @builder.send(:filepath_locale, 'app/./views/../views/pages/index.fr.liquid.haml').should == 'fr'
      end

    end

  end

  # describe '#is_subpage_of?' do
  #
  #   %w(index 404).each do |page|
  #     it "returns false for the '#{page}'" do
  #       @builder.send(:is_subpage_of?, page, 'index').should be_false
  #     end
  #   end
  #
  #   it 'returns true for pages under index' do
  #     @builder.send(:is_subpage_of?, 'about_us', 'index').should be_true
  #   end
  #
  #   it "returns true for pages under 'about_us'" do
  #     @builder.send(:is_subpage_of?, 'about_us/my_team', 'about_us').should be_true
  #   end
  #
  #   it "returns true for pages under 'about-us'" do
  #     @builder.send(:is_subpage_of?, 'about-us/my_team', 'about_us').should be_true
  #   end
  #
  # end

end