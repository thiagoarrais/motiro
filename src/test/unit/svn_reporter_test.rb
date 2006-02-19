$:.push File.expand_path(File.dirname(__FILE__) + '/..')
$:.push File.expand_path(File.dirname(__FILE__) + '/../../app')

require 'date'
require 'test/unit'
require 'stubs/svn_connection'
require 'reporters/svn_reporter'

class SubversionReporterTest < Test::Unit::TestCase

    def setup
        @svn_connection = StubSVNConnection.new
        @svn_connection.log_append_line '------------------------------------------------------------------------'
        @svn_connection.log_append_line 'r1 | thiagoarrais | 2006-02-14 15:45:13 -0400 (Ter, 14 Fev 2006) | 1 line'
        @svn_connection.log_append_line ''
        @svn_connection.log_append_line 'Criacao do trunk do projeto'
        @svn_connection.log_append_line '------------------------------------------------------------------------'

        @reporter = SubversionReporter.new(@svn_connection)
    end

    def test_one_revision
        hl = @reporter.latest_headline
        assert_equal 'thiagoarrais', hl.author
        assert_equal DateTime.new(2006, 02, 14, 15, 45, 13), hl.date
        assert_equal 'Criacao do trunk do projeto', hl.title
    end
    
    def test_more_revisions
        @svn_connection.log_append_line 'r13 | thiagoarrais | 2006-02-19 08:50:07 -0400 (Dom, 19 Fev 2006) | 1 line'
        @svn_connection.log_append_line ''
        @svn_connection.log_append_line 'Leitura de uma revisao SVN pronta'
        @svn_connection.log_append_line '------------------------------------------------------------------------'

        hls = @reporter.latest_headlines(2)

        assert_equal 'thiagoarrais', hls[0].author
        assert_equal DateTime.new(2006, 02, 14, 15, 45, 13), hls[0].date
        assert_equal 'Criacao do trunk do projeto', hls[0].title
        
        assert_equal 'thiagoarrais', hls[1].author
        assert_equal DateTime.new(2006, 02, 19, 8, 50, 07), hls[1].date
        assert_equal 'Leitura de uma revisao SVN pronta', hls[1].title
    end
    
    def test_revision_with_empty_comment
    end
    
    def test_revision_with_multiline_comment
        @svn_connection.log_append_line 'r7 | thiagoarrais | 2006-02-17 18:07:55 -0400 (Sex, 17 Fev 2006) | 4 lines'
        @svn_connection.log_append_line ''
        @svn_connection.log_append_line 'Correcao para a revisao anterior (r6)'
        @svn_connection.log_append_line ''
        @svn_connection.log_append_line 'Esqueci de colocar o svn_reporter. Foi mal!'
        @svn_connection.log_append_line ''
        @svn_connection.log_append_line '------------------------------------------------------------------------'
    end

end
