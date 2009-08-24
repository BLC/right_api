require 'hpricot'
require 'active_support'

require 'right_api/http_server'
require 'right_api/accessible_fragment'

# Rightscale
module RightScale
  API_VERSION = '1.0'

  class Base
    include AccessibleFragment
    
    def initialize(data)
      raise "You must first establish a connection via Base.establish_connection" unless @@connection
      @data = data
    end
    
    def id
      @id ||= href.split('/').last
    end
    
    def data
      @data ||= @@connection.get("/#{plural_name}/#{id}")
    end
    
    def update_attribute(attribute, value)
      @@connection.put("/#{self.class.plural_name}/#{id}", "#{self.class.class_name}[#{attribute}]" => value)
    end
    
    def self.class_name
      name.split("::").last.underscore
    end

    def self.plural_name
      class_name.pluralize
    end
    
    def self.xml_name
      class_name.dasherize
    end

    
    def self.establish_connection(user, password, account_id)
      url = "https://my.rightscale.com/api/acct/#{account_id}"
      params = {'server_url' => url, 'username' => user, 'password' => password}
      
      @@connection = HttpServer.new(params, 60)
      @@connection.get('/login')
      
      params = {'server_url' => "https://my.rightscale.com"}
      
      @@non_api_connection = HttpServer.new(params, 60)
      @@non_api_connection.post('/sessions', 'email' => user, 'password' => password) do |server, response|
        cookies = response.response.get_fields('set-cookie')
        session_cookie = cookies.detect { |cookie| cookie =~ /_session_id/ }
        cookie_header_for_request = session_cookie.split(';').first
        server.headers = server.headers.merge('cookie' => cookie_header_for_request, 'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest')
      end
      
    end

    def self.all(opts={})
      find_with_options(opts)
    end
    
    def self.first(opts={})
      find_first_with_options(opts)
    end

    def self.find(opts=nil)
      if opts.nil?
        raise "Find requires a hash of options or an id"
      elsif opts.is_a?(Hash)
        find_with_options(opts)
      else
        find(:id => opts)
      end
    end
    
    private

    def self.find_with_options(opts)
      find_all
      
      @all.select do |member|
        opts.all? {|k, v| member.send(k) == v }
      end
    end
    
    def self.find_first_with_options(opts)
      find_all
      
      @all.detect do |member|
        opts.all? {|k, v| member.send(k) == v }
      end
    end
    
    def self.find_all
      return unless @all.nil?
      
      response = @@connection.get("/#{plural_name}")
      doc = Hpricot::XML(response)
      @all = (doc / xml_name).map {|data| new(data)}
    end
  end
  
  class Deployment < Base
    def self.find_by_nickname(nickname)
      deployments = all.select { |deployment| deployment.nickname == nickname }
      
      if deployments.size != 1
        raise "Found #{deployments.size} deployments matching #{nickname}. Double check your nickname, it should be exact to avoid hitting the deployment."
      end
      
      deployments.first
    end
    
    def servers
      (@data / 'server').map {|data| Server.new(data)}
    end
  end
  
  class Server < Base
    attr_accessor :aws_id

    def deployment
      @deployment ||= Deployment.all.detect {|deployment| deployment.id == deployment_href.split('/').last}
    end

    def aws_id
      @aws_id ||= @@non_api_connection.get("/servers/#{id}").scan(/i-[a-f0-9]{8}/i).first
    end
    
    def volume_rightscale_ids
      puts @@non_api_connection.get("/servers/#{id}/volumes").scan(/(?=ec2_ebs_volumes\/)\d+/).inspect
    end
  end
  
  class RightScript < Base
  end
  
  class Ec2EbsVolume < Base
  end

  class Ec2EbsSnapshot < Base
  end
end
