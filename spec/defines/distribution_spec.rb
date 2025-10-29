# frozen_string_literal: true

require 'spec_helper'

describe 'reprepro::distribution' do
  let :default_params do
    {
      repository: 'localpkgs',
      architectures: 'amd64 i386',
      components: 'main contrib non-free',
      origin: 'Foobar',
      label: 'Foobar',
      suite: 'precise',
      description: 'Package repository for local site maintenance',
      sign_with: 'F4D5DAA8',
      codename: 'localpkgs',
      udebcomponents: 'main contrib non-free',
      deb_indices: 'Packages Release .gz .bz2',
      dsc_indices: 'Sources Release .gz .bz2',
      update: '',
      pull: '',
      uploaders: '',
      snapshots: false,
      install_cron: true,
      not_automatic: 'No',
      but_automatic_upgrades: 'no',
      log: '',
      create_pull: {},
      create_update: {},
      create_filterlist: {},
    }
  end

  shared_examples 'reprepro shared examples' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_concat__fragment("distribution-#{params[:codename]}")
        .with_target("#{reprepro_params[:basedir]}/#{params[:repository]}/conf/distributions")
        .that_notifies("Exec[export distribution #{params[:codename]}]")
    }

    it {
      is_expected.to contain_exec("export distribution #{params[:codename]}")
        .with_command("su -c 'reprepro -b #{reprepro_params[:basedir]}/#{params[:repository]} export #{params[:codename]}' #{reprepro_params[:owner]}")
        .with_path(['/bin', '/usr/bin'])
        .with_refreshonly(true)
        .with_logoutput('on_failure')
    }

    it {
      is_expected.to contain_file("#{reprepro_params[:basedir]}/#{params[:repository]}/tmp/#{params[:codename]}")
        .with_ensure('directory')
        .with_mode('0755')
    }

    it { is_expected.to contain_cron("#{params[:codename]} cron") }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'With default parameters' do
        let(:pre_condition) { ['include reprepro', 'reprepro::repository{localpkgs:}'] }
        let :reprepro_params do
          {
            basedir: '/var/packages',
            homedir: '/var/packages',
            owner: 'reprepro',
            group: 'reprepro',
          }
        end
        let(:title) { 'localpkgs' }
        let :params do
          default_params
        end

        it_behaves_like 'reprepro shared examples'
      end

      context 'With non default parameters' do
        let(:pre_condition) do
          [
            "class{'reprepro': homedir => '/somewhere/homedir', basedir => '/somewhere/packages', user_name => 'repouser', group_name => 'repogroup' }",
            'reprepro::repository{localpkgs:}',
          ]
        end
        let :reprepro_params do
          {
            basedir: '/somewhere/packages',
            homedir: '/somewhere/homedir',
            owner: 'repouser',
            group: 'repogroup',

          }
        end

        let(:title) { 'precise' }
        let :params do
          default_params.merge(
            name: 'precise',
            codename: 'precise'
          )
        end

        it_behaves_like 'reprepro shared examples'
      end
    end
  end
end
