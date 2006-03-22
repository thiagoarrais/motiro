require File.dirname(__FILE__) + '/../test_helper'

require 'acceptance/subversion_test'

class SubversionAcceptanceTest < Test::Unit::TestCase

    def test_records_revision_details
        commit_title = 'I have created the project dir'
        commit_msg = "#{commit_title}\n" +
                     "\n"
                     "This project dir will hold everything needed to build and\n" +
                     "deploy our project from source code"
        dir_name = 'myproject'
        
        svn_command("mkdir #{@repo_url}/#{dir_name}", commit_msg)

        open '/report/subversion'
        assertTextPresent commit_title
        clickAndWait "//a[text() = \"#{commit_title}\"]"
        assertElementPresent "//div[@id='description']"
        assertTextPresent commit_msg
        
        # assertElementPresent "//div[@id='summary']"
        # assertTextPresent "Adicionado #{dir_name}"
        
        # TODO assert that details of adding a file is showing the file contents
        # TODO assert that details of altering a file shows the diff output
    end

  end