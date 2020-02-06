# frozen_string_literal: true

# Handles API versioning constraints
class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default ||
      (req.respond_to?('headers') &&
       req.headers.key?('Accept') &&
       req.headers['Accept'].eql?(
         "application/vnd.olubalance.v#{@version}"
       ))
  end
end
