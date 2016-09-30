require 'deepviz/result'

class Intel

  URL_INTEL_SEARCH            = 'https://api.deepviz.com/intel/search'
  URL_INTEL_DOWNLOAD_REPORT   = 'https://api.deepviz.com/intel/report'
  URL_INTEL_IP                = 'https://api.deepviz.com/intel/network/ip'
  URL_INTEL_DOMAIN            = 'https://api.deepviz.com/intel/network/domain'
  URL_INTEL_SEARCH_ADVANCED   = 'https://api.deepviz.com/intel/search/advanced'

  def ip_info(api_key, ip, filters=nil)
    if api_key == nil or api_key == ''
      return Result.new(status=INPUT_ERROR, msg='API key cannot be null or empty String')
    end

    if ip.nil? or ip == ''
      msg = 'Parameters missing or invalid. You must specify an IP.'
      return Result.new(status=INPUT_ERROR, msg=msg)
    end

    if filters != nil and !filters.kind_of?(Array)
      msg = 'You must provide one or more output filters in a list'
      return Result.new(status=INPUT_ERROR, msg=msg)
    end

    if filters != nil
      body = {
        :output_filters => filters,
        :api_key => api_key,
        :ip => ip,
      }
    else
      body = {
          :api_key => api_key,
          :ip => ip,
      }
    end

    return do_post(body, URL_INTEL_IP)
  end


  def domain_info(api_key, domain, filters = nil)
    if api_key.nil? or api_key == ''
      return Result.new(status=INPUT_ERROR, msg='API key cannot be null or empty String')
    end


    if domain.nil? or domain == ''
      msg = 'Parameters missing or invalid. You must specify an domain.'
      return Result.new(status=INPUT_ERROR, msg=msg)
    end

    if filters != nil and !filters.kind_of?(Array)
      msg = 'You must provide one or more output filters in a list'
      return Result.new(status=INPUT_ERROR, msg=msg)
    end

    if filters != nil
      body = {
          :output_filters => filters,
          :api_key => api_key,
          :domain => domain,
      }
    else
      body = {
          :api_key => api_key,
          :domain => domain,
      }
    end

    return do_post(body, URL_INTEL_DOMAIN)
  end

  def search(api_key, search_string, options={})
    if api_key == nil or api_key == ''
      return Result.new(status=INPUT_ERROR, msg='API key cannot be null or empty String')
    end

    if search_string == nil or search_string == ''
      return Result.new(status=INPUT_ERROR, msg='String to be searched cannot be null or empty')
    end

    defaults = {
        :start_offset => nil,
        :elements => nil,
    }

    options = defaults.merge(options)

    if options['start_offset'] != nil and options['elements'] != nil and options['start_offset'].is_a? Integer and !options['elements'].is_a? Integer
      result_set = ['start=%d' % options['start_offset'], 'rows=%d' % options['elements']]

      body = {
        :'result_set' => result_set,
        :'string' => search_string,
        :'api_key' => api_key,
      }
    else
      body = {
          :'string' => search_string,
          :'api_key' => api_key,
      }
    end

    return do_post(body, URL_INTEL_SEARCH)
  end

  def advanced_search(api_key, options={})
    if api_key == nil or api_key == ''
      return Result.new(status=INPUT_ERROR, msg='API key cannot be null or empty String')
    end

    defaults = {
        :classification => nil,
        :created_files => nil,
        :never_seen => false,
        :time_delta => nil,
        :result_set => nil,
        :sim_hash => nil,
        :imp_hash => nil,
        :ip_range => nil,
        :strings => nil,
        :country => nil,
        :domain => nil,
        :rules => nil,
        :asn => nil,
        :url => nil,
        :ip => nil,
    }

    options = defaults.merge(options)

    body = {
        :api_key => api_key
    }

    if options['created_files'].kind_of?(Array)
      body[:created_files] = options['created_files']
    end

    _never_seen = 'false'
    if options[:never_seen] != nil and options[:never_seen]
      _never_seen = 'true'
    end
    body[:never_seen] = _never_seen

    if options['result_set'].kind_of?(Array)
      body[:result_set] = options['result_set']
    end

    if options['sim_hash'].kind_of?(Array)
      body[:sim_hash] = options['sim_hash']
    end

    if options['imp_hash'].kind_of?(Array)
      body[:imp_hash] = options['imp_hash']
    end

    if options['strings'].kind_of?(Array)
      body[:strings] = options['strings']
    end

    if options['country'].kind_of?(Array)
      body[:country] = options['country']
    end

    if options['classification'] != nil
      body[:classification] =  options['classification']
    end

    if options['domain'].kind_of?(Array)
      body[:domain] = options['domain']
    end

    if options['rules'].kind_of?(Array)
      body[:rules] = options['rules']
    end

    if options['time_delta'] != nil
      body[:time_delta] =  options['time_delta']
    end

    if options['asn'].kind_of?(Array)
      body[:asn] = options['asn']
    end

    if options['url'].kind_of?(Array)
      body[:url] = options['url']
    end

    if options['ip'].kind_of?(Array)
      body[:ip] = options['ip']
    end

    if options['ip_range'] != nil
      body[:ip_range] =  options['ip_range']
    end

    return do_post(body, URL_INTEL_SEARCH_ADVANCED)
  end

  def do_post(body, api_uri)
    begin
      response = Unirest.post(api_uri,
                              headers:{ 'Content-Type' => 'application/json' },
                              parameters:body.to_json)
    rescue Exception
      return Result.new(status=NETWORK_ERROR, msg='%s - Error while connecting to Deepviz: %s' % [response.code, response.body['errmsg']])
    end

    if response.code == 200
      return Result.new(status=SUCCESS, msg=response.body['data'])
    else
      if response.code >= 500
        return Result.new(status=SERVER_ERROR, msg='%s - Error while connecting to Deepviz: %s' % [response.code, response.body['errmsg']])
      else
        return Result.new(status=CLIENT_ERROR, msg='%s - Error while connecting to Deepviz: %s' % [response.code, response.body['errmsg']])
      end
    end
  end

  def sample_result(api_key, md5)
    return sample_info(api_key, md5, ['classification'])
  end


  def sample_info(api_key, md5, filters)
    if api_key == nil or api_key == ''
      return Result.new(status=INPUT_ERROR, msg='API key cannot be null or empty String')
    end

    if md5 == nil or md5 == ''
      return Result.new(status=INPUT_ERROR, msg='MD5 cannot be null or empty String')
    end

    if filters != nil
      if 0 < filters.length > 10
        return Result.new(status=INPUT_ERROR, msg='Parameter \'output_filters\' takes at least 1 value and at most 10 values (%s given)' % [filters.length])
      end

      body = {:api_key => api_key, :md5 => md5, :output_filters => filters}
    else
      return Result.new(status=INPUT_ERROR, msg='Output filters cannot be null or empty')
    end

    return do_post(body, URL_INTEL_DOWNLOAD_REPORT)
  end

  private :do_post
end