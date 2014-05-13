module Resque
  module Metrics
    module Backends
      class Statsd
        attr_accessor :statsd, :stats_prefix

        def initialize(stats, stats_prefix = 'resque')
          @statsd = statsd
          @stats_prefix = stats_prefix
        end

        def increment_metric(metric, by = 1)
          if metric =~ /(.+)(?:_job)_(time|count)(?::(queue|job):(.*))?$/
            event = $1
            event = 'complete' if event == 'job'

            time_or_count = $2
            queue_or_job = $3
            queue_or_job_name = $4
            key = if queue_or_job && queue_or_job_name
                    # ie resque.complete.queue.high.count, resque.failed.job.Index.timing
                    "#{stats_prefix}.#{event}.#{queue_or_job}.#{queue_or_job_name}.#{time_or_count}"
                  else

                    # ie resque.complete.time
                    "#{stats_prefix}.#{event}.#{time_or_count}"
                  end
            case event
            when 'time'
              statsd.timing key, by
            when 'count'
              statsd.increment key, by
            else
              raise "Not sure how to handle #{$2} metric #{metric}"
            end
          else
            raise "Not sure how to handle metric #{metric}"
          end
        end

        # set_metric: we'll actually be dealing only in increments & timings for now
        # set_avg: let statsd & graphite handle that
        # get_metric: would have to talk to graphite. but man, complicated
      end
    end
  end
end
