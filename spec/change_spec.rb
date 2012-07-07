require 'fileutils'
require 'spec_helper'

describe Change do

  before :all do
    @root = File.expand_path('../../', __FILE__)
    FileUtils.rm_rf(@tmp = "#{@root}/spec/tmp")
    FileUtils.cp_r("#{@root}/spec/fixture", @tmp)
    @change = Change.new(@tmp)
  end

  describe :d do
    it "should return all files as added" do
      @change.d.should == {
        :add => [ "modify.txt", "remove.txt" ],
        :mod => [],
        :rem => []
      }
    end

    it "should cache last changes" do
      @change.d.should == {
        :add => [ "modify.txt", "remove.txt" ],
        :mod => [],
        :rem => []
      }
    end

    it "should return no files modified" do
      @change.d(true).should == {
        :add => [],
        :mod => [],
        :rem => []
      }
    end

    it "should return modified" do
      File.open("#{@tmp}/modify.txt", 'w') { |f| f.write('!') }
      @change.d(true).should == {
        :add => [],
        :mod => [ "modify.txt" ],
        :rem => []
      }
    end

    it "should return removed" do
      FileUtils.rm("#{@tmp}/remove.txt")
      @change.d(true).should == {
        :add => [],
        :mod => [],
        :rem => [ "remove.txt" ]
      }
    end

    it "should return added" do
      File.open("#{@tmp}/add.txt", 'w') { |f| f.write('!') }
      @change.d(true).should == {
        :add => [ "add.txt" ],
        :mod => [],
        :rem => []
      }
    end

    it "should save state" do
      @change = Change.new(@tmp)
      @change.d.should == {
        :add => [],
        :mod => [],
        :rem => []
      }
    end
  end

  describe :d? do
    it "should return state if present" do
      File.open("#{@tmp}/modify.txt", 'w') { |f| f.write('!!') }
      @change.d(true)
      @change.d?('add.txt').should == false
      @change.d?('modify.txt').should == true
    end
  end

  describe :s do
    before :all do
      @change.s(:id)
      @change.r('modify.txt')
      @change.r('remove.txt')
      File.open("#{@tmp}/add.txt", 'w') { |f| f.write('!') }
      File.open("#{@tmp}/modify.txt", 'w') { |f| f.write('!!!') }
      @change.s(nil)
    end

    it "should record dependencies" do
      @change.send(:deps).should == { :id => [ "modify.txt", "remove.txt" ] }
    end

    it "should record files modified during session" do
      @change.send(:sessions).should == {
        :id => {
          :add => [ "add.txt" ], :mod => [ "modify.txt" ], :rem => []
        }
      }
    end

    it "should return proper data within next session" do
      File.open("#{@tmp}/modify.txt", 'w') { |f| f.write('!!!!') }
      @change.s(:id)
      @change.d?("remove.txt").should == true
      @change.d.should == { :add => [], :mod => [ "modify.txt" ], :rem => [] }
      @change.d_.should == { :add => [ "add.txt" ], :mod => [ "modify.txt" ], :rem => [] }
      @change.s(nil)
    end
  end
end