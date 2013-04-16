class GhostMmdVariable < ActiveRecord::Base
  establish_connection(:ghost)
  self.table_name = 'w3mmdvars'

  def value_string
    self[:value_string][1,self[:value_string].length-2]
  end
end