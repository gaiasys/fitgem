module Fitgem
  class Client
    # ==========================================
    #       Heart Rate Retrieval Methods
    # ==========================================

    # Get heart rate log entries for the supplied date
    #
    # @param [DateTime, Date, String] date
    # @return [Hash] Hash containing an average of the days logs, and a
    #   list of all individual entries
    def heart_rate_on_date(date)
      get("/user/#{@user_id}/heart/date/#{format_date(date)}.json")
    end

    # Get heart rate log entries for the supplied date range with different detail levels
    # such as minutes and seconds
    #
    # @param [Hash] opts
    # @option opts [DateTime, Date, String] start_date
    # @option opts [DateTime, Date, String] end_date
    # @option opts [String] :detail_level Number of data points to include. Either 1sec or 1min. Optional.
    # @option opts [String] :start_time The start of the period, in the format HH:mm. Optional.
    # @option opts [String] :end_time The end of the period, in the format HH:mm. Optional.
    # @return [Array]
    def heart_rate_on_intraday(opts)
      paths = []

      start_date = opts[:start_date]
      paths << format_date(start_date) if start_date
      end_date = opts[:end_date]
      paths << format_date(end_date) if end_date
      paths << opts[:detail_level] if opts[:detail_level]

      if opts[:start_time] && opts[:end_time]
        paths << "/time/#{opts[:start_time]}/#{opts[:end_time]}"
      end

      get("/user/#{@user_id}/heart/date/#{paths.join('/')}.json")
    end

    # ==========================================
    #        Heart Rate Logging Methods
    # ==========================================

    # Log heart rate information to fitbit
    #
    # @param [Hash] opts Heart rate data
    # @option opts [String] :tracker Heart rate tracker name;
    #   predefined or custom tracker name (matches tracker name on the website) (REQUIRED)
    # @option opts [Integer, String] :heart_rate Heart rate measurement (REQUIRED)
    # @option opts [DateTime, Date, String] :date Log entry date (REQUIRED)
    # @option opts [DateTime, String] :time Time of the measurement; hours and minutes in the format HH:mm
    #
    # @return [Hash] Summary of logged information
    def log_heart_rate(opts)
      unless opts[:tracker] && opts[:heart_rate] && opts[:date]
        raise Fitgem::InvalidArgumentError, "Must include :tracker, :heart_rate, and :date in order to lof heart rate data"
      end

      opts[:heartRate] = opts.delete :heart_rate
      opts[:date] = format_date(opts[:date])
      opts[:time] = format_time(opts[:time]) if opts[:time]
      post("/user/#{@user_id}/heart.json", opts)
    end

    # Delete logged heart rate information
    #
    # @param [Integer, String] heart_rate_log_id The id of previously logged
    #   heart rate data
    # @return [Hash] Empty hash denotes success
    def delete_heart_rate_log(heart_rate_log_id)
      delete("/user/-/heart/#{heart_rate_log_id}.json")
    end
  end
end