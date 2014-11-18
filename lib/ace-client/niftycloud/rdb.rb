module AceClient
  module Niftycloud
    module Rdb
      def build_client(options={})
        client = AceClient::Query2.new(options)
        client.extend(AceClient::Niftycloud::Rdb)
        client
      end

      def items(key)
         response = self.action("Describe#{key}s", {})
         [response["Describe#{key}sResponse"]["Describe#{key}sResult"]["#{key}s"][key]].flatten rescue []
      end

     { 
        :db_instances => 'DBInstance',
        :db_security_groups => 'DBSecurityGroup',
        :db_snapshots => 'DBSnapshot',
        :db_parameter_groups => 'DBParameterGroup'
      }.each do |method, key|
        define_method(method) { items(key) }
      end

      def delete_db_instances
        db_instances.each do |db_instance|
          self.action('DeleteDBInstance', 'DBInstanceIdentifier' => db_instance['DBInstanceIdentifier'], 'SkipFinalSnapshot' => 'true')
        end
        timeout(60*60) do
          until db_instances.empty?
            if db_instances.any? {|db_instance| db_instance['DBInstanceStatus'] == 'failed' }
              failed = db_instances.select {|db_instance| db_instance['DBInstanceStatus'] == 'failed' }
              raise "DBInstance #{failed.map {|f| f['DBInstanceIdentifier'] }.join(',')} is failed"
            end
            sleep 5
          end
        end
      end

      def delete_db_security_groups
        db_security_groups.each do |db_security_group|
          self.action('DeleteDBSecurityGroup', 'DBSecurityGroupName' => db_security_group['DBSecurityGroupName'])
        end
      end

      def delete_db_snapshots
        db_snapshots.each do |db_snapshot|
          self.action('DeleteDBSnapshot', 'DBSnapshotIdentifier' => db_snapshot['DBSnapshotIdentifier'])
        end
      end

      def delete_db_parameter_groups
        db_parameter_groups.each do |db_parameter_group|
          self.action('DeleteDBParameterGroup', 'DBParameterGroupName' => db_parameter_group['DBParameterGroupName'])
        end
      end

      def delete_resources
        delete_db_instances
        delete_db_security_groups
        delete_db_snapshots
        delete_db_parameter_groups
      end

      module_function :build_client
    end
  end
end
