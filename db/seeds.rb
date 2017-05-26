# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# User.create!(name: "Dan Newton", email: "danknewton@hotmail.com", password: "password", 
#             password_confirmation: "password", admin: true, 
#             activated: true, activated_at: Time.zone.now)

# 99.times do |n|
#   name = Faker::Name.name
#   email = "example2-#{n+1}@hotmail.com"
#   password = "password"
#   User.create!(name: name, email: email, password: password, password_confirmation: password, admin: false, 
#             activated: true, activated_at: Time.zone.now)
# end

# users = User.order(:created_at).take(6)
# 50.times do
#   content = Faker::Lorem.sentence(5)
#   users.each { |user| user.microposts.create!(content: content) }
# end

users = User.all
user = User.find_by(email: "danknewton@hotmail.com")
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
