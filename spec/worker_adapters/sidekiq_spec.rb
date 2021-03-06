# frozen_string_literal: true

require 'spec_helper'
require 'rails_autoscale_agent/worker_adapters/sidekiq'
require 'rails_autoscale_agent/store'

module RailsAutoscaleAgent
  describe WorkerAdapters::Sidekiq do
    subject { described_class.instance }

    describe "#enabled?" do
      specify { expect(subject.enabled?).to be_truthy }
    end

    describe "#collect!" do
      it "collects latency for each queue" do
        store = Store.instance
        allow(Sidekiq::Queue).to receive(:all) { [
          double(name: 'low', latency: 11),
          double(name: 'high', latency: 22.222222),
        ] }

        subject.collect! store

        expect(store.measurements.size).to eq 2
        expect(store.measurements[0].value).to eq 11000
        expect(store.measurements[0].queue_name).to eq 'low'
        expect(store.measurements[1].value).to eq 22223
        expect(store.measurements[1].queue_name).to eq 'high'
      end
    end
  end
end
