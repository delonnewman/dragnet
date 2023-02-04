# frozen_string_literal: true

# Generate random user
class UserGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    name  = attributes.fetch(:name, Name.generate)
    login = Login[name: name]
    email = Email[login: login]
    nick  = name.split(' ').first
    pass  = 'testing123'

    User.new(name: name, login: login, email: email, nickname: nick, password: pass)
  end
end
