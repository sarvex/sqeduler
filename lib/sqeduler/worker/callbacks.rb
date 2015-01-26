# encoding: utf-8
module Sqeduler
  module Worker
    # Basic callbacks for worker events.
    module Callbacks
      def perform(*args)
        before_start
        super
        on_success
      rescue StandardError => e
        puts e
        on_failure(e)
        raise e
      end

      private

      # provides an oppurtunity to log when the job has started (maybe create a
      # stateful db record for this job run?)
      def before_start
        Service.logger.info "Starting #{self.class.name} #{start_time}"
        super if defined?(super)
      end

      # callback for successful run of this job
      def on_success
        Service.logger.info "#{self.class.name} completed at #{end_time}. Total time #{total_time}"
        super if defined?(super)
      end

      # callback for when failues in this job occur
      def on_failure(e)
        Service.logger.error "#{self.class.name} failed with exception #{e}"
        super if defined?(super)
      end
    end
  end
end
