class TranslateMainPage < ActiveRecord::Migration

  def self.up
    Locale.set_base_language('en-US')
    Locale.set_translation('Welcome', Language.pick('pt-BR'),
                           'Bem-vindo')
    Locale.set_translation('User', Language.pick('pt-BR'),
                           'Usuário')
    Locale.set_translation('Password', Language.pick('pt-BR'),
                           'Senha')
    Locale.set_translation('Edit', Language.pick('pt-BR'),
                           'Editar')
    Locale.set_translation('(requires authentication)', Language.pick('pt-BR'),
                           '(identifique-se, por favor)')
    Locale.set_translation('Latest news from %s', Language.pick('pt-BR'),
                           'Últimas notícias do %s')
    Locale.set_translation('Upcoming events', Language.pick('pt-BR'),
                           'Próximos eventos')
    Locale.set_translation('version', Language.pick('pt-BR'),
                           'versão')
                           
  end
  
  def self.down
  end

end
