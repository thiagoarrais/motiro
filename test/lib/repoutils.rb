TEMP_DIR = File.expand_path(File.dirname(__FILE__) + '/../../tmp') unless defined? TEMP_DIR

# Utilities for local repositories
module RepoUtils

  def find_root_dir(prefix='svn')
    find_free_dir_under(TEMP_DIR, prefix)
  end

  def find_free_dir_under(parent_dir, prefix)
    contents = Dir.entries(parent_dir)
    suffix = ''
    if (contents.include?(prefix))
      suffix = 1
      while(contents.include?(prefix + suffix.to_s))
        suffix += 1
      end
    end

    parent_dir + '/' + prefix + suffix.to_s
  end

end
