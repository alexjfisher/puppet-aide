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

    describe '`rules` parameter' do
      let(:params) do
        {
          rules: {
            'Test rule' => {
              'name'  => 'MyRule',
              'rules' => ['p','md5']
            }
          }
        }
      end

      it { is_expected.to contain_aide__rule('Test rule').with_name('MyRule') }
      it { is_expected.to contain_aide__rule('Test rule').with_rules(['p','md5']) }
    end

    describe '`watches` parameter' do
      let(:params) do
        {
          watches: {
            'Exclude /var/log' => {
              'path' => '/var/log',
              'type' => 'exclude'
            }
          }
        }
      end

      it { is_expected.to contain_aide__watch('Exclude /var/log').with_path('/var/log') }
      it { is_expected.to contain_aide__watch('Exclude /var/log').with_type('exclude') }
    end

    describe '`use_default_rules` parameter' do
      let(:params) { { use_default_rules: true } }

      it { is_expected.to have_aide__rule_resource_count(11) }

      context 'when `rules` are also specified' do
        let(:params) do
          {
            rules: {
              'Test rule' => {
                'name'  => 'MyRule',
                'rules' => ['p','md5']
              }
            },
            use_default_rules: true
          }
        end

        it { is_expected.to have_aide__rule_resource_count(12) }
      end
    end
  end
end
