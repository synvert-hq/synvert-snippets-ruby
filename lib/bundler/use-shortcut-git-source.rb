# frozen_string_literal: true

Synvert::Rewriter.new 'bundler', 'use-shortcut-git-source' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    This script is designed to optimize the way Git sources are specified in a Gemfile.

    It scans the Gemfile for any gem declarations that use the 'git' option with a full Git URL.
    It then replaces these full URLs with their shorter equivalents using the following rules:

    1. For GitHub repositories, it replaces 'git://github.com/user/repo.git' or 'https://github.com/user/repo.git' with "github: 'user/repo'".
    2. For Bitbucket repositories, it replaces 'git://user@bitbucket.org/user/repo.git' or 'https://user@bitbucket.org/user/repo.git' with "bitbucket: 'user/repo'".
    3. For GitHub Gists, it replaces 'https://gist.github.com/sha1' with "gist: 'sha1'".

    This makes the Gemfile easier to read and maintain, and it's also more in line with the recommended way of specifying Git sources in a Gemfile.
  EOS

  within_files %w[**/Gemfile] do
    find_node '.send[receiver=nil][message=gem][arguments.-1=.hash[git_value=.str]]' do
      git_value = node.arguments[-1].git_value.to_value
      if git_value =~ %r{^(?:git|https)://github.com/(\w+)/(\w+)(\.git)?$}
        replace 'arguments.-1.git_pair', with: $1 == $2 ? "github: '#$1'" : "github: '#$1/#$2'"
      elsif git_value =~ %r{^(?:git|https)://(?:\w+)@bitbucket.org/(\w+)/(\w+)(\.git)?$}
        replace 'arguments.-1.git_pair', with: $1 == $2 ? "bitbucket: '#$1'" : "bitbucket: '#$1/#$2'"
      elsif git_value =~ %r{^https://gist\.github\.com/(\w+)(\.git)?$}
        replace 'arguments.-1.git_pair', with: "gist: '#$1'"
      end
    end
  end
end
