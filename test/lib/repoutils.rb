# Utilities for local repositories
module RepoUtils

  def find_root_dir(prefix='svn')
    tmpdir = TEMP_DIR
    return find_free_dir_under(tmpdir, prefix)
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

    return parent_dir + '/' + prefix + suffix.to_s
  end

end