require 'discordrb'

api_token = File.read("#{__dir__}/discord.api")
bot = Discordrb::Commands::CommandBot.new token: api_token, client_id: 951501962585726977, prefix: '>'

puts "Bot invite link: #{bot.invite_url}"

bot.command(:request, description: 'Takes a request and creates a ticket to be resolved. Request multiple items by separating `[number] [name]` with a comma.', usage: 'request [number] [item name/description](, [number] [name of additional items])') do |event, *args|
  allowed_roles = ['Core Raider', 'Standby Raider']

  current_role_names = event.user.roles.map(&:name)
  can_request = allowed_roles.any? { |authorized_role| current_role_names.include?(authorized_role) }
  return "Only #{allowed_roles.join(' or ')} can request items from the guild bank." unless can_request

  request = args.join(' ')

  pairs = []
  request.split(',').chunk { |el| el.match(/[[:digit:]]/) }.each { |_, chunk| pairs << chunk.pop.strip }
  event << "Transformed data: #{pairs}"

  request_hash = {}
  pairs.each do |pair|
    quantity, *item = pair.split(' ')
    request_hash[item.join(' ')] = quantity
  end

  event << "Hash: #{request_hash}"
  event << "Your ticket has been received, #{event.user.mention}"
end

bot.run


=begin
Considerations

* All users should be able to request
* A user should be able to have a request tied to their username
* Users should be able to edit or cancel their own requests
* Managers should be able to edit or cancel all requests.
=end