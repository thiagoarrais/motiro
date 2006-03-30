require File.dirname(__FILE__) + '/../test_helper'

require 'test/unit'
require 'reporters/svn_reporter'
# require 'models/svn_change'

class SubversionReporterTest < Test::Unit::TestCase

    revText =  "------------------------------------------------------------------------\n"
    revText += "r2 | gilbertogil | 2006-02-17 18:07:55 -0400 (Sex, 17 Fev 2006) | 4 lines\n"
    revText += "Caminhos mudados:\n"
    revText += "   M /trunk/src/test/unit/svn_reporter_test.rb\n"
    revText += "\n"
    revText += "Estou tentando enganar o SubversionReporter\n"
    revText +=  "------------------------------------------------------------------------\n"
    revText += "Isto aqui ainda é comentário da revisao 2\n\n"
    @@R2 = revText    
    
    revText  = "------------------------------------------------------------------------\n"
    revText += "r6 | thiagoarrais | 2006-02-17 12:22:25 -0300 (Sex, 17 Fev 2006) | 1 line\n"
    revText += "Caminhos mudados:\n"
    revText += "   A /trunk/src/test/stubs/svn_connection.rb\n"
    revText += "   A /trunk/src/test/unit/headline_test.rb\n"
    revText += "\n"
    revText += "Teste do reporter SVN agora falhando decentemente (ao inves de explodir)\n"
    @@R6 = revText
    
    diff_text = <<DIFF_END
