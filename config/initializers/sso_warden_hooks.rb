Warden::Manager.after_authentication(scope: :user, &::Sso::Warden::Hooks::AfterAuthentication.to_proc)
Warden::Manager.before_logout(scope: :user, &::Sso::Warden::Hooks::BeforeLogout.to_proc)

# TODO : Why does it need a passport strategy
# Warden::Strategies.add :passport, ::Sso::Server::Warden::Strategies::Passport
