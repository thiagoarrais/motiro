def get_revision_from_subversion
    basedir = File.expand_path(__FILE__ + '/..')
    svn_result = `svn info --xml #{basedir}`
    md = /<commit\s+revision=\"(\d+)\">/.match(svn_result)
    return md[1]
end


MOTIRO_VERSION = '0.1'
MOTIRO_REVISION = get_revision_from_subversion
