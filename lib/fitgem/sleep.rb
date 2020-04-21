module Fitgem
  class Client
    # ==========================================
    #          Sleep Retrieval Methods
    # ==========================================

    # Get sleep data for specified date
    #
    # @param [DateTime, Date, String] date
    # @return [Array] List of sleep items for the supplied date
    def sleep_on_date(date)
      get("/user/#{@user_id}/sleep/date/#{format_date(date)}.json")
    end

    # Get sleep data for specified date range
    #
    # @param [DateTime, Date, String] base_date
    # @param [DateTime, Date, String] end_date
    # @return [Hash]
    def sleep_on_date_range(base_date, end_date)
      get("/user/#{@user_id}/sleep/date/#{format_date(base_date)}/#{format_date(end_date)}.json")
    end

    # Get sleep data with pagination support. Note from Fitbit API: Some processing
    # is asynchronous. If the system is still processing one or more sleep logs that
    # should be in the response when this API is queried, the response will indicate
    # a retry duration given in milliseconds. The "meta" response may evolve with additional
    # fields in the future. API clients should be prepared to ignore any new object
    # properties they do not recognize.
    #
    # @example Here is a sample response to indicate the retry.
    #   {
    #     "meta": {
    #       "retryDuration": 3000,
    #       "state": "pending"
    #     }
    #   }
    #
    # @param [Hash] opts
    # @option opts [DateTime, Date, String] beforeDate
    # @option opts [DateTime, Date, String] afterDate
    # @option opts [String] sort
    # @option opts [Fixnum] limit
    # @return [Hash]
    def sleep_logs(opts)
      unless opts[:beforeDate] || opts[:afterDate]
        raise ArgumentError, 'Must specify either beforeDate or afterDate'
      end

      unless %w[asc desc].include?(opts[:sort])
        raise ArgumentError, 'Must specify sort order. One of (\"asc\" or \"desc\") is required.'
      end

      unless opts[:limit]
        raise ArgumentError, 'Must specify limit.'
      end

      opts[:beforeDate] = format_date(opts[:beforeDate]) if opts[:beforeDate]
      opts[:afterDate] = format_date(opts[:afterDate]) if opts[:afterDate]
      opts.merge!(offset: 0)

      self.api_version = '1.2'
      query = opts.empty? ? '' : "?#{to_query(opts)}"

      get("/user/#{@user_id}/sleep/list.json#{query}")
    end

    # ==========================================
    #          Sleep Logging Methods
    # ==========================================

    # Log sleep data to fitbit for current user
    #
    # All aspects of the options hash are REQUIRED.
    #
    # @param [Hash] opts Sleep data to log
    # @option opts [String] :startTime Hours and minutes in the format "HH:mm"
    # @option opts [Integer, String] :duration Sleep duration, in miliseconds
    # @option opts [DateTime, Date, String] :date Sleep log entry date;
    #   if a string it must be in the yyyy-MM-dd format, or the values
    #   'today' or 'tomorrow'
    #
    # @return [Hash] Summary of the logged sleep data
    #
    # @since v0.4.0
    def log_sleep(opts)
      post("/user/#{@user_id}/sleep.json", opts)
    end

    # Delete logged sleep data
    #
    # The sleep log id is the one returned when sleep data is recorded
    # via {#log_sleep}.
    #
    # @param [Integer, String] Sleep log id
    # @return [Hash] Empty hash denotes successful deletion
    #
    # @since v0.4.0
    def delete_sleep_log(sleep_log_id)
      delete("/user/#{@user_id}/sleep/#{sleep_log_id}.json")
    end

    private

    def to_query(hash)
      URI.encode(hash.map {|k,v| "#{k}=#{v}" }.join('&'))
    end
  end
end
