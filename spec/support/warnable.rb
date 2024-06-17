# frozen_string_literal: true

shared_examples 'warnable' do
  # it needs to define rewriter_name, fake_file_path (optional), test_content, warnings
  let!(:rewriter) { load_snippet(rewriter_name) }

  describe 'with fakefs', fakefs: true do
    it 'converts' do
      file_paths.each_with_index do |file_path, index|
        FileUtils.mkdir_p(File.dirname(file_path))
        File.write(file_path, test_contents[index])
      end
      rewriter.process
      expect(rewriter.warnings.map(&:message)).to eq(warnings)
    end
  end
end
