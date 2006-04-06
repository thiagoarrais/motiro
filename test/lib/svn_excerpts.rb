    revText =  "------------------------------------------------------------------------\n"
    revText += "r2 | gilbertogil | 2006-02-17 18:07:55 -0400 (Sex, 17 Fev 2006) | 4 lines\n"
    revText += "Caminhos mudados:\n"
    revText += "   M /trunk/src/test/unit/svn_reporter_test.rb\n"
    revText += "\n"
    revText += "Estou tentando enganar o SubversionReporter\n"
    revText +=  "------------------------------------------------------------------------\n"
    revText += "Isto aqui ainda é comentário da revisao 2\n\n"
    R2 = revText    
    
    revText  = "------------------------------------------------------------------------\n"
    revText += "r6 | thiagoarrais | 2006-02-17 12:22:25 -0300 (Sex, 17 Fev 2006) | 1 line\n"
    revText += "Caminhos mudados:\n"
    revText += "   A /trunk/src/test/stubs/svn_connection.rb\n"
    revText += "   A /trunk/src/test/unit/headline_test.rb\n"
    revText += "\n"
    revText += "Teste do reporter SVN agora falhando decentemente (ao inves de explodir)\n"
    R6 = revText
    
    R6C2DIFF = <<DIFF_END
@@ -0,0 +1,10 @@
+require File.dirname(__FILE__) + '/../test_helper'
+
+class HeadlineTest < Test::Unit::TestCase
+  fixtures :headlines
+
+  # Replace this with your real tests.
+  def test_truth
+    assert_kind_of Headline, headlines(:first)
+  end
+end
DIFF_END
    
    R6C1DIFF = <<DIFF_END
@@ -0,0 +1,11 @@
+class StubSVNConnection
+
+    def initialize
+        @log = ''
+    end
+
+    def log_append_line(text)
+        @log += text + '\n'
+    end
+
+end
DIFF_END

    diff_text  = <<DIFF_END
Index: src/test/unit/headline_test.rb
===================================================================
--- src/test/unit/headline_test.rb      (revisão 0)
+++ src/test/unit/headline_test.rb      (revisão 6)
DIFF_END

    diff_text += R6C2DIFF

    diff_text += <<DIFF_END
