namespace :loadtests do 
  task :create_test_data, [:test_type] => :environment do |t, args|
    client_id = "3e372449d494eb6dc7d74cd3da1d6eedd50c7d98f3dedf1caf02960a9a260fb1"
    client_secret = "3e4da2177beee0d8ec458480526b3716047b3ff0df3362262183f6841253a706"

    client = OAuth2::Client.new(client_id, client_secret, raise_errors: false, site: "https://tide-dev.herokuapp.com")
    token = client.password.get_token("pp@kk.com", "12345678")
    puts "User Token: #{token.token}"
    # response = token.get("/api/v1/users/-.json")
    # result = JSON.parse(response.body, symbolize_names: true)
    # puts result.to_s

    game_ids = []
    filename = 'realdata_snoozer.json'
    events_json = IO.read(File.expand_path("../../analyze/spec/fixtures/#{filename}", __FILE__))
    events = JSON.parse(events_json)

    (0..40).each do |i|
      response = token.post("/api/v1/users/-/games.json",
        { body: { def_id: 'snoozer' } })
      result = JSON.parse(response.body, symbolize_names: true)
      game_id = result[:data][:id]
      game_ids << game_id

      response = token.put("/api/v1/users/-/games/#{game_id}/event_log.json",
        { body: { event_log: events } })
      result = JSON.parse(response.body, symbolize_names: true)
      puts result.to_s
    end
    puts "Games Ready = #{game_ids}"
  end
end