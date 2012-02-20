begin
  require 'double_doc'
  guard :double_doc, :rake_task => 'doc' do
    watch(/^(doc|lib)\//)
  end
rescue LoadError => e
end
