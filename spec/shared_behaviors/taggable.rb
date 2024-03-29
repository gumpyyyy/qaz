# coding: utf-8
#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Lygneo::Taggable do
  shared_examples_for "it is taggable" do
    include ActionView::Helpers::UrlHelper

    def tag_link(s)
      link_to  "##{s}", "/tags/#{s}", :class => 'tag'
    end

    describe '.format_tags' do
      before do
        @str = '#what #hey #vöglein'
        @object.send(@object.class.field_with_tags_setter, @str)
        @object.build_tags
        @object.save!
      end

      it "supports non-ascii characters" do
        @object.tags(true).map(&:name).should include('vöglein')
      end

      it 'links each tag' do
        formatted_string = Lygneo::Taggable.format_tags(@str)
        formatted_string.should include(tag_link('what'))
        formatted_string.should include(tag_link('hey'))
        formatted_string.should include(tag_link('vöglein'))
      end

      it 'responds to plain_text' do
        Lygneo::Taggable.format_tags(@str, :plain_text => true).should == @str
      end

      it "doesn't mangle text when tags are involved" do
        expected = {
          nil => '',
          '' => '',
          'abc' => 'abc',
          'a #b c' => "a #{tag_link('b')} c",
          '#'                      => '#',
          '##'                     => '##',
          '###'                    => '###',
          '#a'                     => tag_link('a'),
          '#foobar'                => tag_link('foobar'),
          '#foocar<br>'            => "#{tag_link('foocar')}&lt;br&gt;",
          '#fooo@oo'               => "#{tag_link('fooo')}@oo",
          '#num3ric hash tags'     => "#{tag_link('num3ric')} hash tags",
          '#12345 tag'             => "#{tag_link('12345')} tag",
          '#12cde tag'             => "#{tag_link('12cde')} tag",
          '#abc45 tag'             => "#{tag_link('abc45')} tag",
          '#<3'                    => %{<a href="/tags/<3" class="tag">#&lt;3</a>},
          'i #<3'                  => %{i <a href="/tags/<3" class="tag">#&lt;3</a>},
          'i #<3 you'              => %{i <a href="/tags/<3" class="tag">#&lt;3</a> you},
          '#<4'                    => '#&lt;4',
          'test#foo test'          => 'test#foo test',
          'test.#joo bar'          => 'test.#joo bar',
          'test #foodar test'      => "test #{tag_link('foodar')} test",
          'test #foofar<br> test'  => "test #{tag_link('foofar')}&lt;br&gt; test",
          'test #gooo@oo test'     => "test #{tag_link('gooo')}@oo test",
          'test #foo-test test'    => "test #{tag_link('foo-test')} test",
          'test #hoo'              => "test #{tag_link('hoo')}",
          'test #two_word tags'    => "test #{tag_link('two_word')} tags",
          'test #three_word_tags'  => "test #{tag_link('three_word_tags')}",
          '#terminal_underscore_'  => tag_link('terminal_underscore_'),
          '#terminalunderscore_'   => tag_link('terminalunderscore_'),
          '#_initialunderscore'    => tag_link('_initialunderscore'),
          '#_initial_underscore'   => tag_link('_initial_underscore'),
          '#terminalhyphen-'       => tag_link('terminalhyphen-'),
          '#terminal-hyphen-'      => tag_link('terminal-hyphen-'),
          '#terminalhyphen- tag'   => "#{tag_link('terminalhyphen-')} tag",
          '#-initialhyphen'        => tag_link('-initialhyphen'),
          '#-initialhyphen tag'    => "#{tag_link('-initialhyphen')} tag",
          '#-initial-hyphen'       => tag_link('-initial-hyphen'),
        }

        expected.each do |input,output|
          Lygneo::Taggable.format_tags(input).should == output
        end
      end
    end

    describe '#build_tags' do
      it 'builds the tags' do
        @object.send(@object.class.field_with_tags_setter, '#what')
        @object.build_tags
        @object.tag_list.should == ['what']
        lambda {
          @object.save
        }.should change{@object.tags.count}.by(1)
      end
    end

    describe '#tag_strings' do
      it 'returns a string for every #thing' do
        str = '#what #hey #that"smybike. #@hey ##boo # #THATWASMYBIKE #vöglein #hey#there #135440we #abc/23 ### #h!gh #ok? #see: #re:publica'
        arr = ['what', 'hey', 'that', 'THATWASMYBIKE', 'vöglein', '135440we', 'abc', 'h', 'ok', 'see', 're']

        @object.send(@object.class.field_with_tags_setter, str)
        @object.tag_strings.should =~ arr
      end

      it 'extracts tags despite surrounding text' do
        expected = {
          ''                       => nil,
          '#'                      => nil,
          '##'                     => nil,
          '###'                    => nil,
          '#a'                     => 'a',
          '#foobar'                => 'foobar',
          '#foocar<br>'            => 'foocar',
          '#fooo@oo'               => 'fooo',
          '#num3ric hash tags'     => 'num3ric',
          '#12345 tag'             => '12345',
          '#12cde tag'             => '12cde',
          '#abc45 tag'             => 'abc45',
          '#<3'                    => '<3',
          '#<4'                    => nil,
          'test#foo test'          => nil,
          'test.#joo bar'          => nil,
          'test #foodar test'      => 'foodar',
          'test #foofar<br> test'  => 'foofar',
          'test #gooo@oo test'     => 'gooo',
          'test #<3 test'          => '<3',
          'test #foo-test test'    => 'foo-test',
          'test #hoo'              => 'hoo',
          'test #two_word tags'    => 'two_word',
          'test #three_word_tags'  => 'three_word_tags',
          '#terminal_underscore_'  => 'terminal_underscore_',
          '#terminalunderscore_'   => 'terminalunderscore_',
          '#_initialunderscore'    => '_initialunderscore',
          '#_initial_underscore'   => '_initial_underscore',
          '#terminalhyphen-'       => 'terminalhyphen-',
          '#terminal-hyphen-'      => 'terminal-hyphen-',
          '#terminalhyphen- tag'   => 'terminalhyphen-',
          '#-initialhyphen'        => '-initialhyphen',
          '#-initialhyphen tag'    => '-initialhyphen',
          '#-initial-hyphen'       => '-initial-hyphen',
        }

        expected.each do |text,hashtag|
          @object.send  @object.class.field_with_tags_setter, text
          @object.tag_strings.should == [hashtag].compact
        end
      end

      it 'returns no duplicates' do
        str = '#what #what #what #whaaaaaaaaaat'
        arr = ['what','whaaaaaaaaaat']

        @object.send(@object.class.field_with_tags_setter, str)
        @object.tag_strings.should =~ arr
      end

      it 'is case insensitive' do
        str = '#what #wHaT #WHAT'
        arr = ['what']

        @object.send(@object.class.field_with_tags_setter, str)
        @object.tag_strings.should =~ arr
      end
    end
  end
end

