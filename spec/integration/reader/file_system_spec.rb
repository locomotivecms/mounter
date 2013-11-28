# encoding: UTF-8
require 'spec_helper'

describe Locomotive::Mounter::Reader::FileSystem do

  describe 'simple' do

    before(:each) do
      @path   = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'simple')
      @reader = Locomotive::Mounter::Reader::FileSystem.instance
    end

    describe 'content_types & pages' do

      before(:each) do
        stub_readers(@reader, %w(content_types pages))
        @mounting_point = @reader.run!(path: @path)
      end

      describe 'pages' do

        before(:each) do
          @index    = @mounting_point.pages['index']
          @template = @mounting_point.pages['latest_product']
        end

        it { @mounting_point.pages.size.should == 5 }

        it 'puts pages under the index page' do
          @index.children.size.should == 2
        end

        it 'sets the fullpath to all the pages' do
          @mounting_point.pages.each do |_, page|
            page.depth.should_not be_nil
            page.fullpath.should_not be_nil
          end
        end

        it 'has localized pages with non-nil depth' do
          Locomotive::Mounter.with_locale(:es) do
            @mounting_point.pages.each do |_, page|
              page.fullpath_or_default.should_not be_nil
              page.depth.should_not be_nil
            end
          end
        end

      end

    end

  end

  describe 'a more complicated site' do

    before(:each) do
      @path   = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'default')
      @reader = Locomotive::Mounter::Reader::FileSystem.instance
    end

    it 'runs it' do
      @reader.stubs(:build_mounting_point).returns(true)
      @reader.run!(path: @path).should_not be_nil
    end

    describe 'site' do

      before(:each) do
        stub_readers(@reader)
        @mounting_point = @reader.run!(path: @path)
      end

      it 'has a name' do
        @mounting_point.site.name.should == 'Sample website'
      end

      it 'has locales' do
        @mounting_point.site.locales.should == %w(en fr nb)
      end

      it 'has a seo title' do
        @mounting_point.site.seo_title.should == 'A simple LocomotiveCMS website'
      end

      it 'has a meta keywords' do
        @mounting_point.site.meta_keywords.should == 'some meta keywords'
      end

      it 'has a meta description' do
        @mounting_point.site.meta_description.should == 'some meta description'
      end

    end # site

    describe 'content types & pages' do

      before(:each) do
        stub_readers(@reader, %w(content_types pages))
        @mounting_point = @reader.run!(path: @path)
      end

      describe 'pages' do

        before(:each) do
          @index          = @mounting_point.pages['index']
          @about_us       = @mounting_point.pages['about-us']
          @song_template  = @mounting_point.pages['songs/template']
        end

        it 'has 13 pages' do
          @mounting_point.pages.size.should == 14
        end

        describe '#tree' do

          it 'puts pages under the index page' do
            @index.children.size.should == 8
          end

          it 'keeps the ordering of the config' do
            @index.children.map(&:fullpath).should == ['about-us', 'music', 'store', 'contact', 'events', 'lorem-ipsum-dolor-sit-amet-consectetur-adipisicing-elit-sed-do-eiusmod-tempor-incididunt-ut-labore-et-dolore-magna-aliqua', 'archives', 'songs']
          end

          it 'assigns titles for all the pages' do
            @index.children.map(&:title).should == ['About Us', 'Music', 'Store', 'Contact Us', 'Events', "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo", 'Archives', 'Songs']
          end

          it 'also includes nested children' do
            @index.children.first.children.size.should == 2
            @index.children.first.children.map(&:fullpath).should == ['about-us/john-doe', 'about-us/jane-doe']
          end

          it 'localizes the fullpath' do
            Locomotive::Mounter.with_locale(:fr) do
              @index.children.first.children.map(&:fullpath).should == ['a-notre-sujet/jean-personne', nil]
            end
          end

          it 'localizes titles' do
            Locomotive::Mounter.with_locale(:fr) do
              @index.children.map(&:title).should == ['A notre sujet', nil, 'Magasin', nil, nil, nil, nil, nil]
            end

            Locomotive::Mounter.with_locale(:nb) do
              @index.children.map(&:title).should == ['Om oss', nil, nil, nil, nil, nil, nil, nil]
            end
          end

        end

        describe 'editable elements' do

          it 'keeps track of it' do
            @about_us.editable_elements.size.should == 2
          end

          it 'localizes a editable text' do
            element = @about_us.find_editable_element('banner', 'pitch')
            element.content.should == '<h2>About us</h2><p>Lorem ipsum...</p>'
            Locomotive::Mounter.with_locale(:fr) do
              element.content.should == '<h2>A notre sujet</h2><p>Lorem ipsum...(FR)</p>'
            end
          end

          it 'localizes a editable file' do
            element = @about_us.find_editable_element('banner', 'page_image')
            element.content.should == '/samples/photo_2.jpg'
            Locomotive::Mounter.with_locale(:fr) do
              element.content.should == '/samples/photo.jpg'
            end
          end

        end

        describe '#content_type' do

          it 'assigns it' do
            @song_template.content_type.should_not be_nil
            @song_template.content_type.slug.should == 'songs'
          end

        end

      end # pages

      describe 'content types' do

        # before(:each) do
        #   stub_readers(@reader, %w(content_types))
        #   @mounting_point = @reader.run!(path: @path)
        # end

        it 'has 4 content types' do
          @mounting_point.content_types.size.should == 5
          @mounting_point.content_types.keys.should == %w(bands events messages songs updates)
          @mounting_point.content_types.values.map(&:slug).should == %w(bands events messages songs updates)
        end

        describe 'a single content type' do

          before(:each) do
            @content_type = @mounting_point.content_types.values[1]
          end

          it 'has basic properties: name, slug' do
            @content_type.name.should == 'Events'
            @content_type.slug.should == 'events'
          end

          it 'has fields' do
            @content_type.fields.size.should == 5
            @content_type.fields.map(&:name).should == %w(place date city state notes)
            @content_type.fields.map(&:type).should == [:string, :date, :string, :string, :text]
          end

        end

        describe 'a content type with a select field' do

          before(:each) do
            @content_type = @mounting_point.content_types['updates']
            @field = @content_type.find_field('category')
          end

          it 'has a select field' do
            @field.should_not be_nil
          end

          it 'stores the options' do
            @field.select_options.size.should == 4
          end

          it 'has a name for each option' do
            @field.select_options.map(&:name).should == ['General', 'Gigs', 'Bands', 'Albums']
          end

          it 'has a translated name for each option' do
            Locomotive::Mounter.with_locale(:fr) do
              @field.select_options.map(&:name).should == ['Général', 'Concerts', 'Groupes', nil]
            end
          end

          it 'also allows to set options in an inline style' do
            content_type = @mounting_point.content_types['bands']
            field = content_type.find_field('kind')
            field.select_options.map(&:name).should == ['grunge', 'rock', 'country']
          end

        end

      end # content types

    end

    describe 'snippets' do

      before(:each) do
        stub_readers(@reader, %w(snippets))
        @mounting_point = @reader.run!(path: @path)
      end

      it 'has 3 snippets' do
        @mounting_point.snippets.size.should == 3
        @mounting_point.snippets.keys.sort.should == %w(a-long-one header song)
        @mounting_point.snippets.values.map(&:slug).sort.should == %w(a-long-one header song)
      end

      it 'localizes the template' do
        @mounting_point.snippets.values.first.source.should match /&rarr; Listen/
        Locomotive::Mounter.with_locale(:fr) do
          @mounting_point.snippets.values.first.source.should match /&rarr; écouter/
        end
      end

    end # snippets

    describe 'content entries' do

      before(:each) do
        stub_readers(@reader, %w(content_types content_entries))
        @mounting_point = @reader.run!(path: @path)
      end

      it 'has 26 entries for the 4 content types' do
        @mounting_point.content_entries.size.should == 29
      end

      describe 'a single content entry' do

        before(:each) do
          @content_entry = @mounting_point.content_entries['events/avogadros-number']
        end

        it 'has a label' do
          @content_entry._label.should == "Avogadro's Number"
        end

        it 'has a slug' do
          @content_entry._slug.should == "avogadros-number"
        end

        it 'can access dynamic field' do
          @content_entry.city = 'Fort Collins'
        end

        it 'can access casted value of a dynamic field' do
          @content_entry.date = Date.parse('2012/06/11')
        end

      end

      describe 'a localized content entry' do

        before(:each) do
          @content_entry = @mounting_point.content_entries['updates/update-number-1']
        end

        it 'has a label' do
          @content_entry._label.should == "Update #1"
        end

        it 'has a different label in another locale' do
          Locomotive::Mounter.with_locale(:fr) do
            @content_entry._label.should == "Mise a jour #1"
          end
        end

      end

    end # content entries

    describe 'theme_assets' do

      before(:each) do
        stub_readers(@read, %w{ theme_assets })
        @mounting_point = @reader.run!(path: @path)
      end

      subject { @mounting_point.theme_assets }

      its(:count) { should == 17 }

      it "should not return directories" do
        dir_names = %w{ fonts images javascripts stylesheets }
        dir_rx = Regexp.new %w{ fonts images stylesheets javascripts }.join("\/?$|").concat("\/?$")
        subject.each do |asset|
          asset.to_s.should_not match dir_rx
        end
      end

      it "should not return anything from samples" do
        sample_rx = /samples/
        subject.each do |asset|
          asset.to_s.should_not match sample_rx
        end
      end

    end # theme assets

  end

  describe 'a symlinked site' do

    before(:each) do
      @path   = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'symlinked')
      @reader = Locomotive::Mounter::Reader::FileSystem.instance
    end

    describe 'theme_assets' do

      before(:each) do
        stub_readers(@read, %w{ theme_assets })
        @mounting_point = @reader.run!(path: @path)
      end

      subject { @mounting_point.theme_assets }

      its(:count) { should == 17 }

      it "should not return directories" do
        dir_names = %w{ fonts images javascripts stylesheets }
        dir_rx = Regexp.new %w{ fonts images stylesheets javascripts }.join("\/?$|").concat("\/?$")
        subject.each do |asset|
          asset.to_s.should_not match dir_rx
        end
      end

      it "should not return anything from samples" do
        sample_rx = /samples/
        subject.each do |asset|
          asset.to_s.should_not match sample_rx
        end
      end

    end # theme assets

  end

  def stub_readers(reader, readers = nil)
    klasses = (readers ||= []).insert(0, 'site').map do |name|
      "Locomotive::Mounter::Reader::FileSystem::#{name.camelize}Reader".constantize
    end

    reader.stubs(:readers).returns(klasses)
  end

end
