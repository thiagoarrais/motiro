#  Motiro - A project tracking tool
#  Copyright (C) 2006-2008  Thiago Arrais
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require 'live_mode_test'

class SubversionAcceptanceTest < SeleniumTestCase
  
  include LiveModeTestCase
  
  def test_short_headline
    commit_msg = 'Created my project'
    
    @repo.mkdir('myproject', commit_msg)
    
    open '/report/subversion/en'
    assert_text_present @repo.username
    assert_text_present commit_msg
  end
  
  def test_show_subversion_on_main_page_when_in_development_mode
    commit_msg = 'Created another project'
    
    @repo.mkdir('myproject', commit_msg)
    
    open '/en'
    assert_text_present 'Latest news from Subversion'
    assert_text_present commit_msg
  end
  
  def test_records_revision_description
    commit_title = 'I have created the project dir'
    commit_msg = "#{commit_title}\n" +
                     "\n" +
                     "This project dir will hold everything needed to build and\n" +
                     "deploy our project from source code"
    dir_name = 'myproject'
    
    @repo.mkdir(dir_name, commit_msg)
    
    open '/report/subversion/en'
    assert_text_present commit_title
    click "//a[text() = \"#{commit_title}\"]"
    wait_for_page_to_load(2000)
    
    assert_equal "Revision details - #{commit_title} (Motiro)", get_title 
    assert_element_present "//span[@class='page-title' and text() = 'Revision r1']"
    assert_text_present commit_title
    assert_text_present 'This project dir will hold everything needed to build and'
    assert_text_present 'deploy our project from source code'
    
    assert_element_present "//div[@id='summary']"
    assert_text_present "A /#{dir_name}"
  end
  
  def test_shows_diff_output_when_adding_file
    commit_title = 'I have added a file'
    filename = 'a_file.txt'
    file_contents = "These are the file contents"
    diff_output = "@@ -0,0 +1 @@\n" +
                      "+#{file_contents}\n"
    
    @repo.add_file(filename, file_contents)
    @repo.commit(commit_title)
    
    open '/report/subversion/en'
    click "//a[text() = '#{commit_title}']"
    wait_for_page_to_load(2000)
    
    assert_element_present "//a[text()='A /#{filename}']"
    assert_element_present "//h2[text()='Changes to a_file.txt']"
    assert_text_present file_contents
  end
  
  def test_shows_diff_output_when_modifying_file
    test_shows_diff_output_when_adding_file
    diff_output = "@@ -1 +1 @@\n" +
                      "-These are the file contents\n" +
                      "+These are the modified file contents\n"
    
    commit_title = 'I have modified a file'
    @repo.put_file('a_file.txt', "These are the modified file contents\n" )
    @repo.commit(commit_title)
    
    open '/report/subversion/en'
    click "//a[text() = '#{commit_title}']"
    wait_for_page_to_load(1500)
    
    assert_text_present 'These are the file contents'
    assert_text_present 'These are the modified file contents'
  end
  
  def test_showing_invalid_rid_shows_nice_error_message
    commit_msg = 'Creating the project root'
    
    @repo.mkdir('projectroot', commit_msg)
    
    open '/show/subversion/r104?locale=en'
    assert_equal "Motiro: Welcome", get_title
    assert_text "//div[@id='notice']", 'The article r104 from the Subversion reporter could not be found'
  end
  
  def test_do_not_show_diff_section_when_adding_directories
    commit_title = 'Creating the project trunk'        
    
    @repo.mkdir('trunk', commit_title)
    
    open '/report/subversion/en'
    click "//a[text() = '#{commit_title}']"
    wait_for_page_to_load(1000)
    
    assert_element_not_present "//a[text() = 'A /trunk']"
    assert_text_not_present "Changes to trunk"
    
  end
  
  # TODO what should be the behaviour when removing files?
  # TODO on recorded mode, when something bad happens (like a connection
  #      timeout) during headline retrieval, the headlines are carved in
  #      stone that way and can't be fixed
  
  def test_copy_file
    @repo.add_file('file_number_one.txt', "the content here will be copied to file_number_two\n")
    @repo.commit('added first file')
    
    commit_title = 'files copied'
    @repo.copy('file_number_one.txt', 'file_number_two.txt', commit_title)
    
    open '/report/subversion/en'
    click "//a[text() = '#{commit_title}']"
    wait_for_page_to_load(2000)
    assert_text_present "Changes to file_number_two.txt"
    assert_text_present "the content here will be copied to file_number_two"
  end
  
  def test_move_file
    @repo.add_file('file_number_one.txt', "this file will be renamed to file_number_two\n")
    @repo.commit('added first file')
    
    commit_title = 'renamed file'
    @repo.move('file_number_one.txt', 'file_number_two.txt', commit_title)
    
    open '/report/subversion/en'
    click "//a[text() = '#{commit_title}']"
    wait_for_page_to_load(2000)
    
    assert_text_present "Changes to file_number_one.txt"
    assert_text_present "this file will be renamed to file_number_two"
    assert_text_present "Changes to file_number_two.txt"
    assert_text_present "this file will be renamed to file_number_two"
  end
  
  def test_shows_only_one_diff_when_selected
    @repo.add_file('file_one.txt', 'son, she said, have I got a little story for you')
    @repo.add_file('file_two.txt', 'what you thought was your daddy was nothing but a...')
    
    commit_title = 'added two files'
    @repo.commit(commit_title)
    
    open '/report/subversion/en'
    click "//a[text() = '#{commit_title}']"
    wait_for_page_to_load(1000)
    
    click "//a[contains(text(), 'A /file_one.txt')]"
    
    #TODO using IDs is a little counter-intuitive, maybe we could try text()
    assert_visible "//div[@id='change17300898']"
    assert_not_visible "//div[@id='change462869942']"
    
    click "//a[contains(text(), 'A /file_two.txt')]"
    assert_visible "//div[@id='change462869942']"
    assert_not_visible "//div[@id='change17300898']"
  end
  
  def test_shows_diff_only_when_clicked
    @repo.add_file('alive.txt', 'son, she said, have I got a little story for you')
    
    commit_title = 'added alive.txt'
    @repo.commit(commit_title)
    
    open '/report/subversion/en'
    click "//a[text() = '#{commit_title}']"
    wait_for_page_to_load(1000)
    
    assert_not_visible "//div[@id='changes']"
    assert_not_visible "//div[@id='change-374147303']"
    
    click "//a[contains(text(), 'A /alive.txt')]"
    
    assert_visible "//div[@id='change-374147303']"
  end
  
  def test_translates_page_for_valid_revision_id
    @repo.add_file('daughter.txt', 'alone, listless, breakfast table and an otherwise empty room')
    
    commit_title = 'added daughter.txt'
    @repo.commit(commit_title)
    
    open '/show/subversion/r1?locale=en'
    
    assert_equal "Revision details - #{commit_title} (Motiro)", get_title 
    assert_text_present 'Revision r1'
    assert_element_present "//h2[text()='Changes to daughter.txt']"
    
    click "//a[@id='pt-BR']"
    wait_for_page_to_load(1000)
    
    assert get_title =~ /Detalhes de revis.o - #{commit_title} \(Motiro\)/
    # Revisão r1
    assert_text_present 'Revis'
    assert_text_present 'o r1'
    # Alteraçõµes em dauther.txt
    assert_text_present 'Altera'
    assert_text_present 'es em daughter.txt'
  end
  
  def test_translates_page_for_inexistent_revision_id
    @repo.add_file('daughter.txt', 'alone, listless, breakfast table and an otherwise empty room')
    
    commit_title = 'added daughter.txt'
    @repo.commit(commit_title)
    
    open '/show/subversion/r30?locale=en'
    
    assert_equal "Motiro: Welcome", get_title
    assert_text "//div[@id='notice']", 'The article r30 from the Subversion reporter could not be found'

    open '/show/subversion/r30?locale=pt-BR'
    
    assert_text "//div[@id='notice']", /o foi poss/
    assert_text "//div[@id='notice']", /vel encontrar o artigo r30 do rep/
  end
  
  def test_select_correct_translation_from_comment
    @repo.add_file('wishlist.txt', 'I wish I was a neutron bomb, for once I could go off')
    
    commit_comment = "letras da musica Wishlist do album Yield\n" +
                     "\n" +
                     "Este album foi originalmente lancado em 1998\n" +
                     "\n" +
                     "--- en -----------------------------------\n" +
                     "\n" +
                     "lyrics for the song Wishlist from the album Yield\n" +
                     "\n" +
                     "This album was originally released in 1998\n"

    @repo.commit(commit_comment)
    
    open '/report/subversion/pt-BR'

    assert_text_not_present('lyrics')

    click '//a[text() = "letras da musica Wishlist do album Yield"]'
    wait_for_page_to_load(2000)
    
    assert_text_present("letras da musica Wishlist do album Yield")
    assert_text_present('Este album foi originalmente lancado em 1998')
    assert_text_not_present('this')
    assert_text_not_present('originally released')
    
    open '/report/subversion/en'
    
    assert_text_not_present('letras')
    assert_text_not_present('musica')

    click '//a[text() = "lyrics for the song Wishlist from the album Yield"]'
    wait_for_page_to_load(2000)

    assert_text_present("lyrics for the song Wishlist from the album Yield")
    assert_text_present('This album was originally released in 1998')
    assert_text_not_present('musica')
    assert_text_not_present('Este')
    assert_text_not_present('foi originalmente')
  end

  def test_formats_page_as_wiki_text
    commit_msg = "This is the comment title\n" +
                 "\n" +
                 "This is the second paragraph"
                 
    @repo.mkdir('wikitest', commit_msg)

    open '/report/subversion/en'
    click "//a[text() = 'This is the comment title']"
    wait_for_page_to_load(2000)
    
    assert_element_present "//p[text() = 'This is the second paragraph']"
  end
  
  def test_shows_older_revisions
    1.upto 8 do |n|
      @repo.mkdir("directory#{n}", "Created directory n#{n}")
    end
    
    open '/en'
    click "//a[text() = 'Older']"
    wait_for_page_to_load(2000)
    
    assert_element_present "//a[text() = 'Created directory n1']"
    assert_element_present "//a[text() = 'Created directory n2']"
    assert_element_present "//a[text() = 'Created directory n5']"
    assert_element_present "//a[text() = 'Created directory n7']"
    assert_element_present "//a[text() = 'Created directory n8']"
  end

end
