require 'spec_helper'

describe 'aide', type: 'class' do

  context 'default parameters on RedHat 7' do
    let (:facts) {{
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '7',
    }}
    it {
      should contain_class('aide')
      should contain_package('aide').with({
        'ensure' => 'latest',
        'name'   => 'aide',
      })
     # DB file
     should contain_file('/var/lib/aide/aide.db').with_owner('root')
     should contain_file('/var/lib/aide/aide.db').with_group('root')
     should contain_file('/var/lib/aide/aide.db').with_mode('0600')
    }

    describe 'should allow package to be absent' do
      let(:params) {{ :version => 'absent', :package => ['aide'], }}
      it { should contain_package('aide').with_ensure('absent') }
    end

    describe 'should allow package name to be overridden' do
      let(:params) {{ :version => 'latest', :package => ['notaide'], }}
      it { should contain_package('notaide').with_ensure('latest') }
    end

    describe 'cron' do
      it { is_expected.to contain_class('aide::cron') }
      it {
        is_expected.to contain_cron('aide').with(
          'ensure'  => 'present',
          'command' => '/usr/sbin/aide --config /etc/aide.conf --check',
          'user'    => 'root',
          'hour'    => 0,
          'minute'  => 0
        )
      }
      context 'with nocheck == true' do
        let(:params) { { nocheck: true } }
        it { is_expected.to contain_cron('aide').with_ensure('absent') }
      end
      context 'with mailto set' do
        let(:params) { { mailto: 'root@example.com' } }
        let(:node) { 'host.example.com' }
        it {
          is_expected.to contain_cron('aide').with_command(
            '/usr/sbin/aide --config /etc/aide.conf --check | /usr/bin/mailx -s \'host.example.com - AIDE Integrity Check\' root@example.com')
        }
      end
    end
  end
end
