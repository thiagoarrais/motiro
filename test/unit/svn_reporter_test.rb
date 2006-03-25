require File.dirname(__FILE__) + '/../test_helper'

require 'test/unit'
require 'stubs/svn_connection'
require 'reporters/svn_reporter'
# require 'models/svn_change'

class SubversionReporterTest < Test::Unit::TestCase

    def setup
        @svn_connection = StubSVNConnection.new
        @svn_connection.log_append_line '------------------------------------------------------------------------'
        @svn_connection.log_append_line 'r1 | thiagoarrais | 2006-02-14 15:45:13 -0400 (Ter, 14 Fev 2006) | 1 line'
        @svn_connection.log_append_line 'Caminhos mudados:'
        @svn_connection.log_append_line '   A /trunk'
        @svn_connection.log_append_line ''
        @svn_connection.log_append_line 'Criacao do trunk do projeto'
        @svn_connection.log_append_line '------------------------------------------------------------------------'

        @reporter = SubversionReporter.new(@svn_connection)
    end

    def test_one_revision
        hl = @reporter.latest_headline
        assert_equal 'thiagoarrais', hl.author
        assert_equal Time.local(2006, 02, 14, 15, 45, 13), hl.happened_at
        assert_equal 'Criacao do trunk do projeto', hl.title
    end
    
    def test_more_revisions
        revText =  "------------------------------------------------------------------------\n"
        revText += "r13 | thiagoarrais | 2006-02-19 08:50:07 -0400 (Dom, 19 Fev 2006) | 1 line\n"
        revText += "Caminhos mudados:\n"
        revText += "   M /trunk/src/app/reporters/svn_reporter.rb\n"
        revText += "   M /trunk/src/test/unit/svn_reporter_test.rb\n"
        revText += "\n"
        revText += "Leitura de uma revisao SVN pronta"
        @svn_connection.log_prefix_line revText

        hls = @reporter.latest_headlines

        assert_equal 'thiagoarrais', hls[0].author
        assert_equal Time.local(2006, 02, 19, 8, 50, 07), hls[0].happened_at
        assert_equal 'Leitura de uma revisao SVN pronta', hls[0].title

        assert_equal 'thiagoarrais', hls[1].author
        assert_equal Time.local(2006, 02, 14, 15, 45, 13), hls[1].happened_at
        assert_equal 'Criacao do trunk do projeto', hls[1].title
    end
    
    def test_revision_with_empty_comment
        revText =  "------------------------------------------------------------------------\n"
        revText += "r15 | thiagoarrais | 2006-02-19 09:13:07 -0400 (Dom, 19 Fev 2006) | 1 line\n"
        revText += "Caminhos mudados:\n"
        revText += "   M /trunk/src/test/unit/svn_reporter_test.rb\n"
        revText += "\n"
        revText += ""
        @svn_connection.log_prefix_line revText

        hl = @reporter.latest_headline
        
        assert_equal 'thiagoarrais', hl.author
        assert_equal Time.local(2006, 02, 19, 9, 13, 7), hl.happened_at
        assert_equal '', hl.title
    end
    
    def test_revision_with_multiline_comment
        revText =  "------------------------------------------------------------------------\n"
        revText += "r7 | gilbertogil | 2006-02-17 18:07:55 -0400 (Sex, 17 Fev 2006) | 4 lines\n"
        revText += "Caminhos mudados:\n"
        revText += "   A /trunk/src/app\n"
        revText += "   A /trunk/src/app/reporters\n"
        revText += "   A /trunk/src/app/reporters/svn_reporter.rb\n"
        revText += "\n"
        revText += "Correcao para a revisao anterior (r6)\n"
        revText += "\n"
        revText += "Esqueci de colocar o svn_reporter. Foi mal!\n"
        @svn_connection.log_prefix_line revText
        
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
        revText =  "------------------------------------------------------------------------\n"
        revText += "r2 | gilbertogil | 2006-02-17 18:07:55 -0400 (Sex, 17 Fev 2006) | 4 lines\n"
        revText += "Caminhos mudados:\n"
        revText += "   M /trunk/src/test/unit/svn_reporter_test.rb\n"
        revText += "\n"
        revText += "Estou tentando enganar o SubversionReporter\n"
        revText +=  "------------------------------------------------------------------------\n"
        revText += "Isto aqui ainda é comentário da revisao 2\n"
        @svn_connection.log_prefix_line revText

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
        revText =  "------------------------------------------------------------------------\n"
        revText += "r13 | thiagoarrais | 2006-02-19 08:50:07 -0400 (Dom, 19 Fev 2006) | 1 line\n"
        revText += "Caminhos mudados:\n"
        revText += "   M /trunk/src/app/reporters/svn_reporter.rb\n"
        revText += "   M /trunk/src/test/unit/svn_reporter_test.rb\n"
        revText += "\n"
        revText += "Leitura de uma revisao SVN pronta\n"
        revText +=  "------------------------------------------------------------------------\n"
        revText += "r7 | gilbertogil | 2006-02-17 18:07:55 -0400 (Sex, 17 Fev 2006) | 4 lines\n"
        revText += "Caminhos mudados:\n"
        revText += "   A /trunk/src/app\n"
        revText += "   A /trunk/src/app/reporters\n"
        revText += "   A /trunk/src/app/reporters/svn_reporter.rb\n"
        revText += "\n"
        revText += "Correcao para a revisao anterior (r6)\n"
        revText += "\n"
        revText += "Esqueci de colocar o svn_reporter. Foi mal!\n"
        @svn_connection.log_prefix_line revText
        
        hls = @reporter.latest_headlines
        assert_equal 3, hls.size
        
        assert_equal 'Leitura de uma revisao SVN pronta', hls[0].title
        assert_equal 'Correcao para a revisao anterior (r6)', hls[1].title
        assert_equal 'Criacao do trunk do projeto', hls[2].title
    end
    
    def test_record_full_comment
        revText =  "------------------------------------------------------------------------\n"
        revText += "r7 | gilbertogil | 2006-02-17 18:07:55 -0400 (Sex, 17 Fev 2006) | 4 lines\n"
        revText += "Caminhos mudados:\n"
        revText += "   A /trunk/src/app\n"
        revText += "   A /trunk/src/app/reporters\n"
        revText += "   A /trunk/src/app/reporters/svn_reporter.rb\n"
        revText += "\n"
        revText += "Correcao para a revisao anterior (r6)\n"
        revText += "\n"
        revText += "Esqueci de colocar o svn_reporter. Foi mal!\n"
        @svn_connection.log_prefix_line revText

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
        FlexMock.use do |connection|
            revision_log =  "------------------------------------------------------------------------\n"
            revision_log += "r105 | gilbertogil | 2006-03-24 15:03:06 -0400 (Sex, 24 Mar 2006) | 7 lines\n"
            revision_log += "Caminhos mudados:\n"
            revision_log += "   A /trunk/app/models/change.rb\n"
            revision_log += "\n"
            revision_log += "Agora mostrando resumo das modificacoes de cada revisao\n"
            revision_log += "\n"
            revision_log += "Alem de mostrar o comentario completo, o detalhamento agora mostra os\n"
            revision_log += "nomes dos recursos que foram alterados com a revisao. A partir desta\n"
            revision_log += "revisao, o Motiro ja deve mostrar uma lista de recursos alterados abaixo\n"
            revision_log += "desta mensagem.\n"
            revision_log += "\n"
            revision_log =  "------------------------------------------------------------------------\n"
            
            expected_diff += "@@ -0,0 +1,7 @@\n"
            expected_diff += "+class Change < ActiveRecord::Base\n"
            expected_diff += "+\n"
            expected_diff += "+    def to_s\n"
            expected_diff += "+        return summary\n"
            expected_diff += "+    end\n"
            expected_diff += "+\n"
            expected_diff += "+end\n"

            revision_diff  = "Index: app/models/change.rb\n"
            revision_diff += "===================================================================\n"
            revision_diff += "--- app/models/change.rb        (revision 0)\n"
            revision_diff += "+++ app/models/change.rb        (revision 105)\n"
            revision_diff += expected_diff

            connection.should_receive(:log).
                returns(revision_log)
            connection.should_receive(:diff).with(105)
                returns(revision_diff)
                
            @reporter = SubversionReporter.new(connection)

            hls = @reporter.latest_headlines
            change = hls[0].article.changes[0]
            
            assert_equal 'A /trunk/app/models/change.rb', change.summary
            assert_equal expected_diff, change.diff
        end
    end
    
    #TODO simulate a connection timeout on live and cached modes
    
end
