class MigrateToSchemaV3Seed
  def create_seed
    puts 'MigrateToSchemaV3: '
    puts "Migrating all existing games to have a name, which maps to definition.unique_name"
    count = 0
    Game.all.each do |game|
      if game.name.nil? || game.name.empty?
        if game.definition
          game.name = game.definition.unique_name
          game.save!
          print '.'
          count += 1
        end
      end
    end
    puts "Games migrated: #{count}\n"
    puts "Total games: #{Game.all.length}\n"
  end
end