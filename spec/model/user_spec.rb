require 'spec_helper'

RSpec.describe CASino::User do
  let(:user) { FactoryGirl.create :user }

  describe '#locked?' do
    it 'is true when locked_until is in the future' do
      user = FactoryGirl.create :user, locked_until: 1.hour.from_now
      expect(user).to be_locked
    end

    it 'is false when locked_until is in the past' do
      user = FactoryGirl.create :user, locked_until: 1.hour.ago
      expect(user).to_not be_locked
    end

    it 'is false when locked_until is empty' do
      user = FactoryGirl.create :user, locked_until: nil
      expect(user).to_not be_locked
    end
  end

  describe '#max_failed_logins_reached?' do
    let(:max_failed_attempts) { 2 }

    subject { user.max_failed_logins_reached?(max_failed_attempts) }

    context 'when the user has no login attempts' do
      it { is_expected.to eq false }
    end

    context 'when the user has only successful logins' do
      it { is_expected.to eq false }
    end

    context 'when the maximum of attempts is reached' do
      before { FactoryGirl.create_list :login_attempt, 2, successful: false, user: user }

      context 'in a row' do
        it { is_expected.to eq true }
      end

      context 'but the last attempt was successful' do
        before { FactoryGirl.create :login_attempt, successful: true, user: user }
        it { is_expected.to eq false }
      end

      context 'but a successful between' do
        before do
          FactoryGirl.create :login_attempt, successful: true, user: user
          FactoryGirl.create :login_attempt, successful: false, user: user
        end

        it { is_expected.to eq false }
      end
    end

    context 'when the user has less then the maximum failed attempts' do
      before { FactoryGirl.create :login_attempt, successful: false, user: user }
      it { is_expected.to eq false }
    end
  end
end
