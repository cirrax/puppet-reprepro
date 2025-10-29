# frozen_string_literal: true

require 'spec_helper'

describe 'reprepro::update' do
  let :default_params do
    {
      suite: 'lenny',
      repository: 'dev',
      url: 'http://backports.debian.org/debian-backports',
      ignore_release: 'No',
    }
  end

  shared_examples 'reprepro::update shared examples' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_concat__fragment("update-#{title}")
        .with_target("#{reprepro_params[:basedir]}/#{params[:repository]}/conf/updates")
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

        let(:title) { 'lenny-backports' }
        let(:params) do
          default_params
        end

        it_behaves_like 'reprepro::update shared examples'
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
        let(:title) { 'localpkgs' }
        let :params do
          default_params
        end

        it_behaves_like 'reprepro::update shared examples'
      end
    end
  end
end
