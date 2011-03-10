module Service
  class DuplicateNameError < StandardError; end
  class SubclassError < StandardError; end
  # this is used to stop the
  class ServiceImmediateStopError < StandardError
    attr_accessor :service_result
    def initialize(service_result)
      self.service_result = service_result
    end
  end
  class ServiceDescription
    attr_accessor :name, :klass, :arguments

    def initialize(options = {})
      update(options[:name], options[:klass])
      self.arguments = []
    end

    def update(name, klass)
      self.name = name
      self.klass = klass
    end

    def create(options = {})
      service = klass.new
      inject_arguments(service, options)
      service
    end

    def add_argument(name)
      self.arguments << name.to_sym
    end

    def verify_arguments!(options)
      missing_keys = arguments.select { |arg| !options.has_key?(arg) }
      raise ArgumentError, "Missing the following arguments: #{missing_keys.join(', ')}" if missing_keys.present?
    end

    def inject_arguments(service, options)
      verify_arguments!(options)

      arguments.each do |argument|
        service.send("#{argument}=", options[argument])
      end
    end

  end

  class ServiceResult
    attr_accessor :code, :object, :error
    def initialize
      self.code = :success
    end

    def import(service_result)
      # setup the result from chain
      self.object = service_result.object
      if service_result.error.present?
        record_error(service_result.error)
      else
        self.code = service_result.code
      end
    end

    def import_code(service_result)
      self.code = service_result.code
    end

    def record_error(error)
      self.error = error
      self.code = :error
      HoptoadNotifier.notify(error) if Partnerpedia::Environment.should_notify_hoptoad?
    end

    def to_s
      if error.present?
        "code: #{code}, object: #{object}, error: #{error}"
      else
        "code: #{code}, object: #{object}"
      end
    end

  end

  class Base
    attr_writer :chained_service

    class_attribute :all_services
    self.all_services = {}

    class_attribute :service_description
    class_attribute :defaults, :instance_writer => false

    self.defaults = {
      :return_on_first => [:error],
      :injected_services => {}
    }

    class << self
      # hooks into the inheritance and setups the name by default
      def inherited(base)
        name = base.name.split('::').last.gsub('Service', '').underscore
        base.send(:service_name, name) rescue DuplicateNameError nil
      end

      def inject(options)
      end

      def with_defaults(new_defaults)
        old_defaults = self.defaults
        self.defaults = old_defaults.deep_merge(new_defaults)
        yield
      ensure
        self.defaults = old_defaults
      end

      def return_on_first(*results)
        with_defaults(:return_on_first => Array.wrap(results)) do
          yield
        end
      end

      def injected_services(services = {})
        defaults[:injected_services] = services
      end

      # def service_method(name, *args, &block)
      #   service_description.add_method(name.to_sym)
      #   define_method(name, &block)
      # end

      def service_name(name)
        verify_subclass!
        key_name = name.to_sym
        raise DuplicateNameError, "The service #{self.name} is trying to define a service_name of #{name} when it has already been defined by #{all_services[key_name].klass.name}" if all_services.has_key?(key_name)

        # remove the old entry
        all_services.delete(service_description.name) if service_description.present?

        self.service_description ||= ServiceDescription.new
        service_description.update(key_name, self)

        # save off reference
        all_services[service_description.name] = service_description
      end

      def service(name, options = {})
        return defaults[:injected_services][name] if defaults[:injected_services].has_key?(name)

        description = all_services[name]

        # if the description isn't there then load the class and try again
        if description.blank?
          service_klass = "#{name}_service".classify
          service_klass.constantize rescue nil
          description = all_services[name]
        end

        # actually instantiate the service if it is found
        if description.present?
          initialize_params = (defaults[:init] || {}).merge(options)
          description.create(initialize_params)
        else
          nil
        end
      end

      def service_init(*names)
        verify_subclass!
        Array.wrap(names).each do |name|
          service_description.add_argument(name)
          self.send(:attr_accessor, name.to_sym)
        end
      end

      def verify_subclass!
        raise SubclassError, "This method must only be called from a subclass" if self == Base
      end

      def log(message)
        Rails.logger.info message
      end

    end

    def initialize()
      @chained_service = false
    end
    
    def in_top_level_service_call?(name)
      @_top_level_service_call == name
    end

    def invoke(name, *arguments)
      start_service_call(name)
      log("Start Service Call #{self.class.name}.#{name} w/ #{arguments.inspect}")

      begin
        service_result.object = send(name, *arguments)

        # the following errors are always raised..
      rescue ArgumentError, NoMethodError, NameError
        raise
        # internal helper error to pass state up the stack immediately
      rescue ServiceImmediateStopError => error

        if in_top_level_service_call?(name)
          # skip the entire stacks
          @service_result = error.service_result
        else
          raise
        end
      rescue StandardError => error
        service_result.record_error(error)
      end

      previous_service_result = end_service_call(name)
      error_msg = ''
      log_end_service_call(name, service_result)
      previous_service_result
    end

    def service_call(name, *arguments)
      invoke(name, *arguments).object
    end

    def log_end_service_call(name, result)
      error_msg = ""
      if result.code != :success && result.object.respond_to?(:errors)
        error_msg = " errors: #{result.object.errors.full_messages.join(', ')}"
      end
      log("Ending Service Call #{self.class.name}.#{name} result: #{result}#{error_msg}")
    end

    def return_on_first(*results)
      self.class.return_on_first(*results) do
        yield
      end
    end

    def result(code = nil)
      if @service_result.nil?
        nil
      elsif code.nil?
        @service_result.code
      else
        @service_result.code = code
      end
    end

    def service_result
      @service_result
    end

    def error
      @service_result.error
    end

    def record_error(error)
      @service_result.record_error(error)
    end

    def service(name, options = {})
      self.class.service(name, options).tap do |service|
        service.set_chained_service(self)
      end
    end

    def start_service_call(name)
      if !service_call_in_progress?
        @_top_level_service_call = name
        @_service_result_stack = []
      end

      # save off the old one..
      @_service_result_stack << @service_result if @service_result.present?

      # create the new serviceresult frame
      @service_result = ServiceResult.new
    end

    def set_chained_service(service)
      self.chained_service = service
      @_service_result_stack = []
    end

    def end_service_call(name)
      # clear top_level_call
      if in_top_level_service_call?(name)
        @_top_level_service_call = nil
        @service_result
      else
        # copy the result up
        if should_return_immediately?(name)
          log "Stopping Service Call Chain in #{self.class.name} w/ result: #{@service_result}"
          raise ServiceImmediateStopError.new(@service_result)
        elsif @_service_result_stack.present?
          @old_service_result = @service_result
          @service_result = @_service_result_stack.pop
          @old_service_result
        elsif @chained_service.present?
          log @chained_service.inspect
          @chained_service.service_result.import_code(@service_result)
          @service_result
        else
          raise "Why am i here - Ask Adam"
        end
      end
    end

    def should_return_immediately?(name)
      return false if in_top_level_service_call?(name) # already will return right away
      defaults[:return_on_first].include?(result)
    end

    def service_call_in_progress?
      @chained_service.present? || @_top_level_service_call
    end

    def service_call_results
      if @chained_service.present?
        @chained_service.service_call_results
      else
        @_service_call_results
      end
    end

    def log(message)
      Rails.logger.info message
    end
  end
end
