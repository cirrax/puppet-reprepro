# frozen_string_literal: true

require 'spec_helper'

describe 'reprepro::filterlist' do
  let :default_params do
    {
      repository: 'dev',
      packages: [],
      ensure: 'present',
    }
  end

  shared_examples 'reprepro shared examples' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_file("#{reprepro_params[:basedir]}/#{params[:repository]}/conf/#{title}-filter-list")
        .with_ensure(params[:ensure])
        .with_owner('root')
        .with_mode('0664')
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'With defaults' do
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
          default_params.merge(
            packages: ['somepackage install', 'other install']
          )
        end

        it_behaves_like 'reprepro shared examples'
      end

      context 'With non default class' do
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
            packages: ['somepackage install', 'other install']
          )
        end

        it_behaves_like 'reprepro shared examples'

        context 'With no packages' do
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
          let :params do
            default_params
          end

          it_behaves_like 'reprepro shared examples'
        end
      end
    end
  end
end
