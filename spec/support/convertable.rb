def load_snippet(snippet_name)
  rewriter_path = File.expand_path(File.join(File.dirname(__FILE__), '../../lib', "#{snippet_name}.rb"))
  eval(File.read(rewriter_path))
end

def load_sub_snippets(sub_snippets)
  sub_snippets.each do |sub_snippet| require(sub_snippet)end
end

shared_examples 'convertable' do
  # it needs to define rewriter_name, fake_file_path (optional), test_content and test_rewritten_content
  let!(:rewriter) { load_snippet(rewriter_name) }
  let(:file_path) { defined?(fake_file_path) ? fake_file_path : 'test/test.rb' }

  describe 'with fakefs', fakefs: true do
    before { FileUtils.mkdir_p(File.dirname(file_path)) }

    it 'converts' do
      File.write(file_path, test_content) if test_content
      rewriter.process
      if test_rewritten_content
        expect(File.read(file_path)).to eq(test_rewritten_content)
      else
        expect(File.exist?(file_path)).to be_falsey
      end
    end
  end
end

shared_examples 'convertable with multiple files' do
  # it needs to define rewriter_name, fake_file_paths, test_contents and test_rewritten_contents
  let!(:rewriter) { load_snippet(rewriter_name) }
  let(:file_paths) { fake_file_paths }

  describe 'with fakefs', fakefs: true do
    before do
      file_paths.each do |file_path| FileUtils.mkdir_p(File.dirname(file_path))end
    end

    it 'converts' do
      file_paths.each_with_index { |file_path, index|
        File.write(file_path, test_contents[index]) if test_contents[index]
      }
      rewriter.process
      file_paths.each_with_index do |file_path, index|
        if test_rewritten_contents[index]
          expect(File.read(file_path)).to eq(test_rewritten_contents[index])
        else
          expect(File.exist?(file_path)).to be_falsey
        end
      end
    end
  end
end
