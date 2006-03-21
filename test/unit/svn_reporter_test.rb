require File.dirname(__FILE__) + '/../test_helper'

require 'test/unit'
require 'stubs/svn_connection'
require 'reporters/svn_reporter'

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
    
    def test_name
        assert_equal 'subversion', @reporter.name
    end
    
    #TODO simulate a connection timeout
    
end
