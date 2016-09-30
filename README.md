# ruby-deepviz
ruby-deepviz is a Ruby on Rails wrapper for deepviz.com REST APIs

# Install

ruby-deepviz is hosted by RubyGems.org

```ruby
gem install ruby-deepviz
```

# Usage
To use Deepviz API sdk you will need an API key you can get by
subscribing the service free at https://account.deepviz.com/register/

The complete Deepviz REST APIs documentation can be found at https://api.deepviz.com/docs/

# Sandbox SDK API

To upload a sample:

```ruby
require 'deepviz/sandbox'
sbx = Sandbox.new
result = sbx.upload_sample("my-api-key", "path\\to\\file.exe")
puts result
```

To upload a folder:

```ruby
require 'deepviz/sandbox'
sbx = Sandbox.new
result = sbx.upload_folder("my-api-key", "path\\to\\files")
puts result
```

To download a sample:

```ruby
require 'deepviz/sandbox'
sbx = Sandbox.new
result = sbx.download_sample("my-api-key", "MD5-hash", "output\\directory\\")
puts result
```

To send a bulk download request and download the related archive:

```ruby
require 'deepviz/sandbox'
sbx = Sandbox.new

md5_list = [
  'a6ca3b8c79e1b7e2a6ef046b0702aeb2',
  '34781d4f8654f9547cc205061221aea5',
  'a8c5c0d39753c97e1ffdfc6b17423dd6'
]
result = sbx.bulk_download_request("my-api-key", md5_list)
puts result

id_request = result.msg['id_request']
loop do
  result = sbx.bulk_download_retrieve("my-api-key", id_request, '.')
  puts result
  break if result.status != PROCESSING
  sleep 1
end
```

To retrieve full scan report for a specific MD5

```ruby
require 'deepviz/sandbox'
sbx = Sandbox.new
result = sbx.sample_report("my-api-key", "MD5-hash")
puts result
```

# Threat Intelligence SDK API

To retrieve scan result of a specific MD5

```ruby
require 'deepviz/intel'
intel = Intel.new
result = intel.sample_result("my-api-key", 'a6ca3b8c79e1b7e2a6ef046b0702aeb2')
puts result
```

To retrieve only specific parts of the report of a specific MD5 scan

```ruby
require 'deepviz/intel'
intel = Intel.new
result = intel.sample_info("my-api-key", "MD5-hash", ["classification","rules"])
puts result
```

To retrieve intel data about an IP:

```ruby
require 'deepviz/intel'
intel = Intel.new
result = intel.ip_info("my-api-key", '8.8.8.8')
puts result
```

To retrieve intel data about an IP with output filters:

```ruby
require 'deepviz/intel'
intel = Intel.new
result = intel.ip_info("my-api-key", '8.8.8.8', ['generic_info'])
puts result
```

To retrieve intel data about a domain:

```ruby
require 'deepviz/intel'
intel = Intel.new
result = intel.domain_info("my-api-key", 'google.com')

puts result
```

To retrieve intel data about a domain with output filters:

```ruby
require 'deepviz/intel'
intel = Intel.new
result = intel.domain_info("my-api-key", 'google.com', ['generic_info'])

puts result
```

To run generic search based on strings 
(find all IPs, domains, samples related to the searched keyword):

```ruby
require 'deepviz/intel'
intel = Intel.new
result = intel.search("my-api-key", search_string="justfacebook.net")
puts result
```

To run advanced search based on parameters
(find all MD5 samples connecting to a domain and determined as malicious):

```ruby
require 'deepviz/intel'
intel = Intel.new
result = intel.advanced_search("my-api-key", {'domain' => ['justfacebook.net'], 'classification' => 'M'})
puts result
```