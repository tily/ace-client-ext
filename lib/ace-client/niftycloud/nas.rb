module AceClient
  module Niftycloud
    module Nas
      def build_client(options={})
        client = AceClient::Query2.new(options)
        client.extend(AceClient::Niftycloud::Nas)
        client
      end

      def items(key)
         response = self.action("Describe#{key}s", {})
         [response["Describe#{key}sResponse"]["Describe#{key}sResult"]["#{key}s"][key]].flatten rescue []
      end

     {
        :nas_instances => 'NASInstance',
        :nas_security_groups => 'NASSecurityGroup'
      }.each do |method, key|
        define_method(method) { items(key) }
      end

      def delete_nas_instances
        nas_instances.each do |nas_instance|
          self.action('DeleteNASInstance', 'NASInstanceIdentifier' => nas_instance['NASInstanceIdentifier'])
        end
        timeout(60*60) do
          until nas_instances.empty?
            if nas_instances.any? {|nas_instance| nas_instance['NASInstanceStatus'] == 'failed' }
              failed = nas_instances.select {|nas_instance| nas_instance['NASInstanceStatus'] == 'failed' }
              raise "NASInstance #{failed.map {|f| f['NASInstanceIdentifier'] }.join(',')} is failed"
            end
            sleep 5
          end
        end
      end

      def delete_nas_security_groups
        nas_security_groups.each do |nas_security_group|
          self.action('DeleteNASSecurityGroup', 'NASSecurityGroupName' => nas_security_group['NASSecurityGroupName'])
        end
      end

      def delete_resources
        delete_nas_instances
        delete_nas_security_groups
      end

      module_function :build_client
    end
  end
end
