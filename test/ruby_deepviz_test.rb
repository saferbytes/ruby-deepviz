require 'deepviz/sandbox'
require 'deepviz/intel'

API_KEY = '0000000000000000000000000000000000000000000000000000000000000000'

sbx = Sandbox.new

# Download sample
result = sbx.download_sample(API_KEY, 'a6ca3b8c79e1b7e2a6ef046b0702aeb2', '.')
puts result

# Upload sample
result = sbx.upload_sample(API_KEY, './a6ca3b8c79e1b7e2a6ef046b0702aeb2')
puts(result)

# Upload folder
result = sbx.upload_folder(API_KEY, '.')
puts result

# Retrieve sample scan result
result = sbx.sample_result(API_KEY, 'a6ca3b8c79e1b7e2a6ef046b0702aeb2')
puts result

# Retrieve sample report
result = sbx.sample_report(API_KEY, 'a6ca3b8c79e1b7e2a6ef046b0702aeb2')
puts result

# Send bulk request and retrieve the archive
md5_list = [
  'a6ca3b8c79e1b7e2a6ef046b0702aeb2',
  '34781d4f8654f9547cc205061221aea5',
  'a8c5c0d39753c97e1ffdfc6b17423dd6'
]
result = sbx.bulk_download_request(API_KEY, md5_list)
puts result

id_request = result.msg['id_request']
loop do
  result = sbx.bulk_download_retrieve(API_KEY, id_request, '.')
  puts result
  break if result.status != PROCESSING
  sleep 1
end

########################################################################################################################

ti = Intel.new

# To retrieve intel data about  IPs in the last 7 days:
result = ti.ip_info(API_KEY, {'time_delta' => '7d'})
puts result

# To retrieve intel data about one or more IPs:
result = ti.ip_info(API_KEY, {'ip' => ['1.22.28.94', '1.23.214.1']})
puts result

# To retrieve intel data about one or more domains:
result = ti.domain_info(API_KEY, {'domain' => ['google.com']})
puts result

# To retrieve newly registered domains in the last 7 days:
result = ti.domain_info(API_KEY, {'time_delta' => '7d'})
puts result

# To run generic search based on strings
# (find all IPs, domains, samples related to the searched keyword):
result = ti.search(API_KEY, search_string='justfacebook.net')
puts result

# To run advanced search based on parameters
# (find all MD5 samples connecting to a domain and determined as malicious):
result = ti.advanced_search(API_KEY, {'domain' => ['justfacebook.net'], 'classification' => 'M'})
puts result

# Find all domains registered in the last 7 days, print out the malware tags related to them and
# list all MD5 samples connecting to them. Then for each one of the samples retrieve the matched
# behavioral rules

result_domains = ti.domain_info(API_KEY, {'time_delta' => '3d'})
if result_domains.status == SUCCESS
  domains = result_domains.msg
  for domain in domains.keys
    result_list_samples = ti.advanced_search(API_KEY, {'domain' => [domain], 'classification' => 'M'})
    if result_list_samples.status == SUCCESS
      if result_list_samples.msg.kind_of?(Array)
        if domains[domain]['tag'].any?
          puts 'DOMAIN: %s ==> %s samples [TAG: %s]' % [domain, result_list_samples.msg.length, domains[domain]['tag'].join(', ')]
        else
          puts 'DOMAIN: %s ==> %s samples' % [domain, result_list_samples.msg.length]
        end

        for md5 in result_list_samples.msg
          result_report = sbx.sample_report(API_KEY, md5, filters=['rules'])
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