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
result = sbx.upload_folder(API_KEY, 'folder_to_upload')
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

intel = Intel.new

# To retrieve sample scan result
result = intel.sample_result(API_KEY, 'a6ca3b8c79e1b7e2a6ef046b0702aeb2')
puts result

# To retrieve sample info
result = intel.sample_info(API_KEY, 'a6ca3b8c79e1b7e2a6ef046b0702aeb2', ['hash', 'classification'])
puts result

# To retrieve intel data an IP:
result = intel.ip_info(API_KEY, '8.8.8.8')
puts result

# To retrieve intel data an IP with output_filters:
result = intel.ip_info(API_KEY, '8.8.8.8', ['generic_info'])
puts result

# To retrieve intel data about a domain:
result = intel.domain_info(API_KEY, 'google.com')
puts result

# To retrieve intel data about a domain with output_filters
result = intel.domain_info(API_KEY, 'google.com', ['generic_info'])
puts result

# To run generic search based on strings
# (find all IPs, domains, samples related to the searched keyword):
result = intel.search(API_KEY, search_string='justfacebook.net')
puts result

# To run advanced search based on parameters
# (find all MD5 samples connecting to a domain and determined as malicious):
result = intel.advanced_search(API_KEY, {'domain' => ['justfacebook.net'], 'classification' => 'M'})
puts result