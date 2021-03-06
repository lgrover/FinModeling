module FinModeling
  class ReformulatedCashFlowStatement
    attr_accessor :period

    class FakeCashChangeSummary
      def initialize(re_cfs1, re_cfs2)
        @re_cfs1 = re_cfs1
        @re_cfs2 = re_cfs2
      end
      def filter_by_type(key)
        case key
          when :c
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Cash from Operations"
            @cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @re_cfs1.cash_from_operations.total] ),
                         CalculationRow.new(:key => "Second Row", :vals => [-@re_cfs2.cash_from_operations.total] ) ]
            return @cs
          when :i
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Cash Investments in Operations"
            @cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @re_cfs1.cash_investments_in_operations.total] ),
                         CalculationRow.new(:key => "Second Row", :vals => [-@re_cfs2.cash_investments_in_operations.total] ) ]
            return @cs
          when :d
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Payments to Debtholders"
            @cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @re_cfs1.payments_to_debtholders.total] ),
                         CalculationRow.new(:key => "Second Row", :vals => [-@re_cfs2.payments_to_debtholders.total] ) ]
            return @cs
          when :f
            @cs = FinModeling::CalculationSummary.new
            @cs.title = "Payments to Stockholders"
            @cs.rows = [ CalculationRow.new(:key => "First  Row", :vals => [ @re_cfs1.payments_to_stockholders.total] ),
                         CalculationRow.new(:key => "Second Row", :vals => [-@re_cfs2.payments_to_stockholders.total] ) ]
            return @cs
        end
      end
    end

    def initialize(period, cash_change_summary)
      @period   = period

      @c = cash_change_summary.filter_by_type(:c) # just make this a member....
      @i = cash_change_summary.filter_by_type(:i)
      @d = cash_change_summary.filter_by_type(:d)
      @f = cash_change_summary.filter_by_type(:f)

      @c.title = "Cash from operations"
      @i.title = "Cash investments in operations"
      @d.title = "Payments to debtholders"
      @f.title = "Payments to stockholders"

      if cash_change_summary.class != FakeCashChangeSummary
        @d.rows << CalculationRow.new(:key => "Investment in Cash and Equivalents",
                                                        :type => :d,
                                                        :vals => [-cash_change_summary.total])
      end
    end

    def -(re_cfs2)
      summary = FakeCashChangeSummary.new(self, re_cfs2)
      return ReformulatedCashFlowStatement.new(@period, summary)
    end

    def cash_from_operations
      @c
    end

    def cash_investments_in_operations
      @i
    end

    def payments_to_debtholders
      @d
    end

    def payments_to_stockholders
      @f
    end

    def free_cash_flow
      cs = FinModeling::CalculationSummary.new
      cs.title = "Free Cash Flow"
      cs.rows = [ CalculationRow.new(:key => "Cash from Operations (C)",          :vals => [@c.total] ),
                  CalculationRow.new(:key => "Cash Investment in Operations (I)", :vals => [@i.total] ) ]
      return cs
    end

    def financing_flows
      cs = FinModeling::CalculationSummary.new
      cs.title = "Financing Flows"
      cs.rows = [ CalculationRow.new(:key => "Payments to debtholders (d)",  :vals => [@d.total] ),
                  CalculationRow.new(:key => "Payments to stockholders (F)", :vals => [@f.total] ) ]
      return cs
    end

    def ni_over_c(inc_stmt)
      inc_stmt.comprehensive_income.total.to_f / cash_from_operations.total
    end
  
    def self.empty_analysis
      analysis = CalculationSummary.new
  
      analysis.title = ""
      analysis.header_row = CalculationHeader.new(:key => "", :vals =>  ["Unknown..."])
  
      analysis.rows = []
      analysis.rows << CalculationRow.new(:key => "C ($MM)",   :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "I ($MM)",   :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "d ($MM)",   :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "F ($MM)",   :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "FCF ($MM)", :vals => [nil])
      analysis.rows << CalculationRow.new(:key => "NI / C",    :vals => [nil])
 
      return analysis
    end

    def analysis(inc_stmt)
      analysis = CalculationSummary.new
  
      analysis.title = ""
      analysis.header_row = CalculationHeader.new(:key => "", :vals => [@period.value["end_date"].to_s])
  
      analysis.rows = []
      analysis.rows << CalculationRow.new(:key => "C   ($MM)", :vals => [cash_from_operations.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "I   ($MM)", :vals => [cash_investments_in_operations.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "d   ($MM)", :vals => [payments_to_debtholders.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "F   ($MM)", :vals => [payments_to_stockholders.total.to_nearest_million])
      analysis.rows << CalculationRow.new(:key => "FCF ($MM)", :vals => [free_cash_flow.total.to_nearest_million])
      if inc_stmt
        analysis.rows << CalculationRow.new(:key => "NI / C",  :vals => [ni_over_c(inc_stmt)])
      else
        analysis.rows << CalculationRow.new(:key => "NI / C",  :vals => [nil])
      end
 
      return analysis
    end

  end
end
