# frozen_string_literal: true

require 'spec_helper'

describe 'reprepro::pull' do
  let :default_params do
    {
      repository: 'localpkgs',
      from: 'devs',
      components: '',
      architectures: '',
      udebcomponents: '',
      filter_action: '',
      filter_name: '',
      filter_src_name: '',
      filter_formula: '',
    }
  end

  shared_examples 'reprepro shared examples' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_concat__fragment("pulls-#{title}")
        .with_target("#{reprepro_params[:basedir]}/#{params[:repository]}/conf/pulls")
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'With default parameters' do
        let(:pre_condition) { 'include reprepro' }
        let :reprepro_params do
          {
            basedir: '/var/packages',
            homedir: '/var/packages',
            owner: 'reprepro',
            group: 'reprepro',
          }
        end

        let(:title) { 'default-backports' }
        let :params do
          default_params.merge(
            repository: 'localpkgs',
            from: 'dev'
          )
        end

        it_behaves_like 'reprepro shared examples'
      end

      context 'With non default' do
        let(:pre_condition) { "class{'reprepro': homedir => '/somewhere/homedir', basedir => '/somewhere/packages', user_name => 'repouser', group_name => 'repogroup' }" }
        let :reprepro_params do
          {
            basedir: '/somewhere/packages',
            homedir: '/somewhere/homedir',
            owner: 'repouser',
            group: 'repogroup',
          }
        end

        let(:title) { 'lenny-backports' }
        let :params do
          default_params.merge(
            name: 'lenny-backports',
            repository: 'localpkgs',
            from: 'dev'
          )
        end

        it_behaves_like 'reprepro shared examples'
      end
    end
  end
end
