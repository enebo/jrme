class AbstractGame
  include RandomHelper

  field_accessor :display, :finished, :settings
end

class BaseGame
  field_accessor :throwableHandler => :throwable_handler
end

class BaseSimpleGame
  field_accessor :alphaBits => :alpha_bits
  field_accessor :cam, :depthBits => :depth_bits, :graphNode => :graph_node
  field_accessor :input
  field_accessor :lightState => :light_state
  field_accessor :pause, :rootNode => :root_node
  field_accessor :samples, :showBounds => :show_bounds
  field_accessor :showDepth => :show_depth, :showGraphs => :show_graphs
  field_accessor :showNormals => :show_normals, :statNode => :stat_node
  field_accessor :stencilBits => :stencil_bits
  field_accessor :timer, :tpf, :wireState => :wire_state
end

class SimplePassGame
  field_reader :pManager => :pass_manager
end
