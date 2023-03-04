require 'spec_helper'

describe 'reprepro::repository' do
  let(:default_params) do
    {
      ensure: 'present',
      incoming_name: 'incoming',
      incoming_dir: 'incoming',
      incoming_tmpdir: 'tmp',
      incoming_allow: '',
      options: ['verbose', 'ask-passphrase', 'basedir .'],
      createsymlinks: false,
      distributions: {},
      distributions_defaults: {},
      always_recurse: true,
    }
  end

  shared_examples 'reprepro::repository shared examples' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_file(reprepro_params[:basedir] + '/' + title)
        .with_ensure('directory')
        .with_mode('2755')
        .with_owner(reprepro_params[:owner])
        .with_group(reprepro_params[:group])
        .with_purge(params[:always_recurse])
        .with_recurse(params[:always_recurse])
        .with_force(params[:always_recurse])
    }

    it {
      [reprepro_params[:basedir] + '/' + title + '/dists',
       reprepro_params[:basedir] + '/' + title + '/pool',
       reprepro_params[:basedir] + '/' + title + '/conf',
       reprepro_params[:basedir] + '/' + title + '/lists',
       reprepro_params[:basedir] + '/' + title + '/db',
       reprepro_params[:basedir] + '/' + title + '/logs',
       reprepro_params[:basedir] + '/' + title + '/tmp'].each do |dirname|
        is_expected.to contain_file(dirname)
          .with_ensure('directory')
          .with_mode('2755')
          .with_owner(reprepro_params[:owner])
          .with_group(reprepro_params[:group])
      end
    }

    it {
      is_expected.to contain_file(reprepro_params[:basedir] + '/' + title + '/incoming')
        .with_ensure('directory')
        .with_mode('2775')
        .with_owner(reprepro_params[:owner])
        .with_group(reprepro_params[:group])
    }
    it {
      is_expected.to contain_file(reprepro_params[:basedir] + '/' + title + '/conf/options')
        .with_ensure(params[:ensure])
        .with_mode('0640')
        .with_owner(reprepro_params[:owner])
        .with_group(reprepro_params[:group])
    }
    it {
      is_expected.to contain_file(reprepro_params[:basedir] + '/' + title + '/conf/incoming')
        .with_ensure(params[:ensure])
        .with_mode('0640')
        .with_owner(reprepro_params[:owner])
        .with_group(reprepro_params[:group])
    }
    it {
      is_expected.to contain_concat(reprepro_params[:basedir] + '/' + title + '/conf/distributions')
        .with_mode('0640')
        .with_owner(reprepro_params[:owner])
        .with_group(reprepro_params[:group])
    }
    it {
      is_expected.to contain_concat__fragment('00-distributions-' + title)
        .with_target(reprepro_params[:basedir] + '/' + title + '/conf/distributions')
        .with_content("# Puppet managed\n")
    }
    it {
      is_expected.to contain_concat(reprepro_params[:basedir] + '/' + title + '/conf/updates')
        .with_mode('0640')
        .with_owner(reprepro_params[:owner])
        .with_group(reprepro_params[:group])
    }
    it {
      is_expected.to contain_concat__fragment('00-update-' + title)
        .with_target(reprepro_params[:basedir] + '/' + title + '/conf/updates')
        .with_content("# Puppet managed\n")
    }
    it {
      is_expected.to contain_concat(reprepro_params[:basedir] + '/' + title + '/conf/pulls')
        .with_mode('0644')
        .with_owner('root')
        .with_group('root')
    }
    it {
      is_expected.to contain_concat__fragment('00-pulls-' + title)
        .with_target(reprepro_params[:basedir] + '/' + title + '/conf/pulls')
        .with_content("# Puppet managed\n")
    }

    it {
      is_expected.to contain_concat__fragment('update-repositories add repository ' + title)
        .with_target(reprepro_params[:homedir] + '/bin/update-all-repositories.sh')
        .with_order('50-' + title)
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
        let(:title) { 'localpkgs' }
        let :params do
          default_params
        end

        it_behaves_like 'reprepro::repository shared examples'
      end

      context 'With non default parameters on reprepro main class' do
        let(:pre_condition) { "class{'reprepro': homedir => '/somewhere/homedir', basedir => '/somewhere/packages', user_name => 'repouser', group_name => 'repogroup' }" }
        let :reprepro_params do
          {
            basedir: '/somewhere/packages',
            homedir: '/somewhere/homedir',
            owner: 'repouser',
            group: 'repogroup',
            always_recurse: false,
          }
        end
        let(:title) { 'localpkgs' }
        let :params do
          default_params
        end

        it_behaves_like 'reprepro::repository shared examples'
      end

      context 'With always_recurse being false in main class' do
        let(:pre_condition) { "class{'reprepro': always_recurse => false }" }
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
          {}
        end

        it {
          is_expected.to contain_file(reprepro_params[:basedir] + '/' + title)
            .with_ensure('directory')
            .with_mode('2755')
            .with_owner(reprepro_params[:owner])
            .with_group(reprepro_params[:group])
            .with_purge(false)
            .with_recurse(false)
            .with_force(false)
        }
      end

      context 'With non default parameters on reprepro main class and ensure absent' do
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
          default_params.merge(
            ensure: 'absent',
            always_recurse: false,
          )
        end

        it {
          is_expected.to contain_file(reprepro_params[:basedir] + '/' + title)
            .with_ensure('absent')
            .with_purge(true)
            .with_recurse(true)
            .with_force(true)
        }
      end

      context 'With documentroot for www set' do
        let(:pre_condition) { 'include reprepro' }
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
          default_params.merge(
            documentroot: '/tmp/docroot',
          )
        end

        it_behaves_like 'reprepro::repository shared examples'
        it {
          is_expected.to contain_file('/tmp/docroot/' + title)
            .with_ensure('directory')
        }
        it {
          is_expected.to contain_file('/tmp/docroot/' + title + '/dists')
            .with_ensure('link')
            .with_target('/var/packages/' + title + '/dists')
        }
        it {
          is_expected.to contain_file('/tmp/docroot/' + title + '/pool')
            .with_ensure('link')
            .with_target('/var/packages/' + title + '/pool')
        }
      end
    end
  end
end
