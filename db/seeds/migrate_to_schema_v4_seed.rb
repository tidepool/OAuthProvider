class MigrateToSchemaV4Seed
  def create_seed
    puts 'MigrateToSchemaV4: '
    puts "Migrating all existing authentications to have sync status"
    count = 0
    Authentication.all.each do |conn|
      if conn.sync_status.nil? || conn.sync_status.empty?
        conn.sync_status = "not_synchronized"
        conn.save
      end
    end
    puts "Authentications migrated: #{count}\n"
    puts "Total authentications: #{Authentication.all.length}\n"
  end
end