require 'xmlrpc/client'
#class XMLRPC::Client
#  def set_debug
#    @http.set_debug_output($stderr);
#  end
#end
module Yeti
  module XmlRpc

     def self.rpc_client_instance(url)
        @clients = {} if @clients.blank?
        if @clients[url].blank?
         @clients[url] = XMLRPC::Client.new2(url)
        end
        @clients[url]
     end


    class Error < RuntimeError

    end

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods

      def rpc_send(method, uri, *args)
        client = XmlRpc.rpc_client_instance(uri)
         #   client.set_debug
        result = client.call_async('di', 'yeti', method, *args)

        if result.is_a?(Array)
          raise Error.new("Yeti RPC ERROR: #{result[0]}") unless  (200..299) === result[0].to_i
          result[1]
        else
          raise Error.new("Yeti RPC ERROR: Unexpected result")
        end
      end

    end

  end

end