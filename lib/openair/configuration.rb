module OpenAir
  module Configuration
    extend self

    def reset!
      attributes.clear
    end

    def attributes
      @attributes ||= {}
    end

    def api_key(key=nil)
      if key
        self.api_key = key
      else
        attributes[:api_key] ||
        raise(ConfigurationError,
          '#api_key is a required configuration value.')
      end
    end

    def api_key=(key)
      attributes[:api_key] = key
    end

    def api_url(url=nil)
      if url
        self.api_url = url
      else
        attributes[:api_url] ||= "https://sandbox.openair.com/api.pl"
      end
    end

    def api_url=(url)
      attributes[:api_url] = url
    end

    def company_id(company_id=nil)
      if company_id
        self.company_id = company_id
      else
        attributes[:company_id] ||
        raise(ConfigurationError,
          '#company_id is a required configuration value.')
      end
    end

    def company_id=(company_id)
      attributes[:company_id] = company_id
    end

    def username(username=nil)
      if username
        self.username = username
      else
        attributes[:username] ||
        raise(ConfigurationError,
          '#username is a required configuration value.')
      end
    end

    def username=(username)
      attributes[:username] = username
    end

    def password(password=nil)
      if password
        self.password = password
      else
        attributes[:password] ||
        raise(ConfigurationError,
          '#password is a required configuration value.')
      end
    end

    def password=(password)
      attributes[:password] = password
    end

    def log=(path)
      attributes[:log] = path
    end

    def log(path = nil)
      self.log = path if path
      attributes[:log]
    end

    def logger
      attributes[:logger] ||= ::Logger.new (log && !log.empty?) ? log : $stdout
    end

  end
end
