require 'discordrb'
require 'yaml'

CONFIG = YAML.load_file('config.yaml')
PERMISSIONS = YAML.load_file('permissions.yaml')
bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'], client_id: 951501962585726977, prefix: '>'
puts "Bot invite link: #{bot.invite_url}"
puts "Bot active channels: #{PERMISSIONS['bot-channels']}"
puts "Role IDs allowed for request: #{PERMISSIONS['allow-request']}"
puts "Role IDs allowed for manage: #{PERMISSIONS['allow-manage']}"

bot.command(:test_permission, allowed_roles: PERMISSIONS['allow-manage'], channels: PERMISSIONS['bot-channels'], description: 'Command to test permission setting.') do |event|
  event.respond 'Permission check passed!'
end

bot.command(:meta, help_available: false) do |event|
  event.respond 'You found the hidden command!'
end

bot.command(:request, allowed_roles: PERMISSIONS['allow-request'], channels: PERMISSIONS['bot-channels'], description: 'Takes a request and creates a ticket to be resolved. Request multiple items by separating `[number][name]` with a comma.', usage: 'request [number][item name/description](, [number][name of additional items])') do |event, *args|
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