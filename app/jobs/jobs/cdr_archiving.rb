module Jobs
  class CdrArchiving < ::BaseJob
    def execute
      @archive_delay=GuiConfig.cdr_archive_delay
      @remove_delay=GuiConfig.cdr_remove_delay


      # date_stop<NOW() - already closed table. No new writes to this table
      @candidate=Cdr::Table.where("active and date_stop::timestamp<now()").reorder("date_stop::timestamp desc").offset(@archive_delay).to_a.last
      unless @candidate.nil?
        @candidate.archive
      end

      # We can remove only achived (inactive) CDR tables.
      @remove_candidate=Cdr::Table.where("active=false and date_stop::timestamp<now()").reorder("date_stop::timestamp desc").offset(@remove_delay).to_a.last
      unless @remove_candidate.nil?
        @remove_candidate.remove
      end

    end

  end
end
