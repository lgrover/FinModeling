# multi_column_calculation_summary_spec.rb

require 'spec_helper'

describe FinModeling::CalculationSummary do
  before(:all) do
    @summary = FinModeling::CalculationSummary.new
    @summary.title = "CS 1"
    @summary.rows = [ FinModeling::CalculationRow.new(:key => "Row", :vals => [nil, 0, nil, -101, 2.4]) ]
  end

  describe "valid_vals" do
    subject { @summary.rows.first.valid_vals }
    it "should return all non-nil values" do
      subject.should == @summary.rows[0].vals.select{ |x| !x.nil? }
    end
  end

  describe "filter_by_type" do
    before(:all) do
      @summary2 = FinModeling::CalculationSummary.new
      @summary2.rows = [ ]
      @summary2.rows << FinModeling::CalculationRow.new(:key => "Row", :type => :oa, :vals => [  4])
      @summary2.rows << FinModeling::CalculationRow.new(:key => "Row", :type => :fa, :vals => [109])
      @summary2.rows << FinModeling::CalculationRow.new(:key => "Row", :type => :oa, :vals => [ 93])
      @summary2.rows << FinModeling::CalculationRow.new(:key => "Row", :type => :fa, :vals => [  1])
    end
    it "should return a new FinModeling::CalculationSummary" do
      @summary2.filter_by_type(:oa).should be_an_instance_of FinModeling::CalculationSummary
    end
    it "should return a summary of only the requested type" do
      @summary2.filter_by_type(:oa).rows.map{ |row| row.type }.uniq.should == [:oa]
    end
  end

  describe "+" do
    before(:all) do
      @mccs1 = FinModeling::CalculationSummary.new
      @mccs1.title = "MCCS 1"
      @mccs1.rows = [ FinModeling::CalculationRow.new(:key => "Row 1", :vals => [nil, 0, nil, -101, 2.4]) ]

      @mccs2 = FinModeling::CalculationSummary.new
      @mccs2.title = "MCCS 2"
      @mccs2.rows = [ FinModeling::CalculationRow.new(:key => "Row 1", :vals => [nil, 0, nil, -101, 2.4]) ]
    end

    subject { @mccs1 + @mccs2 }

    it { should be_an_instance_of FinModeling::CalculationSummary }

    its(:title) { should == @mccs1.title }

    it "should set the row labels to the first summary's row labels" do
      subject.rows.map{ |row| row.key }.should == @mccs1.rows.map{ |row| row.key }
    end

    it "should merge the values of summary into an array of values in the result" do
      0.upto(subject.rows.length-1).each do |row_idx|
        subject.rows[row_idx].vals.should == ( @mccs1.rows[row_idx].vals + @mccs2.rows[row_idx].vals )
      end
    end
  end
end
