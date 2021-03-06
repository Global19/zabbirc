module Zabbirc
  module Zabbix
    module Resource
      module Finders
        def find id, *options
          options = options.extract_options!
          options = options.reverse_merge({
                                              :"#{model_name}ids" => id
                                          })
          res = api.send(model_name).get options
          ret = if res.size == 0
                  nil
                elsif res.size > 1
                  raise IDNotUniqueError, "#{model_name.camelize} ID `#{id}` is not unique"
                else
                  self.new res.first
                end
        rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError, OpenSSL::SSL::SSLError => e
          Zabbirc.logger.error "Zabbix::Resource#find: #{e}"
          raise NotConnected, e
        else
          Connection.up!
          ret
        end

        def get *options
          options = options.extract_options!
          res = api.send(model_name).get options
          ret = res.collect do |obj|
            self.new obj
          end
        rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError, OpenSSL::SSL::SSLError => e
          Zabbirc.logger.error "Zabbix::Resource#get: #{e}"
          raise NotConnected, e
        else
          Connection.up!
          ret
        end

      end
    end
  end
end
