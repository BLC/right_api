class HttpServer
  attr_accessor :response_error_checker, :handle_errors, :headers
  attr_reader :last_response
  
  def initialize(server_config, timeout)
    @server_url, @port, @username, @password = server_config['server_url'], server_config['port'], server_config['username'], server_config['password']
    @timeout = timeout
    raise 'No configuration for timeout length' if @timeout.nil?

    @handle_errors = true
    @response_error_checker = Proc.new do |response, path|
      response.include? 'errors' if response
    end

    @headers = {
      'User-Agent'    => 'Mozilla/4.0',
      'Content-Type'  => 'application/x-www-form-urlencoded',
      'Connection'    => 'Keep-Alive',
      'X-API-VERSION' => RightScale::API_VERSION
    }
  end
  
  def delete(resource, &block)
    connect(resource, Net::HTTP::Delete, &block)
  end

  def get(resource, &block)
    connect(resource, Net::HTTP::Get, &block)
  end

  def get_with_params(resource, params={}, &block)
    connect(resource, Net::HTTP::Get, encode_params(params), &block)
  end

  def post(resource, params={}, &block)
    connect(resource, Net::HTTP::Post, encode_params(params), &block)
  end

  def put(resource, params={}, &block)
    connect(resource, Net::HTTP::Put, encode_params(params), &block)
  end

  def with_error_handling_disabled
    original_handle_errors = handle_errors
    self.handle_errors = false

    result = yield
  ensure
    self.handle_errors = original_handle_errors
  end

  private

  def connect(resource, request_object, *args, &block)
    uri = URI.parse url(resource)
    req = request_object.new(uri.path, @headers)
    req.basic_auth @username, @password if @username
    
    response_data = nil
    
    begin
      create_http(uri).start do |http|
        response, data = http.request(req, *args)
        
        block.call(self, response) if block
        
        @last_response = response_data = data_from(response)
      end
    rescue Timeout::Error
      raise "A timeout error occured when connecting to #{resource}.\nThe timeout is currently set to #{@timeout} seconds."
    rescue Errno::ECONNREFUSED
      raise "Could not connect when connecting to #{resource} - the server (#{@server_url}) is down."
    end
    
    check_response_for_errors(response_data, uri.path) if handle_errors
    
    response_data
  end
  
  def data_from(response)
    case response
    when Net::HTTPSuccess
      response.body
    when Net::HTTPRedirection
      response['location']
    end
  end
  
  def create_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.port == 443
    http.read_timeout = @timeout
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    # http.set_debug_output $stderr
        
    http
  end
   
  def url(resource)
    "#{server_path}/#{resource.sub /^\//, ''}"
  end
  
  def server_path
    @port ? "#{@server_url}:#{@port}" : @server_url
  end

  def encode_params(hash)
    params = transform_params(hash)
    stringify_params(params)
  end

  def transform_params(hash)
    params = []

    hash.each do |key, value|
      if value.instance_of? Hash
        params.concat transform_params(value).each{|elements| elements[0].unshift key}
      else
        params.push [[key], value]
      end
    end

    params
  end

  def stringify_params(params)
    params.map do |keys, value|
      left = keys.join('[') + (']' * (keys.length - 1))
      "#{left}=#{CGI::escape(value.to_s)}"
    end.join('&')
  end
  
  def check_response_for_errors(response, path)
    if response && response.include?('No connection could be made')
      raise Errno::ECONNREFUSED
    elsif @response_error_checker.call(response, path)
      raise "An error occured requesting #{path} - please check the XML response:\n #{response}\nCurrent data:\n#{@data}"
    end
  end
end