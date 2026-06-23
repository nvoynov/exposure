require_relative 'exposure/version'
require_relative 'exposure/config'
require_relative 'exposure/basic'
require_relative 'exposure/model'
require_relative 'exposure/ports'
require_relative 'exposure/tasks'
require_relative 'exposure/adapters'
require_relative 'exposure/presenter'
require_relative 'exposure/builder'
require_relative 'exposure/decorator'

# Root namespace for the fine-art photography streaming engine
module Exposure
  BANNER = "Exposure, v#{VERSION}"
end
