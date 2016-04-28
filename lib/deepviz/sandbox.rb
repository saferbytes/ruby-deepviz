require 'json'
require 'unirest'
require 'deepviz/result'


class Sandbox

  URL_UPLOAD_SAMPLE   = 'https://api.deepviz.com/sandbox/submit'
  URL_DOWNLOAD_REPORT = 'https://api.deepviz.com/general/report'
  URL_DOWNLOAD_SAMPLE = 'https://api.deepviz.com/sandbox/sample'
  URL_DOWNLOAD_BULK   = 'https://api.deepviz.com/sandbox/sample/bulk/retrieve'
  URL_REQUEST_BULK    = 'https://api.deepviz.com/sandbox/sample/bulk/request'


  def upload_sample(api_key, path)
    if api_key == nil or api_key == ''
      return Result.new(status=INPUT_ERROR, msg='API key cannot be null or empty String')
    end

    if path == nil or path == ''
      return Result.new(status=INPUT_ERROR, msg='File path cannot be null or empty String')
    else
      if !File.exist?(path)
        return Result.new(status=INPUT_ERROR, msg='File does not exists')
      else
        if File.directory?(path)
          return Result.new(status=INPUT_ERROR, msg='Path is a directory instead of a file')
        else
          if !File.readable?(path)
            return Result.new(status=INPUT_ERROR, msg='Cannot open file "%s"' % File.absolute_path(path))
          end
        end
      end
    end

    begin
      response = Unirest.post(URL_UPLOAD_SAMPLE,
                              headers:{ 'Content-Type' => 'application/json' },
                              parameters:{ :api_key => api_key, :source => 'ruby_deepviz', :file => File.new(path, 'rb') })
    rescue Exception
      return Result.new(status=NETWORK_ERROR, msg='%s - Error while connecting to Deepviz: %s' % [response.code, body['errmsg']])
    end

    if response.code == 428
      return Result.new(status=PROCESSING, msg='Analysis is running')
    else
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
  end


  def upload_folder(api_key, path)
    if api_key == nil or api_key == ''
      return Result.new(status=INPUT_ERROR, msg='API key cannot be null or empty String')
    end

    if path == nil or path == ''
      return Result.new(status=INPUT_ERROR, msg='Folder path cannot be null or empty String')
    else
      if !File.exist?(path)
        return Result.new(status=INPUT_ERROR, msg='Directory does not exists')
      else
        if !File.directory?(path)
          return Result.new(status=INPUT_ERROR, msg='Path is a file instead of a directory')
        end
      end
    end

    if Dir.entries(path).length <= 2
      return Result.new(status=INPUT_ERROR, msg='Empty folder')
    end

    Dir.foreach(path) { |x|
      if x != '.' and x != '..'
        file_path = File.join(path, x)
        result = upload_sample(api_key, file_path)
        if result.status != SUCCESS and result.status != PROCESSING
          result.msg = '"Unable to upload file "%s"' % file_path
          return result
        end
      end
    }

    return Result.new(status=SUCCESS, msg='Every file in folder has been uploaded')
  end


  def download_sample(api_key, md5, path)
    if api_key == nil or api_key == ''
      return Result.new(status=INPUT_ERROR, msg='API key cannot be null or empty String')
    end

    if md5 == nil or md5 == ''
      return Result.new(status=INPUT_ERROR, msg='MD5 cannot be null or empty String')
    end

    if path == nil or path == ''
      return Result.new(status=INPUT_ERROR, msg='Destination path cannot be null or empty String')
    else
      if File.exist?(path) and !File.directory?(path)
        return Result.new(status=INPUT_ERROR, msg='Invalid destination folder')
      end
    end

    body = {
        :api_key => api_key,
        :md5 => md5
    }

    begin
      response = Unirest.post(URL_DOWNLOAD_SAMPLE,
                              headers:{ 'Accept' => 'application/json' },
                              parameters:body.to_json)
    rescue Exception
      return Result.new(status=NETWORK_ERROR, msg='%s - Error while connecting to Deepviz: %s' % [response.code, body['errmsg']])
    end

    if response.code == 200
      dest_path = File.absolute_path(File.join(path, md5))
      open(dest_path, 'wb') do |file|
        file.write(response.body)
      end

      return Result.new(status=SUCCESS, msg='Sample downloaded to "%s"' % dest_path)
    else
      if response.code >= 500
        return Result.new(status=SERVER_ERROR, msg='%s - Error while connecting to Deepviz: %s' % [response.code, response.body['errmsg']])
      else
        return Result.new(status=CLIENT_ERROR, msg='%s - Error while connecting to Deepviz: %s' % [response.code, response.body['errmsg']])
      end
    end
  end


  def sample_report(api_key, md5)
    if api_key == nil or api_key == ''
      return Result.new(status=INPUT_ERROR, msg='API key cannot be null or empty String')
    end

    if md5 == nil or md5 == ''
      return Result.new(status=INPUT_ERROR, msg='MD5 cannot be null or empty String')
    end

    body = {:api_key => api_key, :md5 => md5}

    return do_post(body, URL_DOWNLOAD_REPORT)
  end


  def bulk_download_request(api_key, md5_list)
    if api_key == nil or api_key == ''
      return Result.new(status=INPUT_ERROR, msg='API key cannot be null or empty String')
    end

    if !md5_list.kind_of?(Array)
      return Result.new(status=INPUT_ERROR, msg='MD5 list empty or invalid')
    end

    body = {
        :api_key => api_key,
        :hashes => md5_list
    }

    return do_post(body, URL_REQUEST_BULK)
  end


  def bulk_download_retrieve(api_key, id_request, path)
    if api_key == nil or api_key == ''
      return Result.new(status=INPUT_ERROR, msg='API key cannot be null or empty String')
    end

    if id_request == nil or id_request == ''
      return Result.new(status=INPUT_ERROR, msg='Request ID cannot be null or empty String')
    end

    if path == nil or path == ''
      return Result.new(status=INPUT_ERROR, msg='Destination path cannot be null or empty String')
    else
      if File.exist?(path) and !File.directory?(path)
        return Result.new(status=INPUT_ERROR, msg='Invalid destination folder')
      end
    end

    body = {
        :api_key => api_key,
        :id_request => id_request.to_s
    }

    begin
      response = Unirest.post(URL_DOWNLOAD_BULK,
                              headers: { 'Accept' => 'application/json' },
                              parameters: body.to_json)
    rescue Exception
      return Result.new(status=NETWORK_ERROR, msg='%s - Error while connecting to Deepviz: %s' % [response.code, body['errmsg']])
    end

    if response.code == 200
      dest_path = File.absolute_path(File.join(path, 'bulk_request_%s.zip' % id_request.to_s))
      open(dest_path, 'wb') do |file|
        file.write(response.body)
      end

      return Result.new(status=SUCCESS, msg='Archive downloaded to "%s"' % dest_path)
    elsif response.code == 428
        return Result.new(status=PROCESSING, msg='%s - Your request is being processed. Please try again in a few minutes' % response.code)
    else
      if response.code >= 500
        return Result.new(status=SERVER_ERROR, msg='%s - Error while connecting to Deepviz: %s' % [response.code, response.body['errmsg']])
      else
        return Result.new(status=CLIENT_ERROR, msg='%s - Error while connecting to Deepviz: %s' % [response.code, response.body['errmsg']])
      end
    end
  end

  def do_post(body, api_uri)
    begin
      response = Unirest.post(api_uri,
                              headers:{ 'Content-Type' => 'application/json' },
                              parameters:body.to_json)
    rescue Exception
      return Result.new(status=NETWORK_ERROR, msg='%s - Error while connecting to Deepviz: %s' % [response.code, response.body['errmsg']])
    end

    if response.code == 428
      return Result.new(status=PROCESSING, msg='Analysis is running')
    else
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
  end

  private :do_post
end