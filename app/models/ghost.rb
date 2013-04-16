class Ghost < ActiveRecord::Base
  establish_connection(:ghost)
end