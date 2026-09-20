module Cas
  # Builds a time from the parts a date or datetime select submits
  # ({1 => year, 2 => month, 3 => day[, 4 => hour, 5 => minute]}).
  #
  # Rails' own conversion goes through TZInfo's local_to_utc, which raises when
  # the local time does not exist: Brazil's daylight saving time started at
  # midnight until 2019, so midnight is missing on those days. Time.zone.local
  # moves such a time forward to the first existing hour instead.
  #
  # A pick without a time of day keeps the stored time when the day is
  # unchanged, takes the current time when the day is today, and is midnight
  # otherwise. A pick missing any of year, month or day is no date: the
  # selects offer a blank option, and Rails passes nil for the parts left
  # blank.
  class MultiparameterTime
    DATE_PARTS = [1, 2, 3].freeze

    def initialize(parts, current: nil)
      @parts = parts
      @current = current
    end

    def incomplete?
      !date_given?
    end

    def to_time
      return if incomplete?
      return with_time_of_day if time_of_day_given?
      return @current if same_day_as_current?
      return Time.current if today?

      day
    end

    private

    def date_given?
      DATE_PARTS.all? { |part| @parts[part].present? }
    end

    def time_of_day_given?
      @parts.key?(4)
    end

    def day
      Time.zone.local(@parts[1], @parts[2], @parts[3])
    end

    def with_time_of_day
      Time.zone.local(@parts[1], @parts[2], @parts[3], @parts[4].to_i, @parts[5].to_i)
    end

    def same_day_as_current?
      @current.present? && @current.in_time_zone.to_date == day.to_date
    end

    def today?
      day.to_date == Date.current
    end
  end
end
