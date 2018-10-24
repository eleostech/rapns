class PGError < StandardError; end if !defined?(PGError)
class Mysql; class Error < StandardError; end; end if !defined?(Mysql)
module Mysql2; class Error < StandardError; end; end if !defined?(Mysql2)
module ActiveRecord; end
class ActiveRecord::JDBCError < StandardError; end if !defined?(::ActiveRecord::JDBCError)

module Rapns
  module Daemon
    module Store
      class ActiveRecord
        module Reconnectable
          ADAPTER_ERRORS = [::ActiveRecord::StatementInvalid, PGError, Mysql::Error,
                            Mysql2::Error, ::ActiveRecord::JDBCError]

          def with_database_reconnect_and_retry
            begin
              ::ActiveRecord::Base.connection_pool.with_connection do
                yield
              end
            rescue *ADAPTER_ERRORS => e
              Rapns.logger.error(e)
              database_connection_lost
            end
          end

          def database_connection_lost
            Rapns.logger.warn("Lost connection to database, CRASHING...")
            raise Exception.new("Lost connection to database, CRASHING...")
          end

          def check_database_is_connected
            # Simply asking the adapter for the connection state is not sufficient.
            Rapns::Notification.count
          end

          def sleep_to_avoid_thrashing
            sleep 2
          end
        end
      end
    end
  end
end
