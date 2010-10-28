# Copyright (c) 2009 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module RightScale

  # Mixin for collecting and displaying operational statistics for servers
  module StatsHelper

    # (Integer) Maximum characters in stat name
    MAX_STAT_NAME_WIDTH = 11

    # (Integer) Maximum characters in sub-stat name
    MAX_SUB_STAT_NAME_WIDTH = 17

    # (Integer) Maximum characters in sub-stat value line
    MAX_SUB_STAT_VALUE_WIDTH = 80

    # (Integer) Maximum characters displayed for exception message
    MAX_EXCEPTION_MESSAGE_WIDTH = 60

    # (String) Separator between stat name and stat value
    SEPARATOR = " : "

    # Track activity statistics
    class ActivityStats

      # Number of samples included in calculating average recent activity
      RECENT_SIZE = 10

      # (Integer) Total number of actions
      attr_reader :total

      # (Hash) Number of actions per type
      attr_reader :count_per_type

      # (Float) Average duration in seconds of action weighted toward recent activity
      attr_reader :avg_duration

      # Initialize activity data
      #
      # === Parameters
      # measure_rate(Boolean):: Whether to measure activity rate
      def initialize(measure_rate = true)
        @measure_rate = measure_rate
        @interval = 0.0
        @last_start_time = Time.now
        @avg_duration = 0.0
        @total = 0
        @count_per_type = {}
      end

      # Mark the start of an action and update counts and average rate
      # with weighting toward recent activity
      #
      # === Parameters
      # type(String|Symbol):: Type of action, defaults to nil
      #
      # === Return
      # now(Time):: Update time
      def update(type = nil)
        now = Time.now
        @interval = ((@interval * (RECENT_SIZE - 1)) + (now - @last_start_time)) / RECENT_SIZE if @measure_rate
        @last_start_time = now
        @total += 1
        @count_per_type[type] = (@count_per_type[type] || 0) + 1 if type
        now
      end

      # Mark the finish of an action and update the average duration
      #
      # === Parameters
      # start_time(Time):: Time when action started, defaults to last time start was called
      #
      # === Return
      # now(Time):: Finish time
      def finish(start_time = nil)
        now = Time.now
        start_time ||= @last_start_time
        @avg_duration = ((@avg_duration * (RECENT_SIZE - 1)) + (now - start_time)) / RECENT_SIZE
        now
      end

      # Convert average interval to average rate
      #
      # === Return
      # (Float):: Recent average rate
      def avg_rate
        if @interval == 0.0 then 0.0 else 1.0 / @interval end
      end

      # Get number of seconds since last action
      #
      # === Return
      # (Integer|nil):: Seconds, or nil if the total is 0
      def last
        (Time.now - @last_start_time).to_i if @total > 0
      end

      # Convert count per type into percentage by type
      #
      # === Return
      # (Hash):: Converted data with keys "total" and "percent" with latter being a hash of percentage per type
      def percent
        percent = {}
        @count_per_type.each { |k, v| percent[k] = (v * 100.0) / @total } if @total > 0
        {"percent" => percent, "total" => @total}
      end

    end # ActivityStats

    # Track exception statistics
    class ExceptionStats

      # Maximum number of recent exceptions to track per category
      MAX_RECENT_EXCEPTIONS = 10

      # (Hash) Exceptions raised per category with keys
      #   "total"(Integer):: Total exceptions for this category
      #   "recent"(Array):: Most recent as a hash of "count", "type", "message", "when", and "where"
      attr_reader :stats

      # Initialize exception data
      #
      # === Parameters
      # server(Object):: Server where exceptions are originating, must be defined for callbacks
      # callback(Proc):: Block with following parameters to be activated when an exception occurs
      #   exception(Exception):: Exception
      #   message(Packet):: Message being processed
      #   server(Server):: Server where exception occurred
      def initialize(server = nil, callback = nil)
        @server = server
        @callback = callback
        @stats = {}
      end

      # Track exception statistics and optionally make callback to report exception
      # Catch any exceptions since this function may be called from within an EM block
      # and an exception here would then derail EM
      #
      # === Parameters
      # category(String):: Exception category
      # exception(Exception):: Exception
      #
      # === Return
      # true:: Always return true
      def track(category, exception, message = nil)
        begin
          @callback.call(exception, message, @server) if @server && @callback && message
          exceptions = (@stats[category] ||= {"total" => 0, "recent" => []})
          exceptions["total"] += 1
          recent = exceptions["recent"]
          last = recent.last
          if last && last["type"] == exception.class.name && last["message"] == exception.message && last["where"] == exception.backtrace.first
            last["count"] += 1
            last["when"] = Time.now.to_i
          else
            backtrace = exception.backtrace.first if exception.backtrace
            recent.shift if recent.size >= MAX_RECENT_EXCEPTIONS
            recent.push({"count" => 1, "when" => Time.now.to_i, "type" => exception.class.name,
                         "message" => exception.message, "where" => backtrace})
          end
        rescue Exception => e
          RightLinkLog.error("Failed to track exception '#{exception}' due to: #{e}\n" + e.backtrace.join("\n")) rescue nil
        end
        true
      end

    end # ExceptionStats

    # Convert count per type hash into percentages
    #
    # === Parameters
    # count_per_type(Hash):: Number per type
    #
    # === Return
    # (Hash):: Converted data with keys "total" and "percent" with latter being a hash of percentage per type
    def percent(count_per_type)
      total = 0
      count_per_type.each_value { |v| total += v }
      percent = {}
      count_per_type.each { |k, v| percent[k] = (v * 100.0) / total } if total > 0
      {"percent" => percent, "total" => total}
    end

    # Converts server statistics to a displayable format
    #
    # === Parameters
    # stats(Hash):: Statistics with generic keys "stats time", "last reset time", "identity",
    #   "hostname", "version", and "broker"; other keys ending with "stats" have an associated
    #   hash value that is displayed in sorted key order
    #
    # === Return
    # (String):: Display string
    def stats_str(stats)
      name_width = MAX_STAT_NAME_WIDTH
      str = sprintf("%-#{name_width}s#{SEPARATOR}%s\n", "stats time", Time.at(stats["stats time"])) +
            sprintf("%-#{name_width}s#{SEPARATOR}%s\n", "last reset", Time.at(stats["last reset time"])) +
            sprintf("%-#{name_width}s#{SEPARATOR}%s\n", "hostname", stats["hostname"]) +
            sprintf("%-#{name_width}s#{SEPARATOR}%s\n", "identity", stats["identity"])
      str += brokers_str(stats["brokers"], name_width) if stats.has_key?("brokers")
      str += sprintf("%-#{name_width}s#{SEPARATOR}%s\n", "version", stats["version"].to_i) if stats.has_key?("version")
      stats.to_a.sort.each { |k, v| str += sub_stats_str(k[0..-7], v, name_width) if k.to_s =~ /stats$/ }
      str
    end

    # Convert broker information to displayable format
    #
    # === Parameter
    # brokers(Array):: Hash of information for each broker
    # name_width(Integer):: Fixed width for left-justified name display
    #
    # === Return
    # (String):: Broker display with one line per broker
    def brokers_str(brokers, name_width)
      value_indent = " " * (name_width + SEPARATOR.size)
      sprintf("%-#{name_width}s#{SEPARATOR}", "brokers") + brokers.map do |b|
        sprintf("alias: %s, identity: %s, status: %s, tries: %d\n",
                b["alias"], b["identity"], b["status"], b["tries"])
      end.join(value_indent)
    end

    # Convert grouped set of statistics to displayable format
    # Display any empty values as "none"
    #
    # === Parameters
    # name(String):: Display name for the stat
    # value(Object):: Value of this stat
    # name_width(Integer):: Fixed width for left-justified name display
    #
    # === Return
    # (String):: Single line display of stat
    def sub_stats_str(name, value, name_width)
      value_indent = " " * (name_width + SEPARATOR.size)
      sub_name_width = MAX_SUB_STAT_NAME_WIDTH
      sub_value_indent = " " * (name_width + sub_name_width + (SEPARATOR.size * 2))
      sprintf("%-#{name_width}s#{SEPARATOR}", name) + value.to_a.sort.map do |attr|
        k, v = attr
        sprintf("%-#{sub_name_width}s#{SEPARATOR}", k) + if v.is_a?(Float)
          sprintf("%.3f", v)
        elsif v.is_a?(Hash)
          if v.empty? || v["total"] == 0
            "none"
          elsif k == "exceptions"
            exceptions_str(v, sub_value_indent)
          else
            wrap(hash_str(v), MAX_SUB_STAT_VALUE_WIDTH, sub_value_indent, ", ")
          end
        else
          "#{v || "none"}"
        end + "\n"
      end.join(value_indent)
    end

    # Convert exception information to displayable format
    #
    # === Parameters
    # exceptions(Hash):: Exceptions raised per category
    #   "total"(Integer):: Total exceptions for this category
    #   "recent"(Array):: Most recent as a hash of "count", "type", "message", "when", and "where"
    # indent(String):: Indentation for each line
    #
    # === Return
    # (String):: Exception display with one line per exception
    def exceptions_str(exceptions, indent)
      indent2 = indent + (" " * 4)
      exceptions.to_a.sort.map do |k, v|
        sprintf("%s total: %d, most recent:\n", k, v["total"]) + v["recent"].reverse.map do |e|
          message = e["message"]
          if message && message.size > MAX_EXCEPTION_MESSAGE_WIDTH
            message = e["message"][0..MAX_EXCEPTION_MESSAGE_WIDTH] + "..."
          end
          indent + "(#{e["count"]}) #{Time.at(e["when"])} #{e["type"]}: #{message}\n" + indent2 + "#{e["where"]}"
        end.join("\n")
      end.join("\n" + indent)
    end

    # Convert arbitrary nested hash to displayable format
    # Sort hash entries, numerically if possible, otherwise alphabetically
    # Display any floating point values with one decimal place accuracy
    # Display any empty values as "none"
    #
    # === Parameters
    # hash(Hash):: Hash to be displayed
    #
    # === Return
    # (String):: Single line hash display
    def hash_str(hash)
      str = ""
      hash.to_a.map { |k, v| [k =~ /^\d+$/ ? k.to_i : k, v] }.sort.map do |k, v|
        "#{k}: " + if v.is_a?(Float)
          sprintf("%.1f", v)
        elsif v.is_a?(Hash)
          "[ " + hash_str(v) + " ]"
        else
          "#{v || "none"}"
        end
      end.join(", ")
    end

    # Wrap string by breaking it into lines at the specified separator
    #
    # === Parameters
    # string(String):: String to be wrapped
    # max_length(Integer):: Maximum length of a line excluding indentation
    # indent(String):: Indentation for each line
    # separator(String):: Separator at which to make line breaks
    #
    # === Return
    # (String):: Multi-line string
    def wrap(string, max_length, indent, separator)
      all = []
      line = ""
      for l in string.split(separator)
        if (line + l).length >= max_length
          all.push(line)
          line = ""
        end
        line += line == "" ? l : separator + l
      end
      all.push(line).join(separator + "\n" + indent)
    end

  end # StatsHelper

end # RightScale