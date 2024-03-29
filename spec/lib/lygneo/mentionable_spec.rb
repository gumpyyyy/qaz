
require 'spec_helper'

describe Lygneo::Mentionable do
  include PeopleHelper

  before do
    @people = [alice, bob, eve].map(&:person)
    @test_txt = <<-STR
This post contains a lot of mentions
one @{Alice A; #{@people[0].lygneo_handle}},
two @{Bob B ; #{@people[1].lygneo_handle}}and finally
three @{Eve E; #{@people[2].lygneo_handle}}.
STR
    @test_txt_plain = <<-STR
This post contains a lot of mentions
one Alice A,
two Bob B and finally
three Eve E.
STR
    @short_txt = "@{M1; m1@a.at} text @{M2 ; m2@b.be}text @{M3; m3@c.ca}"
    @status_msg = FactoryGirl.build(:status_message, text: @test_txt)
  end

  describe '#format' do
    context 'html output' do
      it 'adds the links to the formatted message' do
        fmt_msg = Lygneo::Mentionable.format(@status_msg.raw_message, @people)

        fmt_msg.should include(person_link(@people[0], class: 'mention hovercardable'))
        fmt_msg.should include(person_link(@people[1], class: 'mention hovercardable'))
        fmt_msg.should include(person_link(@people[2], class: 'mention hovercardable'))
      end

      it 'escapes the link title (name)' do
        p = @people[0].profile
        p.first_name = "</a><script>alert('h')</script>"
        p.save!

        fmt_msg = Lygneo::Mentionable.format(@status_msg.raw_message, @people)

        fmt_msg.should_not include(p.first_name)
        fmt_msg.should include("&gt;", "&lt;", "&#x27;") # ">", "<", "'"
      end
    end

    context 'plain text output' do
      it 'removes mention markup and displays unformatted name' do
        s_msg = FactoryGirl.build(:status_message, text: @short_txt)
        fmt_msg = Lygneo::Mentionable.format(s_msg.raw_message, @people, plain_text: true)

        fmt_msg.should eql "M1 text M2 text M3"
      end
    end

    it 'leaves the name of people that cannot be found' do
      fmt_msg = Lygneo::Mentionable.format(@status_msg.raw_message, [])
      fmt_msg.should eql @test_txt_plain
    end
  end

  describe '#people_from_string' do
    it 'extracts the mentioned people from the text' do
      ppl = Lygneo::Mentionable.people_from_string(@test_txt)
      ppl.should include(*@people)
    end

    describe 'returns an empty array if nobody was found' do
      it 'gets a post without mentions' do
        ppl = Lygneo::Mentionable.people_from_string("post w/o mentions")
        ppl.should be_empty
      end

      it 'gets a post with invalid handles' do
        ppl = Lygneo::Mentionable.people_from_string("@{a; xxx@xxx.xx} @{b; yyy@yyyy.yyy}")
        ppl.should be_empty
      end
    end
  end

  describe '#filter_for_groups' do
    before do
      @user_A = FactoryGirl.create(:user_with_group, :username => "user_a")
      @user_B = FactoryGirl.create(:user, :username => "user_b")
      @user_C = FactoryGirl.create(:user, :username => "user_c")

      @user_A.groups.create!(name: 'second')

      @mention_B = "@{user B; #{@user_B.lygneo_handle}}"
      @mention_C = "@{user C; #{@user_C.lygneo_handle}}"

      @user_A.share_with(@user_B.person, @user_A.groups.where(name: 'generic'))
      @user_A.share_with(@user_C.person, @user_A.groups.where(name: 'second'))

      @test_txt_B = "mentioning #{@mention_B}"
      @test_txt_C = "mentioning #{@mention_C}"
      @test_txt_BC = "mentioning #{@mention_B}} and #{@mention_C}"

      Lygneo::Mentionable.stub!(:current_user).and_return(@user_A)
    end

    it 'filters mention, if follower is not in a given group' do
      group_id = @user_A.groups.where(name: 'generic').first.id
      txt = Lygneo::Mentionable.filter_for_groups(@test_txt_C, @user_A, group_id)

      txt.should include(@user_C.person.name)
      txt.should include(local_or_remote_person_path(@user_C.person))
      txt.should_not include("href")
      txt.should_not include(@mention_C)
    end

    it 'leaves mention, if follower is in a given group' do
      group_id = @user_A.groups.where(name: 'generic').first.id
      txt = Lygneo::Mentionable.filter_for_groups(@test_txt_B, @user_A, group_id)

      txt.should include("user B")
      txt.should include(@mention_B)
    end

    it 'recognizes "all" as keyword for groups' do
      txt = Lygneo::Mentionable.filter_for_groups(@test_txt_BC, @user_A, "all")

      txt.should include(@mention_B)
      txt.should include(@mention_C)
    end
  end
end