Index: src/test/unit/headline_test.rb
===================================================================
--- src/test/unit/headline_test.rb      (revisão 0)
+++ src/test/unit/headline_test.rb      (revisão 6)
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
Index: src/test/stubs/svn_connection.rb
===================================================================
--- src/test/stubs/svn_connection.rb    (revisão 0)
+++ src/test/stubs/svn_connection.rb    (revisão 6)
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

    @@R6diff = diff_text
    
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
    @@R7 = revText    

    revText =  "------------------------------------------------------------------------\n"
    revText += "r13 | thiagoarrais | 2006-02-19 08:50:07 -0400 (Dom, 19 Fev 2006) | 1 line\n"
    revText += "Caminhos mudados:\n"
    revText += "   M /trunk/src/app/reporters/svn_reporter.rb\n"
    revText += "   M /trunk/src/test/unit/svn_reporter_test.rb\n"
    revText += "\n"
    revText += "Leitura de uma revisao SVN pronta\n"
    @@R13 = revText

    revText =  "------------------------------------------------------------------------\n"
    revText += "r15 | thiagoarrais | 2006-02-19 09:13:07 -0400 (Dom, 19 Fev 2006) | 1 line\n"
    revText += "Caminhos mudados:\n"
    revText += "   M /trunk/src/test/unit/svn_reporter_test.rb\n"
    revText += "\n"
    revText += "\n"
    @@R15 = revText
    
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
    @@R105 = revText

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
    @@R105diff = diff_text

    def setup
        @svn_log  = "------------------------------------------------------------------------\n"
        @svn_log += "r1 | thiagoarrais | 2006-02-14 15:45:13 -0400 (Ter, 14 Fev 2006) | 1 line\n"
        @svn_log += "Caminhos mudados:\n"
        @svn_log += "   A /trunk\n"
        @svn_log += "\n"
        @svn_log += "Criacao do trunk do projeto\n"
        @svn_log += "------------------------------------------------------------------------\n"
        @svn_diff = ''
        
        @svn_connection = FlexMock.new('svn connection')
        @svn_connection.mock_handle(:log) do
            @svn_log
        end

        @svn_connection.mock_handle(:diff) do
            @svn_diff
        end
        
        @reporter = SubversionReporter.new(@svn_connection)
    end

    def test_one_revision
        hl = @reporter.latest_headline
        assert_equal 'thiagoarrais', hl.author
        assert_equal Time.local(2006, 02, 14, 15, 45, 13), hl.happened_at
        assert_equal 'Criacao do trunk do projeto', hl.title
    end
    
    def test_more_revisions
        @svn_log = @@R13 + @svn_log

        hls = @reporter.latest_headlines

        assert_equal 'thiagoarrais', hls[0].author
        assert_equal Time.local(2006, 02, 19, 8, 50, 07), hls[0].happened_at
        assert_equal 'Leitura de uma revisao SVN pronta', hls[0].title

        assert_equal 'thiagoarrais', hls[1].author
        assert_equal Time.local(2006, 02, 14, 15, 45, 13), hls[1].happened_at
        assert_equal 'Criacao do trunk do projeto', hls[1].title
    end
    
    def test_revision_with_empty_comment
        @svn_log = @@R15 + @svn_log

        hl = @reporter.latest_headline
        
        assert_equal 'thiagoarrais', hl.author
        assert_equal Time.local(2006, 02, 19, 9, 13, 7), hl.happened_at
        assert_equal '', hl.title
    end
    
    def test_revision_with_multiline_comment
        @svn_log = @@R7 + @svn_log
        
        hls = @reporter.latest_headlines
        
        hl7 = hls[0]
        assert_equal 'gilbertogil', hl7.author
        assert_equal Time.local(2006, 02, 17, 18, 7, 55), hl7.happened_at
        assert_equal 'Correcao para a revisao anterior (r6)', hl7.title
        
        hl1 = hls[1]        
        assert_equal 'thiagoarrais', hl1.author
        assert_equal Time.local(2006, 02, 14, 15, 45, 13), hl1.happened_at
        assert_equal 'Criacao do trunk do projeto', hl1.title
    end
    
    def test_comment_with_dashes
        @svn_log = @@R2 + @svn_log

        hls = @reporter.latest_headlines
        
        hl2 = hls[0]
        assert_equal 'gilbertogil', hl2.author
        assert_equal Time.local(2006, 02, 17, 18, 7, 55), hl2.happened_at
        assert_equal 'Estou tentando enganar o SubversionReporter', hl2.title
        
        hl1 = hls[1]        
        assert_equal 'thiagoarrais', hl1.author
        assert_equal Time.local(2006, 02, 14, 15, 45, 13), hl1.happened_at
        assert_equal 'Criacao do trunk do projeto', hl1.title
    end
    
    def test_collect_all_available_headlines
        @svn_log = @@R13 + @@R7 + @svn_log
        
        hls = @reporter.latest_headlines
        assert_equal 3, hls.size
        
        assert_equal 'Leitura de uma revisao SVN pronta', hls[0].title
        assert_equal 'Correcao para a revisao anterior (r6)', hls[1].title
        assert_equal 'Criacao do trunk do projeto', hls[2].title
    end
    
    def test_record_full_comment
        @svn_log = @@R7 + @svn_log

        hls = @reporter.latest_headlines
        
        expectedComment  = "Correcao para a revisao anterior (r6)\n"
        expectedComment += "\n"
        expectedComment += "Esqueci de colocar o svn_reporter. Foi mal!\n"

        assert_equal(expectedComment, hls[0].article.description)
    end

    def test_name
        assert_equal 'subversion', @reporter.name
    end
    
    def test_sets_reported_by_field
        hls = @reporter.latest_headlines
        headline = hls[0]
        
        assert_equal @reporter.name, headline.reported_by
    end
    
    def test_retrieves_article_from_revision_id
        hls = @reporter.latest_headlines
        headline = hls[0]

        article = @reporter.article_for(headline.rid)

        assert_not_nil article
        assert_equal 'Criacao do trunk do projeto', article.description
    end
    
    def test_fills_headline_with_article
        hls = @reporter.latest_headlines
        headline = hls[0]
        
        article = headline.article
        assert_not_nil article
        
        changes = article.changes
        assert_not_nil changes
        assert_equal 1, changes.size
        
        assert_equal 'Criacao do trunk do projeto', article.description
        assert_equal '   A /trunk', changes[0].summary
    end
    
    def test_records_diff_output
        @svn_log = @@R105 + @svn_log
        @svn_diff = @@R105diff

        expected_diff  = "@@ -0,0 +1,7 @@\n"
        expected_diff += "+class Change < ActiveRecord::Base\n"
        expected_diff += "+\n"
        expected_diff += "+    def to_s\n"
        expected_diff += "+        return summary\n"
        expected_diff += "+    end\n"
        expected_diff += "+\n"
        expected_diff += "+end"

        hls = @reporter.latest_headlines
        change = hls[0].article.changes[0]

        assert_equal '   A /trunk/app/models/change.rb', change.summary
        assert_equal expected_diff, change.diff

        # TODO directory nodes
        # TODO only directory diff (no diff output)
    end
    
    def test_records_multiple_files_diff
        @svn_log = @@R6 + "-------------\n"
        @svn_diff = @@R6diff
        
        expected_diff_for_connection  = <<DIFF_END
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

        expected_diff_for_headline = <<DIFF_END
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
        
        hls = @reporter.latest_headlines
        changes = hls[0].article.changes
        
        assert_equal '   A /trunk/src/test/stubs/svn_connection.rb', changes[0].summary
        assert_equal expected_diff_for_connection, changes[0].diff
        
        assert_equal '   A /trunk/src/test/unit/headline_test.rb', changes[1].summary
        assert_equal expected_diff_for_headline, changes[1].diff
    end
    
    def test_method_article_for_record_diff_output
        @svn_log = @@R105
        @svn_diff = @@R105diff

        expected_diff  = "@@ -0,0 +1,7 @@\n"
        expected_diff += "+class Change < ActiveRecord::Base\n"
        expected_diff += "+\n"
        expected_diff += "+    def to_s\n"
        expected_diff += "+        return summary\n"
        expected_diff += "+    end\n"
        expected_diff += "+\n"
        expected_diff += "+end"

        article = @reporter.article_for('r105')
        change = article.changes[0]

        assert_equal '   A /trunk/app/models/change.rb', change.summary
        assert_equal expected_diff, change.diff

    end
    
    def teardown
        @svn_connection.mock_verify
    end
    
    #TODO test similar paths (see SubversionReporter#diff_for)
    #TODO simulate a connection timeout on live and cached modes
    
end
