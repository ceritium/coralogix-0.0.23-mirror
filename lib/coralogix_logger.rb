require_relative 'manager'
require_relative 'debug_logger'
require_relative 'httpsender'
require_relative 'constants'

module Coralogix

    class CoralogixLogger
        # Set 'new' method to be a private method. 
        # This way it won't be possible to create a new intance of this class from outside.
        private_class_method :new

        # Constructor. 
        #
        # @param name    -   logger name.
        def initialize name
            @category = name
        end

        # A getter for debug_mode. 
        # Default value is false.
        # When set to true the coralogix logger will print output messages to a console and a file.
        #
        # @return [boolean]    -   true or false. (Default is false)
        def self.debug_mode?
            DebugLogger.debug_mode
        end

        # A setter for debug_mode. 
        # Default value is false.
        # When set to true the coralogix logger will print output messages to a console and a file.
        #
        # @param value    -   true or false. (Default is false)
        def self.debug_mode=(value)
            DebugLogger.debug_mode=value
        end

        # A setter for disable_proxy. 
        # By default HTTP object will use proxy environment variable if exists. In some cases this migh be an issue
        # When set to false the HTTP object will ignore any proxy.
        #
        # @param value    -   true or false. (Default is false)
        def self.disable_proxy=(value)
            CoralogixHTTPSender.disable_proxy=value
        end

        # A class method (static) to return a new instance of the current class.
        # This is the most common pattern when using logging.
        #
        # @param name    -   name of the logger. The category. Usually this will be a new name for every class or a logical unit.
        # @return [CoralogixLogger] return a new instance of CoralogixLogger.
        def self.get_logger name
            #Return a new instance of the current class.
            CoralogixLogger.send(:new, name)
        end

        # Configure coralogix logger with customer specific values
        #
        # @param private_key    -   private key
        # @param app_name       -   application name
        # @param sub_system     -   sub system name
        # @return [boolean] return a true or false.
        def self.configure private_key, app_name, sub_system
            private_key = private_key.strip.empty? ? FAILED_PRIVATE_KEY : private_key
            app_name = app_name.strip.empty? ? NO_APP_NAME : app_name
            sub_system = sub_system.strip.empty? ? NO_SUB_SYSTEM : sub_system
            LoggerManager.configure(:privateKey => private_key, :applicationName => app_name, :subsystemName => sub_system) unless LoggerManager.configured
        end

        # Log a message. 
        #
        # @param severity    -   log severity
        # @param message     -   log message
        # @param category    -   log category
        # @param className   -   log class name
        # @param methodName  -   log method name
        # @param threadId    -   log thread id
        def log severity, message, category: @category, className: "", methodName: "", threadId: Thread.current.object_id.to_s
            LoggerManager.add_logline message, severity, category, :className => className, :methodName => methodName, :threadId => threadId
        end 

        # Create log methods for each severity. 
        # This is a ruby thing. If you are writing in other languages just create a method for each severity.
        # For instance, for info severity it will create a method:
        # def info message, category: @category, className: "", methodName: "", threadId: ""
        SEVERITIES.keys.each do |severity|
            define_method("#{severity}") do |message, category: @category, className: "", methodName: "", threadId: Thread.current.object_id.to_s|
                LoggerManager.add_logline message, SEVERITIES["#{__method__}".to_sym], category, :className => className, :methodName => methodName, :threadId => threadId
            end  
        end
    end

end
