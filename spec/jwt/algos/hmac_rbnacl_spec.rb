# frozen_string_literal: true

RSpec.describe '::JWT::Algos::HmacRbNaCl' do
  before do
    skip('Requires the rbnacl gem greater than 6.0') unless ::JWT.rbnacl_6_or_greater?
  end

  let(:described_class) { ::JWT::Algos::HmacRbNaCl }

  let(:data) { 'this_is_the_string_to_be_signed' }
  let(:key) { 'the secret key' }

  describe '.verify' do
    context 'when signature is generated with OpenSSL' do
      let!(:signature) { ::JWT::Algos::Hmac.sign('HS256', data, key) }
      it 'verifies the signature' do
        allow(OpenSSL::HMAC).to receive(:digest).and_call_original
        expect(described_class.verify('HS256', key, data, signature)).to eq(true)
        expect(OpenSSL::HMAC).not_to have_received(:digest)
      end
    end

    context 'when signature is generated with OpenSSL and key is very long' do
      let(:key) { 'a' * 100 }
      let!(:signature) { ::JWT::Algos::Hmac.sign('HS256', data, key) }

      it 'verifies the signature using OpenSSL features' do
        allow(OpenSSL::HMAC).to receive(:digest).and_call_original
        expect(described_class.verify('HS256', key, data, signature)).to eq(true)
        expect(OpenSSL::HMAC).not_to have_received(:digest)
      end
    end

    context 'when signature is invalid' do
      let(:key) { 'a' * 100 }
      let(:signature) { JWT::Base64.url_decode('some_random_signature') }

      it 'can verify without error' do
        allow(OpenSSL::HMAC).to receive(:digest).and_call_original
        expect(described_class.verify('HS256', key, data, signature)).to eq(false)
        expect(OpenSSL::HMAC).not_to have_received(:digest)
      end
    end
  end

  describe '.sign' do
    context 'when signature is generated by RbNaCl' do
      let!(:signature) { described_class.sign('HS256', data, key) }
      it 'can verify the signature with OpenSSL' do
        expect(::JWT::Algos::Hmac.verify('HS256', key, data, signature)).to eq(true)
      end
    end
  end
end
