# frozen_string_literal: true

require 'spec_helper'

describe 'reprepro::key' do
  let :default_params do
    {}
  end

  shared_examples 'reprepro::key shared examples' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_file("#{reprepro_params[:homedir]}/.gnupg/#{title}")
        .with_owner(reprepro_params[:owner])
        .with_group(reprepro_params[:group])
        .with_mode('0660')
    }

    it {
      is_expected.to contain_exec("import-#{title}")
        .with_refreshonly(true)
        .with_command("su -c 'gpg --import #{reprepro_params[:homedir]}/.gnupg/#{title}' #{reprepro_params[:owner]}")
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'With default params' do
        let(:pre_condition) { 'include reprepro' }
        let :reprepro_params do
          {
            basedir: '/var/packages',
            homedir: '/var/packages',
            owner: 'reprepro',
            group: 'reprepro',
          }
        end

        let(:title) { 'default-key' }
        let(:params) do
          default_params.merge(key_content: 'fsdfsdfsf')
        end

        it_behaves_like 'reprepro::key shared examples'
      end

      context 'With non default parameters on reprepro main class' do
        let(:pre_condition) { "class{'reprepro': homedir => '/somewhere/homedir', basedir => '/somewhere/packages', user_name => 'repouser', group_name => 'repogroup' }" }
        let :reprepro_params do
          {
            basedir: '/somewhere/packages',
            homedir: '/somewhere/homedir',
            owner: 'repouser',
            group: 'repogroup',
          }
        end
        let(:title) { 'mykey' }
        let :params do
          default_params.merge(key_source: '/tmp/key')
        end

        it_behaves_like 'reprepro::key shared examples'
      end
    end
  end
end