Index: src/test/stubs/svn_connection.rb
===================================================================
--- src/test/stubs/svn_connection.rb    (revisão 0)
+++ src/test/stubs/svn_connection.rb    (revisão 6)
DIFF_END

    diff_text += R6C1DIFF

    R6DIFF = diff_text
    
    revText =  "------------------------------------------------------------------------\n"
    revText += "r7 | gilbertogil | 2006-02-17 18:07:55 -0400 (Sex, 17 Fev 2006) | 4 lines\n"
    revText += "Caminhos mudados:\n"
    revText += "   A /trunk/src/app\n"
    revText += "   A /trunk/src/app/reporters\n"
    revText += "   A /trunk/src/app/reporters/svn_reporter.rb\n"
    revText += "\n"
    revText += "Correcao para a revisao anterior (r6)\n"
    revText += "\n"
    revText += "Esqueci de colocar o svn_reporter. Foi mal!\n\n"
    R7 = revText    

    revText =  "------------------------------------------------------------------------\n"
    revText += "r13 | thiagoarrais | 2006-02-19 08:50:07 -0400 (Dom, 19 Fev 2006) | 1 line\n"
    revText += "Caminhos mudados:\n"
    revText += "   M /trunk/src/app/reporters/svn_reporter.rb\n"
    revText += "   M /trunk/src/test/unit/svn_reporter_test.rb\n"
    revText += "\n"
    revText += "Leitura de uma revisao SVN pronta\n"
    R13 = revText

    revText =  "------------------------------------------------------------------------\n"
    revText += "r15 | thiagoarrais | 2006-02-19 09:13:07 -0400 (Dom, 19 Fev 2006) | 1 line\n"
    revText += "Caminhos mudados:\n"
    revText += "   M /trunk/src/test/unit/svn_reporter_test.rb\n"
    revText += "\n"
    revText += "\n"
    R15 = revText
    
    revText =  "------------------------------------------------------------------------\n"
    revText += "r105 | gilbertogil | 2006-03-24 15:03:06 -0400 (Sex, 24 Mar 2006) | 7 lines\n"
    revText += "Caminhos mudados:\n"
    revText += "   A /trunk/app/models/change.rb\n"
    revText += "\n"
    revText += "Agora mostrando resumo das modificacoes de cada revisao\n"
    revText += "\n"
    revText += "Alem de mostrar o comentario completo, o detalhamento agora mostra os\n"
    revText += "nomes dos recursos que foram alterados com a revisao. A partir desta\n"
    revText += "revisao, o Motiro ja deve mostrar uma lista de recursos alterados abaixo\n"
    revText += "desta mensagem.\n"
    revText += "\n"
    revText += "------------------------------------------------------------------------\n"
    R105 = revText

    diff_text  = "Index: app/models/change.rb\n"
    diff_text += "===================================================================\n"
    diff_text += "--- app/models/change.rb        (revision 0)\n"
    diff_text += "+++ app/models/change.rb        (revision 105)\n"
    diff_text += "@@ -0,0 +1,7 @@\n"
    diff_text += "+class Change < ActiveRecord::Base\n"
    diff_text += "+\n"
    diff_text += "+    def to_s\n"
    diff_text += "+        return summary\n"
    diff_text += "+    end\n"
    diff_text += "+\n"
    diff_text += "+end"
    R105DIFF = diff_text
    
    revText =  "------------------------------------------------------------------------\n"
    revText += "r124 | thiagoarrais | 2006-04-02 12:47:35 -0300 (Dom, 02 Abr 2006) | 5 lines\n"
    revText += "Caminhos mudados:\n"
    revText += "   A /trunk/app/views/report/html_fragment.rhtml (de /trunk/app/views/report/subversion_html_fragment.rhtml:123)\n"
    revText += "   D /trunk/app/views/report/subversion_html_fragment.rhtml\n"
    revText += "\n"
    revText += "Reporter de eventos e reestruturacao do codigo\n"
    revText += "\n"
    revText += "- Reporter de eventos ainda nao funciona ao vivo\n"
    revText += "- Ainda nao ha detalhamento dos eventos\n"
    revText += "\n"
    revText += "------------------------------------------------------------------------\n"
    R124 = revText
    
    R124DIFF = <<END
Index: app/views/report/subversion_html_fragment.rhtml
===================================================================
--- app/views/report/subversion_html_fragment.rhtml     (revisão 123)
+++ app/views/report/subversion_html_fragment.rhtml     (revisão 124)
@@ -1,24 +0,0 @@
-<p>
-  <h1>Ã<9A>ltimas notÃ­cias do Subversion</h1>
-  <%= link_to( image_tag('rss.gif', :border => 0),
-               { :controller => 'report',
-                 :action => 'show',
-                 :reporter => 'subversion',
-                 :format => 'rss' } )
-  %>
-</p>
-<% @headlines.each do |headline|%>
-  <p>
-    <%= link_to( h(headline.title),
-                 { :controller => 'report',
-                   :action => 'show',
-                   :reporter => 'subversion',
-                   :id => headline.rid } )%>
-    <br/>
-    <font size="-1">
-      <i><%= h(headline.author) %></i>
-      <%= h(headline.happened_at) %>
-    </font>
-    <hr/>
-  </p>
-<% end %>
\ Sem nova-linha ao fim do arquivo
Index: app/views/report/html_fragment.rhtml
===================================================================
--- app/views/report/html_fragment.rhtml        (revisão 0)
+++ app/views/report/html_fragment.rhtml        (revisão 124)
@@ -0,0 +1,24 @@
+<p>
+  <h1><%= h(@title) %></h1>
+  <%= link_to( image_tag('rss.gif', :border => 0),
+               { :controller => 'report',
+                 :action => 'show',
+                 :reporter => @name,
+                 :format => 'rss' } )
+  %>
+</p>
+<% @headlines.each do |headline|%>
+  <p>
+    <%= link_to( h(headline.title),
+                 { :controller => 'report',
+                   :action => 'show',
+                   :reporter => @name,
+                   :id => headline.rid } )%>
+    <br/>
+    <font size="-1">
+      <i><%= h(headline.author) %></i>
+      <%= h(headline.happened_at) %>
+    </font>
+    <hr/>
+  </p>
+<% end %>
\ Sem nova-linha ao fim do arquivo
END
