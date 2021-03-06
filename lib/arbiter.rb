require 'ap'

module DTK
  module Agent
    class Arbiter

      attr_reader :process_pool

      def initialize(consumer_hash)
        @received_message = consumer_hash
        @process_pool     = []
        @execution_list   = @received_message['execution_list']||[]

        @top_task_id = @received_message['top_task_id']
        @task_id = @received_message['task_id']
        @module_name = @received_message['module_name']
        @action_name = @received_message['action_name']

        # no need to run other commands if there is no execution list
        if @execution_list.empty?
          Log.error "Execution list is not provided or empty, DTK Action Agent has nothing to run"
          return
        end

        @commander = Commander.new(@received_message['execution_list'])
      end

      def run
        return { :results => [], :errors => Log.execution_errors } if @execution_list.empty?

        # start commander runnes
        @commander.run()

        results = @commander.results()

        if @top_task_id && @task_id
          Log.log_results(@execution_list, results, @module_name, @action_name, @top_task_id, @task_id)
        end

        # return results
        { :results => results, :errors => Log.execution_errors }
      end

    end
  end
end