# frozen_string_literal: true

require 'spec_helper'

describe 'reprepro' do
  let :default_params do
    {
      basedir: '/var/packages',
      homedir: '/var/packages',
      manage_user: true,
      user_name: 'reprepro',
      group_name: 'reprepro',
      keys: {},
      key_defaults: {},
      repositories: {},
      repositories_defaults: {},
      package_ensure: 'present',
      package_name: 'reprepro',
      distributions_defaults: {},
    }
  end

  shared_examples 'reprepro shared examples' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_package('reprepro') }

    it {
      is_expected.to contain_group(params[:group_name])
        .with_name(params[:group_name])
    }

    it {
      if params[:basedir] != params[:homedir]
        is_expected.to contain_file(params[:basedir])
          .with_ensure('directory')
          .with_owner(params[:user_name])
          .with_group(params[:group_name])
          .with_mode('0755')
      end
    }

    it {
      is_expected.to contain_user(params[:user_name])
        .with_name(params[:user_name])
        .with_home(params[:homedir])
        .with_shell('/bin/bash')
        .with_comment('Reprepro user')
        .with_gid(params[:group_name])
        .with_managehome(true)
        .with_system(true)
        .that_requires("Group[#{params[:group_name]}]")
        .that_comes_before("File[#{params[:homedir]}/.gnupg]")
        .that_comes_before("File[#{params[:homedir]}/bin]")
    }

    it {
      is_expected.to contain_file("#{params[:homedir]}/.gnupg")
        .with_ensure('directory')
        .with_mode('0700')
        .with_owner(params[:user_name])
        .with_group(params[:group_name])
    }

    it {
      is_expected.to contain_file("#{params[:homedir]}/bin")
        .with_ensure('directory')
        .with_mode('0755')
        .with_owner(params[:user_name])
        .with_group(params[:group_name])
    }

    it {
      is_expected.to contain_file("#{params[:homedir]}/bin/update-distribution.sh")
        .with_mode('0755')
        .with_content(%r{while getopts})
        .with_owner(params[:user_name])
        .with_group(params[:group_name])
        .that_requires("File[#{params[:homedir]}/bin]")
    }

    it {
      is_expected.to contain_concat("#{params[:homedir]}/bin/update-all-repositories.sh")
        .with_owner(params[:user_name])
        .with_group(params[:group_name])
        .with_mode('0755')
    }

    it {
      is_expected.to contain_concat__fragment('update-repositories header')
        .with_target("#{params[:homedir]}/bin/update-all-repositories.sh")
        .with_order('0')
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'With default parameters' do
        let :params do
          default_params
        end

        it_behaves_like 'reprepro shared examples'
      end

      context 'With non-default parameters' do
        let :params do
          default_params.merge(
            basedir: '/somewhere/packages',
            homedir: '/somewhere/homedir',
            user_name: 'repouser',
            group_name: 'repogroup'
          )
        end

        it_behaves_like 'reprepro shared examples'
      end

      context 'With manage_user set to false' do
        let :params do
          default_params.merge(manage_user: false)
        end

        it do
          is_expected.not_to contain_group('reprepro')
          is_expected.not_to contain_user('reprepro')
        end
      end
    end
  end
end
