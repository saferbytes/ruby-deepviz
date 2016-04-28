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

To retrieve intel data about one or more IPs:

```ruby
require 'deepviz/intel'
intel = Intel.new
result = intel.ip_info("my-api-key", {'ip' => ['1.22.28.94', '1.23.214.1']})
puts result
```

To retrieve intel data about IPs contacted in the last 7 days:

```ruby
require 'deepviz/intel'
intel = Intel.new
result = intel.ip_info("my-api-key", {'time_delta' => '7d'})
puts result
```

To retrieve intel data about one or more domains:

```ruby
require 'deepviz/intel'
intel = Intel.new
result = intel.domain_info("my-api-key", {'domain' => ['google.com'], 'filters' => ["sub_domains"]})

# List of the optional filters - they can be combined together
# "whois",
# "sub_domains"

puts result
```

To retrieve newly registered domains in the last 7 days:

```ruby
require 'deepviz/intel'
intel = Intel.new
result = intel.domain_info("my-api-key", {'time_delta' => '7d', 'filters' => ["whois"]})

# List of the optional filters - they can be combined together
# "whois",
# "sub_domains"

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

# More advanced usage examples

Find all domains registered in the last 7 days, print out the malware tags related to them and 
list all MD5 samples connecting to them. Then for each one of the samples retrieve the matched
behavioral rules

```ruby
require 'deepviz/intel'
require 'deepviz/sandbox'

API_KEY = "0000000000000000000000000000000000000000000000000000000000000000"

intel = Intel.new
sbx = Sandbox.new

result_domains = intel.domain_info(API_KEY, {'time_delta' => '3d'})
if result_domains.status == SUCCESS
  domains = result_domains.msg
  for domain in domains.keys
    result_list_samples = intel.advanced_search(API_KEY, {'domain' => [domain], 'classification' => 'M'})
    if result_list_samples.status == SUCCESS
      if result_list_samples.msg.kind_of?(Array)
        if domains[domain]['tag'].any?
          puts 'DOMAIN: %s ==> %s samples [TAG: %s]' % [domain, result_list_samples.msg.length, domains[domain]['tag'].join(', ')]
        else
          puts 'DOMAIN: %s ==> %s samples' % [domain, result_list_samples.msg.length]
        end

        for md5 in result_list_samples.msg
          result_report = intel.sample_info(API_KEY, md5, filters=['rules'])
          if result_report.status == SUCCESS
            puts '%s => [%s]' % [md5, result_report.msg['rules'].join(',')]
          else
            puts result_report
            break
          end
        end
      else
        puts 'DOMAIN: %s ==> No samples found' % domain
      end
    else
      puts result_list_samples
      break
    end
  end
else
  puts result_domains
end
```
result:

```
DOMAIN: avsystemcare.com ==> 8 samples [TAG: trojan.qhost, trojan.rbot, trojan.noupd]
000dde6029443950c8553469887eef9e => [badIpUrlInStrings, suspiciousSectionName, highEntropy, invalidSizeOfCode, invalidPEChecksum, writeExeSections]
2b0a56badf6992af7bbcdfbee7aded4f => [dropExe, antiAv, recentlyRegisteredDomainStrings, autorunRegistryKey, badIpUrlInStrings, runDroppedExe, dialer, sleep, antiDebugging, invalidSizeOfCode, loadImage, runExe, invalidPEChecksum, writeExeSections]
aba074b2373e8ea5661fdafb159c263a => [epOutOfSections, badIpUrlInStrings, invalidSizeOfCode, invalidPEChecksum, epLastSection, writeExeSections]
```