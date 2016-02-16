SUCCESS = 'DEEPVIZ_STATUS_SUCCESS'                  # Request successfully submitted
PROCESSING = 'DEEPVIZ_STATUS_PROCESSING'
INPUT_ERROR = 'DEEPVIZ_STATUS_INPUT_ERROR'
SERVER_ERROR = 'DEEPVIZ_STATUS_SERVER_ERROR'        # Http 5xx
CLIENT_ERROR = 'DEEPVIZ_STATUS_CLIENT_ERROR'        # Http 4xx
NETWORK_ERROR = 'DEEPVIZ_STATUS_NETWORK_ERROR'      # Cannot contact Deepviz
INTERNAL_ERROR = 'DEEPVIZ_STATUS_INTERNAL_ERROR'


class Result
  attr_reader :status
  attr_writer :status
  attr_reader :msg
  attr_writer :msg

  @status = nil
  @msg = nil

  def initialize(status, msg)
    @status = status
    @msg = msg
  end

  def to_s
    'Result(status=%s, msg=%s)' % [@status, @msg]
  end
end